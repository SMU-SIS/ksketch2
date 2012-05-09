/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.playsketch.components.timebar
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import sg.edu.smu.ksketch.utilities.KAppState;
	
	import spark.components.HSlider;
	
	public class TimeSlider extends HSlider
	{
		private var _timeList:Vector.<Number>;
		private var _appState:KAppState;
		
		public function TimeSlider()
		{
			super();
		}
		
		public function init(appState:KAppState):void
		{
			_appState = appState;
			_timeList = new Vector.<Number>();
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
		}
	}
}