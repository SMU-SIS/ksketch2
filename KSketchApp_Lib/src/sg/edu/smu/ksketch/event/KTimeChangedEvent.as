/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.event
{
	import flash.events.Event;
	
	public class KTimeChangedEvent extends Event
	{
		public static const TIME_CHANGED:String = "TIME_CHANGED";
		
		private var _oldTime:Number;
		private var _newTime:Number;
		
		public function KTimeChangedEvent(oldTime:Number, newTime:Number)
		{
			super(TIME_CHANGED);
			
			_oldTime = oldTime;
			_newTime = newTime;
		}

		public function get newTime():int
		{
			return _newTime;
		}

		public function get oldTime():int
		{
			return _oldTime;
		}

	}
}