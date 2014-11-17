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
	import sg.edu.smu.ksketch2.model.data_structures.IVisibilityKey;

	/**
	 * The KVisibilityChangedOperation class serves as the concrete class for
	 * handling visibility changed operations in K-Sketch.
	 */
	public class KVisibilityChangedOperation implements IModelOperation
	{
		private var _key:IVisibilityKey;		// the current key frame
		private var _oldVisibility:Boolean;		// the key frame's older visibility
		private var _newVisibility:Boolean		// the key frame's newer visibility
		
		/**
		 * The main constructor for the KVisibilityChangedOperation class.
		 * 
		 * @param key The current key frame.
		 * @param oldVisibility The key frame's older visibility.
		 * @param newVisibility The key frame's newer visibility.
		 */
		public function KVisibilityChangedOperation(key:IVisibilityKey, oldVisibility:Boolean, newVisibility:Boolean)
		{
			_key = key;							// set the current key frame
			_oldVisibility = oldVisibility;		// set the key frame's older visibility
			_newVisibility = newVisibility;		// set the key frame's newer visibility
			
			/*var log:XML = <op/>;
			log.@type = "Replace Path";
			log.@oldVisibility = _oldVisibility.toString();
			log.@newVisibility = _newVisibility.toString();
			log.appendChild(_key.serialize());
			KSketch2.log.appendChild(log);*/
		}
		
		/**
		 * Gets the error message for the visibility changed operation.
		 * 
		 * @return The error message for the visibility changed operation.
		 */
		public function get errorMessage():String
		{
			return "KVisibilityChangedOperation does not have enough information to perform its duties";
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
			_key.visible = _oldVisibility;
		}
		
		/**
		 * Redoes the visibility changed operation by reverting the state of the
		 * operation to immediately after the operation was performed.
		 */
		public function redo():void
		{
			// set the key frame's visibility to the newer visibility
			_key.visible = _newVisibility;
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