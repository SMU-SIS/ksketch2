/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package sg.edu.smu.ksketch.model.geom
{
	import sg.edu.smu.ksketch.utilities.KMathUtil;

	public class K2DPath
	{
		public var points:Vector.<K2DVector>;
		private var _magnitudeTable:Vector.<Number>;
		
		public function K2DPath()
		{
			points = new Vector.<K2DVector>();
		}
		
		/**
		 * Appends a point to the end of the path
		 */
		public function push(x:Number, y:Number):void
		{
			points.push(new K2DVector(x,y));
		}
		
		/**
		 * Removes the first point of the path and returns it.
		 */
		public function shift():Vector.<K2DVector>
		{
			return points.shift();
		}
		
		public function get length():int
		{
			return points.length;
		}
		
		/**
		 * Returns the point at the given time.
		 * If given time is before the start of the path, the first point will be returned
		 * If given time is after the end of the path, the last point will be returned.
		 * If there are no points at the time, an interpolated point will be returned
		 */
		public function getPoint(proportion:Number):K2DVector
		{
			//No Path, return what getPointByIndex is coded to do.
			if(points.length == 0)
				return null;
			
			if(proportion <= 0)
				return points[0];
			
			if(1 <= proportion)
				return points[length-1];
			
			var time:Number = points[0].y + proportion*(points[length-1].y - points[0].y);	
			
			var startIndex:int = getIndexAtOrBeforeTime(time);
			var startPoint:K2DVector = getPointByIndex(startIndex);
			
			//Point.time == given time, just return without interpolation
			if(startPoint.y == time)
				return startPoint
			else
			{
				//Last Point, no need to interpolate)
				if(startIndex == points.length -1)
					return startPoint
				
				//Interpolate point
				var nextPoint:K2DVector = getPointByIndex(startIndex+1);
				
				var timeDifference:Number = time - startPoint.y;
				
				var proportionDifference:Number = timeDifference/(nextPoint.y-startPoint.y);
				//interpolate by difference
				var finalX:Number = startPoint.x+(nextPoint.x - startPoint.x)*proportionDifference;
				var finalY:Number = time;
				
				return new K2DVector(finalX, finalY);
			}
			
			return null;
		}
		
		/**
		 * Returns the point at the given index
		 * If path is empty, returns null;
		 * If given index <0, returns first point
		 * If given length <= index, returns last point
		 */
		public function getPointByIndex(index:int):K2DVector
		{
			if(points.length == 0)
				return null;
			
			if(index < 0)
				return points[0].clone();
			
			if(points.length <= index)
				return points[points.length-1].clone();
			
			return points[index].clone();
		}
		
		
		/**
		 * Returns the index of a point before or at the given time
		 * If there is no path, returns -1
		 * If time < path start time, returns first point
		 * If path end time < time, returns last point
		 */
		public function getIndexAtOrBeforeTime(time:Number):int
		{
			var i:int = 0;
			var length:int = points.length;
			var point:K2DVector;
			
			if(length == 0)
				return -1;
			
			if(points[length-1].y <= time)
				return length-1;
			
			for(i=0; i<length; ++i)
			{
				if(time <= points[i].y)
				{
					if(time < points[i].y)
						break; //break after finding the index after time
					else
						return(getNextIndexAtSameTime(i,time));
				}
			}
			
			if(i==0)
				return 0; //time == start point's time
			
			return i-1; //returns index-1
		}
		
		/**
		 *Returns the path at or after the given time.
		 */
		public function getIndexAtOrAfterTime(time:Number):int
		{
			var i:int = 0;
			var length:int = points.length;
			var point:K2DVector;
			
			if(length == 0)
				return -1;
			
			if(points[length-1].y <= time)
				return length-1;
			
			for(i=0; i<length; ++i)
			{
				if(time <= points[i].y)
				{
					if(time == points[i].y)
						return(getNextIndexAtSameTime(i,time));
					
					return i;
				}
			}
			
			return i;
		}
		
		public function getNextIndexAtSameTime(startIndex:int, time:Number):int
		{
			var nextIndex:int = startIndex + 1;
			
			if(nextIndex < points.length)
			{
				var nextTime:Number = points[nextIndex].y;
				
				if(time==nextTime)
					return getNextIndexAtSameTime(nextIndex,time);
			}
			
			return startIndex
		}
		
		/**
		 * Creates a copy of this path and returns it
		 */
		public function clone():K2DPath
		{
			var clone:K2DPath = new K2DPath();
			clone.points = clonePath(points);
			return clone;
		}
		
		/**
		 * Creates a copy of the path vector
		 */
		public static function clonePath(targetPath:Vector.<K2DVector>):Vector.<K2DVector>
		{
			var pathClone:Vector.<K2DVector> = new Vector.<K2DVector>();
			
			var i:int = 0;
			var pathLength:int = targetPath.length;
			
			//clone te path
			for(i=0;i<pathLength;i++)
				pathClone.push(targetPath[i].clone());
			
			return pathClone;
		}
		
		/**
		 * Modify the targetPath by removing all points with time <= kskTime.
		 * The remaining path will being at the time of bisection.
		 * Returns a new KPath made up of the removed points, ending at the time of bisection
		 */
		public function split(proportion:Number, shift:Boolean = false):K2DPath
		{
			var bisectionPoint:K2DVector = new K2DVector();
			var newPath:K2DPath = new K2DPath();
			
			//if path length shorter than 2, then return an empty path
			if(points.length < 2)
				return newPath;
			
			var duration:Number = points[length-1].y
			
			bisectionPoint = getPoint(proportion);
			
			var i:int = this.getIndexAtOrBeforeTime(proportion*duration);
			var removedPoints:Vector.<K2DVector> = points.splice(0, i-1);
			
			removedPoints.push(bisectionPoint.clone());
			points.unshift(bisectionPoint.clone());
			
			newPath.points = removedPoints;
			
			var startPoint:K2DVector = points[0].clone() as K2DVector;
			var currentPoint:K2DVector;
			
			for(var j:int = 0; j<points.length; j++)
			{
				currentPoint = points[j];
				currentPoint.y -= startPoint.y;
				
				//if(shift)
				//{
				currentPoint.x -= startPoint.x;
				//}
			}
			
			return newPath;
		}
		
		public function printPoints():void
		{
			for(var i:int = 0; i< points.length; i++)
			{
				trace(points[i].x, points[i].y);	
			}			
		}
		
		public function getPointByProportion(proportion:Number):K2DVector
		{
			var i:int;
			var length:int = points.length;
			
			for(i = 0; i < length-1; i++)
			{
				if(proportion < _magnitudeTable[i])
				{ 
					i-=1;
					break;
				}
			}
			
			var startIndex:int = i;
			var startPoint:K2DVector = getPointByIndex(startIndex);
			
			if(startIndex == length-1)
				return startPoint;
			
			//Point.time == given time, just return without interpolation
			//Last Point, no need to interpolate)
			if(startIndex == points.length -1)
				return startPoint
			
			//Interpolate point
			var nextPoint:K2DVector = getPointByIndex(startIndex+1);
			
			var proportionDifference:Number = (proportion-_magnitudeTable[startIndex])/(_magnitudeTable[startIndex+1]-_magnitudeTable[startIndex]);
			
			//interpolate by difference
			var finalX:Number = startPoint.x+(nextPoint.x - startPoint.x)*proportionDifference;
			var finalY:Number = startPoint.y+(nextPoint.y - startPoint.y)*proportionDifference;
			
			return new K2DVector(finalX, finalY);
		}
		
		public function generateMagnitudeTable():void
		{
			_magnitudeTable = new Vector.<Number>();
			
			var length:int = points.length;
			var i:int;

			var currentMagnitude:Number = 0;
			_magnitudeTable.push(points[0].x);
			
			for(i = 1; i < length; i++)
			{
				currentMagnitude += Math.abs(points[i].x - points[i-1].x);
				_magnitudeTable.push(currentMagnitude);
			}
			
			for(i = 0; i < length; i++)
				_magnitudeTable[i] = _magnitudeTable[i]/currentMagnitude;
		}
	}
}