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
	import sg.edu.smu.ksketch2.model.objects.KObject;

	/**
	 * The KEditKeyTimeOperation class serves as the concrete class for
	 * handling edit key time operations in K-Sketch. Specifically, the
	 * operations for changing a key's time (i.e., when moving markers).
	 */
	public class KEditKeyTimeOperation implements IModelOperation
	{
		private var _object:KObject;	// the current object
		private var _key:KKeyFrame;		// the current key frame
		private var _newTime:Number;		// the current newer time
		private var _oldTime:Number;		// the current older time
		
		/**
		 * The main constructor for the KEditKeyTimeOperation class.
		 * 
		 * @param object The target current object.
		 * @param key The target current key frame.
		 * @param newTime The target newer time.
		 * @param oldTime The target older time.
		 */
		public function KEditKeyTimeOperation(object:KObject, key:IKeyFrame, newTime:Number, oldTime:Number)
		{
			_object = object;			// set the current object
			_key = key as KKeyFrame;	// set the current key frame
			_newTime = newTime;			// set the newer time
			_oldTime = oldTime;			// set the older time
			
			// case: the edit key time operation is invalid
			// throw an error
			if(!isValid())
				throw new Error(errorMessage)
		
			/*var log:XML = <op/>;
			log.@type = "Edit Key Time";
			log.@newTime = _newTime;
			log.@oldTime = _oldTime;
			log.appendChild(_object.serialize());
			log.appendChild(_key.serialize());
			KSketch2.log.appendChild(log);*/
		}
		
		/**
		 * Gets the error message for the edit key time operation.
		 * 
		 * @return The error message for the edit key time operation.
		 */
		public function get errorMessage():String
		{
			return "KEditKeyTimeOperation does not have enough variables to perform undo/redo";
		}
		
		/**
		 * Checks whether the edit key time operation is valid. If not, it
		 * should fail on construction and not be added to the operation stack.
		 * 
		 * @return Whether the edit key time operation is valid. 
		 */
		public function isValid():Boolean
		{
			return (_object != null)&&(_key != null) && !isNaN(_newTime) && !isNaN(_oldTime);
		}
		
		/**
		 * Undoes the edit key time operation by reverting the state of the
		 * operation to immediately before the operation was performed.
		 */
		public function undo():void
		{
			_key.time = _oldTime;
		}
		
		/**
		 * Redoes the edit key time operation by reverting the state of the
		 * operation to immediately after the operation was performed.
		 */
		public function redo():void
		{
			_key.time = _newTime;
		}
		
		/**
		 * Debugs the edit key time operation by showing what is inside the
		 * operation.
		 */
		public function debug():void
		{
			trace(this);
		}
	}
}