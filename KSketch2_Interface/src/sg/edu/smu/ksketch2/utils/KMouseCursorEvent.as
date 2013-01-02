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
	import flash.ui.MouseCursor;
	
	public class KMouseCursorEvent extends Event
	{
		public static const EVENT_CURSOR_CHANGED:String = "my mouse changed";
		public static const DEMO_MODE_CURSOR:String = "demo";
		public static const DEMO_RECORDING_CURSOR:String = "recording";
		public static const SELECT_CURSOR:String = "select";
		public static const INTERPOLTE_MODE_CURSOR:String = MouseCursor.HAND;
		public static const DRAW_MODE_CURSOR:String = MouseCursor.ARROW;
		
		public var cursorName:String;
		
		public function KMouseCursorEvent(type:String, modeName:String)
		{
			super(type);
			cursorName = modeName;
		}
	}
}