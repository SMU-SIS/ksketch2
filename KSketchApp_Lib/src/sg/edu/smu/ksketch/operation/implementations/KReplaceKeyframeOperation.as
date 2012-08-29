package sg.edu.smu.ksketch.operation.implementations
{
	import flash.geom.Matrix;
	import flash.geom.Point;

	import sg.edu.smu.ksketch.event.KObjectEvent;
	import sg.edu.smu.ksketch.model.IKeyFrame;
	import sg.edu.smu.ksketch.model.IKeyFrameList;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.operation.IModelOperation;

	public class KReplaceKeyframeOperation implements IModelOperation
	{
		private var _object:KObject;
		private var _keyFrameList:IKeyFrameList;
		private var _oldKeys:Vector.<IKeyFrame>;
		private var _newKeys:Vector.<IKeyFrame>;
		public var actionType:String;
		
		public function KReplaceKeyframeOperation(obj:KObject, keyFrameList:IKeyFrameList,
							oldKeys:Vector.<IKeyFrame>,newKeys:Vector.<IKeyFrame>)
		{
			_object = obj;
			_keyFrameList = keyFrameList;
			_oldKeys = oldKeys;
			_newKeys = newKeys;
		}

		public function apply():void
		{
			_swapKeys(_oldKeys,_newKeys);
			_object.dispatchEvent(new KObjectEvent(object, KObjectEvent.EVENT_TRANSFORM_CHANGED));
		}
		
		public function undo():void
		{
			_swapKeys(_newKeys,_oldKeys);
			_object.dispatchEvent(new KObjectEvent(object, KObjectEvent.EVENT_TRANSFORM_CHANGED));
		}
		
		internal function get object():KObject
		{
			return _object;
		}

		public function get oldKeys():Vector.<IKeyFrame>
		{
			return _oldKeys;
		}
		
		public function get newKeys():Vector.<IKeyFrame>
		{
			return _newKeys;
		}
		
		private function _swapKeys(keys_remove:Vector.<IKeyFrame>, keys_insert:Vector.<IKeyFrame>):void
		{
			if(keys_remove != null)
				_removeKeys(keys_remove);
			if(keys_insert != null)
				_insertKeys(keys_insert);
		}
		
		private function _removeKeys(keys:Vector.<IKeyFrame>):void
		{
			var length:int = keys.length;
			for(var i:int = 0; i< length; i++)
			{
				if(keys[i])
					_keyFrameList.remove(keys[i]);
			}
		}
		
		private function _insertKeys(keys:Vector.<IKeyFrame>):void
		{
			var length:int = keys.length;
			for(var i:int = 0; i< length; i++)
			{
				if(keys[i])
					_keyFrameList.insertKey(keys[i]);
			}
		}
	}
}