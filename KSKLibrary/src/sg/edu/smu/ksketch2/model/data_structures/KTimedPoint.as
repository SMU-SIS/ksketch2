/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.model.data_structures
{
	/**
	 * The KTimedPoint class serves as the concrete class that defines the core
	 * implementations of timed points in K-Sketch. Timed points consist of points
	 * containing the x-position, y-position, and time.
	 */
	public class KTimedPoint
	{
		public var x:Number;	// x-position
		public var y:Number;	// y-position
		public var time:int;	// time
		
		/**
		 * The main constructor of the KTimedPoint object. The constructor
		 * sets the spatial and temporal information of the timed point.
		 * 
		 * @param x The x-position.
		 * @param y The y-position.
		 * @param time The time.
		 */
		public function KTimedPoint(x:Number=0, y:Number=0, time:int = 0)
		{
			this.x = x;			// set the x-position
			this.y = y;			// set the y-position
			this.time = time;	// set the time
		}
		
		/**
		 * Adds the x- and y-values from anther timed point into the timed point.
		 * 
		 * @param another_Point The other timed point to add from.
		 */
		public function add(another_Point:KTimedPoint):void
		{
			x += another_Point.x;	// add the x-positions from both timed points
			y += another_Point.y;	// add the y-positions from both timed points
		}
		
		/**
		 * Subtracts the x- and y-values from another timed point into the timed point.
		 * 
		 * @param another_Point The other timed point to subtract from.
		 */
		public function subtract(another_Point:KTimedPoint):void
		{
			x -= another_Point.x;	// subtract the x-positions from both timed points
			y -= another_Point.y;	// subtract the y-positions from both timed points
		}
		
		/**
		 * Checks whether the timed point is equivalent to the other timed point.
		 * If all spatial and temporal information of the timed point is equivalent
		 * to the other given timed point, returns true.  Else, return false.
		 * 
		 * @param another_Point The other timed point.
		 * @return Whether the timed point is equivalent to the other timed point.
		 */
		public function isEqualsTo(another_Point:KTimedPoint):Boolean
		{
			if(another_Point.x == x && another_Point.y == y && another_Point.time == time)
				return true;
			else
				return false;
		}
		
		/**
		 * Gets a clone of the timed point.
		 * 
		 * @return A clone of the timed point.
		 */
		public function clone():KTimedPoint
		{
			return new KTimedPoint(x,y,time);
		}
		
		/**
		 * Serializes the timed point to an XML object.
		 * 
		 * @return The serialized XML object of the timed point.
		 */
		public function serialize():String
		{
			return x.toString()+","+y.toString()+","+time.toString();
		}
		
		/**
		 * Prints the spatial and temporal information of the timed point to the console.
		 */
		public function print():void
		{
			trace("(",x,",",y,",",time,")");
		}
	}
}