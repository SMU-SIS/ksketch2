/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.canvas.components.timebar
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import mx.events.FlexEvent;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.canvas.mainView.KSketch_CanvasView;
	import sg.edu.smu.ksketch2.canvas.components.popup.KSketch_Timebar_ContextMenu;
	import sg.edu.smu.ksketch2.canvas.components.popup.KSketch_Timebar_Magnifier;
	import sg.edu.smu.ksketch2.canvas.controls.interactors.widgetstates.KWidgetInteractorManager;
	import sg.edu.smu.ksketch2.events.KTimeChangedEvent;
	
	public class KSketch_TimeControl extends KSketch_TimeSlider implements ITimeControl
	{
		public static const PLAY_START:String = "Start Playing";
		public static const PLAY_STOP:String = "Stop Playing";
		public static const RECORD_START:String = "Start Recording";
		public static const RECORD_STOP:String = "Stop Recording";
		public static const EVENT_POSITION_CHANGED:String = "position changed";

		public static const SNAP_DOWN:int = 20;
		public static const SNAP_MOVE:int = 20;
		
		public static const BAR_TOP:int = 0;
		public static const BAR_BOTTOM:int = 1;
		
		public static const DEFAULT_MAX_TIME:Number = 5000;
		public static const TIME_EXTENSION:Number = 5000;
		public static var recordingSpeed:Number = 1;
		
		public var recordingSpeed:Number = 1;
		private var _editMarkers:Boolean;
		
		public static const PLAY_ALLOWANCE:int = 2000;
		public static const MAX_ALLOWED_TIME:Number = 600000; //Max allowed time of 10 mins
		
		protected var _KSketch:KSketch2;
		protected var _tickmarkControl:KSketch_TickMark_Control;
		protected var _transitionHelper:KWidgetInteractorManager;
		protected var _magnifier:KSketch_Timebar_Magnifier;
		protected var _keyMenu:KSketch_Timebar_ContextMenu;
		
		public static var _isPlaying:Boolean = false;
		protected var _timer:Timer;
		protected var _maxPlayTime:Number;
		protected var _rewindToTime:Number;
		private var _position:int;
		
		private var _maxFrame:int;
		private var _currentFrame:int;
		
		public var timings:Vector.<Number>;
		
		private var _touchStage:Point = new Point(0,0);
		private var _substantialMovement:Boolean = false;
		
		private var grabbedTickTimer:Timer;
		private var nearTick: Number;
		private var _longTouch:Boolean = false;
		private var isNearTick: Boolean = false;
		private var moveTick:Boolean = false;
		
		private var showMagnifier:Boolean = false;
		
		public function KSketch_TimeControl()
		{
			super();
		}
		
		public function init(KSketchInstance:KSketch2, tickmarkControl:KSketch_TickMark_Control,
							 transitionHelper:KWidgetInteractorManager,
							 magnifier:KSketch_Timebar_Magnifier, keyMenu:KSketch_Timebar_ContextMenu):void
		{

			_KSketch = KSketchInstance;
			_tickmarkControl = tickmarkControl;
			_transitionHelper = transitionHelper;
			_magnifier = magnifier;
			_keyMenu = keyMenu;
			timeLabels.init(this);
			
			_timer = new Timer(KSketch2.ANIMATION_INTERVAL);
			
			contentGroup.addEventListener(MouseEvent.MOUSE_DOWN, _touchDown);
			_magnifier.addEventListener(MouseEvent.MOUSE_DOWN, _touchDown);
			
			maximum = KSketch_TimeControl.DEFAULT_MAX_TIME;
			time = 0;

			_position = BAR_TOP;
			dispatchEvent(new Event(EVENT_POSITION_CHANGED));
		}
		
		public function reset():void
		{
			maximum = KSketch_TimeControl.DEFAULT_MAX_TIME;
			time = 0;
		}
		
		public function get position():int
		{
			return _position;
		}
		
		/**
		 * Sets the position of the time bar
		 * Either KSketch_TimeControl.BAR_TOP for top
		 * KSketch_TimeControl.BAR_BOTTOM for bottom
		 */
		public function set position(value:int):void
		{
			if(value == _position)
				return;
			
			_position = value;
			
			if(_position == BAR_TOP)
			{
				removeElement(timeLabels);
				addElementAt(timeLabels,1);
			}
			else
			{
				removeElement(timeLabels);
				addElementAt(timeLabels,1);
			}
			
			_magnifier.dispatchEvent(new FlexEvent(FlexEvent.UPDATE_COMPLETE));
		}
		
		/**
		 * Maximum time value for this application in milliseconds
		 */
		public function set maximum(value:Number):void
		{
			_maxFrame = value/KSketch2.ANIMATION_INTERVAL;
			dispatchEvent(new Event(KTimeChangedEvent.EVENT_MAX_TIME_CHANGED));
		}
		
		/**
		 * Maximum time value for this application in milliseconds
		 */
		public function get maximum():Number
		{
			return _maxFrame * KSketch2.ANIMATION_INTERVAL;
		}
		
		/**
		 * Current time value for this application in milliseconds
		 */
		public function set time(value:Number):void
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
			
			_magnifier.showTime(toTimeCode(time), _currentFrame, timeToX(time));
		}
		
		/**
		 * Current time value for this application in milliseconds
		 */
		public function get time():Number
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
		public function _touchDown(event:MouseEvent):void
		{	
			//upon touchdown, start grabbedTickTimer to time how long the touchdown is
			//if timer completes (means longPress), grab the tick at that particular time
			grabbedTickTimer = new Timer(800,1);
			grabbedTickTimer.start();
			grabbedTickTimer.addEventListener(TimerEvent.TIMER_COMPLETE, _triggerLongTouch);
			
			_touchStage.x = event.stageX;
			_touchStage.y = event.stageY;
			_substantialMovement = false;
			
			var xPos:Number = contentGroup.globalToLocal(_touchStage).x;
			var dx:Number = Math.abs(xPos - timeToX(time));
			
			//check if position x is a tick
			var xPosIsTick:Boolean = false;
			if(_tickmarkControl._ticks)
			{
				var i:int;
				for( i=0; i<_tickmarkControl._ticks.length; i++)
				{
					var tempTick:Number = _tickmarkControl._ticks[i].x;
					if(Math.round(xPos) >= (Math.round(tempTick) - SNAP_DOWN) && Math.round(xPos) <= (Math.round(tempTick) + SNAP_DOWN))
					{
						xPosIsTick = true;
						nearTick = tempTick;
						break;
					}
				}
			}
			
			//check if slider is on top if xPosIsTick is true
			if(xPosIsTick)
			{
				_tickmarkControl.grabTick(nearTick);
				_autoSnap(nearTick);
				nearTick = 0;
			}
			else
				_autoSnap(xPos);
			
			contentGroup.removeEventListener(MouseEvent.MOUSE_DOWN, _touchDown);
			_magnifier.removeEventListener(MouseEvent.MOUSE_DOWN, _touchDown);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, _touchMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, _touchEnd);
		}
		
		/**
		 * Update time control interaction
		 */
		protected function _touchMove(event:MouseEvent):void
		{
			//remove grabbed tick timer if it hasn't completed countdown when user enters move
			if(grabbedTickTimer.currentCount == 0)
			{
				_longTouch = false;
				grabbedTickTimer.removeEventListener(TimerEvent.TIMER, _triggerLongTouch);
				grabbedTickTimer.stop();
			}
			
			//Only consider a move if a significant dx has been covered
			if(Math.abs(event.stageX - _touchStage.x) < (pixelPerFrame*0.5))
				return;
			
			_touchStage.x = event.stageX;
			_touchStage.y = event.stageY;
			_substantialMovement = true;

			var xPos:Number = contentGroup.globalToLocal(_touchStage).x;
			
			if(_tickmarkControl._ticks)
			{
				for(var i:int=0; i<_tickmarkControl._ticks.length; i++)
				{
					nearTick = _tickmarkControl._ticks[i].x;
					if(Math.floor(xPos) >= (Math.round(nearTick) - SNAP_MOVE) && Math.floor(xPos) <= (Math.round(nearTick) + SNAP_MOVE))
					{
						isNearTick = true;
						break;
					}
					else
						isNearTick = false;
				}
			}
			
			//Rout interaction into the tick mark control if there is a grabbed tick
			if(!KSketch_CanvasView.isPlayer && (_tickmarkControl.grabbedTick && _longTouch))
			{
				_tickmarkControl.move_markers(xPos);
				_magnifier.magnify(timeToX(xToTime(xPos)));
				_autoSnap(xPos);
				
				moveTick = true;
			}
			else if(isNearTick)
			{
				_autoSnap(nearTick);
				isNearTick = false;
				nearTick = 0;
			}
			else
				_autoSnap(xPos);
		}
		
		/**
		 * End of time control interaction
		 */
		protected function _touchEnd(event:MouseEvent):void
		{
			//remove grabbedTick timer if it hasn't complete countdown when user ends touch
			if(grabbedTickTimer.currentCount == 0)
			{
				grabbedTickTimer.removeEventListener(TimerEvent.TIMER, _triggerLongTouch);
				grabbedTickTimer.stop();
			}
			
			//Same, route the interaction to the tick mark control if there is a grabbed tick
			if(!KSketch_CanvasView.isPlayer && _tickmarkControl.grabbedTick)
			{
				_tickmarkControl.end_move_markers();
				_magnifier.showTime(toTimeCode(time), timeToFrame(time),timeToX(time));
				_autoSnap(timeToX(time));
			}
			
			if(_longTouch && !moveTick)
			{
				_keyMenu.open(contentGroup,true);
				_keyMenu.x = _magnifier.x;
				_keyMenu.position = position;

				if(this.position == BAR_TOP)
					_keyMenu.y = contentGroup.localToGlobal(new Point()).y + contentGroup.y + 3;
				else
					_keyMenu.y = contentGroup.localToGlobal(new Point()).y
			}
			
			//reset boolean properties
			_magnifier.removeMagnification();
			_longTouch = false;
			moveTick = false;
			isNearTick = false;
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, _touchMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, _touchEnd);
			contentGroup.addEventListener(MouseEvent.MOUSE_DOWN, _touchDown);
			_magnifier.addEventListener(MouseEvent.MOUSE_DOWN, _touchDown);
		}
		
		private function _triggerLongTouch(event:TimerEvent):void
		{
			_longTouch = true;
			
			_showMagnifier(event);
			grabbedTickTimer.removeEventListener(TimerEvent.TIMER, _triggerLongTouch);
			grabbedTickTimer.stop();
		}
		
		public function _showMagnifier(event:TimerEvent):void
		{
			
			if(!KSketch_CanvasView.isPlayer && _tickmarkControl.grabbedTick)
			{
				var toShowTime:Number = xToTime(_tickmarkControl.grabbedTick.x);
				
				_magnifier.showTime(toTimeCode(toShowTime), timeToFrame(toShowTime),timeToX(toShowTime));
				_magnifier.magnify(_tickmarkControl.grabbedTick.x);
			}
			else
			{
				var xPos:Number = contentGroup.globalToLocal(_touchStage).x;
				var timeX:Number = timeToX(time);
				if(Math.abs(xPos - timeX) >KSketch_TickMark_Control.GRAB_THRESHOLD)
					time = xToTime(xPos);
			}
		}
		
		public function _autoSnap(xPos:Number):void
		{
			time = xToTime(xPos); //Else just change the time
			
			if(showMagnifier)
				_magnifier.magnify(timeToX(time));
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
			
			_KSketch.removeEventListener(KTimeChangedEvent.EVENT_TIME_CHANGED, _transitionHelper.updateWidget);
			_KSketch.addEventListener(KTimeChangedEvent.EVENT_TIME_CHANGED, _transitionHelper.updateMovingWidget);
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
			_KSketch.removeEventListener(KTimeChangedEvent.EVENT_TIME_CHANGED, _transitionHelper.updateMovingWidget);
			_KSketch.addEventListener(KTimeChangedEvent.EVENT_TIME_CHANGED, _transitionHelper.updateWidget);
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
			if(!_isPlaying)
				time = time + KSketch2.ANIMATION_INTERVAL;
		}
		
		/**
		 * Stops the recording event
		 */
		public function stopRecording():void
		{
			_timer.removeEventListener(TimerEvent.TIMER, recordHandler);
			_timer.stop();
			this.dispatchEvent(new Event(KSketch_TimeControl.PLAY_STOP));
		}
		
		/**
		 * Converts a time value to frame value
		 */
		public function timeToFrame(value:Number):int
		{
			return value/KSketch2.ANIMATION_INTERVAL; //int(Math.floor(value/KSketch2.ANIMATION_INTERVAL));
		}
		
		/**
		 * Converts a time value to a x position;
		 */
		public function timeToX(value:Number):Number
		{
			return timeToFrame(value)/(_maxFrame*1.0) * backgroundFill.width;
		}
		
		/**
		 * Converts x to time based on this time control
		 */
		public function xToTime(value:Number):Number
		{
			var currentFrame:int = Math.round(value/pixelPerFrame);
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