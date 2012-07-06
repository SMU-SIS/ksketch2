/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.operation.implementations
{
	import sg.edu.smu.ksketch.event.KModelEvent;
	import sg.edu.smu.ksketch.model.KModel;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	
	public class KAddOperation implements IModelOperation
	{
		private var _model:KModel;
		private var _object:KObject;
		
		public function KAddOperation(model:KModel, object:KObject)
		{
			if(model == null || object == null)
				throw new Error("variables can not be null");
			_model = model;
			_object = object;
		}
		
		public function apply():void
		{
			_model.add(_object);
			_model.dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATED));
		}
		
		public function undo():void
		{
			_model.remove(_object);
			_model.dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATED));
		}
		
		public function get object():KObject
		{
			return _object;
		}		
	}
}