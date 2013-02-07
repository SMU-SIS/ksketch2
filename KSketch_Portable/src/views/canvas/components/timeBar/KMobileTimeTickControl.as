package views.canvas.components.timeBar
{
	import flash.events.Event;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.controls.interactioncontrol.KInteractionControl;
	import sg.edu.smu.ksketch2.events.KSketchEvent;
	import sg.edu.smu.ksketch2.events.KTimeChangedEvent;
	import sg.edu.smu.ksketch2.model.data_structures.IKeyFrame;
	import sg.edu.smu.ksketch2.model.data_structures.KModelObjectList;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.utils.SortingFunctions;
	
	import views.canvas.interactioncontrol.KMobileInteractionControl;

	public class KMobileTimeTickControl
	{
		private var _KSketch:KSketch2;
		private var _timeControl:KTouchTimeControl;
		private var _timeTickContainer:UIComponent;
		private var _interactionControl:KMobileInteractionControl;
		
		private var _markers:Vector.<KTouchTickMark>;
		
		/**
		 * A helper class containing the codes for generating tick marks 
		 */
		public function KMobileTimeTickControl(KSketchInstance:KSketch2, timeControl:KTouchTimeControl, interactionControl:KMobileInteractionControl)
		{
			_KSketch = KSketchInstance;
			_timeControl = timeControl;
			_timeTickContainer = timeControl.markerDisplay;
			_interactionControl = interactionControl;
			
			_KSketch.addEventListener(KSketchEvent.EVENT_MODEL_UPDATED, _updateTicks);
			_interactionControl.addEventListener(KInteractionControl.EVENT_UNDO_REDO, _updateTicks);
			_interactionControl.addEventListener(KMobileInteractionControl.EVENT_INTERACTION_END, _updateTicks);
			_timeControl.addEventListener(KTimeChangedEvent.EVENT_MAX_TIME_CHANGED, _drawTicks);
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
			var keys:Vector.<IKeyFrame> = new Vector.<IKeyFrame>();
			var allObjects:KModelObjectList = _KSketch.root.getAllChildren();
			
			//This block of codes are for gathering keys
			var i:int;
			var j:int;
			var currentObject:KObject;
			var length:int = allObjects.length();
			var currentKey:IKeyFrame;
			var availableKeyHeaders:Vector.<IKeyFrame>;
			
			for(i = 0; i<length; i++)
			{
				currentObject = allObjects.getObjectAt(i);
				
				availableKeyHeaders = currentObject.transformInterface.getAllKeyFrames();
				currentKey = currentObject.visibilityControl.visibilityKeyHeader;
				
				if(currentKey)
					availableKeyHeaders.push(currentKey);
				
				for(j = 0; j < availableKeyHeaders.length; j++)
				{
					currentKey = availableKeyHeaders[j];
					while(currentKey)
					{
						currentKey.ownerID = currentObject.id;
						keys.push(currentKey);
						currentKey = currentKey.next
					}
				}
			}
			
			//Make marker objects
			//As compared to desktop version, these markers will not be displayed on the screen literally
			//Draw ticks will take these markers and draw representations on the screen.
			//They will be redrawn whenever their timings are changed.
			//Done for the sake of saving memory (Just trying, not sure if drawing lines are effective or not)
			keys.sort(SortingFunctions._compareKeyTimes);
			_markers = new Vector.<KTouchTickMark>();

			var timings:Vector.<int> = new Vector.<int>();
			var prevKey:IKeyFrame;
			while(0 < keys.length)
			{
				currentKey = keys.shift();
				
				var newMarker:KTouchTickMark = new KTouchTickMark();
				newMarker.key = currentKey;
				newMarker.associatedObject = currentKey.ownerID;
				newMarker.time = currentKey.time;
				newMarker.x = _timeControl.timeToX(newMarker.time);
				_markers.push(newMarker);
				timings.push(newMarker.time);
				prevKey = currentKey;
			}

			_markers.sort(SortingFunctions._compare_x_property);
			_drawTicks();

			timings.unshift(0);
			timings.push(_timeControl.maximum);
			timings.sort(SortingFunctions._sortInt);			

			
			_timeControl.timeList = timings;
		}
		
		/**
		 * Places the markers on the screen
		 */
		private function _drawTicks(event:Event = null):void
		{
			if(!_markers)
				return;
			
			var timings:Vector.<int> = new Vector.<int>();

			_timeTickContainer.graphics.clear();
			_timeTickContainer.graphics.lineStyle(2, 0xFF0000);
			
			var i:int;
			var currentMarker:KTouchTickMark;
			var previousMarker:KTouchTickMark;
			var currentX:Number = Number.NEGATIVE_INFINITY;

			for(i = 0; i<_markers.length; i++)
			{
				currentMarker = _markers[i];
				currentMarker.x = _timeControl.timeToX(currentMarker.time);
				currentMarker.originalPosition = currentMarker.x;
				
				if(currentX < currentMarker.x)
				{
					currentX = currentMarker.x;
					
					if(_timeTickContainer.x <= currentX)
					{
						_timeTickContainer.graphics.moveTo( currentX, -5);
						_timeTickContainer.graphics.lineTo( currentX, 25);
					}
				}

				currentMarker.prev = previousMarker;

				if(previousMarker)
					previousMarker.next = currentMarker;
				previousMarker = currentMarker;
			}
			
			for(i = 0; i < _markers.length; i++)
				_markers[i].updateAssociation();
		}
		
		public function pan_begin(location:Point):void
		{
			
		}
		
		public function pan_update(location:Point):void
		{
			
		}
		
		public function pan_end(location:Point):void
		{
			
		}
	}
}