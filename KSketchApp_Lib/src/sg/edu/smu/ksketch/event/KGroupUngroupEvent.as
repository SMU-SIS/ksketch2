/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.event
{
	import flash.events.Event;
	
	import sg.edu.smu.ksketch.model.KGroup;
	
	public class KGroupUngroupEvent extends Event
	{
		public static const EVENT_GROUP:String = "group";
		public static const EVENT_UNGROUP:String = "ungroup";
		
		private var _group:KGroup;
		
		public function KGroupUngroupEvent(group:KGroup, type:String, 
										   bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_group = group;
		}

		public function get group():KGroup
		{
			return _group;
		}

	}
}