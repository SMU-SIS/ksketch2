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
	 * The time dimension is represented using the type Number
	 */
	public class KTimestampPoint extends Point
	{
		private var _timeStamp:Number;
		
		/**
		 * Constructor.
		 * @param timeStamp TimeStamp of the KTimeStampPoint.
		 * @param x X coordinate of the KTimeStampPoint.
		 * @param y Y coordinate of the KTimeStampPoint.
		 */		
		public function KTimestampPoint(timeStamp:Number, x:Number, y:Number)
		{
			super(x, y);
			_timeStamp = timeStamp;
		}

		/**
		 * The time of the KTimedStampPoint.
		 */		
		public function get timeStamp():Number
		{
			return _timeStamp;
		}
		public function set timeStamp(value:Number):void
		{
			_timeStamp = value;
		}
	}
}