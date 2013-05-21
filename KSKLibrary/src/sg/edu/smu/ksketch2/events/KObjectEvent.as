/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.events
{
	import flash.events.Event;
	
	import sg.edu.smu.ksketch2.model.objects.KGroup;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	
	public class KObjectEvent extends Event
	{
		public static const OBJECT_TRANSFORM_FINALISED:String = "Transform Finalised"
		public static const OBJECT_TRANSFORM_CHANGED:String = "Transform Changed";
		public static const OBJECT_SELECTION_CHANGED:String = "Selection Changed";
		public static const OBJECT_VISIBILITY_CHANGED:String = "Visibility Changed";
		public static const OBJECT_TRANSFORM_BEGIN:String = "Transform Begin";
		public static const OBJECT_TRANSFORM_UPDATING:String = "Transform Updating";
		public static const OBJECT_TRANSFORM_ENDED:String = "Transform Ended";
		
		private var _targetObject:KObject;
		private var _parent:KGroup;
		private var _time:int;
		
		public function KObjectEvent(type:String, targetObject:KObject, eventTime:int)
		{
			super(type);
			_targetObject = targetObject;
			_parent = parent;
			_time = eventTime;
		}
		
		public function get object():KObject
		{
			return _targetObject;
		}
		
		public function get parent():KGroup
		{
			return _parent;
		}
		
		public function get time():int
		{
			return _time;
		}
	}
}