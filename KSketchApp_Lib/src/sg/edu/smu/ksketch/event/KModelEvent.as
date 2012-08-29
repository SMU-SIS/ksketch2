package sg.edu.smu.ksketch.event
{
	import flash.events.Event;
	
	public class KModelEvent extends Event
	{	
		public static const EVENT_MODEL_UPDATING:String = "updating";
		public static const EVENT_MODEL_UPDATED:String = "updated";
		public static const EVENT_MODEL_UPDATE_COMPLETE:String = "completed";
		
		public function KModelEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}