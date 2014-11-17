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
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.model.data_structures.IKeyFrame;
	import sg.edu.smu.ksketch2.model.data_structures.KKeyFrame;
	
	/**
	 * The KRemoveKeyOperation class serves as the concrete class for handling
	 * remove key frame operations in K-Sketch.
	 */
	public class KRemoveKeyOperation extends KKeyOperation
	{
		/**
		 * The main constructor for the KRemoveKeyOperation class.
		 * 
		 * @param before The previous key frame.
		 * @param after The next key frame.
		 * @param insertedKey The inserted key frame.
		 */
		public function KRemoveKeyOperation(before:IKeyFrame, after:IKeyFrame, removedKey:IKeyFrame)
		{
			// set the older key frame as the inserted key frame
			_oldKey = removedKey as KKeyFrame;
			
			// set the previous and next key frames
			super(before, after);
			
			// case: the insert key operation is invalid
			// throw an error
			if(!isValid())
				throw new Error(errorMessage);
			
			/*var log:XML = <op/>;
			log.@type = "Remove Key";
			log.appendChild(_oldKey.serialize());
			
			if(before)
			{
				var beforeLog:XML = <before/>;
				beforeLog.appendChild(before.serialize());
				log.appendChild(beforeLog);
			}
			
			if(after)
			{
				var afterLog:XML = <after/>;
				afterLog.appendChild(after.serialize());
				log.appendChild(afterLog);	
			}
			
			KSketch2.log.appendChild(log);*/
		}
		
		/**
		 * Gets the error message for the remove key operation.
		 * 
		 * @return The error message for the remove key time operation.
		 */
		override public function get errorMessage():String
		{
			return "KRemoveKeyOperation: No removed key is given to this operation"
		}
		
		/**
		 * Checks whether the remove key operation is valid. If not, it should
		 * fail on construction and not be added to the operation stack.
		 * 
		 * @return Whether the remove key operation is valid.
		 */
		override public function isValid():Boolean
		{
			// check if the older key frame is non-null
			return _oldKey != null;
		}
		
		/**
		 * Undoes the remove key operation by reverting the state of the
		 * operation to immediately before the operation was performed.
		 */
		override public function undo():void
		{
			// case: the previous key frame is non-null
			// set the previous key frame as the older key frame
			if(_before)
				_before.next = _oldKey;
			
			// case: the next key frame is non-null
			// set the next key frame as the older key frame
			if(_after)
				_after.previous = _oldKey;
			
			// set the older key frame's previous and next key frames as the
			// current key frame's previous and next key frames, respectively
			_oldKey.previous = _before;
			_oldKey.next = _after;
		}
		
		/**
		 * Redoes the remove key operation by reverting the state of the
		 * operation to immediately after the operation was performed.
		 */
		override public function redo():void
		{
			// case: the previous key frame is non-null
			// set the previous key frame as the next key frame
			if(_before)
				_before.next = _after;
			
			// case: the next key frame is non-null
			// set the next key frame as the previous key frame
			if(_after)
				_after.previous = _before;
			
			// nullify the older key frame's previous and next keys
			_oldKey.previous = null;
			_oldKey.next = null;
		}
	}
}