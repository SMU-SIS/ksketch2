package views.document
{
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import mx.core.UIComponent;
	
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.PanGesture;
	import org.gestouch.gestures.TapGesture;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.controls.widgets.KTimeControl;
	
	import views.canvas.components.timeBar.KTouchTickMarkControl;
	import views.canvas.components.timeBar.KTouchTimeControl;
	
	public class KTouchPreviewTimeControl extends KTouchTimeControl
	{
		private var _tapGesture:TapGesture;
		
		public function KTouchPreviewTimeControl()
		{
			super();
			
			floatingLabel.visible = false;
		}
		
		override public function init(KSketchInstance:KSketch2, tickmarkControl:KTouchTickMarkControl, inputComponent:UIComponent):void
		{
			_KSketch = KSketchInstance;
			
			maximum = KTimeControl.DEFAULT_MAX_TIME;
			time = 0;
			_timer = new Timer(KSketch2.ANIMATION_INTERVAL);
			
			_panGesture = new PanGesture(inputComponent);
			_panGesture.maxNumTouchesRequired = 1;
			_panGesture.addEventListener(GestureEvent.GESTURE_CHANGED, _updatePanning);
			
			_tapGesture = new TapGesture(inputComponent);
			_tapGesture.addEventListener(GestureEvent.GESTURE_RECOGNIZED, _handlePlayPause);
		}
		
		private function _handlePlayPause(event:GestureEvent):void
		{
			if(_isPlaying)
				stop();
			else
				play();
		}
		
		override protected function _updatePanning(event:GestureEvent):void
		{
			updateSlider(_panGesture.offsetX, _panGesture.offsetY);	
		}
	}
}