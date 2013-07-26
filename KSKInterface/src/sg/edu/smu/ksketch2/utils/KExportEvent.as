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
	import flash.display.BitmapData;
	import flash.events.Event;
	
	/**
	 * The KExportEvent class serves as the concrete class for handling
	 * export events in K-Sketch.
	 */
	public class KExportEvent extends Event
	{
		/**
		 * The export event status.
		 */
		public static const EVENT_EXPORT:String = "export save";
		
		/**
		 * The export data.
		 */
		public var data:Vector.<BitmapData>;
		
		/**
		 * The main constructor for the KExportEvent class.
		 * 
		 * @param type The event type.
		 * @param exportData The export data.
		 */
		public function KExportEvent(type:String, exportData:Vector.<BitmapData>)
		{
			super(type);
			
			data = exportData;
		}
	}
}