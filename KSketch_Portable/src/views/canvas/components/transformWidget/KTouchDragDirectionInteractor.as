package views.canvas.components.transformWidget
{
	import flash.display.DisplayObject;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.PanGesture;
	import org.gestouch.gestures.TapGesture;
	import org.gestouch.gestures.TransformGesture;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.controls.interactioncontrol.IInteractionControl;
	import sg.edu.smu.ksketch2.controls.interactors.KRotateInteractor;
	import sg.edu.smu.ksketch2.utils.KMathUtil;
	
	import views.canvas.interactors.KTouchTransitionInteractor;
	import views.canvas.interactors.KTransitionDelegator;
	
	public class KTouchDragDirectionInteractor extends KTouchTransitionInteractor
	{
		private var _delegator:KTransitionDelegator;
		private var _directionArrow:DisplayObject;
		private var _widget:TouchWidgetTemplate;
		
		private var _activationGesture:TapGesture;
		private var _deactivationGesture:TapGesture;
		
		private var _center:Point;
		private var _previousPoint:Point;
		
		public function KTouchDragDirectionInteractor(KSketchInstance:KSketch2, interactionControl:IInteractionControl, delegator:KTransitionDelegator,
													  inputComponent:DisplayObject, widget:TouchWidgetTemplate)
		{
			super(KSketchInstance, interactionControl);
			
			_activationGesture = new TapGesture(inputComponent);
			_activationGesture.numTapsRequired = 2;
			
			_deactivationGesture = new TapGesture(widget.parent);
			_deactivationGesture.numTapsRequired = 1;
			
			_delegator = delegator;
			_directionArrow = inputComponent;
			_widget = widget;
		}
		
		override public function activate():void
		{
			super.activate();
			_activationGesture.addEventListener(GestureEvent.GESTURE_RECOGNIZED, _enterEditState);
		}
		
		override public function deactivate():void
		{
			super.deactivate();

			reset();
			_activationGesture.removeAllEventListeners();
		}
		
		override public function reset():void
		{
			_delegator.exitChangeDirectionMode();
			_deactivationGesture.removeAllEventListeners();
			_directionArrow.stage.removeEventListener(TouchEvent.TOUCH_BEGIN, _touch_update);
			_directionArrow.stage.removeEventListener(TouchEvent.TOUCH_END, _touch_end);
			activate();
		}
		
		private function _enterEditState(event:GestureEvent):void
		{
			_delegator.enterChangeDirectionMode();
			_activationGesture.removeAllEventListeners();
			_deactivationGesture.addEventListener(GestureEvent.GESTURE_RECOGNIZED, _exitEditState);
		}
		
		private function _exitEditState(event:GestureEvent):void
		{
			reset();
		}
		
		private function _touch_begin(event:TouchEvent):void
		{
			_previousPoint = new Point(event.stageX, event.stageY);
			_center = _widget.localToGlobal(new Point());
			
			_directionArrow.stage.addEventListener(TouchEvent.TOUCH_BEGIN, _touch_update);
			_directionArrow.stage.addEventListener(TouchEvent.TOUCH_END, _touch_end);			
		}
		
		private function _touch_update(event:TouchEvent):void
		{
			var touchLocation:Point = new Point(event.stageX, event.stageY);

			var angleChange:Number = KMathUtil.angleOf(_previousPoint.subtract(_center), touchLocation.subtract(_center));

			if(angleChange > Math.PI)
				angleChange = angleChange - KRotateInteractor.PIx2;
			
			//_directionArrow.rotation += angleChange/Math.PI * 180;
			_previousPoint = touchLocation;
		}
		
		private function _touch_end(event:TouchEvent):void
		{
			reset();
		}
	}
}