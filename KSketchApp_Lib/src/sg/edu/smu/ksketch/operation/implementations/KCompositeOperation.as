package sg.edu.smu.ksketch.operation.implementations
{
	import sg.edu.smu.ksketch.operation.IModelOperation;
	
	public class KCompositeOperation implements IModelOperation
	{
		private var _operations:Vector.<IModelOperation>;
		
		public function KCompositeOperation(operations:Vector.<IModelOperation> = null)
		{
			_operations = operations;
			if(_operations == null)
				_operations = new Vector.<IModelOperation>();
		}
		
		public function apply():void
		{
			var length:uint = _operations.length;
			for(var i:int=0; i<length; i++)
				_operations[i].apply();
		}
		
		public function undo():void
		{
			for(var i:int=_operations.length-1; i>=0; i--)
				_operations[i].undo();
		}
		
		public function addOperation(op:IModelOperation):void
		{
			_operations.push(op);
		}
		
		public function get length():int
		{
			return _operations.length;
		}
		
		public function getOperation(index:int):IModelOperation
		{
			return _operations[index];			
		}
	}
}