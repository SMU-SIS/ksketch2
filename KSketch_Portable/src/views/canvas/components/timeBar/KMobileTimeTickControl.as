package views.canvas.components.timeBar
{
	import flash.events.Event;
	import flash.geom.Point;
	
	import mx.core.UIComponent;

	import sg.edu.smu.ksketch2.KSketch2;
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
		
		private var _markers:Vector.<AbstractMarker>;
		
		/**
		 * A helper class containing the codes for generating tick marks 
		 */
		public function KMobileTimeTickControl(KSketchInstance:KSketch2, timeControl:KTouchTimeControl, interactionControl:KMobileInteractionControl)
		{
			_KSketch = KSketchInstance;
			_timeControl = timeControl;
			_timeTickContainer = timeControl.markerDisplay;
			_interactionControl = interactionControl;

			_interactionControl.addEventListener(KSketchEvent.EVENT_SELECTION_SET_CHANGED, _updateTicks);
			_interactionControl.addEventListener(KMobileInteractionControl.EVENT_INTERACTION_END, _updateTicks);
			_timeControl.addEventListener(KTimeChangedEvent.EVENT_MAX_TIME_CHANGED, _updateTicks);
		}
		
		/**
		 * Update tickmarks should be invoked when
		 * The selection set is modified
		 * 	-	Object composition of the selection set changed, 
		 * 		not including changes the the composition of the selection because of visibility within selection
		 *	-	Objects are modified by transitions (which changed the timing of the key frames)
		 *  -	The time control's maximum time changed (Position of the tick marks will be affected by the change)
		 */
/*		private function _updateTicks(event:Event):void
		{
			_timeTickContainer.graphics.clear();
			_timeTickContainer.graphics.lineStyle(2, 0xFF0000);
			
	/*		var keysHeaders:Vector.<IKeyFrame> = object.transformInterface.getAllKeyFrames();

			
			
			var timings:Vector.<int> = new Vector.<int>();
			timings.push(0);
			timings.push(_timeControl.maximum);
			
			for(var i:int = 0; i<keysHeaders.length; i++)
			{
				var currentKey:IKeyFrame = keysHeaders[i];
				
				while(currentKey)
				{
					var tickX:Number = _timeControl.timeToX(currentKey.time);
					_timeTickContainer.graphics.moveTo( tickX, -5);
					_timeTickContainer.graphics.lineTo( tickX, 25);
					timings.push(currentKey.time);
					currentKey = currentKey.next;
				}
			}

			timings.sort(SortingFunctions._sortInt);
			_timeControl.timeList = timings;*/
//		}
		
		/**
		 * Function to fill and instantiate the two marker vectors with usable markers
		 */
		private function _updateTicks(event:Event):void
		{
			var timings:Vector.<int> = new Vector.<int>();
			_markers = new Vector.<AbstractMarker>();
			var keys:Vector.<IKeyFrame> = new Vector.<IKeyFrame>();
			var allObjects:KModelObjectList = _KSketch.root.getAllChildren();
			
			var i:int;
			var j:int;
			var currentObject:KObject;
			var length:int = allObjects.length();
			var currentKey:IKeyFrame;
			var availableKeyHeaders:Vector.<IKeyFrame>;
			_timeControl.timeList = new Vector.<int>();
			
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
			
			keys.sort(SortingFunctions._compareKeyTimes);
			
			_drawTicks(keys);
			
//			_timeControl.timeList.sort(SortingFunctions._sortInt);
//			_markers.sort(SortingFunctions._compareMarkerPosition);
		}
		
		/**
		 * Places the markers on the screen
		 */
		private function _drawTicks(keys:Vector.<IKeyFrame>):void
		{
			var prevKey:IKeyFrame;
			var currentKey:IKeyFrame;
			while(0 < keys.length)
			{
				currentKey = keys.shift();
				
				var newMarker:AbstractMarker = new AbstractMarker();
				newMarker.key = currentKey;
				newMarker.associatedObject = currentKey.ownerID;
				newMarker.time = currentKey.time;
//				newMarker.activityBars = new Vector.<KMarkerActivityBar>();
				_markers.push(newMarker);
				
				prevKey = currentKey;
			}
			
			_timeTickContainer.graphics.clear();
			_timeTickContainer.graphics.lineStyle(2, 0xFF0000);
			
			var i:int;
			var currentMarker:AbstractMarker;
			var previousMarker:AbstractMarker;
			
			for(i = 0; i<_markers.length; i++)
			{
				currentMarker = _markers[i];
				currentMarker.x = _timeControl.timeToX(currentMarker.time);
				currentMarker.originalPosition = currentMarker.x;

				_timeTickContainer.graphics.moveTo( currentMarker.x, -5);
				_timeTickContainer.graphics.lineTo( currentMarker.x, 25);
				
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