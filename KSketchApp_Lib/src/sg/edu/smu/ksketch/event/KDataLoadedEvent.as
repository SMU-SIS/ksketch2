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
	public class KDataLoadedEvent extends Event
	{
		public static const EVENT_DATA_LOADED:String = "data loaded";
		
		private var _object:Object;
		private var _data:Object;
		
		public function KDataLoadedEvent(object:Object, data:Object)
		{
			super(EVENT_DATA_LOADED);
			_object = object;
			_data = data;
		}

		public function get object():Object
		{
			return _object;
		}

		public function get data():Object
		{
			return _data;
		}
	}
}