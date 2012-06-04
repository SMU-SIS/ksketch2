/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.interactor
{
	public class KPortion
	{
		private var _total:uint;
		private var _selected:uint;
		
		public function KPortion(totalPnts:uint, selectedPnts:uint)
		{
			_total = totalPnts;
			_selected = selectedPnts;
		}
		
		public function get total():uint
		{
			return _total;
		}

		public function get selected():uint
		{
			return _selected;
		}

		public function get portion():Number
		{
			return _total == 0?0:( _selected / _total );
		}
	}
}