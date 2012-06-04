/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.operation.implementations
{
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.model.IParentKeyFrame;

	public class KParentInfo
	{
		private var _object:KObject;
		
		private var _oldParentKeyframe:IParentKeyFrame;
		private var _oldIndex:int;
		
		private var _newParentKeyframe:IParentKeyFrame;
		
		public function KParentInfo(object:KObject, newParentKeyframe:IParentKeyFrame, 
									oldParentKeyframe:IParentKeyFrame=null, oldIndex:int=-1)
		{
			_object = object;
			_oldParentKeyframe = oldParentKeyframe;
			_oldIndex = oldIndex;
			_newParentKeyframe = newParentKeyframe;
		}

		internal function get object():KObject
		{
			return _object;
		}

		internal function get oldParentKeyframe():IParentKeyFrame
		{
			return _oldParentKeyframe;
		}

		internal function get oldIndex():int
		{
			return _oldIndex;
		}

		internal function get newParentKeyframe():IParentKeyFrame
		{
			return _newParentKeyframe;
		}
	}
}