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
	}
}