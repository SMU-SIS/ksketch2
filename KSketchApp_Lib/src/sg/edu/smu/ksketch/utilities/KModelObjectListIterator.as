/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

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