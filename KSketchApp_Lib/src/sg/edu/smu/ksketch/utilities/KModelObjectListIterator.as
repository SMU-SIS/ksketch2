/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package sg.edu.smu.ksketch.utilities
{
	import sg.edu.smu.ksketch.model.KObject;
	
	public class KModelObjectListIterator implements IIterator
	{
		private var _list:KModelObjectList;
		private var _index:int;
		
		public function KModelObjectListIterator(list:KModelObjectList)
		{
			_list = list;
			_index = 0;
		}
		
		public function hasNext():Boolean
		{
			return _index < _list.length();
		}
		
		public function next():KObject
		{
			return _list.getObjectAt(_index++);
		}
		
		public function top():KObject
		{
			return _list.getObjectAt(_index);
		}
	}
}