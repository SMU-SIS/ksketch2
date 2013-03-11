package views.canvas.components.timeBar
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.system.Capabilities;
	import flash.utils.Timer;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.controls.widgets.ITimeControl;
	import sg.edu.smu.ksketch2.controls.widgets.KTimeControl;
	import sg.edu.smu.ksketch2.events.KTimeChangedEvent;
	

	public class KTouchTimeControl extends TouchSliderTemplate implements ITimeControl
	{
		public var recordingSpeed:Number = 1;
		private var _editMarkers:Boolean;
		
		public static const PLAY_ALLOWANCE:int = 2000;
		public static const MAX_ALLOWED_TIME:int = 600000; //Max allowed time of 10 mins
		
		protected var _KSketch:KSketch2;
		protected var _magnifier:KTouchTimeSliderMagnifier;
		protected var _tickmarkControl:KTouchTickMarkControl;
		
		protected var _isPlaying:Boolean = false;
		protected var _timer:Timer;
		protected var _maxPlayTime:int;
		protected var _rewindToTime:int;
		
		private var _maxFrame:int;
		private var _currentFrame:int;
		
		public var timings:Vector.<int>;
		
		private var _touchStage:Point = new Point(0,0);

		public function KTouchTimeControl()
		{
			super();
		}
		
		public function init(KSketchInstance:KSketch2, tickmarkControl:KTouchTickMarkControl):void
		{
			_KSketch = KSketchInstance;
			_tickmarkControl = tickmarkControl;
			
			_timer = new Timer(KSketch2.ANIMATION_INTERVAL);
			
			addEventListener(MouseEvent.MOUSE_DOWN, _touchDown);

			_magnifier = new KTouchTimeSliderMagnifier();
			_magnifier.init(contentGroup, this);
			
			timeDisplay.graphics.lineStyle(6,0x000000, 0.25);
			var anchor:Point = contentGroup.globalToLocal(localToGlobal(new Point(0,0)));
			timeDisplay.graphics.moveTo(0,anchor.y);
			timeDisplay.graphics.lineTo(0,anchor.y+height);
			
			maximum = KTimeControl.DEFAULT_MAX_TIME;
			time = 0;
			
			_magnifier.open(contentGroup);
		}
		
		public function reset():void
		{
			maximum = KTimeControl.DEFAULT_MAX_TIME;
			time = 0;
		}
		
		public function dispose():void
		{
			if(_magnifier)
			{
				_magnifier.visible = false;
				_magnifier.close();
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
			
			_currentFrame = timeToFrame(value);
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
			timeDisplay.x = pct*backgroundFill.width;
			
			_magnifier.x = timeToX(time);
			_magnifier.showTime(time, _currentFrame);
		}
		
		/**
		 * Current time value for this application in milliseconds
		 */
		public function get time():int
		{
			return _KSketch.time
		}
		
		public function get currentFrame():int
		{
			return _currentFrame;
		}
		
		protected function _touchDown(event:MouseEvent):void
		{
			_touchStage.x = event.stageX;
			_touchStage.y = event.stageY;
			var xPos:Number = contentGroup.globalToLocal(_touchStage).x;
			
			var dx:Number = Math.abs(xPos - timeToX(time));

			if(dx > Capabilities.screenDPI/7)
				_tickmarkControl.grabTick(xPos);
			
			if(_tickmarkControl.grabbedTick)
			{
				var toShowTime:int = xToTime(_tickmarkControl.grabbedTick.x);
				_magnifier.x = _tickmarkControl.grabbedTick.x;
				_magnifier.showTime(toShowTime, timeToFrame(toShowTime));
				_magnifier.magnify(_tickmarkControl.grabbedTick.x);
			}
			else
			{
				var timeX:Number = timeToX(time);
				
				if(Math.abs(xPos - timeX) > Capabilities.screenDPI/7)
					time = xToTime(xPos);
				
				_magnifier.magnify(timeToX(time));
			}
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, _touchMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, _touchEnd);
			removeEventListener(MouseEvent.MOUSE_DOWN, _touchDown);
		}
		
		protected function _touchMove(event:MouseEvent):void
		{
			if(Math.abs(event.stageX - _touchStage.x) < (pixelPerFrame*0.5))
				return;
			
			_touchStage.x = event.stageX;
			_touchStage.y = event.stageY;
			var xPos:Number = contentGroup.globalToLocal(_touchStage).x;
			
			if(_tickmarkControl.grabbedTick)
			{
				_tickmarkControl.move_markers(xPos);
				var toShowTime:int = xToTime(_tickmarkControl.grabbedTick.x);
				_magnifier.x = _tickmarkControl.grabbedTick.x;
				_magnifier.showTime(toShowTime, timeToFrame(toShowTime));
				_magnifier.magnify(_tickmarkControl.grabbedTick.x);
			}
			else
			{
				time = xToTime(xPos);
				_magnifier.magnify(timeToX(time));
			}
		}
		
		protected function _touchEnd(event:MouseEvent):void
		{
			if(_tickmarkControl.grabbedTick)
				_tickmarkControl.end_move_markers();
			
			_magnifier.closeMagnifier();
			_tickmarkControl.grabbedTick = null;
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, _touchMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, _touchEnd);
			addEventListener(MouseEvent.MOUSE_DOWN, _touchDown);
		}
		
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
		 * Converts a time value to frame value
		 */
		public function timeToFrame(value:int):int
		{
			return int(Math.floor(value/KSketch2.ANIMATION_INTERVAL));
		}
		
		/**
		 * Converts a time value to a x position;
		 */
		public function timeToX(value:int):Number
		{
			return timeToFrame(value)/(_maxFrame*1.0) * backgroundFill.width;
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
		
		public static function toTimeCode(milliseconds:Number):String
		{
			var seconds:int = Math.floor((milliseconds/1000));
			var strSeconds:String = seconds.toString();
			if(seconds < 10)
				strSeconds = "0" + strSeconds;
			
			
			var remainingMilliseconds:int = (milliseconds%1000)/10;
			var strMilliseconds:String = remainingMilliseconds.toString();
			strMilliseconds = strMilliseconds.charAt(0) + strMilliseconds.charAt(1);
			
			if(remainingMilliseconds < 10)
				strMilliseconds = "0" + strMilliseconds;
			
			var timeCode:String = strSeconds + ':' + strMilliseconds;
			return timeCode;
		}
	}
}