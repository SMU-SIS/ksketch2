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
	import sg.edu.smu.ksketch.event.KObjectEvent;
	import sg.edu.smu.ksketch.model.IParentKeyFrame;
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.model.KModel;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	import sg.edu.smu.ksketch.operation.KGroupUtil;
	import sg.edu.smu.ksketch.utilities.IIterator;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;

	public class KGroupOperation extends KCompositeOperation implements IModelOperation
	{
		private var _grandParent:KGroup;
		private var _newParent:KGroup;
		private var _time:Number;
		
		public function KGroupOperation(grandParent:KGroup, newParent:KGroup, groupTime:Number, operations:Vector.<IModelOperation> = null)
		{
			_grandParent = grandParent;
			_newParent = newParent;
			_time = groupTime;
			super(operations);
		}
		
		//Apply adds the new parent back into the model
		//Then moves all of new parent's "children" back into it
		override public function apply():void
		{
			KGroupUtil.addObjectToParent(_time, _newParent, _grandParent, null);
			super.apply();
		}
		
		//Undo moves all of newParent's children to their old parents
		//Then removes newParent from the model;
		override public function undo():void
		{	
			super.undo();
			KGroupUtil.addObjectToParent(_time, _newParent, null, null);
		}
	}
}