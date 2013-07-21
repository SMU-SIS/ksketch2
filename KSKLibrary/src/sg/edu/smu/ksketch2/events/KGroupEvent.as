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
	
	/**
	 * The KGroupEvent class serves as the concrete class for denoting
	 * events to a KGroup in K-Sketch.
	 */
	public class KGroupEvent extends Event
	{
		public static const OBJECT_REMOVED:String = "Object Removed";
		public static const OBJECT_ADDED:String = "Object Added";
		
		private var _group:KGroup;
		private var _child:KObject;
		
		/**
		 * The main constructor for the KGroupEvent class.
		 * 
		 * @param type The event type.
		 * @param targetGroup The target group.
		 * @param targetObject The target object.
		 */
		public function KGroupEvent(type:String, targetGroup:KGroup, targetObject:KObject)
		{
			super(type);
			_group = targetGroup;
			_child = targetObject;
		}
		
		/**
		 * Gets the group of objects.
		 * 
		 * @return The group of objects.
		 */
		public function get group():KGroup
		{
			return _group;
		}
		
		/**
		 * Gets the child object.
		 * 
		 * @return The child object.
		 */
		public function get child():KObject
		{
			return _child;
		}
	}
}