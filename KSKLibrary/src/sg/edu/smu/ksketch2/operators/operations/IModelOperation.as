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
	/**
	 * The IModelOperation class serves as the interface class for a model
	 * operation in K-Sketch.
	 */
	public interface IModelOperation
	{
		/**
		 * Gets the error message for the model operation.
		 * 
		 * @return The error message for the model operation.
		 */
		function get errorMessage():String;
		
		/**
		 * Checks whether the operation is valid. If not, it should fail on
		 * construction and not be added to the operation stack.
		 * 
		 * @return Whether the operation is valid.
		 */
		function isValid():Boolean;

		/**
		 * Undoes the model operation by reverting the state of the model to
		 * immediately before the model operation was performed.
		 */
		function undo():void;
		
		/**
		 * Redoes the model operation by reverting the state of the model to
		 * immediately after the operation was performed.
		 */
		function redo():void;
		
		/**
		 * Debugs the model operation by showing what is inside the model
		 * operation.
		 */
		function debug():void;
	}
}