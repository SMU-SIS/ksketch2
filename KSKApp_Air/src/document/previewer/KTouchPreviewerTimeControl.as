package document.previewer
{
	import flash.display.DisplayObject;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import sg.edu.smu.ksketch2.canvas.components.timebar.KSketch_TimeControl;
	
	public class KTouchPreviewerTimeControl
	{
		import org.gestouch.events.GestureEvent;
		import org.gestouch.gestures.PanGesture;
		import org.gestouch.gestures.TapGesture;
		
		import sg.edu.smu.ksketch2.KSketch2;
		
		private const _PAN_SPEED_1:int = 1
		private const _PAN_SPEED_2:int = 3;
		private const _PAN_SPEED_3:int = 9;
		private const _PAN_SPEED_4:int = 15;
		
		private const _PAN_THRESHOLD_1:Number = 5;
		private const _PAN_THRESHOLD_2:Number = 8;
		private const _PAN_THRESHOLD_3:Number = 10;
		
		private const _STEP_THRESHOLD:Number = 7;
		
		private var _KSketch:KSketch2;
		private var _tapGesture:TapGesture;
		private var _panGesture:PanGesture;
		
		private var _timer:Timer;
		private var _maxPlayTime:int;
		private var _rewindToTime:int;
		
		private var isPlaying:Boolean;
		
		protected var _panVector:Point = new Point();
		protected var _panSpeed:int = _PAN_SPEED_1;
		protected var _prevOffset:Number = 1;
		protected var _panOffset:Number = 0;
		
		public function KTouchPreviewerTimeControl()
		{
		}
		
		public function init(KSketchInstance:KSketch2, inputComponent:DisplayObject):void
		{
			_KSketch = KSketchInstance;
			isPlaying = false;
			
			_timer = new Timer(KSketch2.ANIMATION_INTERVAL);
			
			_tapGesture = new TapGesture(inputComponent);
			_tapGesture.addEventListener(GestureEvent.GESTURE_RECOGNIZED, handlePlayPause);
			
			_panGesture = new PanGesture(inputComponent);
			_panGesture.addEventListener(GestureEvent.GESTURE_CHANGED, updateSlider);
		}
		
		public function get time():int
		{
			return _KSketch.time;
		}
		
		public function set time(value:int):void
		{
			if(value < 0)
				value = 0;
			
			if(value > _KSketch.maxTime)
				value = _KSketch.maxTime;
			
			_KSketch.time = value;
		}
		
		public function handlePlayPause(event:org.gestouch.events.GestureEvent):void
		{
			if(isPlaying)
				stop();
			else
				play();	
		}
		
		public function updateSlider(event:org.gestouch.events.GestureEvent):void
		{
			//Changed direction, have to reset all pan gesture calibrations till now.
			if((_prevOffset * _panGesture.offsetX) < 0)
				resetSliderInteraction();
			
			_panVector.x = _panGesture.offsetX;
			_panVector.y = _panGesture.offsetY;
			
			var absOffset:Number = _panVector.length;
			
			//Pan Offset is the absolute distance moved during a pan gesture
			//Need to update to see how far this pan has moved.
			_panOffset += absOffset;

			//Speed calibration according to how far the pan gesture moved.
			if( absOffset <= _PAN_THRESHOLD_1)
				_panSpeed = _PAN_SPEED_1;
			else if(absOffset <= _PAN_THRESHOLD_2)
				_panSpeed = _PAN_SPEED_2;
			else if(absOffset <= _PAN_THRESHOLD_3)
				_panSpeed = _PAN_SPEED_3 * (_KSketch.maxTime/KSketch_TimeControl.DEFAULT_MAX_TIME);
			else
				_panSpeed = absOffset * (_KSketch.maxTime/KSketch_TimeControl.DEFAULT_MAX_TIME);
 
			//Update the time according to the direction of the pan.
			//Advance if it's towards the right
			//Roll back if it's towards the left.
			if(_panOffset > _STEP_THRESHOLD)
			{				
				if(0 < _panGesture.offsetX)
					time = time + (_panSpeed*KSketch2.ANIMATION_INTERVAL);
				else if(_panGesture.offsetX < 0)
					time = time - (_panSpeed*KSketch2.ANIMATION_INTERVAL);
				
				_panOffset = 0;
			}
			
			//Save the current offset value, will need this thing to check for
			//change in direction in the next update event
			_prevOffset =  _panGesture.offsetX;
		}
		
		/**
		 * Enters the playing state machien
		 */
		public function play():void
		{
			_timer.delay = KSketch2.ANIMATION_INTERVAL;
			_timer.addEventListener(TimerEvent.TIMER, _playHandler);
			_timer.start();
			
			if(_KSketch.maxTime <= time)
				time = 0;
			
			_maxPlayTime = _KSketch.maxTime;
			
			_rewindToTime = time;
			isPlaying = true;
		}
		
		/**
		 * For resetting slider interaction values;
		 */
		public function resetSliderInteraction():void
		{
			_prevOffset = 1;
			_panOffset = 0;
			_panSpeed = _PAN_SPEED_1;
		}
		
		/**
		 * Updates the play state machine
		 * Different from record handler because it stops on max time
		 */
		private function _playHandler(event:TimerEvent):void 
		{
			if(time >= _maxPlayTime)
			{
				time = _rewindToTime;
				stop();
			}
			else
				time = time + KSketch2.ANIMATION_INTERVAL;
		}
		
		/**
		 * Stops playing and remove listener from the timer
		 */
		public function stop():void
		{
			_timer.removeEventListener(TimerEvent.TIMER, _playHandler);
			_timer.stop();
			isPlaying = false;
		}
	}
}