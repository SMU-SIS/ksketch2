package views.canvas.components.timeBar
{
	import mx.core.UIComponent;
	
	import sg.edu.smu.ksketch2.events.KSketchEvent;
	import sg.edu.smu.ksketch2.model.data_structures.IKeyFrame;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	
	import views.canvas.interactioncontrol.KMobileInteractionControl;

	public class KMobileTimeTickControl
	{
		private var _timeControl:KTouchTimeControl;
		private var _timeTickContainer:UIComponent;
		private var _interactionControl:KMobileInteractionControl;
		
		public function KMobileTimeTickControl(timeControl:KTouchTimeControl, interactionControl:KMobileInteractionControl)
		{
			
			_timeControl = timeControl;
			_timeTickContainer = timeControl.markerDisplay;
			_interactionControl = interactionControl;

			_interactionControl.addEventListener(KSketchEvent.EVENT_SELECTION_SET_CHANGED, _updateTicks);
		}
		
		private function _updateTicks(event:KSketchEvent):void
		{
			_timeTickContainer.graphics.clear();
			
			if(!_interactionControl.selection)
				return;
			
			if(!_interactionControl.selection.objects.length() > 1)
				return;
			
			_timeTickContainer.graphics.lineStyle(2, 0xFF0000);
			
			var object:KObject = _interactionControl.selection.objects.getObjectAt(0);
			var keysHeaders:Vector.<IKeyFrame> = object.transformInterface.getAllKeyFrames();

			for(var i:int = 0; i<keysHeaders.length; i++)
			{
				var currentKey:IKeyFrame = keysHeaders[i];
				
				while(currentKey)
				{
					var tickX:Number = _timeControl.timeToX(currentKey.time);
					_timeTickContainer.graphics.moveTo( tickX, -5);
					_timeTickContainer.graphics.lineTo( tickX, 25);

					currentKey = currentKey.next;
				}
			}
		}
	}
}