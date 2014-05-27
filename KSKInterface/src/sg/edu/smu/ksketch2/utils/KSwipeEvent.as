package sg.edu.smu.ksketch2.utils
{
	import flash.events.Event;
	
	public class KSwipeEvent extends Event
	{
		public static const SCROLLING_STARTED:String ="SCROLLING_STARTED"; 
		public static const SCROLLING_STOPPED:String ="SCROLLING_STOPPED";
		public static const TAP_ACTION:String ="TAP_ACTION";
		public static const DELETE_ACTION:String ="DELETE_ACTION";
		
		private var _userObj:Object;
		private var _userId:int;
		
		public function KSwipeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public function get userId():int
		{
			return _userId;
		}
		
		public function set userId(value:int):void
		{
			_userId = value;
		}
		
		public function get userObj():Object
		{
			return _userObj;
		}
		
		public function set userObj(value:Object):void
		{
			_userObj = value;
		}
		
	}
}