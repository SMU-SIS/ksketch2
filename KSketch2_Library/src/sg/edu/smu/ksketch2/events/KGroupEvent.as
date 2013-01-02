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
	
	public class KGroupEvent extends Event
	{
		public static const OBJECT_REMOVED:String = "Object Removed";
		public static const OBJECT_ADDED:String = "Object Added";
		
		private var _group:KGroup;
		private var _child:KObject;
		
		/**
		 * Class Denoting Events related to a KGroup
		 */
		public function KGroupEvent(type:String, targetGroup:KGroup, targetObject:KObject)
		{
			super(type);
			_group = targetGroup;
			_child = targetObject;
		}
		
		public function get group():KGroup
		{
			return _group;
		}
		
		public function get child():KObject
		{
			return _child;
		}
	}
}