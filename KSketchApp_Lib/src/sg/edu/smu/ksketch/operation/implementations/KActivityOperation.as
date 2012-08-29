package sg.edu.smu.ksketch.operation.implementations
{
	import sg.edu.smu.ksketch.event.KObjectEvent;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	
	public class KActivityOperation implements IModelOperation
	{
		private var _target:KObject;
		private var _time:Number;
		private var _alpha:Number;
		
		public function KActivityOperation(target:KObject, alpha:Number, time:Number)
		{
			_target = target;
			_time = time;
			_alpha = alpha;
		}
		
		public function apply():void
		{
			_target.addActivityKey(_time,_alpha);
			_target.dispatchEvent(new KObjectEvent(_target, 
				KObjectEvent.EVENT_VISIBILITY_CHANGED));
		}
		
		public function undo():void
		{
			_target.removeActivityKey(_time);
			_target.dispatchEvent(new KObjectEvent(_target, 
				KObjectEvent.EVENT_VISIBILITY_CHANGED));
		}
	}
}