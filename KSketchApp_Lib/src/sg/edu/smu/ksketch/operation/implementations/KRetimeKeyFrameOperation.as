package sg.edu.smu.ksketch.operation.implementations
{
	import sg.edu.smu.ksketch.event.KModelEvent;
	import sg.edu.smu.ksketch.model.IKeyFrame;
	import sg.edu.smu.ksketch.model.KModel;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	import sg.edu.smu.ksketch.utilities.KAppState;
	
	public class KRetimeKeyFrameOperation implements IModelOperation
	{
		private var _appState:KAppState;
		private var _model:KModel;
		private var _keys:Vector.<IKeyFrame>;
		private var _oldTimes:Vector.<Number>;
		private var _newTimes:Vector.<Number>;
		
		public function KRetimeKeyFrameOperation(appState:KAppState, model:KModel,
			keys:Vector.<IKeyFrame>, oldTimes:Vector.<Number>, newTimes:Vector.<Number>)
		{
			_appState = appState;
			_model = model;
			_keys = keys;
			_oldTimes = oldTimes;
			_newTimes = newTimes;
		}
		
		public function apply():void
		{
			for (var i:int; i < _keys.length; i++)
				_keys[i].retimeKeyframe(_newTimes[i]);
			_model.dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATE_COMPLETE));
			_model.dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATED));
			if (_newTimes.length > 0)
				_appState.time = _newTimes[_newTimes.length-1]; 
		}
		
		public function undo():void
		{
			for (var i:int; i < _keys.length; i++)
				_keys[i].retimeKeyframe(_oldTimes[i]);
			_model.dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATE_COMPLETE));
			_model.dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATED));
			if (_oldTimes.length > 0)
				_appState.time = _oldTimes[_oldTimes.length-1]; 
		}
	}
}