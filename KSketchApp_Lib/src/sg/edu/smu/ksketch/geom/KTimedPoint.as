/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package sg.edu.smu.ksketch.geom
{
	import flash.geom.Point;

	/**
	 * The extension of Point class with a time dimension. 
	 * The time dimension is represented with an integer.
	 */
	public class KTimedPoint extends Point
	{
		private var _kskTime:Number;
		
		/**
		 * Constructor.
		 * @param time Time of the KTimePoint.
		 * @param x X coordinate of the KTimePoint.
		 * @param y Y coordinate of the KTimePoint.
		 */		
		public function KTimedPoint(time:Number, x:Number=0, y:Number=0)
		{
			super(x, y);
			_kskTime = time;
		}
		
		/**
		 * The time of the KTimedPoint.
		 */		
		public function get kskTime():int
		{
			return _kskTime;
		}
		public function set kskTime(value:int):void
		{
			_kskTime = value;
		}
	}
}