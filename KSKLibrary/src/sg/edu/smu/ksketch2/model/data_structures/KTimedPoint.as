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
	public class KTimedPoint
	{
		public var x:Number;
		public var y:Number;
		public var time:int;
		
		public function KTimedPoint(x:Number=0, y:Number=0, time:int = 0)
		{
			this.x = x;
			this.y = y;
			this.time = time;
		}
		
		/**
		 * Adds the x and y values from anther_Point into KTimedPoint object
		 */
		public function add(another_Point:KTimedPoint):void
		{
			x += another_Point.x;
			y += another_Point.y;
		}
		
		/**
		 * Subtracts the x and y values of anther_Point from KTimedPoint object
		 */
		public function subtract(another_Point:KTimedPoint):void
		{
			x -= another_Point.x;
			y -= another_Point.y;
		}
		
		/**
		 * Compares this point to another_Point. 
		 * If all values of this point is equal to those of another_point, returns true
		 * else false
		 */
		public function isEqualsTo(another_Point:KTimedPoint):Boolean
		{
			if(another_Point.x == x && another_Point.y == y && another_Point.time == time)
				return true;
			else
				return false;
		}
		
		/**
		 * Returns a clone of this KTimedPoint object
		 */
		public function clone():KTimedPoint
		{
			return new KTimedPoint(x,y,time);
		}
		
		public function serialize():String
		{
			return x.toString()+","+y.toString()+","+time.toString();
		}
		
		public function print():void
		{
			trace("(",x,",",y,",",time,")");
		}
		
		
		
	}
}