package sg.edu.smu.ksketch.operation.implementations
{
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	import sg.edu.smu.ksketch.operation.KGroupUtil;
	
	public class KChangeParentOperation implements IModelOperation
	{
		private var _object:KObject;
		private var _newParent:KGroup;
		private var _oldParent:KGroup;
		private var _time:Number;
		
		/**
		 * Operation representing changing of parent from oldParent/adding of object to newParent.
		 * Both newParent and oldParent can be null;
		 * New parent = null means adding to nothing
		 */
		public function KChangeParentOperation(object:KObject, newParent:KGroup, oldParent:KGroup, changeTime:Number)
		{
			_object = object;
			_newParent = newParent;
			_oldParent = oldParent;
			_time = changeTime;
		}
		
		public function apply():void
		{
			KGroupUtil.addObjectToParent(_time, _object, _newParent);
		}
		
		public function undo():void
		{
			KGroupUtil.addObjectToParent(_time, _object, _oldParent);
		}
	}
}