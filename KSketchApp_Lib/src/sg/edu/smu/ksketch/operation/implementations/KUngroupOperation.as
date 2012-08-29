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
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.model.KModel;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	import sg.edu.smu.ksketch.operation.KGroupUtil;
	import sg.edu.smu.ksketch.operation.KUngroupUtil;
	
	public class KUngroupOperation implements IModelOperation
	{
		private var _model:KModel;
		private var _object:KObject;		
		private var _time:Number;
		private var _oldParent:KGroup;
		private var _newParent:KGroup;
		
		public function KUngroupOperation(model:KModel,object:KObject,time:Number,
										  oldParent:KGroup, newParent:KGroup)
		{
			_model = model;
			_object = object;
			_time = time;			
			_oldParent = oldParent;
			_newParent = newParent;
		}
		
		public function apply():void
		{			
			if (!_oldParent.directChildIterator(_time).hasNext())
				_oldParent.addActivityKey(_time,0);
			_do(_model,_object,_time,_newParent);
		}
		
		public function undo():void
		{
			if (!_newParent.directChildIterator(_time).hasNext())
				_newParent.addActivityKey(_time,0);
			_do(_model,_object,_time,_oldParent);
		}
		
		private function _do(model:KModel,object:KObject,time:Number,parent:KGroup):void
		{
			if (!parent.children.contains(object))
				parent.add(object);
			parent.addActivityKey(time,1);
			KGroupUtil.setParentKey(time,object,parent);
			KUngroupUtil.removeDuplicateParentKeys(object);
			parent.updateCenter();
			KUngroupUtil.dispatchUngroupOperationEvent(model,parent,object);
		}
	}
}