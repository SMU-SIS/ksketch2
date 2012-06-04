/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.event
{
	import flash.events.Event;
	
	import sg.edu.smu.ksketch.model.KObject;

	public class KObjectEvent extends Event
	{
		public static const EVENT_OBJECT_ADDED:String = "added";
		public static const EVENT_OBJECT_REMOVED:String = "removed";
		public static const EVENT_COLOR_CHANGED:String = "color changed";
		public static const EVENT_POINTS_CHANGED:String = "points changed";
		public static const EVENT_TRANSFORM_CHANGED:String = "transform changed";
		public static const EVENT_VISIBILITY_CHANGED:String = "visibility changed";
		public static const EVENT_PARENT_CHANGED:String = "parent changed";
		public static const EVENT_OBJECT_CENTER_CHANGED:String = "center changed";
		
		private var _object:KObject;
		
		public function KObjectEvent(object:KObject, type:String, 
									 bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_object = object;
		}

		public function get object():KObject
		{
			return _object;
		}

	}
}