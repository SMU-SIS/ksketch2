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

	public class KParentChangeOperation implements IModelOperation
	{
		private var _newParent:KGroup;
		private var _oldParent:KGroup;
		private var _child:KObject;
		
		/**
		 * Operation representing a change in the child object's parents
		 */
		public function KParentChangeOperation(child:KObject, newParent:KGroup, oldParent:KGroup)
		{
			_newParent = newParent;
			_oldParent = oldParent;
			_child = child;
			
			if(!isValid())
				throw new Error(errorMessage);
		}
		
		public function undo():void
		{
			_child.parent = _oldParent;
		}
		
		public function redo():void
		{
			_child.parent = _newParent;
		}
		
		public function isValid():Boolean
		{
			return (_child != null) && (_newParent != null || _oldParent != null) ;
		}
		
		public function get errorMessage():String
		{
			return "KParentChangeOperation is missing required variables to be constructed properly." +
				"Check if you have a child and one of the parents as input during construction"
		}
		
		public function debug():void
		{
			trace(this);
		}
	}
}