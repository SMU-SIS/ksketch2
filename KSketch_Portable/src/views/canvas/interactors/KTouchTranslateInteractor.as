package views.canvas.interactors
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.PanGesture;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	
	import views.canvas.interactioncontrol.KMobileInteractionControl;
	
	public class KTouchTranslateInteractor extends KTouchTransitionInteractor
	{
		private var _translateGesture:PanGesture;
		
		private var _previousPoint:Point;
		private var _startPoint:Point;
		
		public function KTouchTranslateInteractor(KSketchInstance:KSketch2, interactionControl:KMobileInteractionControl,
												  inputComponent:DisplayObject, modelSpace:DisplayObject)
		{
			super(KSketchInstance, interactionControl, modelSpace);
			_translateGesture = new PanGesture(inputComponent);
			_translateGesture.maxNumTouchesRequired = 1;
		}
		
		override public function reset():void
		{
			super.reset();
			_translateGesture.removeAllEventListeners();
			_startPoint = null;
			
			activate();
		}
		
		override public function activate():void
		{
			super.activate();
			_translateGesture.addEventListener(GestureEvent.GESTURE_BEGAN, _interaction_begin);
		}
		
		override public function deactivate():void
		{
			super.deactivate();
			_translateGesture.removeAllEventListeners();
		}
		
		override protected function _interaction_begin(event:GestureEvent):void
		{
			super._interaction_begin(event);
			
			_startPoint = _translateGesture.location;
			
			var i:int = 0;
			var length:int = _transitionObjects.length();
			var currentObject:KObject;
			
			for(i; i < length; i++)
				_KSketch.beginTransform(_transitionObjects.getObjectAt(i),_interactionControl.transitionMode, _interactionControl.currentInteraction);
			
			_translateGesture.addEventListener(GestureEvent.GESTURE_CHANGED, _update_Translate);
			_translateGesture.addEventListener(GestureEvent.GESTURE_ENDED, _interaction_end);			
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
			var i:int = 0;
			var length:int = _transitionObjects.length();
			var currentObject:KObject;
			var dxdy:Point = _translateGesture.location.subtract(_startPoint);
			
			dxdy.x /= _KSketch.scaleX;
			dxdy.y /= _KSketch.scaleY;
			
			for(i; i < length; i++)
				_KSketch.updateTransform(_transitionObjects.getObjectAt(i), dxdy.x, dxdy.y, 0, 0 );
		}
	}
}