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
	import sg.edu.smu.ksketch2.model.objects.KGroup;
	import sg.edu.smu.ksketch2.model.objects.KObject;

	/**
	 * The KParentChangeOperation class serves as the concrete class for
	 * handling parent change operations in K-Sketch. Specifically, the
	 * operation representing a change in the child object's parents.
	 */
	public class KParentChangeOperation implements IModelOperation
	{
		private var _newParent:KGroup;		// the newer parent objects
		private var _oldParent:KGroup;		// the older parent objects
		private var _child:KObject;			// the child object
		
		/**
		 * The main constructor for the KParentChangeOperation class.
		 * 
		 * @param child The target child object.
		 * @param newParent The target newer parent objects.
		 * @param oldParent The target older parent objects.
		 */
		public function KParentChangeOperation(child:KObject, newParent:KGroup, oldParent:KGroup)
		{
			_newParent = newParent;		// set the newer parent objects
			_oldParent = oldParent;		// set the older parent objects
			_child = child;				// set the child object
			
			// case: the operation is invalid
			// throw an error
			if(!isValid())
				throw new Error(errorMessage);
		}
		
		/**
		 * Undoes the parent change operation by reverting the state of the
		 * operation to immediately before the operation was performed.
		 */
		public function undo():void
		{
			// set the child's parent to the older parent
			_child.parent = _oldParent;
		}
		
		/**
		 * Redoes the parent change operation by reverting the state of the
		 * operation to immediately after the operation was performed.
		 */
		public function redo():void
		{
			// set the child's parent to the newer parent
			_child.parent = _newParent;
		}
		
		/**
		 * Checks whether the parent change operation is valid. If not, it
		 * should fail on construction and not be added to the operation stack.
		 * 
		 * @return Whether the parent change operation is valid.
		 */
		public function isValid():Boolean
		{
			return 	(_child != null) &&				// check if child is non-null
						(_newParent != null ||		// check if either new or old parents are non-null
						_oldParent != null
					);
		}
		
		/**
		 * Gets the error message for the parent change operation.
		 * 
		 * @return The error message for the parent change operation.
		 */
		public function get errorMessage():String
		{
			return "KParentChangeOperation is missing required variables to be constructed properly." +
				"Check if you have a child and one of the parents as input during construction"
		}
		
		/**
		 * Debugs the parent change operation by showing what is inside the
		 * operation.
		 */
		public function debug():void
		{
			trace(this);
		}
	}
}