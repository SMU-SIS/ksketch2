/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.canvas.controls.interactors.draw.selectors
{
	/**
	 * The KPortion class serves as the concrete class for representing
	 * portions of points in K-Sketch.
	 */
	public class KPortion
	{
		private var _total:uint;		// the total number of points
		private var _selected:uint;		// the selected number of points
		
		/**
		 * The main constructor of the KPortion class. This constructor
		 * sets the total and selected number of points.
		 * 
		 * @param totalPnts The total number of points.
		 * @param selectedPnts The selected number of points.
		 */
		public function KPortion(totalPnts:uint, selectedPnts:uint)
		{
			// set the total number of points
			_total = totalPnts;
			
			// set the selected number of points
			_selected = selectedPnts;
		}
		
		/**
		 * Gets the total number of points.
		 * 
		 * @return The total number of points.
		 */
		public function get total():uint
		{
			return _total;
		}
		
		/**
		 * Gets the selected number of points.
		 * 
		 * @return The selected number of points.
		 */
		public function get selected():uint
		{
			return _selected;
		}
		
		/**
		 * Gets the portion of the points. This involves getting the ratio
		 * of selected number of points to total number of points.
		 * 
		 * @return The portion of the points.
		 */
		public function get portion():Number
		{
			// case: total # of points == 0, return 0
			// case: total # of points != 0, return ratio
			return _total == 0 ? 0 : ( _selected / _total );
		}
	}
}