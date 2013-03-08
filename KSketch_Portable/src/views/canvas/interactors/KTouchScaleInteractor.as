package views.canvas.interactors
{
	import flash.display.DisplayObject;
	
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.TransformGesture;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	
	import views.canvas.interactioncontrol.KMobileInteractionControl;
	
	public class KTouchScaleInteractor extends KTouchTransitionInteractor
	{
		private var _scaleGesture:TransformGesture;
		private var _scale:Number;
		
		public function KTouchScaleInteractor(KSketchInstance:KSketch2, interactionControl:KMobileInteractionControl,
											  inputComponent:DisplayObject, modelSpace:DisplayObject)
		{
			super(KSketchInstance, interactionControl, modelSpace);
			_scaleGesture = new TransformGesture(inputComponent);
		}
		
		override public function reset():void
		{
			super.reset();
			_scaleGesture.removeAllEventListeners();
			
			activate();
			_scale = 1;
		}
		
		override public function activate():void
		{
			super.activate();
			_scaleGesture.addEventListener(GestureEvent.GESTURE_BEGAN, _interaction_begin);
		}
		
		override public function deactivate():void
		{
			super.deactivate();
			_scaleGesture.removeAllEventListeners();
		}
		
		override protected function _interaction_begin(event:GestureEvent):void
		{
			if(_scaleGesture.touchesCount < 2)
				return;
			
			super._interaction_begin(event);
			
			_scale = 1;
			
			var i:int = 0;
			var length:int = _transitionObjects.length();
			var currentObject:KObject;
			
			for(i; i < length; i++)
				_KSketch.beginTransform(_transitionObjects.getObjectAt(i),_interactionControl.transitionMode, _interactionControl.currentInteraction);
			
			_scaleGesture.addEventListener(GestureEvent.GESTURE_CHANGED, _update_Translate);
			_scaleGesture.addEventListener(GestureEvent.GESTURE_ENDED, _interaction_end);			
		}
		
		override protected function _interaction_end(event:GestureEvent):void
		{
			var i:int = 0;
			var length:int = _transitionObjects.length();
			var currentObject:KObject;
			
			for(i; i < length; i++)
				_KSketch.endTransform(_transitionObjects.getObjectAt(i),  _interactionControl.currentInteraction);
			
			super._interaction_end(event);
			reset();
		}
		
		private function _update_Translate(event:GestureEvent):void
		{
			if(_scaleGesture.touchesCount < 2)
				return;
			
			_scale *= _scaleGesture.scale;
			
			var i:int = 0;
			var length:int = _transitionObjects.length();
			var currentObject:KObject;
			
			for(i; i < length; i++)
				_KSketch.updateTransform(_transitionObjects.getObjectAt(i), 0, 0, 0, _scale-1);
		}
	}
}