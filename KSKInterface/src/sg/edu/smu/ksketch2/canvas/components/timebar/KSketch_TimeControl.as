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
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import mx.events.FlexEvent;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.canvas.components.popup.KSketch_Timebar_Context_Double;
	import sg.edu.smu.ksketch2.canvas.components.popup.KSketch_Timebar_Context_Single;
	import sg.edu.smu.ksketch2.canvas.components.popup.KSketch_Timebar_Magnifier;
	import sg.edu.smu.ksketch2.canvas.components.view.KSketch_CanvasView;
	import sg.edu.smu.ksketch2.canvas.controls.interactors.widgetstates.KWidgetInteractorManager;
	import sg.edu.smu.ksketch2.events.KTimeChangedEvent;
	
	public class KSketch_TimeControl extends KSketch_TimeSlider implements ITimeControl
	{
		public static const PLAY_START:String = "Start Playing";
		public static const PLAY_STOP:String = "Stop Playing";
		public static const EVENT_POSITION_CHANGED:String = "position changed";

		public static const SNAP_DOWN:int = 20;
		public static const SNAP_MOVE:int = 20;
		
		public static const BAR_TOP:int = 0;
		public static const BAR_BOTTOM:int = 1;
		
		public static const DEFAULT_MAX_TIME:Number = 5000;
		public static const PLAY_ALLOWANCE:int = 2000;
		public static const MAX_ALLOWED_TIME:Number = 600000; //Max allowed time of 10 mins
		
		private const CLICK_TIME:int = 300;
		private const DOUBLE_CLICK_SPEED:int = 300;
		
		protected var _KSketch:KSketch2;
		protected var _tickmarkControl:KSketch_TickMark_Control;
		protected var _transitionHelper:KWidgetInteractorManager;
		protected var _magnifier:KSketch_Timebar_Magnifier;
		protected var _contextDouble:KSketch_Timebar_Context_Double;
		protected var _contextSingle:KSketch_Timebar_Context_Single;
		
		public static var isPlaying:Boolean = false;
		public var timings:Vector.<Number>;
		
		protected var _timer:Timer;
		protected var _maxPlayTime:Number;
		protected var _rewindToTime:Number;
		private var _recordingSpeed:Number = 1;
		private var _position:int;
		
		private var _maxFrame:int;
		private var _currentFrame:int;
		private var _touchStage:Point = new Point(0,0);
		private var _substantialMovement:Boolean = false;
		
		private var _grabbedTickIndex:int;
		private var _nearTick: Number;
		private var _isNearTick: Boolean = false;
		private var _showMagnifier:Boolean = false;
		
		private var mouseTimeout = "undefined";
		private var clickTimer:int;
		private var _action:String = "";
		
		public function KSketch_TimeControl()
		{
			super();
		}
		
		public function init(KSketchInstance:KSketch2, tickmarkControl:KSketch_TickMark_Control,
							 transitionHelper:KWidgetInteractorManager, magnifier:KSketch_Timebar_Magnifier, 
							 contextDouble:KSketch_Timebar_Context_Double, contextSingle:KSketch_Timebar_Context_Single):void
		{
			_KSketch = KSketchInstance;
			_tickmarkControl = tickmarkControl;
			_transitionHelper = transitionHelper;
			_magnifier = magnifier;
			_contextDouble = contextDouble;
			_contextSingle = contextSingle;
			timeLabels.init(this);
			
			_timer = new Timer(KSketch2.ANIMATION_INTERVAL);
			
			contentGroup.addEventListener(MouseEvent.MOUSE_DOWN, _mouseDownListener);
			_magnifier.addEventListener(MouseEvent.MOUSE_DOWN, _mouseDownListener);
			
			maximum = KSketch_TimeControl.DEFAULT_MAX_TIME;
			time = 0;

			_position = BAR_TOP;
			dispatchEvent(new Event(EVENT_POSITION_CHANGED));
		}
		
		/**
		 * On touch function. Time slider interactions begins here
		 * Determines whether to use the tick mark control or to just itneract with the slider
		 */
		private function _mouseDownListener(event:MouseEvent):void 
		{
			if(isPlaying)
				stop();
			
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
				var roundXPos:Number = roundToNearestTenth(xPos);
				for(i=0; i<_tickmarkControl._ticks.length; i++)
				{
					if(roundXPos == _tickmarkControl._ticks[i].x)
					{
						xPosIsTick = true;
						_nearTick = roundXPos;
						break;
					}
				}
				
				//implement autosnapping if xpos is not yet a tick
				if(!xPosIsTick)
				{
					for(i=0; i<_tickmarkControl._ticks.length; i++)
					{
						var tempTick:Number = _tickmarkControl._ticks[i].x;
						if(Math.round(xPos) >= (Math.round(tempTick) - SNAP_DOWN) && Math.round(xPos) <= (Math.round(tempTick) + SNAP_DOWN))
						{
							xPosIsTick = true;
							_nearTick = tempTick;
							break;
						}
					}	
				}
			}
			
			//check if slider is on top if xPosIsTick is true
			if(xPosIsTick)
			{
				_autoSnap(_nearTick);
				_nearTick = 0;
			}
			else
				_autoSnap(xPos);
			
			contentGroup.removeEventListener(MouseEvent.MOUSE_DOWN, _mouseDownListener);
			_magnifier.removeEventListener(MouseEvent.MOUSE_DOWN, _mouseDownListener);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, _mouseMoveListener);
			stage.addEventListener(MouseEvent.MOUSE_UP, _mouseUpListener);
			
			clickTimer = getTimer();
		}
		
		/**
		 * Update time control interaction
		 */
		private function _mouseMoveListener(event:MouseEvent):void 
		{
			_action = "Move time slider on Time Bar";
			
			//Only consider a move if a significant dx has been covered
			if(Math.abs(event.stageX - _touchStage.x) < (pixelPerFrame*0.5))
				return;
			
			_touchStage.x = event.stageX;
			_touchStage.y = event.stageY;
			_substantialMovement = true;
			
			var xPos:Number = contentGroup.globalToLocal(_touchStage).x;
			var i:int;
			
			if(_tickmarkControl._ticks)
			{
				for(i=0; i<_tickmarkControl._ticks.length; i++)
				{
					_nearTick = _tickmarkControl._ticks[i].x;
					if(Math.floor(xPos) >= (Math.round(_nearTick) - SNAP_MOVE) && Math.floor(xPos) <= (Math.round(_nearTick) + SNAP_MOVE))
					{
						_isNearTick = true;
						break;
					}
					else
						_isNearTick = false;
				}
			}
			
			if(_isNearTick)
			{
				_autoSnap(_nearTick);
				_isNearTick = false;
				_nearTick = 0;
			}
			else
				_autoSnap(xPos);
		}
		
		/**
		 * End of time control interaction
		 */
		private function _mouseUpListener(event:MouseEvent):void 
		{
			//Google analytics
			if(_action == "Move time slider on Time Bar")
				KSketch_CanvasView.tracker.trackPageview( "/timebar/moveTime" );
			
			// if this is a single or double tap
			if(getTimer() - clickTimer < CLICK_TIME)
			{
				if (mouseTimeout != "undefined") //if this is a double tap
				{
					_action = "Open time bar context menu (double tap)";
					_contextDouble.open(contentGroup,true);
					_contextDouble.x = _magnifier.x;
					_contextDouble.position = position;
					_contextDouble.y = contentGroup.localToGlobal(new Point()).y + contentGroup.y + 3;
						
					clearTimeout(mouseTimeout);
					mouseTimeout = "undefined";
				} 
				else	//if this is a single tap
				{
					function handleSingleClick():void 
					{
						_action = "Open time bar menu (single tap)";
						_magnifier.magnify(timeToX(time));
						_contextSingle.open(contentGroup,true);
						_contextSingle.x = _magnifier.x;
						_contextSingle.y = contentGroup.localToGlobal(new Point()).y + contentGroup.y - 80;
						
						mouseTimeout = "undefined";
					}
					mouseTimeout = "undefined";
					mouseTimeout = setTimeout(handleSingleClick, DOUBLE_CLICK_SPEED);
				}
			} 
			else // if no other click occurs before timeout, execute single click function
			{
				_action = "Open time bar menu (single tap)";
				_magnifier.magnify(timeToX(time));
				_contextSingle.open(contentGroup,true);
				_contextSingle.x = _magnifier.x;
				_contextSingle.y = contentGroup.localToGlobal(new Point()).y + contentGroup.y - 80;
			}
			
			//reset boolean properties
			_grabbedTickIndex = null;
			_isNearTick = false;
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, _mouseMoveListener);
			stage.removeEventListener(MouseEvent.MOUSE_UP, _mouseUpListener);
			contentGroup.addEventListener(MouseEvent.MOUSE_DOWN, _mouseDownListener);
			_magnifier.addEventListener(MouseEvent.MOUSE_DOWN, _mouseDownListener);
			
			//LOG
			_KSketch.logCounter ++;
			var log:XML = <Action/>;
			var date:Date = new Date();
			log.@category = "Time Bar Control";
			log.@type = _action;
			//trace("ACTION " + _KSketch.logCounter + ": " + action);
			KSketch2.log.appendChild(log);
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
			
			_magnifier.dispatchEvent(new FlexEvent(FlexEvent.UPDATE_COMPLETE));
		}
		
		/**
		 * Maximum time value for this application in milliseconds
		 */
		public function set maximum(value:Number):void
		{
			var newVal:int = Math.ceil(value/1000) * 1000;
			_maxFrame = newVal/KSketch2.ANIMATION_INTERVAL;
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
		 * Current time value for this application in second
		 */
		public function get time():Number
		{
			return _KSketch.time
		}
		
		public function get currentFrame():int
		{
			return _currentFrame;
		}
		
		public function moveTickMark(previous:Boolean):void
		{
			var xPos:Number = timeToX(time);
			
			if(previous)
				_tickmarkControl.moveLeft = true;
			else
				_tickmarkControl.moveLeft = false;
			
			isATick(xPos);
			
			//Rout interaction into the tick mark control if there is a grabbed tick
			if(_tickmarkControl.grabbedTick)
			{
				var oldXPos:Number;
				
				if(previous)
					time -= KSketch2.ANIMATION_INTERVAL;
				else
					time += KSketch2.ANIMATION_INTERVAL;
				xPos = roundToNearestTenth(timeToX(time));
				_tickmarkControl.move_markers(xPos);
				
				//If tickmark moves to the left and causes stacking of previous keyframes
				if(previous)
				{
					var length:int = _tickmarkControl._ticks.length;
					for(var i:int=0; i<length; i++)
					{
						//get hold of the grabbed tick mark index first
						if(!_grabbedTickIndex)
						{
							if(_tickmarkControl.grabbedTick.x == _tickmarkControl._ticks[i].x)
								_grabbedTickIndex = i;
						}
						
						if(_grabbedTickIndex)
						{
							//to prevent grabbing of near tick marks when stacking occurs, 
							//reposition xPos to the initial grabbed tick mark's x pos 
							if(i != _grabbedTickIndex)
							{
								if(xPos == _tickmarkControl._ticks[i].x)
									xPos = _tickmarkControl._ticks[_grabbedTickIndex].x;
							}
							else
								oldXPos = _tickmarkControl._ticks[i].x;
						}
					}
				}
			}
		}
		
		public function isATick(xPos:Number):Boolean
		{
			var xPosIsTick:Boolean = false;
			if(_tickmarkControl._ticks)
			{
				var i:int;
				var roundXPos:Number = roundToNearestTenth(xPos);
				for(i=0; i<_tickmarkControl._ticks.length; i++)
				{
					if(roundXPos == _tickmarkControl._ticks[i].x)
					{
						xPosIsTick = true;
						_tickmarkControl.grabTick(roundXPos);
						break;
					}
				}
			}
			return xPosIsTick;
		}
		
		public function _autoSnap(xPos:Number):void
		{
			time = xToTime(xPos); //Else just change the time
			
			if(_showMagnifier)
				_magnifier.magnify(timeToX(time));
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
		 * Advances the time during recording
		 * Extends the time if max is reached
		 */
		private function _recordHandler(event:TimerEvent):void 
		{
			if(!isPlaying)
				time = time + KSketch2.ANIMATION_INTERVAL;
		}
		
		/**
		 * Enters the playing state machien
		 */
		public function play(playFromStart:Boolean):void
		{
			isPlaying = true;
			_timer.delay = KSketch2.ANIMATION_INTERVAL;
			_timer.addEventListener(TimerEvent.TIMER, playHandler);
			_timer.start();
			
			//comment out for player - play from start #50
			if(playFromStart)
				time = 0;
			else
				time = _KSketch.time;
			
			//comment out for editor - play from start #50
			//time = 0;
			
			_maxPlayTime = _KSketch.maxTime + PLAY_ALLOWANCE;
			
			_rewindToTime = time;
			this.dispatchEvent(new Event(KSketch_TimeControl.PLAY_START));
			
			_KSketch.removeEventListener(KTimeChangedEvent.EVENT_TIME_CHANGED, _transitionHelper.updateWidget);
			_KSketch.addEventListener(KTimeChangedEvent.EVENT_TIME_CHANGED, _transitionHelper.updateMovingWidget);
		}
		
		/**
		 * Stops playing and remove listener from the timer
		 */
		public function stop():void
		{
			_timer.removeEventListener(TimerEvent.TIMER, playHandler);
			_timer.stop();
			isPlaying = false;
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
			KSketch_CanvasView.tracker.trackPageview( "/timebar/recording" );
			if(_recordingSpeed <= 0)
				throw new Error("One does not record in 0 or negative time!");
			
			//The bigger the recording speed, the faster the recording
			_timer.delay = KSketch2.ANIMATION_INTERVAL * _recordingSpeed;
			_timer.addEventListener(TimerEvent.TIMER, _recordHandler);
			_timer.start();
		}
		
		/**
		 * Stops the recording event
		 */
		public function stopRecording():void
		{
			_timer.removeEventListener(TimerEvent.TIMER, _recordHandler);
			_timer.stop();
			this.dispatchEvent(new Event(KSketch_TimeControl.PLAY_STOP));
		}
		
		/**
		 * Converts a time value to frame value
		 */
		public function timeToFrame(value:Number):int
		{
			return int(value/KSketch2.ANIMATION_INTERVAL);
		}
		
		/**
		 * Converts a time value to a x position;
		 */
		public function timeToX(value:Number):Number
		{
			var xPos: Number = timeToFrame(value)/(_maxFrame*1.0) * backgroundFill.width;
			xPos = roundToNearestTenth(xPos);
			return xPos;
		}
		
		/**
		 * Converts x to time based on this time control
		 */
		public function xToTime(value:Number):Number
		{
			var currentFrame:int = Math.ceil(value/pixelPerFrame);
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
		
		public static function roundToNearestTenth(value:Number):int
		{
			var newValue:int = Math.floor(value/10) * 10;
			return newValue;
		}
	}
}