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
	public class KCompositeOperation implements IModelOperation
	{
		private var operationStack:Vector.<IModelOperation>;
		
		public function KCompositeOperation()
		{
			operationStack = new Vector.<IModelOperation>();
		}
		
		public function isValid():Boolean
		{
			return 0 < length 
		}
		
		public function get length():int
		{
			return operationStack.length;
		}
		
		public function addOperation(operation:IModelOperation):void
		{
			if(operation)
			{
				if(operation.isValid())
					operationStack.push(operation);
				else throw new Error(operation.errorMessage)
			}
			else
				throw new Error("Can't add an empty operation");
		}
		
		public function undo():void
		{
			for(var i:int = operationStack.length-1; -1 < i; i--)
				operationStack[i].undo();
		}
		
		public function redo():void
		{
			for(var i:int = 0; i<operationStack.length; i++)
				operationStack[i].redo();
		}
		
		public function get errorMessage():String
		{
			return "This compositeOperation does not have any operations in its operation stack."
		}
		
		public function debug():void
		{
			trace("Debugging", this, "has", operationStack.length, "operations");
			
			for(var i:int = 0; i<operationStack.length; i++)
				trace(this, i ,"	",operationStack[i].debug());
		}
	}
}