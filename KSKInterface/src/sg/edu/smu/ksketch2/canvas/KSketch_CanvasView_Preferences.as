/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.canvas
{
	import flash.net.SharedObject;

	/**
	 * The KSketch_CanvasView_Preferences serves as the concrete class for handling
	 * canvas view preferences in K-Sketch.
	 */
	public class KSketch_CanvasView_Preferences
	{
		/**
		 * Shared object ID status.
		 */
		public static const SHARED_OBJECT_ID:String = "KSketch_Pref";
		
		/**
		 * Left position status.
		 */
		public static const POS_LEFT:String = "LEFT";
		
		/**
		 * Right position status.
		 */
		public static const POS_RIGHT:String = "RIGHT";
		
		/**
		 * Top position status.
		 */
		public static const POS_TOP:String = "TOP";
		
		/**
		 * Bottom position status.
		 */
		public static const POS_BOTTOM:String = "BOTTOM";
		
		/**
		 * Open status.
		 */
		public static const OPEN:String = "OPEN";
		
		/**
		 * Close status.
		 */
		public static const CLOSE:String = "CLOSE";
		
		/**
		 * Auto status.
		 */
		public static const AUTO:String = "AUTO";
		
		/**
		 * Non-auto status.
		 */
		public static const NOT_AUTO:String = "NOT AUTO";
		
		/**
		 * Gets the shared object.
		 * 
		 * @return The shared object.
		 */
		public static function getSharedObject():SharedObject
		{
			var prefs:SharedObject = SharedObject.getLocal(SHARED_OBJECT_ID);
			return prefs;			
		}
		
		/**
		 * Gets the time bar position.
		 * 
		 * @return The time bar position
		 */
		public static function get timebarPosition():String
		{
			var prefs:SharedObject = SharedObject.getLocal(SHARED_OBJECT_ID);
			
			if(prefs.data.timebarPos)
				return prefs.data.timebarPos;
			else
				return POS_RIGHT;
		}
		
		/**
		 * Sets the time bar position.
		 * 
		 * @param value The target time bar position.
		 */
		public static function set timebarPosition(value:String):void
		{
			var prefs:SharedObject = SharedObject.getLocal(SHARED_OBJECT_ID);
			prefs.data.timebarPos = value;
			prefs.flush();
		}
		
		/**
		 * Gets the menu position.
		 * 
		 * @return The menu position.
		 */
		public static function get menuPosition():String
		{
			var prefs:SharedObject = SharedObject.getLocal(SHARED_OBJECT_ID);
			if(prefs.data.menuPos)
				return prefs.data.menuPos;
			else
				return POS_RIGHT;
		}
		
		/**
		 * Sets the menu position.
		 * 
		 * @param value The target menu position.
		 */
		public static function set menuPosition(value:String):void
		{
			var prefs:SharedObject = SharedObject.getLocal(SHARED_OBJECT_ID);
			prefs.data.menuPos = value;
			prefs.flush();
		}
		
		/**
		 * Gets the menu open value.
		 * 
		 * @return The menu open value.
		 */
		public static function get menuOpen():String
		{
			var prefs:SharedObject = SharedObject.getLocal(SHARED_OBJECT_ID);
			if(prefs.data.menuOpen)
				return prefs.data.menuOpen;
			else
				return CLOSE;
		}
		
		/**
		 * Sets the menu open value.
		 * 
		 * @param value The target menu open value.
		 */
		public static function set menuOpen(value:String):void
		{
			var prefs:SharedObject = SharedObject.getLocal(SHARED_OBJECT_ID);
			prefs.data.menuOpen = value;
			prefs.flush();
		}
		
		/**
		 * Gets the auto insert value.
		 * 
		 * @return The auto insert value.
		 */
		public static function get autoInsert():String
		{
			var prefs:SharedObject = SharedObject.getLocal(SHARED_OBJECT_ID);
			if(prefs.data.autoInsert)
				return prefs.data.autoInsert;
			else
				return CLOSE;
		}
		
		/**
		 * Sets the auto insert value.
		 * 
		 * @param value The target auto insert value.
		 */
		public static function set autoInsert(value:String):void
		{
			var prefs:SharedObject = SharedObject.getLocal(SHARED_OBJECT_ID);
			prefs.data.autoInsert = value;
			prefs.flush();
		}
	}
}