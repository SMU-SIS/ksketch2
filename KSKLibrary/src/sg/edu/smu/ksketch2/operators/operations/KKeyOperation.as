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

	/**
	 * The KKeyOperation class serves as the concrete class for handling
	 * key frame operations in K-Sketch. Specifically, handles generic
	 * key frame operations that require giving it either an inserted
	 * or removed key.
	 */
	public class KKeyOperation implements IModelOperation
	{
		protected var _before:KKeyFrame;	// the previous key frame
		protected var _after:KKeyFrame;		// the next key frame
		protected var _newKey:KKeyFrame;	// the newer key frame
		protected var _oldKey:KKeyFrame;	// the older key frame
		
		/**
		 * The main constructor for the KKeyOperation class.
		 * 
		 * @param before The previous key frame.
		 * @param after The next key frame.
		 */
		public function KKeyOperation(before:IKeyFrame, after:IKeyFrame)
		{
			_before = before as KKeyFrame;		// set the previous key frame
			_after = after as KKeyFrame;		// set the next key frame
			
			// case: the key operation is invalid
			// throw an error message
			if(!this.isValid())
				throw new Error(this.errorMessage);
		}
		
		/**
		 * Gets the error message for the key frame operation.
		 * 
		 * @return The error message for the key frame operation.
		 */
		public function get errorMessage():String
		{
			return "KKeyOperation: The are no before and after keys to work with";
		}
		
		/**
		 * Checks whether the key frame operation is valid. If not, it should
		 * fail on construction and not be added to the operation stack.
		 * 
		 * @return Whether the key frame operation is valid.
		 */
		public function isValid():Boolean
		{
			return (_before != null ||		// check if either the previous or
					_after != null)			// next key frame is non-null
		}
		
		/**
		 * Undoes the key frame operation by reverting the state of the
		 * operation to immediately before the operation was performed.
		 */
		public function undo():void
		{
			
		}
		
		/**
		 * Redoes the key frame operation by reverting the state of the
		 * operation to immediately after the operation was performed.
		 */
		public function redo():void
		{
			
		}
		
		/**
		 * Debugs the key frame operation by showing what is inside the
		 * operation.
		 */
		public function debug():void
		{
			trace(this);
		}
	}
}