/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.operation.implementations
{
	import sg.edu.smu.ksketch.event.KObjectEvent;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	
	/**
	 * An operation that changes how an object appears over time.
	 * Each operation of this class contains another opertaion that modifies a target object.
	 * This class ensures that after undo or redo, the appropriate events are triggered.  
	 */
	public class KTransitionOperation implements IModelOperation
	{
		private var _target:KObject;
		
		private var _changes:KCompositeOperation;
		
		public function KTransitionOperation(target:KObject, changes:KCompositeOperation = null)
		{
			_changes = changes;
			_target = target;
			if(_changes == null)
				_changes = new KCompositeOperation();
		}
		
		public function get target():KObject
		{
			return _target;
		}

		public function apply():void
		{
			_changes.apply();
			_target.dispatchEvent(new KObjectEvent(_target, KObjectEvent.EVENT_TRANSFORM_CHANGED));
		}
		
		public function undo():void
		{
			_changes.undo();
			_target.dispatchEvent(new KObjectEvent(_target, KObjectEvent.EVENT_TRANSFORM_CHANGED));
		}
		
		public function addChange(op:IModelOperation):void
		{
			_changes.addOperation(op);
		}
	}
}