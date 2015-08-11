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
		 * Double-tap enabled status.
		 */
		public static const DOUBLETAP_ON:String = "DOUBLETAP_ON";
		
		/**
		 * Double-tap disabled status status.
		 */
		public static const DOUBLETAP_OFF:String = "DOUBLETAP_OFF";
		
		/**
		 * Auto-log enabled status.
		 */
		public static const AUTOLOG_ON:String = "AUTOLOG_ON";
		
		/**
		 * Auto-log disabled status.
		 */
		public static const AUTOLOG_OFF:String = "AUTOLOG_OFF";
		
		/**
		 * Mobile-device enabled status.
		 */
		public static const MOBILE_ON:String = "MOBILE_ON";
		
		/**
		 * Mobile-device disabled status.
		 */
		public static const MOBILE_OFF:String = "MOBILE_OFF";
		
		//KSKETCH-SYNPHNE
		public static const DEFAULT_DURATION:int = 120;
		public static const DEFAULT_ACCURACY:int = 100;
		public static const TAPANYWHERE_ON:String = "TAPANYWHERE_ON";
		public static const TAPANYWHERE_OFF:String = "TAPANYWHERE_OFF";
		public static const DIFFICULTY_EASY:String = "DIFFICULTY_EASY";
		public static const DIFFICULTY_MEDIUM:String = "DIFFICULTY_MEDIUM";
		public static const DIFFICULTY_HARD:String = "DIFFICULTY_HARD";
		
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
		 * @return The  menu position.
		 */
		public static function get menuPosition():String
		{
			var prefs:SharedObject = SharedObject.getLocal(SHARED_OBJECT_ID);
			if(prefs.data.menuPos)
				return prefs.data.menuPos;
			else
				return POS_TOP;
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
 		 * @return The  menu open value.
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
		
		/**
		 * Gets the double tap feature value.
		 * 
		 * @return The double tap value.
		 */
		public static function get doubleTap():String
		{
			var prefs:SharedObject = SharedObject.getLocal(SHARED_OBJECT_ID);
			if(prefs.data.doubleTap)
				return prefs.data.doubleTap;
			else
				return CLOSE;
		}
		
		/**
		 * Sets the double tap feature value.
		 * 
		 * @param value The target double tap value.
		 */
		public static function set doubleTap(value:String):void
		{
			var prefs:SharedObject = SharedObject.getLocal(SHARED_OBJECT_ID);
			prefs.data.doubleTap = value;
			prefs.flush();
		}
		
		/**
		 * Gets the auto log feature value.
		 * 
		 * @return The auto log value.
		 */
		public static function get autoLog():String
		{
			var prefs:SharedObject = SharedObject.getLocal(SHARED_OBJECT_ID);
			if(prefs.data.autoLog)
				return prefs.data.autoLog;
			else
				return CLOSE;
		}
		
		/**
		 * Sets the auto log feature value.
		 * 
		 * @param value The target auto log value.
		 */
		public static function set autoLog(value:String):void
		{
			var prefs:SharedObject = SharedObject.getLocal(SHARED_OBJECT_ID);
			prefs.data.autoLog = value;
			prefs.flush();
		}
		
		/**
		 * Gets the mobile device enabled/disabled value.
		 * 
		 * @return The mobile device value.
		 */
		public static function get mobileEnabled():String
		{
			var prefs:SharedObject = SharedObject.getLocal(SHARED_OBJECT_ID);
			if(prefs.data.mobileEnabled)
				return prefs.data.mobileEnabled;
			else
				return CLOSE;
		}
		
		/**
		 * Sets the auto log feature value.
		 * 
		 * @param value The target auto log value.
		 */
		public static function set mobileEnabled(value:String):void
		{
			var prefs:SharedObject = SharedObject.getLocal(SHARED_OBJECT_ID);
			prefs.data.mobileEnabled = value;
			prefs.flush();
		}
		
		//KSKETCH-SYNPHNE
		public static function get tapAnywhere():String
		{
			var prefs:SharedObject = SharedObject.getLocal(SHARED_OBJECT_ID);
			if(prefs.data.tapAnywhere)
				return prefs.data.tapAnywhere;
			else
				return TAPANYWHERE_ON;
		}
		
		public static function set tapAnywhere(value:String):void
		{
			var prefs:SharedObject = SharedObject.getLocal(SHARED_OBJECT_ID);
			prefs.data.tapAnywhere = value;
			prefs.flush();
		}
		
		public static function get duration():int
		{
			var prefs:SharedObject = SharedObject.getLocal(SHARED_OBJECT_ID);
			if(prefs.data.duration_time)
				return prefs.data.duration_time;
			else
				return DEFAULT_DURATION;
		}
		
		public static function set duration(value:int):void
		{
			var prefs:SharedObject = SharedObject.getLocal(SHARED_OBJECT_ID);
			prefs.data.duration_time = value;
			prefs.flush();
		}
	}
}