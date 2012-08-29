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
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	
	public class KEditTransformOperation extends KCompositeOperation implements IModelOperation
	{
		private var _target:KObject;
		
		public function KEditTransformOperation(targetObject:KObject, operations:Vector.<IModelOperation>=null)
		{
			super(operations);
			_target = targetObject;
		}
		
		override public function apply():void
		{
			super.apply();
			_target.dispatchEvent(new KObjectEvent(_target, KObjectEvent.EVENT_TRANSFORM_CHANGED));
		}
		
		override public function undo():void
		{
			super.undo();
			_target.dispatchEvent(new KObjectEvent(_target, KObjectEvent.EVENT_TRANSFORM_CHANGED));
		}
	}
}