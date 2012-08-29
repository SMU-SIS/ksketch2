/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package sg.edu.smu.ksketch.operation.implementations
{
	import sg.edu.smu.ksketch.model.IKeyFrame;
	import sg.edu.smu.ksketch.model.IParentKeyFrame;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	
	public class KRemoveParentKeyFrameOperation implements IModelOperation
	{
		private var _object:KObject;
		private var _removedKeys:Vector.<IKeyFrame>;
		
		public function KRemoveParentKeyFrameOperation(object:KObject,
													   removedKeys:Vector.<IKeyFrame>)
		{
			_object = object;
			_removedKeys = removedKeys;
		}
		
		public function apply():void
		{
			for(var i:int = 0; i< _removedKeys.length; i++)
				_object.removeParentKey(_removedKeys[i].endTime);
		}
		
		public function undo():void
		{
			for(var i:int = 0; i< _removedKeys.length; i++)
				_object.addParentKey(_removedKeys[i].endTime,
					(_removedKeys[i] as IParentKeyFrame).parent);
		}
		
		public function get object():KObject
		{
			return _object;
		}
		
		public function get removedKeys():Vector.<IKeyFrame>
		{
			return _removedKeys;
		}		
	}
}