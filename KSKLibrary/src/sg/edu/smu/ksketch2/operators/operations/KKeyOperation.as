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

	public class KKeyOperation implements IModelOperation
	{
		protected var _before:KKeyFrame;
		protected var _after:KKeyFrame;
		protected var _newKey:KKeyFrame;
		protected var _oldKey:KKeyFrame;
		
		/**
		 * Generic key frame operation
		 * You only need to give either an inserted key or removed key
		 */
		public function KKeyOperation(before:IKeyFrame, after:IKeyFrame)
		{
			_before = before as KKeyFrame;
			_after = after as KKeyFrame;
			
			if(!this.isValid())
				throw new Error(this.errorMessage);
		}
		
		public function get errorMessage():String
		{
			return "KKeyOperation: The are no before and after keys to work with";
		}
		
		public function isValid():Boolean
		{
			return (_before != null ||_after != null)
		}
		
		public function undo():void
		{
			
		}
		
		public function redo():void
		{
			
		}
		
		public function debug():void
		{
			trace(this);
		}
	}
}