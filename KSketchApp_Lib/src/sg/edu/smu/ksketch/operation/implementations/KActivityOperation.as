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