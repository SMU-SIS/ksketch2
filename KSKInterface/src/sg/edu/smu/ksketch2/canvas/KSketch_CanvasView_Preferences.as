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

	public class KSketch_CanvasView_Preferences
	{
		public static const SHARED_OBJECT_ID:String = "KSketch_Pref";
		
		public static const POS_LEFT:String = "LEFT";
		public static const POS_RIGHT:String = "RIGHT";
		public static const POS_TOP:String = "TOP";
		public static const POS_BOTTOM:String = "BOTTOM";
		public static const OPEN:String = "OPEN";
		public static const CLOSE:String = "CLOSE";
		public static const AUTO:String = "AUTO";
		public static const NOT_AUTO:String = "NOT AUTO";
		
		public static function getSharedObject():SharedObject
		{
			var prefs:SharedObject = SharedObject.getLocal(SHARED_OBJECT_ID);
			return prefs;			
		}
		
		public static function get timebarPosition():String
		{
			var prefs:SharedObject = SharedObject.getLocal(SHARED_OBJECT_ID);
			
			if(prefs.data.timebarPos)
				return prefs.data.timebarPos;
			else
				return POS_RIGHT;
		}
		
		public static function set timebarPosition(value:String):void
		{
			var prefs:SharedObject = SharedObject.getLocal(SHARED_OBJECT_ID);
			prefs.data.timebarPos = value;
			prefs.flush();
		}
		
		public static function get menuPosition():String
		{
			var prefs:SharedObject = SharedObject.getLocal(SHARED_OBJECT_ID);
			
			if(prefs.data.menuPos)
				return prefs.data.menuPos;
			else
				return POS_RIGHT;
		}
		
		public static function set menuPosition(value:String):void
		{
			var prefs:SharedObject = SharedObject.getLocal(SHARED_OBJECT_ID);
			prefs.data.menuPos = value;
			prefs.flush();
		}
		
		public static function get menuOpen():String
		{
			var prefs:SharedObject = SharedObject.getLocal(SHARED_OBJECT_ID);
			if(prefs.data.menuOpen)
				return prefs.data.menuOpen;
			else
				return CLOSE;
		}
		
		public static function set menuOpen(value:String):void
		{
			var prefs:SharedObject = SharedObject.getLocal(SHARED_OBJECT_ID);
			prefs.data.menuOpen = value;
			prefs.flush();
		}
		
		public static function get autoInsert():String
		{
			var prefs:SharedObject = SharedObject.getLocal(SHARED_OBJECT_ID);
			if(prefs.data.autoInsert)
				return prefs.data.autoInsert;
			else
				return CLOSE;
		}
		
		public static function set autoInsert(value:String):void
		{
			var prefs:SharedObject = SharedObject.getLocal(SHARED_OBJECT_ID);
			prefs.data.autoInsert = value;
			prefs.flush();
		}
	}
}