package views.canvas.interactors
{
	import flash.display.DisplayObject;
	
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.PanGesture;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.controls.interactioncontrol.IInteractionControl;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;
	
	public class KTouchTranslateInteractor extends KTouchTransitionInteractor
	{
		private var _translateGesture:PanGesture;
		
		private var _dx:Number;
		private var _dy:Number;
		
		public function KTouchTranslateInteractor(KSketchInstance:KSketch2, interactionControl:IInteractionControl, inputComponent:DisplayObject)
		{
			super(KSketchInstance, interactionControl, inputComponent);
			
			_translateGesture = new PanGesture(inputComponent);
			_translateGesture.maxNumTouchesRequired = 1;
		}
		
		override public function reset():void
		{
			super.reset();
			_translateGesture.removeAllEventListeners();
			
			_dx = NaN;
			_dy = NaN;
			
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
			
			_dx = 0;
			_dy = 0;
			
			var i:int = 0;
			var length:int = _transitionObjects.length();
			var currentObject:KObject;
			
			for(i; i < length; i++)
			{
				currentObject = _transitionObjects.getObjectAt(i);
				_KSketch.transform_Begin_Translation(currentObject, KSketch2.TRANSITION_INTERPOLATED, new KCompositeOperation());
			}
			
			_translateGesture.addEventListener(GestureEvent.GESTURE_CHANGED, _update_Translate);
			_translateGesture.addEventListener(GestureEvent.GESTURE_ENDED, _interaction_end);			
		}
		
		override protected function _interaction_end(event:GestureEvent):void
		{
			var i:int = 0;
			var length:int = _transitionObjects.length();
			var currentObject:KObject;
			
			for(i; i < length; i++)
			{
				currentObject = _transitionObjects.getObjectAt(i);
				_KSketch.transform_End_Translation(currentObject, new KCompositeOperation());
			}
			
			super._interaction_end(event);
			reset();
		}
		
		private function _update_Translate(event:GestureEvent):void
		{
			_dx += _translateGesture.offsetX;
			_dy += _translateGesture.offsetY;
			
			var i:int = 0;
			var length:int = _transitionObjects.length();
			var currentObject:KObject;
			
			for(i; i < length; i++)
			{
				currentObject = _transitionObjects.getObjectAt(i);
				_KSketch.transform_Update_Translation(currentObject, _dx, _dy);
			}
		}
	}
}