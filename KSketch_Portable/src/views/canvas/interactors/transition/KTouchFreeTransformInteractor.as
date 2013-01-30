package views.canvas.interactors.transition
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.TransformGesture;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.controls.interactioncontrol.IInteractionControl;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;
	
	import views.canvas.interactioncontrol.KMobileInteractionControl;
	
	public class KTouchFreeTransformInteractor extends KTouchTransitionInteractor
	{
		private var _dx:Number;
		private var _dy:Number;
		private var _theta:Number;
		private var _scale:Number;
		
		private var _center:Point;
		private var _transformGesture:TransformGesture;
		
		public function KTouchFreeTransformInteractor(KSketchInstance:KSketch2, interactionControl:KMobileInteractionControl, inputComponent:DisplayObject)
		{
			super(KSketchInstance, interactionControl);
			_transformGesture = new TransformGesture(inputComponent);
		}
		
		override public function reset():void
		{
			super.reset();
			_transformGesture.removeAllEventListeners();
			
			activate();
		}
		
		override public function activate():void
		{
			super.activate();
			_transformGesture.addEventListener(GestureEvent.GESTURE_BEGAN, _interaction_begin);
		}
		
		override public function deactivate():void
		{
			super.deactivate();
			_transformGesture.removeAllEventListeners();
		}
		
		override protected function _interaction_begin(event:GestureEvent):void
		{
			super._interaction_begin(event);
			_center = _newSelection.centerAt(_KSketch.time);
			_dx = 0;
			_dy = 0;
			_theta = 0;
			_scale = 1;
			
			var i:int = 0;
			var length:int = _transitionObjects.length();
			var currentObject:KObject;
			
			for(i; i < length; i++)
			{
				currentObject = _transitionObjects.getObjectAt(i);

				_KSketch.transform_Begin_Translation(currentObject, _interactionControl.transitionMode, _interactionControl.currentInteraction);
				_KSketch.transform_Begin_Rotation(currentObject, _interactionControl.transitionMode, _interactionControl.currentInteraction);
				_KSketch.transform_Begin_Scale(currentObject, _interactionControl.transitionMode, _interactionControl.currentInteraction);
			}
			
			_transformGesture.addEventListener(GestureEvent.GESTURE_CHANGED, _update_Transform);
			_transformGesture.addEventListener(GestureEvent.GESTURE_ENDED, _interaction_end);			
		}
		
		override protected function _interaction_end(event:GestureEvent):void
		{
			var i:int = 0;
			var length:int = _transitionObjects.length();
			var currentObject:KObject;
			
			for(i; i < length; i++)
			{
				currentObject = _transitionObjects.getObjectAt(i);
				_KSketch.transform_End_Translation(currentObject, _interactionControl.currentInteraction);
				_KSketch.transform_End_Rotation(currentObject, _interactionControl.currentInteraction);
				_KSketch.transform_End_Scale(currentObject, _interactionControl.currentInteraction);
			}
			
			super._interaction_end(event);
			reset();
		}
		
		private function _update_Transform(event:GestureEvent):void
		{
			_dx += _transformGesture.offsetX;
			_dy += _transformGesture.offsetY;
			_theta += _transformGesture.rotation;
			_scale *= _transformGesture.scale;
			
			var i:int = 0;
			var length:int = _transitionObjects.length();
			var currentObject:KObject;
			
			for(i; i < length; i++)
			{
				currentObject = _transitionObjects.getObjectAt(i);
				_KSketch.transform_Update_Translation(currentObject, _dx, _dy);
				_KSketch.transform_Update_Rotation(currentObject, _theta);
				_KSketch.transform_Update_Scale(currentObject, _scale-1);
			}			
		}
	}
}