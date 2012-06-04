/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.event
{
	import sg.edu.smu.ksketch.utilities.IModelObjectList;
	import sg.edu.smu.ksketch.interactor.KSelection;

	public class KSelectionChangedEvent extends KModelEvent
	{
		public static const EVENT_SELECTION_CHANGING:String = "selection changing";
		public static const EVENT_SELECTION_CHANGED:String = "selection changed";
		
		private var _oldSelection:KSelection;
		private var _newSelection:KSelection;
		
		public function KSelectionChangedEvent(
			type:String, oldSelection:KSelection, newSelection:KSelection)
		{
			super(type);
			_oldSelection = oldSelection;
			_newSelection = newSelection;
		}

		public function get oldSelection():KSelection
		{
			return _oldSelection;
		}

		public function get newSelection():KSelection
		{
			return _newSelection;
		}


	}
}