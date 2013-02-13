package views.canvas.components.timeBar
{
	import flash.events.Event;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.controls.interactioncontrol.KInteractionControl;
	import sg.edu.smu.ksketch2.controls.widgets.KTimeControl;
	import sg.edu.smu.ksketch2.events.KSketchEvent;
	import sg.edu.smu.ksketch2.events.KTimeChangedEvent;
	import sg.edu.smu.ksketch2.model.data_structures.IKeyFrame;
	import sg.edu.smu.ksketch2.model.data_structures.KModelObjectList;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.utils.SortingFunctions;
	
	import views.canvas.interactioncontrol.KMobileInteractionControl;

	public class KTouchTimeTickControl
	{
		private var _KSketch:KSketch2;
		private var _timeControl:KTouchTimeControl;
		private var _timeTickContainer:UIComponent;
		private var _interactionControl:KMobileInteractionControl;
		
		private var _ticks:Vector.<KTouchTickMark>;
		private var _before:Vector.<KTouchTickMark>;
		private var _after:Vector.<KTouchTickMark>;
		
		private var _startX:Number;
		
		/**
		 * A helper class containing the codes for generating tick marks 
		 */
		public function KTouchTimeTickControl(KSketchInstance:KSketch2, timeControl:KTouchTimeControl, interactionControl:KMobileInteractionControl)
		{
			_KSketch = KSketchInstance;
			_timeControl = timeControl;
			_timeTickContainer = timeControl.markerDisplay;
			_interactionControl = interactionControl;
			
			_KSketch.addEventListener(KSketchEvent.EVENT_MODEL_UPDATED, _updateTicks);
			_interactionControl.addEventListener(KInteractionControl.EVENT_UNDO_REDO, _updateTicks);
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
			_timeControl.timeList = new Vector.<int>();
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
					_generateTicks(transformKeyHeaders[j]);
					
				//Generate markers for visibility key
				_generateTicks(currentObject.visibilityControl.visibilityKeyHeader);
			}
			
			_ticks.sort(SortingFunctions._compare_x_property);
			_drawTicks();

			//Set timings for time control's jumping function
			_timeControl.timeList.unshift(0);
			_timeControl.timeList.push(_timeControl.maximum);
			_timeControl.timeList.sort(SortingFunctions._sortInt);			
		}
		
		/**
		 * Creates a chain of doubly linked markers
		 * Pushes the set of newly created markers into _markers
		 */
		private function _generateTicks(headerKey:IKeyFrame):void
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
				newTick.init(currentKey, _timeControl.timeToX(currentKey.time));
				_ticks.push(newTick);
				_timeControl.timeList.push(newTick.time);
				
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
			
			//Need to make sure tick.x and tick.time are in sync
			
			
			var timings:Vector.<int> = new Vector.<int>();

			_timeTickContainer.graphics.clear();
			_timeTickContainer.graphics.lineStyle(2, 0xFF0000);
			
			var maxTime:int = _timeControl.maximum;
			var i:int;
			var currentMarker:KTouchTickMark;
			var currentX:Number = Number.NEGATIVE_INFINITY;
			
			for(i = 0; i<_ticks.length; i++)
			{
				currentMarker = _ticks[i];
				
				if(currentX < currentMarker.x)
				{
					currentX = currentMarker.x;
					
					if(currentX < 0 || _timeControl.backgroundFill.width < currentX)
						continue;
					
					if(_timeTickContainer.x <= currentX)
					{
						_timeTickContainer.graphics.moveTo( currentX, -5);
						_timeTickContainer.graphics.lineTo( currentX, 25);
					}
				}
			}
			

		}
		
		public function pan_begin(location:Point):void
		{
			//Panning begins
			//Split markers into two sets before/after
			_startX = _timeControl.contentGroup.globalToLocal(location).x;

			var i:int;
			var length:int = _ticks.length;
			var currentTick:KTouchTickMark;
			
			_before = new Vector.<KTouchTickMark>();
			_after = new Vector.<KTouchTickMark>();
			
			for(i = 0; i < length; i++)
			{
				currentTick = _ticks[i];
				currentTick.originalPosition = currentTick.x;
				if(currentTick.x <= _startX)
					_before.push(currentTick);

				//After ticks are a bit special
				//Only add in the first degree ticks
				if(currentTick.x >= _startX)
				{
					if(!currentTick.prev )
						_after.push(currentTick);
					else if(currentTick.prev.x < _startX)
						_after.push(currentTick)
				}
			}
		}
		
		public function pan_update(location:Point):void
		{
			//On Pan compute how much finger moved (_changeX)
			var currentX:Number = _timeControl.contentGroup.globalToLocal(location).x
			var changeX:Number = currentX - _startX;
			var pixelPerFrame:Number = _timeControl.pixelPerFrame;			
			
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
					tickChangeX = Math.floor((currentX - tick.originalPosition)/pixelPerFrame)*pixelPerFrame;

					if(tickChangeX < 0)
						tick.moveToX(tick.originalPosition + tickChangeX, pixelPerFrame);
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
					tickChangeX = Math.floor((currentX - tick.originalPosition)/pixelPerFrame)*pixelPerFrame;
					
					if(tickChangeX > 0)
						tick.moveSelfAndNext(tick.originalPosition + tickChangeX, pixelPerFrame);
					else
						tick.moveSelfAndNext(tick.originalPosition, pixelPerFrame);
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
			
			if(maxTime < KTimeControl.DEFAULT_MAX_TIME)
				maxTime = KTimeControl.DEFAULT_MAX_TIME;
			else if(KTouchTimeControl.MAX_ALLOWED_TIME < maxTime)
				maxTime = KTouchTimeControl.MAX_ALLOWED_TIME;
			
			if(_timeControl.time < maxTime)
				_timeControl.maximum = maxTime;
			else
				_timeControl.maximum = _timeControl.time;
				

		}
		
		public function pan_end(location:Point):void
		{

//			_interactionControl.end_interaction_operation
		}
	}
}