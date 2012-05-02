/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.event
{
	import flash.events.Event;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;

	public class KDataSavedEvent extends Event
	{
		public static const EVENT_DATA_SAVED:String = "data saved";
		
		private var _object:Object;
		
		public function KDataSavedEvent(object:Object)
		{
			super(EVENT_DATA_SAVED);
			_object = object;
		}
		
		public function get object():Object
		{
			return _object;
		}		
	}
}