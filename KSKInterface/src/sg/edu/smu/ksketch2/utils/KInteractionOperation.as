/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.utils
{
	import sg.edu.smu.ksketch2.canvas.controls.IInteractionControl;
	import sg.edu.smu.ksketch2.canvas.components.timebar.ITimeControl;
	import sg.edu.smu.ksketch2.events.KObjectEvent;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;
	
	/**
	 * The KInteractionOperation class serves as the concrete class for handling
	 * interaction operations in K-Sketch.
	 */
	public class KInteractionOperation extends KCompositeOperation
	{
		private var _interactionControl:IInteractionControl;	// the interaction control
		private var _timeControl:ITimeControl;					// the time control
		
		public var startTime:int;								// the start time
		public var endTime:int;									// the end time
		
		public var newSelection:KSelection;						// the new selection
		public var oldSelection:KSelection;						// the old selection
		
		/**
		 * The main constructor for the KInteractionOperation class.
		 * 
		 * @param interactionControl The target interaction control.
		 * @param timeControl The target time control.
		 */
		public function KInteractionOperation(interactionControl:IInteractionControl, timeControl:ITimeControl)
		{
			// initialize the interaction operation
			super();
			
			// set the interaction and time control
			_interactionControl = interactionControl;
			_timeControl = timeControl;
		}
		
		/**
		 * Undoes the interaction operation by reverting the state of the
		 * interaction operation to immediately before the interaction
		 * operation was performed.
		 */
		override public function undo():void
		{
			super.undo();
			_interactionControl.selection = oldSelection;
			_timeControl.time = startTime;
			_interactionControl.determineMode();
			_interactionControl.triggerInterfaceUpdate();
			
			var i:int;
			var currentObject:KObject
			
			if(oldSelection)
			{
				for(i = 0; i< oldSelection.objects.length(); i++)
				{
					currentObject = oldSelection.objects.getObjectAt(i);
					currentObject.transformInterface.dirty = true;
					currentObject.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_CHANGED, currentObject, startTime));
				}
			}
		}
		
		/**
		 * Redoes the interaction operation by reverting the state of the
		 * interaction operation to immediately after the interaction
		 * operation was performed.
		 */
		override public function redo():void
		{
			super.redo();
			_interactionControl.selection = newSelection;
			_timeControl.time = endTime;
			_interactionControl.determineMode();
			_interactionControl.triggerInterfaceUpdate();
			
			var i:int;
			var currentObject:KObject;
			if(newSelection)
			{
				for(i = 0; i< newSelection.objects.length(); i++)
				{
					currentObject = newSelection.objects.getObjectAt(i);
					currentObject.transformInterface.dirty = true;
					currentObject.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_CHANGED, currentObject, endTime));
				}
			}
		}
		
		/**
		 * Checks whether the interaction operation is valid. If not, it should
		 * fail on construction and not be added to the interaction operation
		 * stack. Validity for interaction operations involves valid start
		 * and end times.
		 * 
		 * @return Whether the interaction operation is valid.
		 */
		override public function isValid():Boolean
		{
			// checks whether start and end times are valid
			return (!isNaN(startTime) && !isNaN(endTime));
		}
		
		/**
		 * Gets the error message for the interaction operation.
		 * 
		 * @return The error message for the interaction operation.
		 */
		override public function get errorMessage():String
		{
			// case: the error is not related to validity
			// throw the corresponding non-validity error message
			if(isValid())
				return super.errorMessage;
			
			// case: the error is related to validity
			// throw validity-related error
			else
				return "The start and end time for this interaction operation has not been specified";
		}
	}
}