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
	import sg.edu.smu.ksketch2.model.data_structures.IKeyFrame;

	/**
	 * The SortingFunctions class serves as the concrete class for handling
	 * sorting functions in K-Sketch.
	 */
	public class SortingFunctions
	{
		/**
		 * Compares the x-positions for both objects.
		 * 
		 * @param marker1 The target first object.
		 * @param marker2 The target second object.
		 * @return The comparison.
		 */
		public static function _compare_x_property(marker1:*, marker2:*):Number
		{
			if(marker1.x <= marker2.x)
				return -1;
			else
				return 1;				
		}
		
		/**
		 * Compares the times for both key frames.
		 * 
		 * @param key1 The target first key.
		 * @param key2 The target second key.
		 * @return The comparison.
		 */
		public static function _compareKeyTimes(key1:IKeyFrame, key2:IKeyFrame):Number
		{
			if(key1.time <= key2.time)
				return -1;
			else
				return 1;				
		}
		
		/**
		 * Compares the values for both integers.
		 * 
		 * @param int1 The target first integer value.
		 * @param int2 The target second integer value.
		 * @param The comparison.
		 */
		public static function _sortInt(int1:int, int2:int):int
		{
			if(int1 <= int2)
				return -1;
			else
				return 1;				
		}
		
	}
}