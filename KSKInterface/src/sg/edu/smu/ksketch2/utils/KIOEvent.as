/**
 * Copyright 2010-2015 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.utils
{
	import flash.events.Event;
	
	public class KIOEvent extends Event
	{
		public static const EVENT_SAVE:String = "ksketch save";
		public static const EVENT_LOAD:String = "ksketch load";
		
		public var _saveData:XML;
		public var closing:Boolean;
		
		public function KIOEvent(type:String, data:XML = null, isClosing:Boolean = false)
		{
			_saveData = data;
			closing = isClosing
			super(type);
		}
		
		public function get saveData():XML
		{
			return _saveData;
		}
	}
}