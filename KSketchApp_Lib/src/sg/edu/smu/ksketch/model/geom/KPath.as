package sg.edu.smu.ksketch.model.geom
{
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch.utilities.KMathUtil;

	/**
	 * KPath stores the path point of spatial key frame from 0 to duration.
	 */
	public class KPath
	{
		public static const MOVETO:int = 0;
		public static const LINETO:int = 1;
		public static const MINIMUM_DISPLAY_DURATION:Number = 1.0;
		
		public var path:Vector.<KPathPoint>;
		
		public function KPath()
		{
			path = new Vector.<KPathPoint>();
		}
		
		/**
		 * The length of this path
		 */
		public function get length():int
		{
			return path.length;
		}
		
		/**
		 * Returns the duration of the path
		 */
		public function get duration():Number
		{
			if(length == 0)
				return 0;
			
			return path[length-1].time - path[0].time;			
		}
		
		/**
		 * Append a point to the end of this path.
		 * x and y should be in absolute values relative to the holding keyframe's center
		 * time should be in negative duration
		 * type should be either 0(move to) or 1(line to)
		 */
		//store as proportion instead of time!
		public function addPoint(x:Number = 0, y:Number = 0, time:Number = 0, type:int = 0):void //tested
		{
			path.push(new KPathPoint(x,y,time,type));
		}
		
		/**
		 * Currently requires a time input. Computing the path's proportion cumulatively is too costly now.
		 * Returns the point on the path that is the given fraction of the way from 
		 * the first point to the last point. Fraction is assumed to be between 0 and 1.
		 * If fraction < 0, returns the first point. If Fraction is 1 < fraction,
		 * returns the last point.
		 */
		//take time input only
		public function getPoint(proportion:Number):KPathPoint
		{
			var time:Number = proportion * duration;
			
			var baseIndex:int = getIndexAtOrBefore(time);
			
			if(path.length == 0)
				return null;
			
			if(baseIndex < 0)
				return path[0];
			
			if(length <= (baseIndex+1))
				return path[length-1];
			
			var pathPoint:KPathPoint = path[baseIndex].clone() as KPathPoint;
			var nextPoint:KPathPoint = path[baseIndex+1].clone() as KPathPoint;
			
			var timeDifference:Number = time-pathPoint.time;
			var proportionDifference:Number = timeDifference/(nextPoint.time-pathPoint.time);
			
			//interpolate by difference
			var differenceVector:Point = nextPoint.subtract(pathPoint);
			pathPoint.x += differenceVector.x*proportionDifference;
			pathPoint.y += differenceVector.y*proportionDifference;
			pathPoint.time = time;
			
			return pathPoint;
		}
		
		/**
		 * Returns a copy of the point at index
		 * Returns null if index < 0 or if point does not exist
		 */
		//Tested with -1,0,50,99,100,101 for 100 points
		public function getPointByIndex(index:int):KPathPoint
		{
			if(index < 0)
				return null;
			
			if(index < path.length)
			{	
				return path[index].clone() as KPathPoint;
			}
			else
			{
				return null;
			}
		}
		
		/**
		 * Returns a copy of the last point for which point time <= time
		 * Returns null if time < path[0].time
		 * Returns path[length-1] if path[length-1].time < time
		 */
		//Tested with -101, -100, -99, -50, -1, 0, 1 for time -100 to 0
		public function getAtOrBefore(time:Number):KPathPoint
		{
			var index:int = getIndexAtOrBefore(time);

			return getPointByIndex(index);
		}
		
		/**
		 * Returns a copy of the first point for which time <= point time
		 * Returns null if path[length-1].time < time
		 * Returns path[0] if time < path[0].time
		 */
		//Tested with -101, -100, -99, -50, -1, 0, 1 for time -100 to 0
		public function getAtOrAfter(time:Number):KPathPoint
		{
			var index:int = getIndexAtOrAfter(time);
			
			return getPointByIndex(index);
		}
		
		/**
		 * Returns the index of last point for which point time <= time
		 * Returns -1 if time < path[0].time
		 * Returns path.length-1 if path[length-1].time < time
		 */
		//Tested with -101, -100, -99, -50, -1, 0, 1 for time -100 to 0
		public function getIndexAtOrBefore(time:Number):int
		{
			var i:int = 0;
			var length:int = path.length;
			var point:KPathPoint;
			
			if(length == 0)
			{
				return -1;
			}
			
			//Unoptimised search
			for(i=0; i<length; ++i)
			{
				if(time < path[i].time)
				{
					break; //break after finding the index after time
				}
			}
			
			if(i==0)
			{
				if(time < path[0].time)
				{
					return -1; //No points before time, return -1
				}
				else
					return 0; //time == start point's time
			}
			else
			{
				return i-1; //returns index of point before the one after
			}
		}
		
		/**
		 * Returns the index of last point for which point time <= time
		 * Returns 0 if time < path[0].time
		 * Returns -1 if time < path[length-1].time
		 */
		//Tested with -101, -100, -99, -50, -1, 0, 1 for time -100 to 0
		public function getIndexAtOrAfter(time:Number):int
		{
			var i:int = 0;
			var length:int = path.length;
			var point:KPathPoint;
			
			//Unoptimised search
			for(i=0; i<length; i++)
			{
				if(time <= path[i].time)
					return i; //Return i if found
			}
			
			return -1; //else return -1
		}
		
		/**
		 * Replaces the point at given index with a copy of the given point
		 * If index < 0, pathPoint will be prepended to this path
		 * If index > length-1, the path will be extended with empty points 
		 * so that it is possible to add a point at this index.
		 */
		//Tested with -1, 0, 50, 99, 100, 110 for insert into index 0 to 99 
		public function setPointByIndex(index:int, point:KPathPoint):void
		{
			var difference:int = index - length;
			
			//Determine if there is a need to extend path
			if(difference < 0)
			{
				if(index < 0)
					path.splice(0,0,point); //prepend point to path
				else
					path[index] = point.clone() as KPathPoint; //replaces the point at index
			}
			else
			{
				var i:int = 0;
				var numIterations:int = difference;
				var lastPoint:KPathPoint = path[length-1] as KPathPoint
				
				//Inserts a copy of the last point to extend the path
				for(i = 0; i< numIterations; i++)
				{
					path.push(lastPoint.clone());
				}
				
				//Inserts the given point
				path.push(point.clone());
			}
		}
		
		/**
		 * Replaces the points starting at the given index with a copy of the given points.
		 * If index < 0, then -index points will be prepended to this path and points will
		 * be set starting at 0. 
		 * The path will be extended (with empty points if necessary) to make space for all 
		 * of the given points.
		 */
		//Tested with vector length 5, index -5,-1,0,1,5
		public function setPointsByIndex(index:int, points:Vector.<KPathPoint>):void
		{
			var i:int = 0;
			
			if(index < 0)
			{
				for(i=0; i<-index; i++)
				{
					path.splice(i,0,points[i]);
				}
			}
			else
			{
				for(i = 0; i < index; i++)
					setPointByIndex(length,points[i]);
			}
		}
		
		/**
		 * Creates a copy of this KPath and returns it
		 */
		public function clone():KPath
		{
			var clone:KPath = new KPath();
			clone.path = clonePath(path);
			return clone;
		}
		
		/**
		 * Creates a copy of the path vector
		 */
		public static function clonePath(targetPath:Vector.<KPathPoint>):Vector.<KPathPoint>
		{
			var pathClone:Vector.<KPathPoint> = new Vector.<KPathPoint>();
			
			var i:int = 0;
			var pathLength:int = targetPath.length;
			
			//clone te path
			for(i=0;i<pathLength;i++)
				pathClone.push(targetPath[i].clone() as KPathPoint);
			
			return pathClone;
		}
		
		/**
		 * Modify the targetPath by removing all points with time <= kskTime.
		 * The remaining path will being at the time of bisection.
		 * Returns a new KPath made up of the removed points, ending at the time of bisection
		 */
		public function split(proportion:Number, shift:Boolean = false):KPath
		{
			var bisectionPoint:KPathPoint = new KPathPoint();
			var newPath:KPath = new KPath();

			//if path length shorter than 2, then return an empty path
			if(path.length < 2)
				return newPath;
			
			var oldTransformPoint:KPathPoint = getPoint(1);
			var oldX:Number = oldTransformPoint.x;
			var oldY:Number = oldTransformPoint.y;
			
			bisectionPoint = getPoint(proportion);
			
			var i:int = getIndexAtOrBefore(proportion*duration);
			var removedPoints:Vector.<KPathPoint> = path.splice(0, i-1);
			removedPoints.push(bisectionPoint.clone());
			
			if(path.length == 1)
				path.unshift(bisectionPoint.clone() as KPathPoint);
			
			newPath.path = removedPoints;

			var startPoint:KPathPoint = path[0].clone() as KPathPoint;
			var currentPoint:KPathPoint;
			
			for(var j:int = 0; j<path.length; j++)
			{
				currentPoint = path[j];
				currentPoint.time -= startPoint.time;
				
				if(shift)
				{
					currentPoint.x -= startPoint.x;
					currentPoint.y -= startPoint.y;
				}
			}
			
			var midEnd:KPathPoint = newPath.getPoint(1);
			var midX:Number = midEnd.x;
			var midY:Number = midEnd.y;
			
			var backEnd:KPathPoint = getPoint(1);
			var backX:Number = backEnd.x;
			var backY:Number = backEnd.y;
			var xError:Number = oldX - midX - backX;
			var yError:Number = oldY - midY - backY;
			
			if(xError !=0 || yError !=0)
				correctPathError(xError, yError);
			
			return newPath;
		}
		
		private function correctPathError(xError:Number, yError:Number):void
		{
			var pathLength:int = path.length;
			
			var duration:Number;
			
			if(pathLength == 0)
				duration = 0;
			else
				duration = path[pathLength-1].time;
			
			var i:int = 0;
			var currentPoint:KPathPoint;
			var proportion:Number;
			
			for(i = 0; i<pathLength; i++)
			{
				currentPoint = path[i];
				
				if(duration == 0)
					proportion = i/(pathLength-1);
				else
					proportion  = currentPoint.time/duration;
				
				currentPoint.x += proportion*xError;
				currentPoint.y += proportion*yError;
			}
		}
	}
}