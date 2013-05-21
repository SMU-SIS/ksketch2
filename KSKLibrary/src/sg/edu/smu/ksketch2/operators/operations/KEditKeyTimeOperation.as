/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.operators.operations
{
	import sg.edu.smu.ksketch2.model.data_structures.IKeyFrame;
	import sg.edu.smu.ksketch2.model.data_structures.KKeyFrame;
	import sg.edu.smu.ksketch2.model.objects.KObject;

	public class KEditKeyTimeOperation implements IModelOperation
	{
		private var _object:KObject;
		private var _key:KKeyFrame;
		private var _newTime:int;
		private var _oldTime:int;
		
		/**
		 * Operation for changing a key's time (ie. when moving markers)
		 */
		public function KEditKeyTimeOperation(object:KObject, key:IKeyFrame, newTime:int, oldTime:int)
		{
			_object = object;
			_key = key as KKeyFrame;
			_newTime = newTime;
			_oldTime = oldTime;
			
			if(!isValid())
				throw new Error(errorMessage)
		}
		
		public function get errorMessage():String
		{
			return "KEditKeyTimeOperation does not have enough variables to perform undo/redo";
		}
		
		public function isValid():Boolean
		{
			return (_object != null)&&(_key != null) && !isNaN(_newTime) && !isNaN(_oldTime);
		}
		
		public function undo():void
		{
			_key.time = _oldTime;
		}
		
		public function redo():void
		{
			_key.time = _newTime;
		}
		
		public function debug():void
		{
			trace(this);
		}
	}
}