/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.canvas.components.timebar
{
	import flash.events.Event;
	
	import spark.components.Group;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.KSketchStyles;
	import sg.edu.smu.ksketch2.canvas.controls.KInteractionControl;
	import sg.edu.smu.ksketch2.events.KSketchEvent;
	import sg.edu.smu.ksketch2.events.KTimeChangedEvent;
	import sg.edu.smu.ksketch2.model.data_structures.IKeyFrame;
	import sg.edu.smu.ksketch2.model.data_structures.ISpatialKeyFrame;
	import sg.edu.smu.ksketch2.model.data_structures.KModelObjectList;
	import sg.edu.smu.ksketch2.model.data_structures.KSpatialKeyFrame;
	import sg.edu.smu.ksketch2.model.objects.KGroup;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.utils.SortingFunctions;
	
	/**
	 * Tick mark control generates tick marks and handles interactions with the tick marks
	 * It is more like an extension to the time control class.
	 * YOU TECHNICALLY DO NOT INTERACT WITH THE TICK MARKS' VISUAL REPRESENATIONS.
	 * YOU WORK WITH THE TICK MARKS' DATA (ABOVE THE MODEL, ON THE INTERFACE)
	 * THEN THIS CLASS WILL DRAW THE UPDATED STUFFS ON THE SCREEN
	 * KEY FRAME DATA (those that actually matter to the model).
	 */	
	public class KSketch_TickMark_Control
	{	
		public static const GRAB_THRESHOLD:Number = 10;
		public var moveLeft:Boolean = false;
		
		private var _KSketch:KSketch2;
		private var _timeControl:KSketch_TimeControl;
		private var _interactionControl:KInteractionControl;
		
		public var _ticks:Vector.<KSketch_TickMark>;
		private var _before:Vector.<KSketch_TickMark>;
		private var _after:Vector.<KSketch_TickMark>;
		
		private var _grabbedTick:KSketch_TickMark;
		
		private var _startX:Number;
		private var _changeX:Number;
		private var _pixelPerFrame:Number;
		
		/**
		 * A helper class containing the codes for generating and moving tick marks
		 * Should Probably read the comments within the codes
		 */
		public function KSketch_TickMark_Control(KSketchInstance:KSketch2, timeControl:KSketch_TimeControl, interactionControl:KInteractionControl)
		{
			_KSketch = KSketchInstance;
			_timeControl = timeControl;
			_interactionControl = interactionControl;
			
			_KSketch.addEventListener(KSketchEvent.EVENT_MODEL_UPDATED, _updateTicks);
			_interactionControl.addEventListener(KInteractionControl.EVENT_UNDO_REDO, _updateTicks);
			_interactionControl.addEventListener(KSketchEvent.EVENT_SELECTION_SET_CHANGED, _updateTicks);
			_interactionControl.addEventListener(KInteractionControl.EVENT_INTERACTION_END, _updateTicks);
			_timeControl.addEventListener(KTimeChangedEvent.EVENT_MAX_TIME_CHANGED, _recalibrateTicksAgainstMaxTime);
		}
		
		/**
		 * GrabbedTick is the immediate tickmark that is within touch range when interacting with the time control
		 * If a tick mark has been grabbed, all time control interactions should be routed to the tick mark control
		 */
		public function get grabbedTick():KSketch_TickMark
		{
			return _grabbedTick;
		}
		
		/**
		 * Update tickmarks should be invoked when
		 * The selection set is modified
		 * 	-	Object composition of the selection set changed, 
		 * 		not including changes the the composition of the selection because of visibility within selection
		 *	-	Objects are modified by transitions (which changed the timing of the key frames)
		 *  -	The time control's maximum time changed (Position of the tick marks will be affected by the change)
		 *  -	Goodness, I need to fill up this list...
		 */
		private function _updateTicks(event:Event = null):void
		{
			var allObjects:KModelObjectList = _KSketch.root.getAllChildren();
			_timeControl.timings = new Vector.<Number>();
			_ticks = new Vector.<KSketch_TickMark>();
			
			//Gather the keys from objects and generate chains of markers from the keys
			var i:int;
			var j:int;
			var length:int = allObjects.length();
			
			var currentObject:KObject;
			var transformKeyHeaders:Vector.<IKeyFrame>;
			
			var isSelected:Boolean;
			var selectedGroup:KGroup;
			for(i = 0; i<length; i++)
			{
				currentObject = allObjects.getObjectAt(i);
				isSelected = currentObject.selected;
				transformKeyHeaders = currentObject.transformInterface.getAllKeyFrames();
				
				//Generate markers for each set of transform keys
				for(j = 0; j < transformKeyHeaders.length; j++)
				{
					if(currentObject.selected)
					{
						if(_interactionControl.selection)
						{
							if(_interactionControl.selection.objects.getObjectAt(0) is KGroup)
							{
								selectedGroup = _interactionControl.selection.objects.getObjectAt(0) as KGroup;
								if(currentObject.parent.id == selectedGroup.id)
									if(currentObject is KObject)
										isSelected = false;
							}
						}		
					}
					
					_generateTicks(transformKeyHeaders[j], currentObject.id, isSelected);
				}	
				
				//visibility keys
				_generateTicks(currentObject.visibilityControl.visibilityKeyHeader, currentObject.id, isSelected);
			}
			
			_ticks.sort(SortingFunctions._compare_x_property);
			_drawTicks();
			
			//Set timings for time control's jumping function
			_timeControl.timings.sort(SortingFunctions._sortInt);	
			
			//calibrate time on timebar with ticks
			_update_object_model();
		}
		
		/**
		 * Creates a chain of doubly linked markers
		 * Pushes the set of newly created markers into _markers
		 */
		private function _generateTicks(headerKey:IKeyFrame, ownerID:int, objectSelected:Boolean):void
		{
			//Make marker objects
			//As compared to desktop version, these markers will not be displayed on the screen literally
			//Draw ticks will take these markers and draw representations on the screen.
			//They will be redrawn whenever their positions are changed.
			//Done for the sake of saving memory (Just trying, not sure if drawing lines are effective or not)
			var currentKey:IKeyFrame = headerKey;
			var newTick:KSketch_TickMark;
			var prev:KSketch_TickMark;
			
			while(currentKey)
			{
				newTick = new KSketch_TickMark();
				newTick.init(currentKey, _timeControl.timeToX(currentKey.time), ownerID);
				newTick.selected = objectSelected;
				_ticks.push(newTick);
				_timeControl.timings.push(newTick.time);
				
				if(prev)
				{
					newTick.prev = prev;
					prev.next = newTick;
				}
				
				prev = newTick;
				
				currentKey = currentKey.next;
			}
		}
		
		//Recompute the xPositions of all available time ticks against the time control's maximum time
		//Only updates the available time ticks' position
		//Does not create new time ticks.
		private function _recalibrateTicksAgainstMaxTime(event:Event = null):void
		{
			if(!_ticks || _ticks.length == 0)
				return;
			
			var i:int = 0;
			var length:int = _ticks.length;
			var currentTick:KSketch_TickMark;
			
			for(i; i<length; i++)
			{
				currentTick = _ticks[i];
				currentTick.x = _timeControl.timeToX(currentTick.time);
			}
			
			_drawTicks();
		}
		
		/**
		 * Draws the visual representation of markers and activities on the time control
		 */
		private function _drawTicks():void
		{
			if(!_ticks)
				return;
			
			//Before we start anything, we should nuke the displays first
			_timeControl.selectedTickMarkDisplay.graphics.clear();
			_timeControl.unselectedTickMarkDisplay.graphics.clear();
			_timeControl.activityDisplay.graphics.clear();
			
			var i:int;
			var drawTarget:Group;
			var currentMarker:KSketch_TickMark;
			
			//Sort the tick marks from smallest x to biggest x
			//Start drawing from the smallest X
			//Avoid drawing on the same X again
			//Increment smallest X after draw
			//This should cut down on redrawing on the same locations -> less processing
			//Doing two passes for selected and unselected stuffs
			//Algo can be improved
			
			var currentX:Number = Number.NEGATIVE_INFINITY;
			
			//Draw condition
			//Rigth now it is drawing if and only if there is only 1 object selected
			if(_interactionControl.selection && _interactionControl.selection.objects.length() == 1)
			{
				_timeControl.unselectedTickMarkDisplay.graphics.lineStyle(KSketchStyles.TIME_TICK_THICKNESS, KSketchStyles.ACTIVITY_OTHER_COLOR);
				
				drawTarget = _timeControl.activityDisplay;
				
				for(i = 0; i<_ticks.length; i++)
				{
					currentMarker = _ticks[i];
					
					if(!currentMarker.selected)
						continue;
					
					//Draw the selected stuffs first
					if(currentX <= currentMarker.x)
					{
						currentX = currentMarker.x;
						
						if(currentX < 0)
							continue;
						
						var firstFrame:KSpatialKeyFrame =  _interactionControl.selection.objects.getObjectAt(0).transformInterface.getActiveKey(currentMarker.key.time) as KSpatialKeyFrame;	
						
						if(firstFrame)
						{
							if(firstFrame.passthrough)
								_timeControl.selectedTickMarkDisplay.graphics.lineStyle(KSketchStyles.TIME_TICK_THICKNESS_A, KSketchStyles.TIME_TICK_CONTROLPOINT);
							else
								_timeControl.selectedTickMarkDisplay.graphics.lineStyle(KSketchStyles.TIME_TICK_THICKNESS_B, KSketchStyles.TIME_TICK_KEYFRAME);
						}
						else
							_timeControl.selectedTickMarkDisplay.graphics.lineStyle(KSketchStyles.TIME_TICK_THICKNESS_A, KSketchStyles.TIME_TICK_CONTROLPOINT);
						
						if(drawTarget.x <= currentX)
						{
							_timeControl.selectedTickMarkDisplay.graphics.moveTo( currentX, 0);
							_timeControl.selectedTickMarkDisplay.graphics.lineTo( currentX, drawTarget.height);
							
							//Activity bars
							if(currentMarker.prev)
							{
								if(currentMarker.key is ISpatialKeyFrame)
								{
									if((currentMarker.key as ISpatialKeyFrame).hasActivityAtTime())
									{
										drawTarget.graphics.beginFill(KSketchStyles.ACTIVITY_COLOR, 0.6);
										drawTarget.graphics.drawRect(currentMarker.prev.x, 0, currentMarker.x - currentMarker.prev.x, drawTarget.height);	
										drawTarget.graphics.endFill();	
									}
								}
							}
						}
					}
				}
			}
			else
			{
				_timeControl.unselectedTickMarkDisplay.alpha = KSketchStyles.TIME_TICK_SELECTED_ALPHA;
				_timeControl.unselectedTickMarkDisplay.graphics.lineStyle(KSketchStyles.TIME_TICK_THICKNESS_A, KSketchStyles.ACTIVITY_OTHER_COLOR);
			}
			
			//Draw unselected markers
			currentX = Number.NEGATIVE_INFINITY;
			drawTarget = _timeControl.unselectedTickMarkDisplay;
			for(i = 0; i<_ticks.length; i++)
			{
				currentMarker = _ticks[i];
				
				if(_interactionControl.selection && _interactionControl.selection.objects.length() > 1)
				{
					currentMarker.selected = false;
				}
				
				if(!currentMarker.selected)
				{
					currentX = currentMarker.x;
					
					if(currentX < 0 || _timeControl.backgroundFill.width < currentX)
						continue;
					
					if(drawTarget.x <= currentX)
					{
						drawTarget.graphics.moveTo(currentX, 0);
						drawTarget.graphics.lineTo(currentX, drawTarget.height);
					}
				}
			}
		}
		
		/**
		 * Grab tick "tries to grab a tick" on the time tick control
		 */
		public function grabTick(locationX:Number):void
		{
			var i:int;
			var length:int = _ticks.length;
			var currentTick:KSketch_TickMark;
			
			_startX = locationX;
			
			for(i = 0; i < length; i++)
			{
				currentTick = _ticks[i];
				
				if(_interactionControl.selection)
					if(!currentTick.selected)
						continue;
				
				if(locationX == currentTick.x)
				{
					_grabbedTick = currentTick;
					break;
				}
			}
			
			//Stop process if there are no grabbed ticks
			if(!_grabbedTick)
				return;
			
			//Separate ticks into before/after sets
			//Ticks exactly on the spot are classified as before
			_before = new Vector.<KSketch_TickMark>();
			_after = new Vector.<KSketch_TickMark>();
			
			for(i = 0; i < length; i++)
			{
				currentTick = _ticks[i];
				currentTick.originalPosition = currentTick.x;
				
				if(currentTick.x <= locationX)
				{
					if(_grabbedTick.selected == currentTick.selected)
						_before.push(currentTick);
				}
				
				//After ticks are a bit special
				//Only add in the first degree ticks
				//because a tick will be pushed by the marker before itself
				if(currentTick.x >= locationX)
				{
					if(_grabbedTick.selected == currentTick.selected)
					{
						if(!currentTick.prev )
							_after.push(currentTick);
						else if(currentTick.prev.x < locationX)
							_after.push(currentTick)
					}
				}
			}
			
			_pixelPerFrame = _timeControl.pixelPerFrame;
		}
		
		/**
		 * Update function. Moves the grabbed marker to a rounded value
		 * near locationX. Rounded value is a frame boundary
		 */
		public function move_markers(locationX:Number):void
		{
			if(!_interactionControl.currentInteraction)
				_interactionControl.begin_interaction_operation();
			
			//On Pan compute how much finger moved (_changeX)
			var currentX:Number = locationX;
			var changeX:Number = currentX - _startX;
			changeX = (changeX/_pixelPerFrame)*_pixelPerFrame;
			
			//If _changeX -ve use before
			//If _changeX +ve use after
			//If SumOffsetX crosses a marker, it pushes it along the best it could (subject to key frame linking rules)
			var i:int = 0;
			var length:int;
			var tick:KSketch_TickMark;
			var tickChangeX:Number;
			
			//Moving towards the left causes stacking
			if(changeX <= 0)
			{
				moveLeft = true;
				length = _before.length;
				
				for(i = 0; i < length; i++)
				{
					tick = _before[i];	
					tickChangeX = ((currentX - tick.originalPosition)/_pixelPerFrame)*_pixelPerFrame;
					
					if(tickChangeX < 0)
						tick.moveToX(tick.originalPosition + tickChangeX, _pixelPerFrame);
					else
						tick.x = tick.originalPosition;	
				}
			}
			
			//Moving towards the right pushes future keys
			if(changeX >= 0)
			{
				length = _after.length;
				
				for(i = 0; i < length; i++)
				{
					tick = _after[i];	
					
					tickChangeX = ((currentX - tick.originalPosition)/_pixelPerFrame)*_pixelPerFrame;
					
					if(tickChangeX > 0)
						tick.moveSelfAndNext(tick.originalPosition + tickChangeX, _pixelPerFrame);
					else
						tick.moveSelfAndNext(tick.originalPosition, _pixelPerFrame);
						
				}
			}
			
			//Update marker positions
			length = _ticks.length
			var currentTick:KSketch_TickMark;
			var maxTime:Number = 0;
			for(i = 0; i < length; i++)
			{
				currentTick = _ticks[i];
				currentTick.time = _timeControl.xToTime(currentTick.x);
				if(KSketch_TimeControl.MAX_ALLOWED_TIME < currentTick.time)
				{
					currentTick.time = KSketch_TimeControl.MAX_ALLOWED_TIME;
					currentTick.x = _timeControl.timeToX(currentTick.time);
				}
				
				if(maxTime < currentTick.time)
					maxTime = currentTick.time;
			}
			
			//Redraw markers
			_drawTicks();
			_changeX = changeX;
			_update_object_model();
			
		}
		
		public function _update_object_model():void
		{
			//Update the model
			var i:int;
			var length:int = _ticks.length;
			var currentTick:KSketch_TickMark;
			var allObjects:KModelObjectList = _KSketch.root.getAllChildren();
			var maxTime:Number = 0;
			for(i = 0; i < _ticks.length; i++)
			{
				currentTick = _ticks[i];
				if(currentTick.time > maxTime)
					maxTime = currentTick.time;
				
				_KSketch.editKeyTime(allObjects.getObjectByID(currentTick.associatedObjectID),
					currentTick.key, currentTick.time,
					_interactionControl.currentInteraction);
			}
			
			//Update the time control's maximum time if needed
			//Happens when a marker has been pushed beyond the max time
			if(KSketch_TimeControl.DEFAULT_MAX_TIME < maxTime)
				_timeControl.maximum = maxTime;
			else
				_timeControl.maximum = KSketch_TimeControl.DEFAULT_MAX_TIME;
		}
		
		/**
		 * Makes changes to the model
		 * Right now it is very brute force, all key frames
		 * refered in existing markers are being updated regardless of them being
		 * changed or not.
		 */
		public function end_move_markers():void
		{
			if(_interactionControl.currentInteraction)
			{
				if(_interactionControl.currentInteraction.length > 0)
					_KSketch.dispatchEvent(new KSketchEvent(KSketchEvent.EVENT_MODEL_UPDATED, _KSketch.root));
				
				_interactionControl.end_interaction_operation();
			}
			else
				_interactionControl.cancel_interaction_operation();
			
			_grabbedTick = null;
			moveLeft = false;
		}
	}
}