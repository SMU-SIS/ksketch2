/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.event
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	public class KFileLoadedEvent extends Event
	{
		public static const EVENT_FILE_LOADED:String = "file loaded";
		
		private var _filePath:String;
		private var _content:ByteArray;
		
		public function KFileLoadedEvent(filePath:String, content:ByteArray)
		{
			super(EVENT_FILE_LOADED);
			_filePath = filePath;
			_content = content;
		}

		public function get filePath():String
		{
			return _filePath;
		}

		public function get content():ByteArray
		{
			return _content;
		}


	}
}