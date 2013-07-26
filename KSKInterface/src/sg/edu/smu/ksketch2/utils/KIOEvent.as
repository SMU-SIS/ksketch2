/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.utils
{
	import flash.events.Event;
	
	/**
	 * The KIOEvent class serves as the concrete class for handling I/O
	 * operations in K-Sketch.
	 */
	public class KIOEvent extends Event
	{
		/**
		 * The ksketch save status.
		 */
		public static const EVENT_SAVE:String = "ksketch save";
		
		/**
		 * The ksketch load status.
		 */
		public static const EVENT_LOAD:String = "ksketch load";
		
		private var _saveData:XML;		// the save data
		public var closing:Boolean;		// the closing status boolean flag
		
		/**
		 * The main constructor for the KIOEvent class.
		 * 
		 * @param type The target event type.
		 * @param data The target XML data.
		 * @param isClosing The target boolean flag for determining whether the I/O event is closing.
		 */
		public function KIOEvent(type:String, data:XML = null, isClosing:Boolean = false)
		{
			_saveData = data;
			closing = isClosing
			super(type);
		}
		
		/**
		 * Gets the save data.
		 * 
		 * @return The save data.
		 */
		public function get saveData():XML
		{
			return _saveData;
		}
	}
}