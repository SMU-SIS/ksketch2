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
		private var _command:String;
		
		public function KCommandEvent(command:String)
		{
			super(command);
			_command = command;
		}
		
		public function get command():String
		{
			return _command;
		}
	}
}