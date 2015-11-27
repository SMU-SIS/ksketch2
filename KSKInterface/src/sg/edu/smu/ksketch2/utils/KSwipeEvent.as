/**
 * Copyright 2010-2015 Singapore Management University
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.utils
{
	import flash.events.Event;
	
	public class KSwipeEvent extends Event
	{
		public static const TAP_ACTION:String ="TAP_ACTION";
		public static const DELETE_ACTION:String ="DELETE_ACTION";
		public static const LOG_ACTION:String = "LOG_ACTION";
		public static const SAVE_ACTION:String = "SAVE_ACTION";
		public static const SAVE_CLOSE_ACTION:String = "SAVE_CLOSE_ACTION";
		
		private var _userObj:Object;
		private var _userId:int;
		
		public function KSwipeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}