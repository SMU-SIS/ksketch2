package sg.edu.smu.ksketch2.components.timebar
{
	import flash.events.MouseEvent;
	
	import sg.edu.smu.ksketch.logger.KLogger;
	import sg.edu.smu.ksketch.utilities.KAppState;
	import sg.edu.smu.ksketch2.components.skins.TimeSliderSkin;
	
	import spark.components.HSlider;
	
	public class TimeSlider extends HSlider
	{
		private var _timeList:Vector.<Number>;
		private var _appState:KAppState;
		private var _skinDrawn:Boolean;
		
		public function TimeSlider()
		{
				super();
				_skinDrawn = false;
		}
		
		public function init(appState:KAppState):void
		{
			_appState = appState;
			_timeList = new Vector.<Number>();
		}
		
		override public function set maximum(value:Number):void
		{
			if(super.maximum == value && _skinDrawn)
				return;
			
			super.maximum = value;
			
			if(skin)
				(skin as TimeSliderSkin).drawTrackScale();
		}
		
		/**
		 * timeList defines the times that the slider can jump to when tapped on.
		 */
		public function set timeList(timeList:Vector.<Number>):void
		{
			_timeList = timeList;
		}
		
		protected override function track_mouseDownHandler(event:MouseEvent):void
		{
			var currentTime:Number = _appState.time;
			var clickTime:Number = (event.localX / width) * _appState.maxTime;
			
			var currentIndex:int = 0;
			
			for(var i:int = 0; i < _timeList.length; i++)
			{
				currentIndex = i;
				
				if(currentTime <= _timeList[i])
					break;
			}
			
			var toTime:Number = 0;
			
			if(clickTime < currentTime)
			{
				currentIndex -= 1;
				
				if(currentIndex < 0)
					toTime = 0;
				else
					toTime = _timeList[currentIndex];
			}
			else
			{
				if(currentIndex < _timeList.length)
				{
					var checkTime:Number = _timeList[currentIndex];
					if(checkTime == _appState.time)
					{
						while(checkTime == _appState.time)
						{
							currentIndex += 1;
						
							if(currentIndex < _timeList.length)
								checkTime = _timeList[currentIndex];
							else
								break;
						}
					}
						
					toTime = checkTime;
				}
				else
					toTime = _appState.time;
			}
			_appState.time = toTime;
			
			KLogger.log(KLogger.CHANGE_TIME, KLogger.CHANGE_TIME_ACTION, KLogger.CHANGE_TIME_TAP,
				KLogger.TIME_FROM, currentTime, KLogger.TIME_TO, toTime);

			KLogger.logGutterTab(currentTime,toTime);
		}
	}
}