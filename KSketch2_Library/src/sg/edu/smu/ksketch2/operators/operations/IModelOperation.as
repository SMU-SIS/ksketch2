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
	public interface IModelOperation
	{
		/**
		 * error message for this operation
		 */
		function get errorMessage():String;
		
		/**
		 * If the operation is not valid, it should fail on construction and should not be added to an operation stack
		 */
		function isValid():Boolean;

		/**
		 * Revert the state of the model to before this operation was performed
		 */
		function undo():void;
		
		/**
		 * Revert the state of the model to immediately after this operation was performed
		 */
		function redo():void;
		
		/**
		 * Shows Whats inside this operation
		 */
		function debug():void;
	}
}