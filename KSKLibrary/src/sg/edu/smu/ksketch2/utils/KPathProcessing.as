package sg.edu.smu.ksketch2.utils
{
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.model.data_structures.KPath;
	import sg.edu.smu.ksketch2.model.data_structures.KTimedPoint;

	public class KPathProcessing
	{
		/**
		 * Adds dx and dy to the portion of path starting from startProportion to endProportion
		 */
		public static function interpolateSpan(path:KPath,
											   startProportion:Number, endProportion:Number,
											   dx:Number, dy:Number):void
		{
			if(path.length == 0)
				throw new Error("Given path is empty, can't interpolate");
			
			var points:Vector.<KTimedPoint> = path.points;
			var index:int = 0;
			var duration:int = path.pathDuration;
			var currentProportion:Number = 0;;
			var currentPoint:KTimedPoint;
			
			//If the duration of this path is 0
			//offset the whole thing with dx and dy
			if(duration == 0)
			{
				index = 0;
				for(index; index < points.length; index++)
				{
					currentPoint = points[index];
					currentPoint.x += dx;
					currentPoint.y += dy;
				}
			}
			else
			{
				var stepDx:Number;
				var stepDy:Number;
				var propDiff:Number = endProportion - startProportion;
				var interpolationFactor:Number;
				
				for(index; index < points.length; index++)
				{
					currentPoint = points[index];
					currentProportion = currentPoint.time/duration;
					
					if(startProportion <= currentProportion)
					{
						interpolationFactor = (currentProportion - startProportion) / propDiff;
						
						if(interpolationFactor < 0)
							interpolationFactor = 0;
						else if(interpolationFactor > 1)
							interpolationFactor = 1;
						
						stepDx = dx * interpolationFactor;
						stepDy = dy * interpolationFactor;
						
						currentPoint.x += stepDx;
						currentPoint.y += stepDy;
					}
				}
			}
		}
		
		/**
		 * Makes sure that a path has at least one point in every frame
		 * in the time span that it is active in, and that it begins and ends
		 * at frames.
		 * 
		 * If a path is empty. It will not be filled
		 */
		public static function normalisePathDensity(path:KPath):void
		{
			if(path.length == 0)
				return;
			
			var duration:int = path.pathDuration;
			
			if(duration == 0)//nothing to be done here // maybe make sure that there are at least 2 points at 0
				return;
			
			//Round the duration to the nearest frame
			var remainingDuration:int = duration%KSketch2.ANIMATION_INTERVAL;
			var toAdd:int = Math.round(remainingDuration/KSketch2.ANIMATION_INTERVAL)*KSketch2.ANIMATION_INTERVAL;
			duration = duration - remainingDuration + toAdd;
			
			var refinedPoints:Vector.<KTimedPoint> = new Vector.<KTimedPoint>();
			var currentTime:int = 0;
			var currentPoint:KTimedPoint;
			
			for(currentTime; currentTime <= duration; currentTime += KSketch2.ANIMATION_INTERVAL)
			{
				currentPoint = path.find_Point(currentTime/duration);
				refinedPoints.push(currentPoint);
			}
			
			path.points = refinedPoints;
		}
		
		/**
		 * Makes a path linear vs time
		 */
		public static function discardPathTimings(path:KPath):void
		{
			if(path.length == 0)
				return; //return, nothing to discard
			
			var currentTime:int = 0;
			var currentProportion:Number = 0;
			var currentPoint:KTimedPoint;
			var pathDuration:int = path.pathDuration;
			var newPoints:Vector.<KTimedPoint> = new Vector.<KTimedPoint>();
			
			while(currentProportion <= 1)
			{
				currentPoint = path.find_Point_By_Magnitude(currentProportion);
				currentPoint.time = currentTime;
				newPoints.push(currentPoint);
				currentTime += KSketch2.ANIMATION_INTERVAL;
				currentProportion = currentTime / pathDuration;
			}
			
			path.points = newPoints;
		}
		
		/**
		 * Replace straight line between points with Catmull Rom Spline
		 */
		public static function CatmullRomSpline(path:KPath):void
		{
			var points:Vector.<KTimedPoint> = path.points;
			
			//Check there is at least 4 control points
			var pCtr:int = points.length;
			
			if(pCtr < 4)
				return;
			
			//Set tangent for all points
			var m:Array = new Array(pCtr);
			
			//Tangent for first control point
			m[0] = PointTangent(points[1], points[0]);
			pCtr--;
			
			//Tangent for the rest of control points
			for(var i:int = 1; i<pCtr; i++)
			{
				m[i] = PointTangent(points[i + 1], points[i - 1]);
			}
			
			//Tangent for last control point
			m[pCtr] = PointTangent(points[pCtr], points[pCtr - 1]);
			
			//Create new points for Catmull Rom Spline
			var newPoints:Vector.<KTimedPoint> = new Vector.<KTimedPoint>();
			
			var nxtJ:int;
			var p0:KTimedPoint;
			var p1:KTimedPoint;
			var m0:KTimedPoint;
			var m1:KTimedPoint;
			
			for(var j:int = 0; j < pCtr; j++)
			{
				nxtJ = j + 1;
				p0 = points[j];
				p1 = points[nxtJ];
				m0 = m[j];
				m1 = m[nxtJ];
				
				//Set resolution to maximum update every 1 pixel
				var res:Number = 1/(1 + distance(p0, p1))*3;
				
				for(var t:Number = 0; t < 1; t+=res)
				{
					var t2:Number = t * t;
					var OneMinusT:Number = 1 - t;
					var twoT:Number = 2*t;
					
					var h00:Number = (1 + twoT)*OneMinusT*OneMinusT;
					var h10:Number = t*OneMinusT*OneMinusT;
					var h01:Number = t2*(3 - twoT);
					var h11:Number = t2*(t - 1);					
					
					var xCoord:Number = h00 * p0.x + h10 * m0.x + h01 * p1.x + h11 * m1.x;
					var yCoord:Number = h00 * p0.y + h10 * m0.y + h01 * p1.y + h11 * m1.y;
					
					newPoints.push(new KTimedPoint(xCoord, yCoord));
				}		
			}
			
			//Add last control point to Catmull Rom Spline
			newPoints.push(new KTimedPoint(points[pCtr].x, points[pCtr].y));
			var myPoint:KTimedPoint;
			for(var a:int = 0; a < newPoints.length; a++)
			{
				myPoint = newPoints[a];
				myPoint.time = a/newPoints.length*path.pathDuration;
			}
			
			path.points = newPoints;
		}
		
		public static function distance(p1:KTimedPoint, p2:KTimedPoint):Number
		{
			return Math.sqrt(((p1.x-p2.x)*(p1.x-p2.x))+((p1.y-p2.y)*(p1.y-p2.y)));
		}
		
		/**
		 * Used to calculate tangent of control points in Catmull Rom Spline
		 */
		public static function PointTangent(prevPt:KTimedPoint, nxtPt:KTimedPoint):KTimedPoint
		{
			return new KTimedPoint((prevPt.x - nxtPt.x)/2, (prevPt.y - nxtPt.y)/2);
		}
	}
}