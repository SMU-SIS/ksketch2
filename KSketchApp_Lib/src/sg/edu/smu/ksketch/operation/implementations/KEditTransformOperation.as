package sg.edu.smu.ksketch.operation.implementations
{
	import sg.edu.smu.ksketch.event.KObjectEvent;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	
	public class KEditTransformOperation extends KCompositeOperation implements IModelOperation
	{
		private var _target:KObject;
		
		public function KEditTransformOperation(targetObject:KObject, operations:Vector.<IModelOperation>=null)
		{
			super(operations);
			_target = targetObject;
		}
		
		override public function apply():void
		{
			super.apply();
			_target.dispatchEvent(new KObjectEvent(_target, KObjectEvent.EVENT_TRANSFORM_CHANGED));
		}
		
		override public function undo():void
		{
			super.undo();
			_target.dispatchEvent(new KObjectEvent(_target, KObjectEvent.EVENT_TRANSFORM_CHANGED));
		}
	}
}