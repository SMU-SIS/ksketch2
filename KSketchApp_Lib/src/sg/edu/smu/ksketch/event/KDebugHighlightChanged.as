/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package sg.edu.smu.ksketch.event
{
	import flash.events.Event;
	
	import sg.edu.smu.ksketch.utilities.KModelObjectList;

	public class KDebugHighlightChanged extends Event
	{
		public static const EVENT_DEBUG_CHANGED:String = "debug changed";
		
		private var _oldSelection:KModelObjectList;
		private var _newSelection:KModelObjectList;
		
		public function KDebugHighlightChanged(oldSelection:KModelObjectList, newSelection:KModelObjectList)
		{
			super(EVENT_DEBUG_CHANGED);
			_oldSelection = oldSelection;
			_newSelection = newSelection;
		}
		
		
		public function get oldSelection():KModelObjectList
		{
			return _oldSelection;
		}

		public function set oldSelection(value:KModelObjectList):void
		{
			_oldSelection = value;
		}

		public function get newSelection():KModelObjectList
		{
			return _newSelection;
		}

		public function set newSelection(value:KModelObjectList):void
		{
			_newSelection = value;
		}


	}
}