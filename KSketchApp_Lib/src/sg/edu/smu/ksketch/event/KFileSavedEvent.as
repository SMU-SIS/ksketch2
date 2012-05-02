/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

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