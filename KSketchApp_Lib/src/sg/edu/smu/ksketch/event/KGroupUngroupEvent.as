/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

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