package sg.edu.smu.ksketch.operation.implementations
{
	import sg.edu.smu.ksketch.event.KObjectEvent;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	import sg.edu.smu.ksketch.operation.KModelFacade;
	
	public class KRemoveOperation implements IModelOperation
	{
		private var _facade:KModelFacade;
		private var _target:KObject;
		private var _time:Number;
		
		public function KRemoveOperation(facade:KModelFacade,
										 target:KObject, time:Number)
		{
			_facade = facade;
			_target = target;
			_time = time;
		}
		
		public function apply():void
		{
			_target.getParent(_time).remove(_target);
			_facade.dispatchEvent(new KObjectEvent(_target,KObjectEvent.EVENT_OBJECT_REMOVED));
		}
		
		public function undo():void
		{
			_target.getParent(_time).add(_target);
			_facade.dispatchEvent(new KObjectEvent(_target,KObjectEvent.EVENT_OBJECT_ADDED));
		}
	}
}