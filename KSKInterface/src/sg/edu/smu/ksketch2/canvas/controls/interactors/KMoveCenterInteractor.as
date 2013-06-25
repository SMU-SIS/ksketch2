package sg.edu.smu.ksketch2.canvas.controls.interactors
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.PanGesture;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.canvas.components.timebar.KSketch_TimeControl;
	import sg.edu.smu.ksketch2.canvas.controls.IInteractionControl;
	import sg.edu.smu.ksketch2.canvas.controls.KInteractionControl;
	import sg.edu.smu.ksketch2.canvas.controls.interactors.draw.KInteractor;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.utils.KMathUtil;
	
	public class KMoveCenterInteractor extends KInteractor
	{
		private var _panGesture:PanGesture;
		
		private var _modelSpace:DisplayObject;
		private var _previousPoint:Point;
		private var _startPoint:Point;
		private var _center:Point;
		
		public function KMoveCenterInteractor(KSketchInstance:KSketch2, interactionControl:KInteractionControl,
										  inputComponent:DisplayObject, modelSpace:DisplayObject)
		{
			super(KSketchInstance, interactionControl);
			
			_modelSpace = modelSpace;
			_panGesture = new PanGesture(inputComponent);
			_panGesture.maxNumTouchesRequired = 1;
		}
		
		override public function reset():void
		{
			super.reset();
			_panGesture.removeAllEventListeners();
			
			activate();
		}
		
		override public function activate():void
		{
			super.activate();
			_panGesture.addEventListener(GestureEvent.GESTURE_BEGAN, _interaction_begin);
		}
		
		public function deactivate():void
		{
			_panGesture.removeAllEventListeners();
		}
		
		private function _interaction_begin(event:GestureEvent):void
		{
			_previousPoint = _panGesture.location;
			//_center = getGlobalCenter();
			
			
			_panGesture.addEventListener(GestureEvent.GESTURE_CHANGED, _update_Rotate);
			_panGesture.addEventListener(GestureEvent.GESTURE_ENDED, _interaction_end);			
		}
		
		private function _interaction_end(event:GestureEvent):void
		{
			var log:XML = <op/>;
			var date:Date = new Date();
			
			log.@category = "Widget";
			log.@type = "Move Center";
			log.@elapsedTime = KSketch_TimeControl.toTimeCode(date.time - _KSketch.logStartTime);
			_KSketch.log.appendChild(log);
			
			reset();
		}
		
		private function _update_Rotate(event:GestureEvent):void
		{
			var touchLocation:Point = _panGesture.location;
			
			var angleChange:Number = KMathUtil.angleOf(_previousPoint.subtract(_center), touchLocation.subtract(_center));
			
			_previousPoint = touchLocation;
		}
	}
}