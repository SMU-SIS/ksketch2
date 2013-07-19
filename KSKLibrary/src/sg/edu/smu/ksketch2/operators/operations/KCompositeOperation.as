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
	 * The KCompositeOperation class serves as the concrete class for handling
	 * composite operations in K-Sketch.
	 */
	public class KCompositeOperation implements IModelOperation
	{
		private var operationStack:Vector.<IModelOperation>;	// the stack of composite operations
		
		/**
		 * The main constructor for the KCompositeOperation class.
		 */
		public function KCompositeOperation()
		{
			// initialize the stack of composite operations
			operationStack = new Vector.<IModelOperation>();
		}
		
		/**
		 * Checks whether the composite operation is valid. If not, it should
		 * fail on construction and not be added to the composite operation
		 * stack.
		 * 
		 * @return Whether the composite operation is valid.
		 */
		public function isValid():Boolean
		{
			return 0 < length 
		}
		
		/**
		 * Gets the length of the stack of composite operations.
		 * 
		 * @return The length of the stack of composite operations.
		 */
		public function get length():int
		{
			return operationStack.length;
		}
		
		/**
		 * Adds a model operation to the active stack of composite operations.
		 * 
		 * @param operation The target model operation.
		 */
		public function addOperation(operation:IModelOperation):void
		{
			// case: the given model operation is not null
			if(operation)
			{
				// case: the given model operation is valid
				if(operation.isValid())
				{
					// push the given model operation to the stack
					operationStack.push(operation);
				}
				else throw new Error(operation.errorMessage)
			}
			
			// case: the given model operation is either null or invalid
			// throw an error
			else
				throw new Error("Can't add an empty operation");
		}
		
		/**
		 * Undoes the composite operation by reverting the state of the
		 * composite operation to immediately before the composite operation was performed.
		 */
		public function undo():void
		{
			// iterate throu
			for(var i:int = operationStack.length-1; -1 < i; i--)
				operationStack[i].undo();
		}
		
		/**
		 * Redoes the composite operation by reverting the state of the
		 * composite operation to immediately after the composite operation was performed.
		 */
		public function redo():void
		{
			for(var i:int = 0; i<operationStack.length; i++)
				operationStack[i].redo();
		}
		
		/**
		 * Gets the error message for the composite operation.
		 * 
		 * @return The error message for the composite operation.
		 */
		public function get errorMessage():String
		{
			return "This compositeOperation does not have any operations in its operation stack."
		}
		
		/**
		 * Debugs the composite operation by showing what is inside the composite
		 * operation.
		 */
		public function debug():void
		{
			// output the number of composite operations
			trace("Debugging", this, "has", operationStack.length, "operations");
			
			// output the contents of the composite operations stack
			for(var i:int = 0; i<operationStack.length; i++)
				trace(this, i ,"	",operationStack[i].debug());
		}
	}
}