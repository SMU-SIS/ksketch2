package views.canvas.interactors
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.TransformGesture;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.controls.interactioncontrol.IInteractionControl;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;
	
	public class KTouchFreeTransformInteractor extends KTouchTransitionInteractor
	{
		private var _center:Point;
		private var _transformGesture:TransformGesture;
		
		public function KTouchFreeTransformInteractor(KSketchInstance:KSketch2, interactionControl:IInteractionControl, inputComponent:DisplayObject)
		{
			super(KSketchInstance, interactionControl, inputComponent);
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
			
			_center = _newSelection.centerAt(0);
			
			var i:int = 0;
			var length:int = _transitionObjects.length();
			var currentObject:KObject;
			
			for(i; i < length; i++)
			{
				currentObject = _transitionObjects.getObjectAt(i);
//				_KSketch.transform_Begin_Rotation(currentObject, KSketch2.TRANSITION_INTERPOLATED, new KCompositeOperation());
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
//				_KSketch.transform_End_Rotation(currentObject, new KCompositeOperation());
			}
			
			super._interaction_end(event);
			reset();
		}
		
		private function _update_Transform(event:GestureEvent):void
		{
			trace("Updating free transform");
			
			var i:int = 0;
			var length:int = _transitionObjects.length();
			var currentObject:KObject;
			
			for(i; i < length; i++)
			{
				currentObject = _transitionObjects.getObjectAt(i);
//				_KSketch.transform_Update_Rotation(currentObject, _theta);
			}			
		}
	}
}