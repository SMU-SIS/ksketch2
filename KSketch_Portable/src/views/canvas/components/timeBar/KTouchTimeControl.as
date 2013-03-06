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
	
	import views.canvas.components.popup.KTouchMagnifier;

	public class KTouchTimeControl extends TouchSliderTemplate implements ITimeControl
	{
		public var recordingSpeed:Number = 1;
		private var _editMarkers:Boolean;
		
		public static const PLAY_ALLOWANCE:int = 2000;
		public static const MAX_ALLOWED_TIME:int = 600000; //Max allowed time of 10 mins
		
		protected var _KSketch:KSketch2;
		protected var _magnifier:KTouchMagnifier;
		protected var _tickmarkControl:KTouchTickMarkControl;
		
		protected var _isPlaying:Boolean = false;
		protected var _timer:Timer;
		protected var _maxPlayTime:int;
		protected var _rewindToTime:int;
		
		private var _maxFrame:int;
		private var _currentFrame:int;
		
		public var timings:Vector.<int>;
		
		private var _touchStage:Point;

		public function KTouchTimeControl()
		{
			super();
		}
		
		public function init(KSketchInstance:KSketch2, tickmarkControl:KTouchTickMarkControl):void
		{
			_KSketch = KSketchInstance;
			_tickmarkControl = tickmarkControl;
			floatingLabel.init(this);
			
			maximum = KTimeControl.DEFAULT_MAX_TIME;
			time = 0;
			editMarkers = false;
			
			_timer = new Timer(KSketch2.ANIMATION_INTERVAL);
			floatingLabel.y = localToGlobal(new Point(0,0)).y - 40;
			
			addEventListener(MouseEvent.MOUSE_DOWN, _touchDown);

			_magnifier = new KTouchMagnifier();
			_magnifier.init(contentGroup, this);
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
			timeLine.graphics.clear();
			timeLine.graphics.lineStyle(3,0x000000);
			var anchor:Point = contentGroup.globalToLocal(localToGlobal(new Point(0,0)));
			timeLine.graphics.moveTo(pct*backgroundFill.width,anchor.y);
			timeLine.graphics.lineTo(pct*backgroundFill.width,anchor.y+height);
		}
		
		/**
		 * Current time value for this application in milliseconds
		 */
		public function get time():int
		{
			return _KSketch.time
		}
		
		protected function _touchDown(event:MouseEvent):void
		{
			_touchStage = new Point(event.stageX, event.stageY);
			var touchX:Number = contentGroup.globalToLocal(_touchStage).x;
			var dx:Number = Math.abs(touchX - timeToX(time));

			if(dx > Capabilities.screenDPI/7)
				_tickmarkControl.grabTick(_touchStage);
			
			if(_tickmarkControl.grabbedTick)
				var tickGlobal:Point = markerDisplay.localToGlobal(new Point(_tickmarkControl.grabbedTick.x, 0));
			else
				time = xToTime(touchX);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, _touchMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, _touchEnd);
			removeEventListener(MouseEvent.MOUSE_DOWN, _touchDown);
		}
		
		protected function _touchMove(event:MouseEvent):void
		{
			_touchStage = new Point(event.stageX, event.stageY);
			
			if(!_tickmarkControl.grabbedTick)
				time = xToTime(contentGroup.globalToLocal(_touchStage).x);
			else
				_tickmarkControl.move_markers(_touchStage);
		}
		
		protected function _touchEnd(event:MouseEvent):void
		{
			if(_tickmarkControl.grabbedTick)
				_tickmarkControl.end_move_markers();
			
			_magnifier.close();
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