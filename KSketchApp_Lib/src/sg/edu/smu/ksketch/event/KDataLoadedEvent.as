package sg.edu.smu.ksketch.event
{
	import flash.events.Event;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;
	public class KDataLoadedEvent extends Event
	{
		public static const EVENT_DATA_LOADED:String = "data loaded";
		
		private var _object:Object;
		private var _data:Object;
		
		public function KDataLoadedEvent(object:Object, data:Object)
		{
			super(EVENT_DATA_LOADED);
			_object = object;
			_data = data;
		}

		public function get object():Object
		{
			return _object;
		}

		public function get data():Object
		{
			return _data;
		}
	}
}