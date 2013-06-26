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
	import mx.utils.StringUtil;
	
	import sg.edu.smu.ksketch2.KSketch2;

	public class KPath
	{
		public var points:Vector.<KTimedPoint>;
		
		/**
		 * Class that holds 3d points
		 */
		public function KPath()
		{
			points = new Vector.<KTimedPoint>();
		}
		
		public function isTrivial(thresholdMagnitude:Number):Boolean
		{
			if(points.length == 0)
				return true;
			
			if(thresholdMagnitude < 0)
				throw new Error("KPath.isTrivial: One does not simply give a negative threshold magnitude." +
					"It is known to cause time-space distortions and can destroy the world");
			
			var i:int;
			var length:int = points.length;
			var pathMagnitude:Number = 0;
			var previousPoint:KTimedPoint = points[0];
			var currentPoint:KTimedPoint;
			var dx:Number;
			var dy:Number;
			
			for(i=1; i<length; i++)
			{
				currentPoint  = points[i];
				dx = currentPoint.x - previousPoint.x;
				dy = currentPoint.y - previousPoint.y;
				pathMagnitude += Math.sqrt((dx*dx)+(dy*dy));
				previousPoint = currentPoint;
			}
			
			if(pathMagnitude <= thresholdMagnitude)
				return true;
			
			return false;
		}
		
		public function get pathDuration():int
		{
			if(length == 0)
				return 0;
			else if (length == 1)
				return points[0].time;
			else
				return points[length-1].time - points[0].time;;			
		}
		
		public function get length():int
		{
			return points.length;
		}
		
		/**
		 * Adds a point to the end of this KPath
		 */
		public function push(x:Number=0,y:Number=0,time:int=0):void
		{
			points.push(new KTimedPoint(x,y,time));
		}
		
		/**
		 * Given a proportion of the duration of this path,
		 * Returns the point at the given proportion of time.
		 * If the proportion points to a position in between two
		 * recorded times, will return the interpolated point.
		 * Returns null if the path is empty
		 */
		public function find_Point(proportion:Number):KTimedPoint
		{	
			if(length == 0)
				return null;
			
			if(1 <= proportion)
				return points[length-1];
			
			var duration:int = points[length-1].time - points[0].time;
			
			if(duration == 0)
				return points[length-1];
			
			var baseIndex:int = find_IndexAtOrBeforeProportion(proportion);

			var nextIndex:int = baseIndex+1;
			var basePoint:KTimedPoint = points[baseIndex];
			var nextPoint:KTimedPoint = points[nextIndex];
			
			var baseProportion:Number = basePoint.time/duration;
			var numerator:Number = proportion - baseProportion;
			
			if(numerator == 0)
				return basePoint.clone();
			
			var denominator:Number = (nextPoint.time - basePoint.time)/duration;
			var interpolationFactor:Number = numerator/denominator;
			
			var x:Number = (nextPoint.x-basePoint.x)*interpolationFactor + basePoint.x;
			var y:Number = (nextPoint.y-basePoint.y)*interpolationFactor + basePoint.y;
			var time:Number = (nextPoint.time-basePoint.time)*interpolationFactor + basePoint.time;
			
			return new KTimedPoint(x,y,time);
		}
		
		/**
		 * Given a proportion of the duration of this path,
		 * Returns the point at the given proportion of time.
		 * If the proportion points to a position in between two
		 * recorded times, will return the interpolated point.
		 * Returns null if the path is empty
		 */
		public function find_Point_By_Magnitude(proportion:Number):KTimedPoint
		{
			if(points.length < 2)
				return new KTimedPoint(0,0,0);
			
			var i:int;
			var length:int = points.length;
			var pathMagnitude:Number = 0;
			var previousPoint:KTimedPoint = points[0];
			var magnitudeTable:Vector.<Number> = new Vector.<Number>;
			var currentPoint:KTimedPoint;
			var dx:Number;
			var dy:Number;
			
			magnitudeTable.push(0);
			for(i=1; i<length; i++)
			{
				currentPoint  = points[i];
				dx = currentPoint.x - previousPoint.x;
				dy = currentPoint.y - previousPoint.y;
				pathMagnitude += Math.sqrt((dx*dx)+(dy*dy));
				magnitudeTable.push(pathMagnitude);
				
				previousPoint = currentPoint;
			}
			
			if(pathMagnitude == 0)
				return new KTimedPoint(0,0,0);
			
			var queriedMagnitude:Number = proportion * pathMagnitude;
			
			for(i = 0; i < length-1; i++)
			{
				if(queriedMagnitude <= magnitudeTable[i])
					break;
			}

			var startIndex:int = i - 1;

			if(startIndex < 0)
				startIndex = 0;
			
			var startPoint:KTimedPoint = points[startIndex];
			
			//Point.time == given time, just return without interpolation
			//Last Point, no need to interpolate)
			if(startIndex == points.length -1)
				return startPoint;
			
			//Interpolate point
			var nextPoint:KTimedPoint = points[startIndex+1];
			var denominator:Number = magnitudeTable[startIndex+1]-magnitudeTable[startIndex];
			var proportionDifference:Number;
				
			proportionDifference = (queriedMagnitude-magnitudeTable[startIndex])/denominator;

			//interpolate by difference
			var finalX:Number = startPoint.x+(nextPoint.x - startPoint.x)*proportionDifference;
			var finalY:Number = startPoint.y+(nextPoint.y - startPoint.y)*proportionDifference;
			var finalZ:Number = pathDuration*proportion;
			
			return new KTimedPoint(finalX, finalY, finalZ);
		}
		
		public function find_IndexByMagnitudeProportion(proportion:Number):int
		{
			var i:int;
			var length:int = points.length;
			var pathMagnitude:Number = 0;
			var previousPoint:KTimedPoint = points[0];
			var magnitudeTable:Vector.<Number> = new Vector.<Number>;
			var currentPoint:KTimedPoint;
			var dx:Number;
			var dy:Number;
			
			magnitudeTable.push(0);
			for(i=1; i<length; i++)
			{
				currentPoint  = points[i];
				dx = currentPoint.x - previousPoint.x;
				dy = currentPoint.y - previousPoint.y;
				pathMagnitude += Math.sqrt((dx*dx)+(dy*dy));
				magnitudeTable.push(pathMagnitude);
				previousPoint = currentPoint;
			}
			
			var queriedMagnitude:Number = proportion * pathMagnitude;
			
			for(i = 0; i < length-1; i++)
			{
				if(queriedMagnitude <= magnitudeTable[i])
					break;
			}
			
			var startIndex:int = i - 1;
			
			if(startIndex < 0)
				startIndex = 0;
			
			return startIndex;
		}
		
		/**
		 * Given a proportion of the duration of this path,
		 * Returns the index of the point that is before the given time
		 */
		public function find_IndexAtOrBeforeProportion(proportion:Number):int
		{
			if(length == 0)
				throw new Error("This is an empty path!");
			
			var duration:int = points[length-1].time - points[0].time;
			var proportionDuration:int = proportion * duration;

			var i:int;
			var indexBeforeProp:int = 0;
	
			for(i = 0; i < length; i++)
			{	
				if(points[i].time <= proportionDuration)
					indexBeforeProp = i;
				else
					break;
			}
			
			return indexBeforeProp;
		}
		
		/**
		 * Splits this path into 2 portions according to the given proportion
		 * Returns the front portion of the split path
		 * The last point of the front path will be the same as the first point of the latter path
		 * Special Cases:
		 * Path Length = 0 or Path Length = 1 : Returns empty path. Does not split path
		 * Proportion = 0; Returns empty path. Does not split path
		 * Proportion = 1; Returns The whole path. Replaces path on this KPath with empty path
		 * Oh, remember to set replace key operations before this happen.
		 */
		public function splitPath(proportion:Number):KPath
		{
			var frontPath:KPath = new KPath();
			
			//Optimise for special cases
			if(proportion == 0)
				return frontPath;
			else if(proportion == 1 || length <2)
			{
				frontPath.points = points;
				points = new Vector.<KTimedPoint>();
				return frontPath;
			}
		
			var indexBeforeProp:int = KSketch2.discardTransitionTimings?
										find_IndexByMagnitudeProportion(proportion):
										find_IndexAtOrBeforeProportion(proportion);
			
			//This splice will split the vector into 2 sets
			//frontPoints will contain the points before splitPoint
			//EndPoint 
			var splitPoint:KTimedPoint = find_Point(proportion);
			var frontPoints:Vector.<KTimedPoint> = points.splice(0,indexBeforeProp+1);
			
			if(!frontPoints[frontPoints.length-1].isEqualsTo(splitPoint))
				frontPoints.push(splitPoint.clone());
			
			if(points.length != 0)
			{
				if(!points[0].isEqualsTo(splitPoint))
					points.unshift(splitPoint.clone());
				
				var i:int = 0;
				var pathLength:int = points.length;
				var currentPoint:KTimedPoint;
				//Now, all paths are supposed to have their deltas start from 0
				//So we subtract to clean this up
				for(i = 0; i<pathLength; i++)
				{
					currentPoint = points[i];
					currentPoint.x -= splitPoint.x;
					currentPoint.y -= splitPoint.y;
					currentPoint.time -= splitPoint.time;
				}
			}

			frontPath.points = frontPoints;
			
			return frontPath;
		}
		
		/**
		 * Merge the entire sourcePath into this path from startAtProportion till the end of this path.
		 * The source path will be linearly compressed 
		 */
		public function mergePath(sourcePath:KPath):void
		{
			var i:int;
			var currentPoint:KTimedPoint;	
			var pathLength:int = length;

			if(pathLength == 0)
			{
				var sourceLength:int = sourcePath.points.length;
				for(i = 0; i<sourceLength; i++)
					points.push(sourcePath.points[i].clone());
			}
			else if(pathDuration==0)
			{
				for(i = 0; i<pathLength; i++)
				{
					currentPoint = points[i];
					proportion = i/pathLength;
					currentPoint.add(sourcePath.find_Point(proportion));
				}
			}
			else
			{
				var offSetTime:int = points[0].time;
				var duration:int = pathDuration - offSetTime;
				var proportion:Number;
				for(i = 0; i<pathLength; i++)
				{
					currentPoint = points[i];
					proportion = (currentPoint.time - offSetTime)/duration;
					currentPoint.add(sourcePath.find_Point(proportion));
				}
			}
		}
		
		/**
		 * Appends a path to this path
		 */
		public function appendPath(toBeAppendedPath:KPath):void
		{
			if(length == 0)
			{
				points = toBeAppendedPath.points;
				return;
			}
			
			var lastPoint:KTimedPoint = points[length-1];
			
			var i:int;
			var currentPoint:KTimedPoint;
			
			for(i = 0; i<toBeAppendedPath.length; i++)
			{
				currentPoint = toBeAppendedPath.points[i];
				currentPoint.time += lastPoint.time;
				currentPoint.x += lastPoint.x;
				currentPoint.y += lastPoint.y;
				points.push(currentPoint);
			}
		}
		
		/**
		 * returns a copy of this KPath object
		 */
		public function clone():KPath
		{
			var clone:KPath = new KPath();
			
			var i:int = 0;
			var pathLength:int = length;
			
			for(i=0; i<pathLength; i++)
				clone.points.push(points[i].clone());	
			
			return clone;
		}
		
		public function serialize():XML
		{
			var pathXML:XML = <path type="" points=""/>;
			var pointSerial:String = "";
			for(var i:int = 0; i<points.length; i++)
			{
				pointSerial+=points[i].serialize() + " ";
			}
			
			StringUtil.trim(pointSerial);
			pathXML.@points = pointSerial;
			return pathXML;
		}
		
		public function debug():void
		{
			for(var i:int = 0; i < points.length; i++)
			{
				points[i].print();
			}
		}
		
		public function deserialize(pointSerial:String):void
		{
			if(pointSerial.length <= 3)
				return;				
			
			var pointVector:Array = StringUtil.trim(pointSerial).split(" ");
			var onePoint:Array;
			for(var i:int = 0; i<pointVector.length; i++)
			{
				onePoint = pointVector[i].split(",");
				push(onePoint[0], onePoint[1], onePoint[2]);
			}
		}
	}
}