package sg.edu.smu.ksketch2.canvas.components.timebar
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.canvas.KSketch_CanvasView;
	import sg.edu.smu.ksketch2.controls.components.ITimeControl;
	import sg.edu.smu.ksketch2.events.KTimeChangedEvent;
	
	public class KSketch_TimeControl extends KSketch_TimeSlider implements ITimeControl
	{
		public static const PLAY_START:String = "Start Playing";
		public static const PLAY_STOP:String = "Stop Playing";
		public static const RECORD_START:String = "Start Recording";
		public static const RECORD_STOP:String = "Stop Recording";
		public static const DEFAULT_MAX_TIME:int = 5000;
		public static const TIME_EXTENSION:int = 5000;
		public static var recordingSpeed:Number = 1;
		
		public var recordingSpeed:Number = 1;
		private var _editMarkers:Boolean;
		
		public static const PLAY_ALLOWANCE:int = 2000;
		public static const MAX_ALLOWED_TIME:int = 600000; //Max allowed time of 10 mins
		
		protected var _KSketch:KSketch2;
		protected var _tickmarkControl:KSketch_TickMark_Control;
		
		protected var _isPlaying:Boolean = false;
		protected var _timer:Timer;
		protected var _maxPlayTime:int;
		protected var _rewindToTime:int;
		
		private var _maxFrame:int;
		private var _currentFrame:int;
		
		public var timings:Vector.<int>;
		
		public static const BAR_TOP:int = 0;
		public static const BAR_BOTTOM:int = 1;
		
		private var _touchStage:Point = new Point(0,0);

		public function KSketch_TimeControl()
		{
			super();
		}
		
		public function init(KSketchInstance:KSketch2, tickmarkControl:KSketch_TickMark_Control):void
		{
			_KSketch = KSketchInstance;
			_tickmarkControl = tickmarkControl;
			
			_timer = new Timer(KSketch2.ANIMATION_INTERVAL);
			
			addEventListener(MouseEvent.MOUSE_DOWN, _touchDown);

			timeDisplay.graphics.lineStyle(6,0xFF0000, 0.4);
			
			var anchor:Point = contentGroup.globalToLocal(localToGlobal(new Point(0,0)));
			timeDisplay.graphics.moveTo(0,anchor.y);
			timeDisplay.graphics.lineTo(0,anchor.y+height);
			
			maximum = KSketch_TimeControl.DEFAULT_MAX_TIME;
			time = 0;
		}
		
		public function reset():void
		{
			maximum = KSketch_TimeControl.DEFAULT_MAX_TIME;
			time = 0;
		}
		
		public function updatePosition():void
		{

		}
		
		public function dispose():void
		{

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
			
			if(KSketch_TimeControl.DEFAULT_MAX_TIME < time)
			{
				var modelMax:int = _KSketch.maxTime
					
				if(modelMax <= time && time <= maximum )
						maximum = time;
				else
					maximum = modelMax;
			}
			else if(time < KSketch_TimeControl.DEFAULT_MAX_TIME && maximum != KSketch_TimeControl.DEFAULT_MAX_TIME)
			{
				if(_KSketch.maxTime < KSketch_TimeControl.DEFAULT_MAX_TIME)
					maximum = KSketch_TimeControl.DEFAULT_MAX_TIME;
			}
			
			var pct:Number = _currentFrame/(_maxFrame*1.0);
			timeDisplay.x = pct*backgroundFill.width;
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
		
		/**
		 * On touch function. Time slider interactions begins here
		 * Determines whether to use the tick mark control or to just itneract with the slider
		 */
		protected function _touchDown(event:MouseEvent):void
		{
			_touchStage.x = event.stageX;
			_touchStage.y = event.stageY;
			var xPos:Number = contentGroup.globalToLocal(_touchStage).x;
			
			var dx:Number = Math.abs(xPos - timeToX(time));
			
			if(!KSketch_CanvasView.isPlayer && dx > KSketch_TickMark_Control.GRAB_THRESHOLD)
				_tickmarkControl.grabTick(xPos);
			
			if(!KSketch_CanvasView.isPlayer && _tickmarkControl.grabbedTick)
			{
				
			}
			else
			{
				var timeX:Number = timeToX(time);
				
				if(Math.abs(xPos - timeX) >KSketch_TickMark_Control.GRAB_THRESHOLD)
					time = xToTime(xPos);
			}
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, _touchMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, _touchEnd);
			removeEventListener(MouseEvent.MOUSE_DOWN, _touchDown);
		}
		
		/**
		 * Update time control interaction
		 */
		protected function _touchMove(event:MouseEvent):void
		{
			//Only consider a move if a significant dx has been covered
			if(Math.abs(event.stageX - _touchStage.x) < (pixelPerFrame*0.5))
				return;
			
			_touchStage.x = event.stageX;
			_touchStage.y = event.stageY;
			var xPos:Number = contentGroup.globalToLocal(_touchStage).x;
			
			//Rout interaction into the tick mark control if there is a grabbed tick
			if(!KSketch_CanvasView.isPlayer && _tickmarkControl.grabbedTick)
			{
				_tickmarkControl.move_markers(xPos);
			}
			else
			{
				time = xToTime(xPos); //Else just change the time
			}
		}
		
		/**
		 * End of time control interaction
		 */
		protected function _touchEnd(event:MouseEvent):void
		{
			//Same, route the interaction to the tick mark control if there is a grabbed tick
			if(!KSketch_CanvasView.isPlayer && _tickmarkControl.grabbedTick)
			{
				_tickmarkControl.end_move_markers();
			}
			else
			{
				var log:XML = <op/>;
				var date:Date = new Date();
				
				log.@category = "Timeline";
				log.@type = "Scroll";
				log.@elapsedTime = KSketch_TimeControl.toTimeCode(date.time - _KSketch.logStartTime);
				_KSketch.log.appendChild(log);
			}
			
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
			this.dispatchEvent(new Event(KSketch_TimeControl.PLAY_START));
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
			this.dispatchEvent(new Event(KSketch_TimeControl.PLAY_STOP));
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
		
		/**
		 * Converts x to time based on this time control
		 */
		public function xToTime(value:Number):int
		{
			var currentFrame:int = Math.floor(value/pixelPerFrame);
			
			return currentFrame * KSketch2.ANIMATION_INTERVAL;
		}
		
		/**
		 * Num Pixels per frame
		 */
		public function get pixelPerFrame():Number
		{
			return backgroundFill.width/_maxFrame;
		}
		
		/**
		 * Returns the given time (milliseconds) as a SS:MM String
		 */
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
			
			var timeCode:String = strSeconds + '.' + strMilliseconds;
			return timeCode;
		}
	}
}