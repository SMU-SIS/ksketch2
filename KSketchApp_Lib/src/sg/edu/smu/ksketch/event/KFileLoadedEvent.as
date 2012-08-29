package sg.edu.smu.ksketch.event
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	public class KFileLoadedEvent extends Event
	{
		public static const EVENT_FILE_LOADED:String = "file loaded";
		
		private var _fileName:String;
		private var _filePath:String;
		private var _content:ByteArray;
		
		public function KFileLoadedEvent(fileName:String, filePath:String, content:ByteArray)
		{
			super(EVENT_FILE_LOADED);
			_fileName = fileName;
			_filePath = filePath;
			_content = content;
		}

		public function get fileName():String
		{
			return _fileName;
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