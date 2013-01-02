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
	
	public class KRemoveKeyOperation extends KKeyOperation
	{
		public function KRemoveKeyOperation(before:IKeyFrame, after:IKeyFrame, removedKey:IKeyFrame)
		{
			_oldKey = removedKey as KKeyFrame;
			super(before, after);
			
			if(!isValid())
				throw new Error(errorMessage);
		}
		
		override public function get errorMessage():String
		{
			return "KRemoveKeyOperation: No removed key is given to this operation"
		}
		
		override public function isValid():Boolean
		{
			return _oldKey != null;
		}
		
		override public function undo():void
		{
			if(_before)
				_before.next = _oldKey;
			
			if(_after)
				_after.previous = _oldKey;
			
			_oldKey.previous = _before;
			_oldKey.next = _after;
		}
		
		override public function redo():void
		{
			if(_before)
				_before.next = _after;
			
			if(_after)
				_after.previous = _before;
			
			_oldKey.previous = null;
			_oldKey.next = null;
		}
	}
}