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
	public class K3DPath
	{
		public var points:Vector.<K3DVector>;
		
		public function K3DPath()
		{
			points = new Vector.<K3DVector>();
		}
		
		/**
		 * Appends a point to the end of the path
		 */
		public function push(x:Number,y:Number,z:Number):void
		{
			points.push(new K3DVector(x,y,z));
		}
		
		/**
		 * Removes the first point of the path and returns it.
		 */
		public function shift():Vector.<K3DVector>
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
		public function getPoint(proportion:Number):K3DVector
		{
			//No Path, return what getPointByIndex is coded to do.
			if(points.length == 0)
				return null;
			
			if(proportion <= 0)
				return points[0];
			
			if(1 <= proportion)
				return points[length-1];
			
			var time:Number = points[0].z + proportion*(points[length-1].z - points[0].z);	
			
			var startIndex:int = getIndexAtOrBeforeTime(time);
			var startPoint:K3DVector = getPointByIndex(startIndex);
			
			//Point.time == given time, just return without interpolation
			if(startPoint.z == time)
				return startPoint
			else
			{
				//Last Point, no need to interpolate)
				if(startIndex == points.length -1)
					return startPoint
				
				//Interpolate point
				var nextPoint:K3DVector = getPointByIndex(startIndex+1);
				
				var timeDifference:Number = time - startPoint.z;
				
				var proportionDifference:Number = timeDifference/(nextPoint.z-startPoint.z);
				//interpolate by difference
				var finalX:Number = startPoint.x+(nextPoint.x - startPoint.x)*proportionDifference;
				var finalY:Number = startPoint.y+(nextPoint.y - startPoint.y)*proportionDifference;
				var finalZ:Number = time;
				
				return new K3DVector(finalX, finalY, finalZ);
			}
			
			return null;
		}
		
		/**
		 * Returns the point at the given index
		 * If path is empty, returns null;
		 * If given index <0, returns first point
		 * If given length <= index, returns last point
		 */
		public function getPointByIndex(index:int):K3DVector
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
		 * Returns the index of a point before or at the given time.
		 * If there is no path, returns -1.
		 * If time < path start time, returns first point.
		 * If path end time < time, returns last point.
		 */
		public function getIndexAtOrBeforeTime(time:Number):int
		{
			var i:int = 0;
			var length:int = points.length;
			var point:K3DVector;
			
			if(length == 0)
				return -1;
			
			if(points[length-1].z <= time)
				return length-1;
			
			for(i=0; i<length; ++i)
			{
				if(time <= points[i].z)
				{
					if(time < points[i].z)
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
			var point:K3DVector;
			
			if(length == 0)
				return -1;
			
			if(points[length-1].z <= time)
				return length-1;
			
			for(i=0; i<length; ++i)
			{
				if(time <= points[i].z)
				{
					if(time == points[i].z)
						return(getNextIndexAtSameTime(i,time));
					
					return i;
				}
			}
			
			return i-1;
		}
		
		public function getNextIndexAtSameTime(startIndex:int, time:Number):int
		{
			var nextIndex:int = startIndex + 1;
			
			if(nextIndex < points.length)
			{
				var nextTime:Number = points[nextIndex].z;
				
				if(time==nextTime)
					return getNextIndexAtSameTime(nextIndex,time);
			}
			
			return startIndex
		}
		
		/**
		 * Creates a copy of this path and returns it
		 */
		public function clone():K3DPath
		{
			var clone:K3DPath = new K3DPath();
			clone.points = clonePath(points);
			return clone;
		}
		
		/**
		 * Creates a copy of the path vector
		 */
		public static function clonePath(targetPath:Vector.<K3DVector>):Vector.<K3DVector>
		{
			var pathClone:Vector.<K3DVector> = new Vector.<K3DVector>();
			
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
		public function split(proportion:Number, shift:Boolean = false):K3DPath
		{
			var bisectionPoint:K3DVector = new K3DVector();
			var newPath:K3DPath = new K3DPath();
			
			//if path length shorter than 2, then return an empty path
			if(points.length < 2)
				return newPath;
			
			var duration:Number = points[length-1].z;
			
			var oldTransformPoint:K3DVector = getPoint(1);
			var oldX:Number = oldTransformPoint.x;
			var oldY:Number = oldTransformPoint.y;
			
			bisectionPoint = getPoint(proportion);
			
			var i:int = this.getIndexAtOrBeforeTime(proportion*duration);
			var removedPoints:Vector.<K3DVector> = points.splice(0, i-1);
			
			removedPoints.push(bisectionPoint.clone());
			
			if(points.length == 1)
				points.unshift(bisectionPoint.clone());
			
			newPath.points = removedPoints;
			
			var startPoint:K3DVector = points[0].clone() as K3DVector;
			var currentPoint:K3DVector;
			
			for(var j:int = 0; j<points.length; j++)
			{
				currentPoint = points[j];
				currentPoint.z -= startPoint.z;
				
				if(shift)
				{
					currentPoint.x -= startPoint.x;
					currentPoint.y -= startPoint.y;
				}
			}
			
			var midEnd:K3DVector = newPath.getPoint(1);
			var midX:Number = midEnd.x;
			var midY:Number = midEnd.y;
			
			var backEnd:K3DVector = getPoint(1);
			var backX:Number = backEnd.x;
			var backY:Number = backEnd.y;
			var xError:Number = oldX - midX - backX;
			var yError:Number = oldY - midY - backY;
			
			if(xError !=0 || yError !=0)
				correctPathError(xError, yError);
			
			return newPath;
		}
		
		public function printPoints():void
		{
			for(var i:int = 0; i< points.length; i++)
			{
				trace(points[i].x, points[i].y,points[i].z);	
			}			
		}
		
		private function correctPathError(xError:Number, yError:Number):void
		{
			var pathLength:int = points.length;
			
			var duration:Number;
			
			if(pathLength == 0)
				duration = 0;
			else
				duration = points[pathLength-1].z;
			
			var i:int = 0;
			var currentPoint:K3DVector;
			var proportion:Number;
			
			for(i = 0; i<pathLength; i++)
			{
				currentPoint = points[i];
				
				if(duration == 0)
					proportion = i/(pathLength-1);
				else
					proportion  = currentPoint.z/duration;
				
				currentPoint.x += proportion*xError;
				currentPoint.y += proportion*yError;
			}
		}
	}
}