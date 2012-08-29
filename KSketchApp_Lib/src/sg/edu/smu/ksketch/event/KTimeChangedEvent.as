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