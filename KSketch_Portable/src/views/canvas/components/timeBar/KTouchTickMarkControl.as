package views.canvas.components.timeBar
{
	import flash.events.Event;
	import flash.geom.Point;
	import flash.system.Capabilities;
	
	import spark.components.Group;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.controls.interactioncontrol.KInteractionControl;
	import sg.edu.smu.ksketch2.controls.widgets.KTimeControl;
	import sg.edu.smu.ksketch2.events.KSketchEvent;
	import sg.edu.smu.ksketch2.events.KTimeChangedEvent;
	import sg.edu.smu.ksketch2.model.data_structures.IKeyFrame;
	import sg.edu.smu.ksketch2.model.data_structures.ISpatialKeyFrame;
	import sg.edu.smu.ksketch2.model.data_structures.KModelObjectList;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.utils.SortingFunctions;
	
	import views.canvas.interactioncontrol.KMobileInteractionControl;

	public class KTouchTickMarkControl
	{
		private const _UNSELECTED_TICK_MARK_COLOR:uint = 0xCBCBCB;
		private const _SELECTED_TICK_MARK_COLOR:uint = 0x777777;
		
		private const _D_ACTIVITY_COLOR:uint = 0x58ACFA;
		private const _D_TICK_MARK_THICKNESS:Number = 3;
		
		private const _I_ACTIVITY_COLOR:uint = 0xE2EFFB;
		private const _I_TICK_MARK_THICKNESS:Number = 6;
		
		private var _KSketch:KSketch2;
		private var _timeControl:KTouchTimeControl;
		private var _interactionControl:KMobileInteractionControl;
		
		private var _ticks:Vector.<KTouchTickMark>;
		private var _before:Vector.<KTouchTickMark>;
		private var _after:Vector.<KTouchTickMark>;

		private var _startX:Number;
		private var _changeX:Number;
		private var _pixelPerFrame:Number;
		private var _thresholdPixelPerFrame:Number;
		private var _grabThreshold:Number = Capabilities.screenDPI/7;

		public var grabbedTick:KTouchTickMark;
		
		
		/**
		 * A helper class containing the codes for generating and moving tick marks
		 */
		public function KTouchTickMarkControl(KSketchInstance:KSketch2, timeControl:KTouchTimeControl, interactionControl:KMobileInteractionControl)
		{
			_KSketch = KSketchInstance;
			_timeControl = timeControl;
			_interactionControl = interactionControl;
			
			_KSketch.addEventListener(KSketchEvent.EVENT_MODEL_UPDATED, _updateTicks);
			_interactionControl.addEventListener(KInteractionControl.EVENT_UNDO_REDO, _updateTicks);
			_interactionControl.addEventListener(KSketchEvent.EVENT_SELECTION_SET_CHANGED, _updateTicks);
			_interactionControl.addEventListener(KMobileInteractionControl.EVENT_INTERACTION_END, _updateTicks);
			_timeControl.addEventListener(KTimeChangedEvent.EVENT_MAX_TIME_CHANGED, _recalibrateTicksAgainstMaxTime);
		}
		
		/**
		 * Update tickmarks should be invoked when
		 * The selection set is modified
		 * 	-	Object composition of the selection set changed, 
		 * 		not including changes the the composition of the selection because of visibility within selection
		 *	-	Objects are modified by transitions (which changed the timing of the key frames)
		 *  -	The time control's maximum time changed (Position of the tick marks will be affected by the change)
		 */
		
		/**
		 * Function to fill and instantiate the two marker vectors with usable markers
		 */
		private function _updateTicks(event:Event = null):void
		{
			var allObjects:KModelObjectList = _KSketch.root.getAllChildren();
			_timeControl.timings = new Vector.<int>();
			_ticks = new Vector.<KTouchTickMark>();
			
			//Gather the keys from objects and generate chains of markers from the keys
			var i:int;
			var j:int;
			var length:int = allObjects.length();
			
			var currentObject:KObject;
			var currentKey:IKeyFrame;
			var transformKeyHeaders:Vector.<IKeyFrame>;

			for(i = 0; i<length; i++)
			{
				currentObject = allObjects.getObjectAt(i);
				transformKeyHeaders = currentObject.transformInterface.getAllKeyFrames();
				
				//Generate markers for transform keys
				for(j = 0; j < transformKeyHeaders.length; j++)
					_generateTicks(transformKeyHeaders[j], currentObject.id, currentObject.selected);
					
				//Generate markers for visibility key
				_generateTicks(currentObject.visibilityControl.visibilityKeyHeader, currentObject.id, currentObject.selected);
			}
			
			_ticks.sort(SortingFunctions._compare_x_property);
			_drawTicks();

			//Set timings for time control's jumping function
			_timeControl.timings.sort(SortingFunctions._sortInt);			
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
			var newTick:KTouchTickMark;
			var prev:KTouchTickMark;
			
			while(currentKey)
			{
				newTick = new KTouchTickMark();
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
				var currentTick:KTouchTickMark;

				for(i; i<length; i++)
				{
					currentTick = _ticks[i];
					currentTick.x = _timeControl.timeToX(currentTick.time);
				}
				
				_drawTicks();
		}
		
		/**
		 * Draws the markers on the screen
		 */
		private function _drawTicks():void
		{
			if(!_ticks)
				return;
			
			var maxTime:int = _timeControl.maximum;
			var i:int;
			var currentMarker:KTouchTickMark;
			var currentX:Number = Number.NEGATIVE_INFINITY;
			var timings:Vector.<int> = new Vector.<int>();
			
			_timeControl.selectedTickMarkDisplay.graphics.clear();
			_timeControl.unselectedTickMarkDisplay.graphics.clear();
			_timeControl.activityDisplay.graphics.clear();
			
			var drawTarget:Group;
			
			if(_interactionControl.selection && _interactionControl.selection.objects.length() == 1)
			{
				if(KSketch2.studyMode == KSketch2.STUDY_P)
				{
					_timeControl.selectedTickMarkDisplay.graphics.lineStyle(_D_TICK_MARK_THICKNESS,_SELECTED_TICK_MARK_COLOR);
					_timeControl.unselectedTickMarkDisplay.graphics.lineStyle(_D_TICK_MARK_THICKNESS,_UNSELECTED_TICK_MARK_COLOR);
				}
				else
				{
					_timeControl.selectedTickMarkDisplay.graphics.lineStyle(_I_TICK_MARK_THICKNESS,_SELECTED_TICK_MARK_COLOR);
					_timeControl.unselectedTickMarkDisplay.graphics.lineStyle(_I_TICK_MARK_THICKNESS,_UNSELECTED_TICK_MARK_COLOR);
				}
				
				drawTarget = _timeControl.activityDisplay;

				for(i = 0; i<_ticks.length; i++)
				{
					currentMarker = _ticks[i];
					
					if(!currentMarker.selected)
						continue;
					
					if(currentX < currentMarker.x)
					{
						currentX = currentMarker.x;
						
						if(currentX < 0)
							continue;
						
						if(drawTarget.x <= currentX)
						{
							_timeControl.selectedTickMarkDisplay.graphics.moveTo( currentX, 0);
							_timeControl.selectedTickMarkDisplay.graphics.lineTo( currentX, drawTarget.height);
							
							if(currentMarker.prev)
							{
								if(currentMarker.key is ISpatialKeyFrame)
								{
									if((currentMarker.key as ISpatialKeyFrame).hasActivityAtTime())
									{
										if(KSketch2.studyMode == KSketch2.STUDY_P)
											drawTarget.graphics.beginFill(_D_ACTIVITY_COLOR);
										else
											drawTarget.graphics.beginFill(_I_ACTIVITY_COLOR);
										
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
				if(KSketch2.studyMode == KSketch2.STUDY_P)
					_timeControl.unselectedTickMarkDisplay.graphics.lineStyle(_D_TICK_MARK_THICKNESS,_SELECTED_TICK_MARK_COLOR);
				else
					_timeControl.unselectedTickMarkDisplay.graphics.lineStyle(_I_TICK_MARK_THICKNESS,_SELECTED_TICK_MARK_COLOR);
			}
			
			//Brute force occurring here. JT was just too lazy to make a better algorithm!
			//First pass to draw unselected tick marks
			currentX = Number.NEGATIVE_INFINITY;
			drawTarget = _timeControl.unselectedTickMarkDisplay;
			for(i = 0; i<_ticks.length; i++)
			{
				currentMarker = _ticks[i];
				
				if(currentX < currentMarker.x)
				{
					currentX = currentMarker.x;
					
					if(currentX < 0 || _timeControl.backgroundFill.width < currentX)
						continue;
					
					if(drawTarget.x <= currentX)
					{
						drawTarget.graphics.moveTo( currentX, 0);
						drawTarget.graphics.lineTo( currentX, drawTarget.height);
					}
				}
			}
		}
		
		public function grabTick(locationX:Number):void
		{
			//Panning begins
			//Split markers into two sets before/after
			_startX = locationX;
			
			var i:int;
			var length:int = _ticks.length;
			var currentTick:KTouchTickMark;
			
			_before = new Vector.<KTouchTickMark>();
			_after = new Vector.<KTouchTickMark>();
			
			//Snap the start x to the closest tick
			var dx:Number;
			var smallestdx:Number = Number.POSITIVE_INFINITY;
			
			for(i = 0; i < length; i++)
			{
				currentTick = _ticks[i];
				
				if(_interactionControl.selection)
					if(!currentTick.selected)
						continue;

				dx = Math.abs(currentTick.x - _startX);
				
				if(dx > _grabThreshold)
					continue;
				
				if(dx < smallestdx)
				{
					smallestdx = dx;
					_startX = currentTick.x;
					grabbedTick = currentTick;
				}
			}
			
			if(!grabbedTick)
				return;
			
			for(i = 0; i < length; i++)
			{
				currentTick = _ticks[i];
				currentTick.originalPosition = currentTick.x;
				
				if(currentTick.x <= _startX)
					_before.push(currentTick);
				
				//After ticks are a bit special
				//Only add in the first degree ticks
				//because a tick will be pushed by the marker before itself
				if(currentTick.x >= _startX)
				{
					if(!currentTick.prev )
						_after.push(currentTick);
					else if(currentTick.prev.x < _startX)
						_after.push(currentTick)
				}
			}
			
			_pixelPerFrame = _timeControl.pixelPerFrame;
			_thresholdPixelPerFrame = 1.5*_pixelPerFrame;
		}
		
		public function move_markers(locationX:Number):void
		{
			if(!_interactionControl.currentInteraction)
				_interactionControl.begin_interaction_operation();
			
			//On Pan compute how much finger moved (_changeX)
			var currentX:Number = locationX;
			var changeX:Number = currentX - _startX;
			changeX = Math.floor(changeX/_pixelPerFrame)*_pixelPerFrame;
			
			//If _changeX -ve use before
			//If _changeX +ve use after
			//If SumOffsetX crosses a marker, it pushes it along the best it could (subject to key frame linking rules)
			var i:int = 0;
			var length:int;
			var tick:KTouchTickMark;
			var tickChangeX:Number;
			
			if(changeX <= 0)
			{
				length = _before.length;
				
				for(i = 0; i < length; i++)
				{
					tick = _before[i];	
					tickChangeX = Math.floor((currentX - tick.originalPosition)/_pixelPerFrame)*_pixelPerFrame;

					if(tickChangeX < 0)
						tick.moveToX(tick.originalPosition + tickChangeX, _pixelPerFrame);
					else
						tick.x = tick.originalPosition;
				}
			}

			if(changeX >= 0)
			{
				length = _after.length;
				
				for(i = 0; i < length; i++)
				{
					tick = _after[i];	
					tickChangeX = Math.floor((currentX - tick.originalPosition)/_pixelPerFrame)*_pixelPerFrame;
					
					if(tickChangeX > 0)
						tick.moveSelfAndNext(tick.originalPosition + tickChangeX, _pixelPerFrame);
					else
						tick.moveSelfAndNext(tick.originalPosition, _pixelPerFrame);
				}
			}
			
			//Update marker positions once changed
			//Redraw markers
			length = _ticks.length
			var currentTick:KTouchTickMark;
			var maxTime:int = 0;
			for(i = 0; i < length; i++)
			{
				currentTick = _ticks[i];
				currentTick.time = _timeControl.xToTime(currentTick.x);
				
				if(KTouchTimeControl.MAX_ALLOWED_TIME < currentTick.time)
				{
					currentTick.time = KTouchTimeControl.MAX_ALLOWED_TIME;
					currentTick.x = _timeControl.timeToX(currentTick.time);
				}

				if(maxTime < currentTick.time)
					maxTime = currentTick.time;
			}

			_drawTicks();
			_changeX = changeX;
		}
		
		public function end_move_markers():void
		{
			var i:int;
			var length:int = _ticks.length;
			var currentTick:KTouchTickMark;
			var allObjects:KModelObjectList = _KSketch.root.getAllChildren();
			var maxTime:int = 0;
			for(i = 0; i < _ticks.length; i++)
			{
				currentTick = _ticks[i];
				if(currentTick.time > maxTime)
					maxTime = currentTick.time;
				_KSketch.editKeyTime(allObjects.getObjectByID(currentTick.associatedObjectID),
																currentTick.key, currentTick.time,
																_interactionControl.currentInteraction);
			}
			
			if(KTimeControl.DEFAULT_MAX_TIME < maxTime)
				_timeControl.maximum = maxTime;
			else
				_timeControl.maximum = KTimeControl.DEFAULT_MAX_TIME;
			
			if(_interactionControl.currentInteraction)
			{
				if(_interactionControl.currentInteraction.length > 0)
					_KSketch.dispatchEvent(new KSketchEvent(KSketchEvent.EVENT_MODEL_UPDATED, _KSketch.root));
				
				_interactionControl.end_interaction_operation();
				
				var log:XML = <op/>;
				var date:Date = new Date();
				
				log.@category = "Tickmark";
				log.@type = "Move Tickmark";
				log.@moveFrom = KTouchTimeControl.toTimeCode(_timeControl.xToTime(_startX));
				log.@moveTo = KTouchTimeControl.toTimeCode(_timeControl.xToTime(_startX+_changeX));
				log.@elapsedTime = KTouchTimeControl.toTimeCode(date.time - _KSketch.logStartTime);
				_KSketch.log.appendChild(log);
			}
			else
				_interactionControl.cancel_interaction_operation();
		}
	}
}