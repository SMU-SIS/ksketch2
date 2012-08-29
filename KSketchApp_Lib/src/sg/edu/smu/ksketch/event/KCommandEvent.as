/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

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