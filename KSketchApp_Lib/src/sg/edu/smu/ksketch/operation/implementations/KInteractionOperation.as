/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package sg.edu.smu.ksketch.operation.implementations
{
	import sg.edu.smu.ksketch.event.KObjectEvent;
	import sg.edu.smu.ksketch.event.KTimeChangedEvent;
	import sg.edu.smu.ksketch.interactor.KSelection;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	import sg.edu.smu.ksketch.utilities.IIterator;
	import sg.edu.smu.ksketch.utilities.KAppState;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;
	
	/**
	 * An operation that is produced through interactions with selected objects.
	 * Each operation of this class contains another opertaion that modifies the model.
	 * This class ensures that after undo or redo, the appropriate objects 
	 * are selected and the timeline is set to the appropriate time.  
	 */
	public class KInteractionOperation implements IModelOperation
	{
		private var _appState:KAppState;
		private var _startTime:Number;
		private var _endTime:Number;
		private var _oldSelection:KSelection;
		private var _newSelection:KSelection;
		private var _change:IModelOperation;
		
		public function KInteractionOperation(appState:KAppState, startTime:Number, 
											  endTime:Number, oldSelection:KSelection, 
											  newSelection:KSelection, change:IModelOperation)
		{
			_appState = appState;
			_startTime = startTime;
			_endTime = endTime;
			_oldSelection = oldSelection;
			_newSelection = newSelection;
			_change = change;
		}
		
		public function get newSelection():KSelection
		{
			return _newSelection;
		}
		
		public function get oldSelection():KSelection
		{
			return _oldSelection;
		}
		
		public function apply():void
		{
			_change.apply();
			_appState.time = _endTime;
			_appState.selection = _newSelection;
		//	_appState.dispatchEvent(new KTimeChangedEvent(0, _endTime));
			if (_newSelection != null)
				_dispatchEvent(_newSelection.objects);
		}
		
		public function undo():void
		{
			_appState.time = _startTime;
			_change.undo();
			_appState.selection = _oldSelection;
		//	_appState.dispatchEvent(new KTimeChangedEvent(0, _startTime));
			if (_oldSelection != null)
				_dispatchEvent(_oldSelection.objects);
		}
		
		private function _dispatchEvent(objs:KModelObjectList):void
		{
			var it:IIterator = objs.iterator;
			while (it.hasNext())
			{
				var obj:KObject = it.next();
				obj.dispatchEvent(new KObjectEvent(obj,KObjectEvent.EVENT_TRANSFORM_CHANGED));
			}
		}
	}
}