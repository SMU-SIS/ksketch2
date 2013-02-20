package views.canvas.components.timeBar
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import mx.core.UIComponent;
	
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.PanGesture;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.controls.widgets.ITimeControl;
	import sg.edu.smu.ksketch2.controls.widgets.KTimeControl;
	import sg.edu.smu.ksketch2.events.KTimeChangedEvent;

	public class KTouchTimeControl extends TouchSliderTemplate implements ITimeControl
	{
		public var recordingSpeed:Number = 1;
		private var _editMarkers:Boolean;
		
		private const _PAN_SPEED_1:int = 1
		private const _PAN_SPEED_2:int = 3;
		private const _PAN_SPEED_3:int = 9;
		private const _PAN_SPEED_4:int = 15;
		
		private const _PAN_THRESHOLD_1:Number = 5;
		private const _PAN_THRESHOLD_2:Number = 8;
		private const _PAN_THRESHOLD_3:Number = 10;
		
		private const _STEP_THRESHOLD:Number = 7;
		
		public static const PLAY_ALLOWANCE:int = 2000;
		public static const MAX_ALLOWED_TIME:int = 600000; //Max allowed time of 10 mins
		
		protected var _KSketch:KSketch2;
		private var _tickmarkControl:KTouchTickMarkControl;
		protected var _timer:Timer;
		private var _maxPlayTime:int;
		protected var _isPlaying:Boolean = false;
		private var _rewindToTime:int;
		
		private var _maxFrame:int;
		private var _currentFrame:int;
		
		protected var _panVector:Point = new Point();
		protected var _panSpeed:int = _PAN_SPEED_1;
		protected var _prevOffset:Number = 1;
		protected var _panOffset:Number = 0;
		protected var _panGesture:PanGesture;
		
		public var timings:Vector.<int>;
		
		public function KTouchTimeControl()
		{
			super();
		}
		
		public function init(KSketchInstance:KSketch2, tickmarkControl:KTouchTickMarkControl, inputComponent:UIComponent):void
		{
			_KSketch = KSketchInstance;
			_tickmarkControl = tickmarkControl;
			floatingLabel.init(contentGroup);
			
			maximum = KTimeControl.DEFAULT_MAX_TIME;
			time = 0;
			editMarkers = false;
			
			_timer = new Timer(KSketch2.ANIMATION_INTERVAL);
			floatingLabel.y = localToGlobal(new Point(0,0)).y - 40;
			
			inputComponent.addEventListener(TouchEvent.TOUCH_BEGIN, _tickmarkControl.openMagnifier);
			inputComponent.addEventListener(TouchEvent.TOUCH_END, _tickmarkControl.closeMagnifier);
			_panGesture = new PanGesture(inputComponent);
			_panGesture.maxNumTouchesRequired = 1;
			_panGesture.addEventListener(GestureEvent.GESTURE_BEGAN, _beginPanning);
			_panGesture.addEventListener(GestureEvent.GESTURE_CHANGED, _updatePanning);
			_panGesture.addEventListener(GestureEvent.GESTURE_ENDED, _endPanning);
		}
		
		public function reset():void
		{
			maximum = KTimeControl.DEFAULT_MAX_TIME;
			time = 0;
			editMarkers =  false;
		}
		
		public function set editMarkers(edit:Boolean):void
		{
			_editMarkers = edit;
			
			if(_editMarkers)
			{
				backgroundFill.alpha = 0.5;
				timeFill.alpha = 0.2;
			}
			else
			{
				backgroundFill.alpha = 1;
				timeFill.alpha = 1;
			}
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
			if(MAX_ALLOWED_TIME < value)
				value = MAX_ALLOWED_TIME;
			if(maximum < value)
				maximum = value;
			
			_currentFrame = int(Math.floor(value/KSketch2.ANIMATION_INTERVAL));
			_KSketch.time = _currentFrame * KSketch2.ANIMATION_INTERVAL;
			
			if(KTimeControl.DEFAULT_MAX_TIME < time)
			{
				var modelMax:int = _KSketch.maxTime
					
				if(modelMax <= time && time <= maximum )
						maximum = time;
				else
					maximum = modelMax;
			}
			else if(time < KTimeControl.DEFAULT_MAX_TIME && maximum != KTimeControl.DEFAULT_MAX_TIME)
			{
				if(_KSketch.maxTime < KTimeControl.DEFAULT_MAX_TIME)
					maximum = KTimeControl.DEFAULT_MAX_TIME;
			}
			
			var pct:Number = _currentFrame/(_maxFrame*1.0);
			timeFill.percentWidth = pct*100;

			if(!_isPlaying && floatingLabel.owner)
			{
				floatingLabel.x = timeFill.localToGlobal(new Point(pct*backgroundFill.width, 0)).x;
				floatingLabel.showMessage(time, _currentFrame);
			}
		}
		
		/**
		 * Current time value for this application in milliseconds
		 */
		public function get time():int
		{
			return _KSketch.time
		}
		
		protected function _beginPanning(event:GestureEvent):void
		{
			_tickmarkControl.pan_begin(_panGesture.location);
		}
		
		protected function _updatePanning(event:GestureEvent):void
		{
			//If edit markers, rout event into the tick mark control and return
			_tickmarkControl.pan_update(_panGesture.location);
		}
		
		protected function _endPanning(event:GestureEvent):void
		{
			if(event.type == GestureEvent.GESTURE_ENDED)
			{
				//If edit markers, rout event into the tick mark control and return
				_tickmarkControl.pan_end(_panGesture.location);
			}
		}
		
		/**
		 * update slider with offsetX, subjected to speed changes
		 */
		public function updateSlider(offsetX:Number, offsetY:Number):void
		{
			//Changed direction, have to reset all pan gesture calibrations till now.
			if((_prevOffset * offsetX) < 0)
				resetSliderInteraction();
			
			_panVector.x = offsetX;
			_panVector.y = offsetY;
			
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
				_panSpeed = _PAN_SPEED_3 * (maximum/KTimeControl.DEFAULT_MAX_TIME);
			else
				_panSpeed = absOffset * (maximum/KTimeControl.DEFAULT_MAX_TIME);
			
			//Update the time according to the direction of the pan.
			//Advance if it's towards the right
			//Roll back if it's towards the left.
			if(_panOffset > _STEP_THRESHOLD)
			{				
				if(0 < offsetX)
					time = time + (_panSpeed*KSketch2.ANIMATION_INTERVAL);
				else if(offsetX < 0)
					time = time - (_panSpeed*KSketch2.ANIMATION_INTERVAL);
				
				_panOffset = 0;
			}
			
			//Save the current offset value, will need this thing to check for
			//change in direction in the next update event
			_prevOffset =  offsetX;
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
		 * Play Pause Record functions
		 */
		
		/**
		 * Enters the playing state machien
		 */
		public function play():void
		{
			_isPlaying = true;
			_timer.delay = KSketch2.ANIMATION_INTERVAL;
			_timer.addEventListener(TimerEvent.TIMER, playHandler);
			_timer.start();
			
			if(_KSketch.maxTime <= time)
				time = 0;
			
			_maxPlayTime = _KSketch.maxTime + PLAY_ALLOWANCE;
			
			_rewindToTime = time;
			this.dispatchEvent(new Event(KTimeControl.PLAY_START));
		}
		
		/**
		 * Updates the play state machine
		 * Different from record handler because it stops on max time
		 */
		private function playHandler(event:TimerEvent):void 
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
			_timer.removeEventListener(TimerEvent.TIMER, playHandler);
			_timer.stop();
			_isPlaying = false;
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
//			if((time + KSketch2.ANIMATION_INTERVAL) > maximum)
//				maximum = maximum + KSketch2.ANIMATION_INTERVAL;
			
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
		
		public function xToTime(value:Number):int
		{
			var currentFrame:int = Math.floor(value/pixelPerFrame);
			
			return currentFrame * KSketch2.ANIMATION_INTERVAL;
		}
		
		public function get pixelPerFrame():Number
		{
			return backgroundFill.width/_maxFrame;
		}
		
		
		/**
		 * Sets next closest landmark time in the given direction as the 
		 * current time.
		 */
		public function jumpInDirection(direction:Number):void
		{
			var i:int;
			var length:int = timings.length;
			
			var timeList:Vector.<int> = new Vector.<int>();
			
			for(i = 0; i<length; i++)
			{
				timeList.push(timings[i]);
			}
			
			timeList.unshift(0);
			timeList.push(maximum);

			var currentTime:Number = _KSketch.time;			
			var currentIndex:int = 0;
			
			for(i = 0; i < timeList.length; i++)
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