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
	
	public class KTimeChangedEvent extends Event
	{
		public static const EVENT_TIME_CHANGED:String = "Time changed";
		public static const EVENT_MAX_TIME_CHANGED:String = "Max time changed"
		private var _from:int;
		private var _to:int;
		
		/**
		 * Event signifying time changed, but the model/scene graph is not modified
		 */
		public function KTimeChangedEvent(type:String, fromTime:int, toTime:int)
		{
			super(type, bubbles, cancelable);
			
			_from = fromTime;
			_to = toTime;
		}
		
		public function get from():int
		{
			return _from;
		}
		
		public function get to():int
		{
			return _to;
		}
	}
}