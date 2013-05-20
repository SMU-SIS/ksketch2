/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.controls.interactors.draw.selectors
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