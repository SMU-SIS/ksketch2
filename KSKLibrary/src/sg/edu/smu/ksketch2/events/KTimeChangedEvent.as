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
	
	/**
	 * The KTimeChangedEvent serves as the concrete class for signifying
	 * time changes in K-Sketch. Note that the model/scene graph is not
	 * modified in this class.
	 */
	public class KTimeChangedEvent extends Event
	{
		/**
		 * The changed time event.
		 */
		public static const EVENT_TIME_CHANGED:String = "Time changed";
		
		/**
		 * The changed max time event.
		 */
		public static const EVENT_MAX_TIME_CHANGED:String = "Max time changed"
			
		private var _from:int;	// the starting time
		private var _to:int;	// the ending time
		
		/**
		 * The main constructor of the KTimeChangedEvent class.
		 * 
		 * @param type The event type.
		 * @param fromTime The starting time.
		 * @param toTime The ending time.
		 */
		public function KTimeChangedEvent(type:String, fromTime:int, toTime:int)
		{
			super(type, bubbles, cancelable);
			
			_from = fromTime;
			_to = toTime;
		}
		
		/**
		 * Gets the starting time.
		 * 
		 * @return The starting time.
		 */
		public function get from():int
		{
			return _from;
		}
		
		/**
		 * Gets the ending time.
		 * 
		 * @return The ending time.
		 */
		public function get to():int
		{
			return _to;
		}
	}
}