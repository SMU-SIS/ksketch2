package views.canvas.components.timeBar
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.PanGesture;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.controls.widgets.ITimeControl;
	import sg.edu.smu.ksketch2.controls.widgets.KTimeControl;
	import sg.edu.smu.ksketch2.events.KTimeChangedEvent;

	public class KTouchTimeControl extends TouchSliderTemplate implements ITimeControl
	{
		public var recordingSpeed:Number = 1;
		
		private const _PAN_SPEED_1:int = 1;
		private const _PAN_SPEED_2:int = 2;
		private const _PAN_SPEED_3:int = 3;
		private const _PAN_SPEED_4:int = 4;
		
		private const _PAN_THRESHOLD_1:Number = 0.03;
		private const _PAN_THRESHOLD_2:Number = 0.10;
		private const _PAN_THRESHOLD_3:Number = 0.15;
		
		private var _KSketch:KSketch2;
		private var _timer:Timer;
		
		private var _maxFrame:int;
		private var _currentFrame:int;
		
		private var _panSpeed:int;
		private var _prevOffset:Number;
		private var _panOffset:Number;
		private var _panGesture:PanGesture;
		
		public var timeList:Vector.<int>;
		
		public function KTouchTimeControl()
		{
			super();
		}
		
		public function init(KSketchInstance:KSketch2):void
		{
			_KSketch = KSketchInstance;
			maximum = KTimeControl.DEFAULT_MAX_TIME;
			time = 0;
			
			_timer = new Timer(KSketch2.ANIMATION_INTERVAL);
			
			_panGesture = new PanGesture(this);
			_panGesture.maxNumTouchesRequired = 1;
			_panGesture.addEventListener(GestureEvent.GESTURE_CHANGED, _updatePanning);
			_panGesture.addEventListener(GestureEvent.GESTURE_ENDED, _resetPan);
		}
		
		public function reset():void
		{
			maximum = KTimeControl.DEFAULT_MAX_TIME;
			time = 0;
		}
		
		/**
		 * Maximum time value for this application in milliseconds
		 */
		public function set maximum(value:int):void
		{
			_maxFrame = value/KSketch2.ANIMATION_INTERVAL;
			dispatchEvent(new Event(KTimeChangedEvent.EVENT_MAX_TIME_CHANGED));
		}
		
		/**
		 * Maximum time value for this application in milliseconds
		 */
		public function get maximum():int
		{
			return _maxFrame * KSketch2.ANIMATION_INTERVAL;
		}
		
		/**
		 * Current time value for this application in milliseconds
		 */
		public function set time(value:int):void
		{
			if(value < 0)
				value = 0;
			if(maximum < value)
				value = maximum;
			
			_KSketch.time = value;
			_currentFrame = int(Math.floor(value/KSketch2.ANIMATION_INTERVAL));
			timeFill.percentWidth = _currentFrame/(_maxFrame*1.0)*100;
		}
		
		/**
		 * Current time value for this application in milliseconds
		 */
		public function get time():int
		{
			return _KSketch.time
		}
		
		/**
		 * Handles the panning gesture's change.
		 */
		private function _updatePanning(event:GestureEvent):void
		{
			//Pan Offset is the absolute distance moved during a pan gesture
			//Need to update to see how far this pan has moved.
			_panOffset += Math.abs(_panGesture.offsetX)/width;
			
			//Changed direction, have to reset all pan gesture calibrations till now.
			if((_prevOffset * _panGesture.offsetX) < 0)
				_resetPan(event);
			
			//Speed calibration according to how far the pan gesture moved.
			if( _panOffset < _PAN_THRESHOLD_1)
				_panSpeed = _PAN_SPEED_1;
			else if(_PAN_THRESHOLD_1 <= _panOffset < _PAN_THRESHOLD_2)
				_panSpeed = _PAN_SPEED_2;
			else if(_PAN_THRESHOLD_2 <= _panOffset < _PAN_THRESHOLD_3)
				_panSpeed = _PAN_SPEED_3;
			else
				_panSpeed = _PAN_SPEED_4 * (maximum/KTimeControl.DEFAULT_MAX_TIME);
			
			//Update the time according to the direction of the pan.
			//Advance if it's towards the right
			//Roll back if it's towards the left.
			if(0 < _panGesture.offsetX)
				time = time + (_panSpeed*KSketch2.ANIMATION_INTERVAL);
			else
				time = time - (_panSpeed*KSketch2.ANIMATION_INTERVAL);
			
			//Save the current offset value, will need this thing to check for
			//change in direction in the next update event
			_prevOffset =  _panGesture.offsetX;
		}
		
		/**
		 * For resetting pan values;
		 */
		private function _resetPan(event:GestureEvent):void
		{
			_prevOffset = 1;
			_panOffset = 0;
			_panSpeed = _PAN_SPEED_1;
		}
		
		/**
		 * Play Pause Record functions
		 */
		
		/**
		 * Enters the playing state machien
		 */
		public function play():void
		{
			_timer.delay = KSketch2.ANIMATION_INTERVAL;
			_timer.addEventListener(TimerEvent.TIMER, playHandler);
			_timer.start();
			this.dispatchEvent(new Event(KTimeControl.PLAY_START));
		}
		
		/**
		 * Updates the play state machine
		 * Different from record handler because it stops on max time
		 */
		private function playHandler(event:TimerEvent):void 
		{
			if(time >= maximum)
			{
				time = maximum;
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
			_timer.removeEventListener(TimerEvent.TIMER, playHandler);
			_timer.stop();
			this.dispatchEvent(new Event(KTimeControl.PLAY_STOP));
		}
				
		/**
		 * Starts the recording state machine
		 * Also sets a timer delay according the the recordingSpeed variable
		 * for this time control
		 */
		public function startRecording():void
		{
			if(recordingSpeed <= 0)
				throw new Error("One does not record in 0 or negative time!");
			
			//The bigger the recording speed, the faster the recording
			_timer.delay = KSketch2.ANIMATION_INTERVAL * recordingSpeed;
			_timer.addEventListener(TimerEvent.TIMER, recordHandler);
			_timer.start();
		}
		
		/**
		 * Advances the time during recording
		 * Extends the time if max is reached
		 */
		private function recordHandler(event:TimerEvent):void 
		{
			if((time + KSketch2.ANIMATION_INTERVAL) > maximum)
				maximum = maximum + KTimeControl.TIME_EXTENSION;
			
			time = time + KSketch2.ANIMATION_INTERVAL;
		}
		
		/**
		 * Stops the recording event
		 */
		public function stopRecording():void
		{
			_timer.removeEventListener(TimerEvent.TIMER, recordHandler);
			_timer.stop();
		}
		
		/**
		 * Converts a time value to a x position;
		 */
		public function timeToX(value:int):Number
		{
			var currentFrame:int = value/KSketch2.ANIMATION_INTERVAL;
			return currentFrame/(_maxFrame*1.0) * backgroundFill.width;
		}
		
		
		/**
		 * Sets next closest landmark time in the given direction as the 
		 * current time.
		 */
		public function jumpInDirection(direction:Number):void
		{
			if(!timeList)
				return;
			
			var currentTime:Number = _KSketch.time;			
			var currentIndex:int = 0;
			
			for(var i:int = 0; i < timeList.length; i++)
			{
				currentIndex = i;
				
				if(currentTime <= timeList[i])
					break;
			}
			
			var toTime:Number = 0;
			
			if(direction < 0)
			{
				currentIndex -= 1;
				
				if(currentIndex < 0)
					toTime = 0;
				else
					toTime = timeList[currentIndex];
			}
			else
			{
				if(currentIndex < timeList.length)
				{
					var checkTime:Number = timeList[currentIndex];
					if(checkTime == _KSketch.time)
					{
						while(checkTime == _KSketch.time)
						{
							currentIndex += 1;
							
							if(currentIndex < timeList.length)
								checkTime = timeList[currentIndex];
							else
								break;
						}
					}
					
					toTime = checkTime;
				}
				else
					toTime = _KSketch.time;
			}
			
			time = toTime;
		}
	}
}