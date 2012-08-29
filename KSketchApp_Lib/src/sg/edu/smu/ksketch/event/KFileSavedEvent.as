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
	
	public class KFileSavedEvent extends Event
	{
		public static const EVENT_FILE_SAVED:String = "file saved";
		
		private var _filePath:String;
		
		public function KFileSavedEvent(filePath:String)
		{
			super(EVENT_FILE_SAVED);
			_filePath = filePath;
		}

		public function get filePath():String
		{
			return _filePath;
		}

	}
}