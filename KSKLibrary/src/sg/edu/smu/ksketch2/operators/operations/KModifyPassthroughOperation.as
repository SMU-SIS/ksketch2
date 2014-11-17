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
	 * The KInsertKeyOperation class serves as the concrete class for handling
	 * insert key frame operations in K-Sketch.
	 */
	public class KModifyPassthroughOperation implements IModelOperation
	{
		private var _key:IKeyFrame;	
		
		/**
		 * The main constructor for the KInsertKeyOperation class.
		 * 
		 * @param before The previous key frame.
		 * @param after The next key frame.
		 * @param insertedKey The inserted key frame.
		 */
		public function KModifyPassthroughOperation(insertedKey:IKeyFrame)
		{
			// set the newer key frame as the inserted key frame
			_key = insertedKey as KKeyFrame;
			
			// case: the insert key operation is invalid
			// throw an error
			if(!isValid())
				throw new Error(errorMessage);
			
			/*var log:XML = <op/>;
			log.@type = "Modify Passthrough";
			log.appendChild(_key.serialize());
			KSketch2.log.appendChild(log);*/
		}
		
		/**
		 * Gets the error message for the insert key operation.
		 * 
		 * @return The error message for the insert key time operation.
		 */
		public function get errorMessage():String
		{
			return "KModifyPassthroughOperation: No existing key is given to this operation"
		}
		
		/**
		 * Checks whether the visibility changed operation is valid. If not, it
		 * should fail on construction and not be added to the operation stack.
		 * 
		 * @return Whether the visibility changed operation is valid.
		 */
		public function isValid():Boolean
		{
			// check if the key frame is non-null
			return _key != null;
		}
		
		/**
		 * Undoes the visibility changed operation by reverting the state of the
		 * operation to immediately before the operation was performed.
		 */
		public function undo():void
		{
			// set the keyframe's visibility to the older visibility
			if(_key.passthrough)
				_key.passthrough = false
			else
				_key.passthrough = true;
		}
		
		/**
		 * Redoes the visibility changed operation by reverting the state of the
		 * operation to immediately after the operation was performed.
		 */
		public function redo():void
		{
			// set the key frame's visibility to the newer visibility
			if(_key.passthrough)
				_key.passthrough = false;
			else
				_key.passthrough = true;
		}
		
		/**
		 * Debugs the visibility changed operation by showing what is inside the
		 * operation.
		 */
		public function debug():void
		{
			
		}
	}
}