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
	import sg.edu.smu.ksketch2.controls.interactioncontrol.IInteractionControl;
	import sg.edu.smu.ksketch2.controls.widgets.ITimeControl;
	import sg.edu.smu.ksketch2.events.KObjectEvent;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;
	
	public class KInteractionOperation extends KCompositeOperation
	{
		private var _interactionControl:IInteractionControl;
		private var _timeControl:ITimeControl;
		
		public var startTime:int;
		public var endTime:int;
		
		public var newSelection:KSelection;
		public var oldSelection:KSelection;
		
		public function KInteractionOperation(interactionControl:IInteractionControl, timeControl:ITimeControl)
		{
			super();
			_interactionControl = interactionControl;
			_timeControl = timeControl;
		}
		
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
		
		override public function isValid():Boolean
		{
			return (!isNaN(startTime) && !isNaN(endTime));
		}
		
		override public function get errorMessage():String
		{
			if(isValid())
				return super.errorMessage;
			else
				return "The start and end time for this interaction operation has not been specified";
		}
	}
}