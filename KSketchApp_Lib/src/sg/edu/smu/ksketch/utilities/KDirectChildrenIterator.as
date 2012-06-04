/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.utilities
{
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.components.KObjectView;
	
	public class KDirectChildrenIterator implements IIterator
	{
		private var _group:KGroup;
		private var _next:int;
		private var _count:int;
		private var _time:Number;
		private var _length:int;
		
		public function KDirectChildrenIterator(group:KGroup, kskTime:Number)
		{
			_group = group;
			_next = -1;
			_time = kskTime;
			_count = 0;
			_length = 0;
			var gLength:int = _group.length();
			var object:KObject;
			for(var i:int;i<gLength;i++)
			{
				object = _group.getObjectAt(i);
				if(object.getVisibility(kskTime) > KObjectView.GHOST_ALPHA && 
					object.getParent(kskTime) == _group)
					_length ++;
			}
			moveToNextChild();
		}
		
		public function hasNext():Boolean
		{
			return _count < _length;
		}
		
		public function next():KObject
		{
			if(!hasNext())
				throw new Error("No such element!");
			var obj:KObject = _group.getObjectAt(_next);
			_count ++;
			
			moveToNextChild();
			
			return obj;
		}
		
		public function top():KObject
		{
			if(!hasNext())
				throw new Error("No such element!");
			return _group.getObjectAt(_next);
		}
		
		private function moveToNextChild():void
		{
			if(hasNext())
			{
				var next:KObject;
				do
					next = _group.getObjectAt(++_next);
				while(next.getVisibility(_time) <= KObjectView.GHOST_ALPHA || 
					next.getParent(_time) != _group);
			}
		}		
	}
}