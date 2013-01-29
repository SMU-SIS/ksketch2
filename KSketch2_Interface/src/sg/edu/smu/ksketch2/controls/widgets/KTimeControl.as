/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.controls.widgets
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.controls.skins.TimeSliderSkin;
	import sg.edu.smu.ksketch2.events.KSketchEvent;
	import sg.edu.smu.ksketch2.events.KTimeChangedEvent;
	
	import spark.components.HSlider;

	public class KTimeControl extends HSlider implements ITimeControl
	{
		public static const PLAY_START:String = "Start Playing";
		public static const PLAY_STOP:String = "Stop Playing";
		public static const RECORD_START:String = "Start Recording";
		public static const RECORD_STOP:String = "Stop Recording";
	
		public static const DEFAULT_MAX_TIME:int = 5000;
		public static const TIME_EXTENSION:int = 5000;
		public static var recordingSpeed:Number = 1; //factor of KSketch.animation interval.
		
		public var timeList:Vector.<int>;
		private var _maxPlayTime:int;
		private var _KSketch:KSketch2;
		private var _skinDrawn:Boolean;
		public var isRecording:Boolean;
		public var pixelPerFrame:Number = 0;

		//Variables for playing, recording etc
		private var _timer:Timer;
		private var _startFrame:int;

		public function KTimeControl()
		{
			super();
			_skinDrawn = false;
			isRecording = false;
			_timer = new Timer(KSketch2.ANIMATION_INTERVAL);
		}
		
		public function init(KSketchInstance:KSketch2):void
		{
			_KSketch = KSketchInstance;
			maxTime = DEFAULT_MAX_TIME;
			time = 0;
			_maxPlayTime = DEFAULT_MAX_TIME;
			addEventListener(Event.CHANGE, _handler_sliderChanged);
		}
		
		override protected function system_mouseWheelHandler(event:MouseEvent):void
		{
			event.delta = -event.delta;
			
			super.system_mouseWheelHandler(event);
		}
		
		public function get defaultMaximum():int
		{
			return (DEFAULT_MAX_TIME/KSketch2.ANIMATION_INTERVAL);
		}
		
		public function get time():int
		{
			return _KSketch.time;
		}
		
		public function set time(newTime:int):void
		{
			if(newTime < 0)
				newTime = 0;
			
			value = newTime/KSketch2.ANIMATION_INTERVAL;
			_KSketch.time = value*KSketch2.ANIMATION_INTERVAL; 
		}
		
		public function get maxTime():int
		{
			return maximum * KSketch2.ANIMATION_INTERVAL;
		}
		
		public function set maxTime(value:int):void
		{
			maximum = value/KSketch2.ANIMATION_INTERVAL;
			
			if(skin is TimeSliderSkin)
				(skin as TimeSliderSkin).drawTrackScale();

			dispatchEvent(new Event(KTimeChangedEvent.EVENT_MAX_TIME_CHANGED));
		}
		
		override public function set maximum(value:Number):void
		{
			if(super.maximum == value)
				return;
			
			super.maximum = value;
			maxTime = maxTime;
			
			
			if(skin)
			{
				pixelPerFrame = Math.floor((width - (thumb.width/2))/maximum*20)/20;
				if(skin is TimeSliderSkin)
					(skin as TimeSliderSkin).drawTrackScale();
			}
		}
		
		override protected function track_mouseDownHandler(event:MouseEvent):void
		{
			if(!timeList || timeList.length < 2)
			{
				super.track_mouseDownHandler(event);
				return;
			}
			
			var currentTime:Number = _KSketch.time;
			var clickTime:int = pointToValue(event.localX, event.localY) * KSketch2.ANIMATION_INTERVAL;
			
			var currentIndex:int = 0;
			
			for(var i:int = 0; i < timeList.length; i++)
			{
				currentIndex = i;
				
				if(currentTime <= timeList[i])
					break;
			}
			
			var toTime:Number = 0;
			
			if(clickTime < currentTime)
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
		
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w,h);
			pixelPerFrame = Math.floor((width - (thumb.width/2))/maximum*20)/20;
		}
		
		public function getNearestFrameValue(rawFrameNumber:Number):Number
		{
			return nearestValidValue(rawFrameNumber, snapInterval);
		}
		
		public function updateMaxTime(currentMaxModelTime:int):void
		{
			var currentMax:int = maxTime;
			var expectedNewLowerMaxTime:int = currentMax - TIME_EXTENSION;
			
			if(expectedNewLowerMaxTime < DEFAULT_MAX_TIME)
				expectedNewLowerMaxTime = DEFAULT_MAX_TIME;
			
			var expectedNewHigherMaxTime:int = currentMax + TIME_EXTENSION;

			if(currentMaxModelTime < (0.8* currentMax))
			{
				if(currentMaxModelTime < (expectedNewLowerMaxTime*0.8))
					maxTime = expectedNewLowerMaxTime;
			}
			else
					maxTime = expectedNewHigherMaxTime;	
			
			_maxPlayTime = currentMaxModelTime + 1000;
			_maxPlayTime  = (_maxPlayTime < maxTime) ? _maxPlayTime:maxTime;
		}
		
		public function nearestSnappedXValue(rawXValue:Number):Number
		{
			var operator:Number;
			if(rawXValue < 0)
			{
				operator = -1;
				rawXValue *= operator;
			}
			else
				operator = 1;
			
			return operator*getNearestFrameValue(rawXValue/pixelPerFrame)*pixelPerFrame;
		}

		public function positionToTime(position:Number):int
		{
			if(position <= width)
				return getNearestFrameValue(position/pixelPerFrame)*KSketch2.ANIMATION_INTERVAL;
			else
				return Math.ceil(position/pixelPerFrame)*KSketch2.ANIMATION_INTERVAL;
			}
		
		public function timeToPosition(queryTime:int):Number
		{
			return Math.floor((queryTime/KSketch2.ANIMATION_INTERVAL)*pixelPerFrame);
		}

		private function _handler_sliderChanged(event:Event):void
		{
			time = value*KSketch2.ANIMATION_INTERVAL;
		}
		
		public function startPlaying():void
		{
			_timer.delay = KSketch2.ANIMATION_INTERVAL;
			_timer.addEventListener(TimerEvent.TIMER, playHandler);
			startTimer();
			this.dispatchEvent(new Event(PLAY_START));
		}

		private function playHandler(event:TimerEvent):void 
		{
			var now_Frame:int = value + 1;

			if(time >= _maxPlayTime)
			{
				time = _maxPlayTime;
				stopPlaying();
			}
			else
				time = now_Frame*KSketch2.ANIMATION_INTERVAL;
		}
		
		public function pause():void
		{
			_timer.removeEventListener(TimerEvent.TIMER, playHandler);
			stopTimer();
			this.dispatchEvent(new Event(PLAY_STOP));
		}
		
		public function stopPlaying():void
		{
			_timer.removeEventListener(TimerEvent.TIMER, playHandler);
			stopTimer();
			this.dispatchEvent(new Event(PLAY_STOP));
		}
		
		public function startRecording():void
		{
			if(recordingSpeed <= 0)
				throw new Error("One does not record in 0 or negative time!");
			
			_timer.delay = KSketch2.ANIMATION_INTERVAL/recordingSpeed;
			_timer.addEventListener(TimerEvent.TIMER, recordHandler);
			startTimer();
			isRecording = true;
			this.dispatchEvent(new Event(RECORD_START));
		}
		
		private function recordHandler(event:TimerEvent):void 
		{
			var now_Frame:int = value + 1;
			while(now_Frame > maximum)
				maximum = maximum + TIME_EXTENSION/KSketch2.ANIMATION_INTERVAL;
			time = now_Frame*(KSketch2.ANIMATION_INTERVAL);
		}
		
		public function stopRecording():void
		{
			if(!isRecording)
				return;
			
			_timer.removeEventListener(TimerEvent.TIMER, recordHandler);
			stopTimer();
			isRecording = false;
			this.dispatchEvent(new Event(RECORD_STOP));
		}
		
		private function startTimer():void
		{
			_startFrame = value;
			_timer.start();
		}
		
		private function stopTimer():void
		{
			_timer.stop();
		}
	}
}