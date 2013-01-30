package views.canvas.interactors.transition
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.PanGesture;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.controls.interactioncontrol.IInteractionControl;
	import sg.edu.smu.ksketch2.controls.interactors.KRotateInteractor;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;
	import sg.edu.smu.ksketch2.utils.KMathUtil;
	
	import views.canvas.components.transformWidget.TouchWidgetTemplate;
	import views.canvas.interactioncontrol.KMobileInteractionControl;
	
	public class KTouchOrientatePathInteractor extends KTouchTransitionInteractor
	{
		public static const dragRange:Number = 185;
		
		private var _dragGesture:PanGesture;
		private var _dx:Number;
		private var _dy:Number;
		private var _theta:Number;
		
		private var _previousPoint:Point;
		
		public function KTouchOrientatePathInteractor(KSketchInstance:KSketch2, interactionControl:KMobileInteractionControl, inputComponent:DisplayObject)
		{
			super(KSketchInstance, interactionControl);
			
			_dragGesture = new PanGesture(inputComponent);
			_dragGesture.maxNumTouchesRequired = 1;
		}
		
		override public function reset():void
		{
			super.reset();
			_dragGesture.removeAllEventListeners();
			
			_dx = NaN;
			_dy = NaN;
			_theta = NaN;
			
			activate();
		}
		
		override public function activate():void
		{
			super.activate();
			_dragGesture.addEventListener(GestureEvent.GESTURE_BEGAN, _interaction_begin);
		}
		
		override public function deactivate():void
		{
			super.deactivate();
			_dragGesture.removeAllEventListeners();
		}
		
		override protected function _interaction_begin(event:GestureEvent):void
		{
			super._interaction_begin(event);
			
			_dx = 0;
			_dy = 0;
			_theta = 0;
			var selectionCenter:Point = _newSelection.centerAt(_KSketch.time);
			_previousPoint = _dragGesture.location.subtract(selectionCenter);
			
			var i:int = 0;
			var length:int = _transitionObjects.length();
			var currentObject:KObject;
			
			for(i; i < length; i++)
			{
				currentObject = _transitionObjects.getObjectAt(i);
				_KSketch.transform_Begin_Translation(currentObject, _interactionControl.transitionMode, _interactionControl.currentInteraction);
				_KSketch.transform_Begin_Rotation(currentObject, _interactionControl.transitionMode,  _interactionControl.currentInteraction);
			}
			
			_dragGesture.addEventListener(GestureEvent.GESTURE_CHANGED, _update_Drag);
			_dragGesture.addEventListener(GestureEvent.GESTURE_ENDED, _interaction_end);			
		}
		
		override protected function _interaction_end(event:GestureEvent):void
		{
			var i:int = 0;
			var length:int = _transitionObjects.length();
			var currentObject:KObject;
			
			for(i; i < length; i++)
			{
				currentObject = _transitionObjects.getObjectAt(i);
				_KSketch.transform_End_Translation(currentObject,  _interactionControl.currentInteraction);
				_KSketch.transform_End_Rotation(currentObject,  _interactionControl.currentInteraction);
			}
			
			super._interaction_end(event);
			reset();
		}
		
		private function _update_Drag(event:GestureEvent):void
		{
			var selectionCenter:Point = _newSelection.centerAt(_KSketch.time);
			var current:Point = _dragGesture.location.subtract(selectionCenter);
			var angleChange:Number = KMathUtil.angleOf(_previousPoint, current);
			
			if(angleChange > Math.PI)
				angleChange = angleChange - 6.283185307;;
			
			_theta += angleChange;
			
			var proportion:Number = dragRange/current.length;
			
			_dx += current.x - (current.x*proportion);
			_dy += current.y - (current.y*proportion);
			
			var i:int = 0;
			var length:int = _transitionObjects.length();
			var currentObject:KObject;
			
			for(i; i < length; i++)
			{
				currentObject = _transitionObjects.getObjectAt(i);
				_KSketch.transform_Update_Translation(currentObject, _dx, _dy);
				_KSketch.transform_Update_Rotation(currentObject, _theta);
			}
			
			_previousPoint = current;
		}
	}
}