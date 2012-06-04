/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.event
{
	import flash.events.Event;
	
	public class KCommandEvent extends Event
	{		
		public static const EVENT_PEN_CHANGE:String = "pen_change";
		public static const EVENT_TIMEBAR_CHANGED:String = "timebar_change";
		
		private var _command:String;
		
		public function KCommandEvent(type:String,command:String)
		{
			super(type);
			_command = command;
		}
		
		public function get command():String
		{
			return _command;
		}
	}
}