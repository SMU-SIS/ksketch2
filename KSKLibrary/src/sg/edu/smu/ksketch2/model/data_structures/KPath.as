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

	/**
	 * The KPath class serves as the concrete class that defines the core
	 * implementations of key frame paths in K-Sketch.
	 */
	public class KPath
	{
		public var points:Vector.<KTimedPoint>;		// the set of points in the key frame path
		
		/**
		 * The default constructor for the KPath object. The constructor initializes
		 * an empty list of points in the key frame path.
		 */
		public function KPath()
		{
			// initialize an empty list of points in the key frame path
			points = new Vector.<KTimedPoint>();
		}
		
		/**
		 * Checks if the key frames path is trivial. Triviality is checked based on whether
		 * the length of the path is long enough based on the threshold parameter value.
		 * 
		 * @param thresholdMagnitude The minimum threshold path distance necessary for
		 * the path to satisfy non-triviality.
		 * @return Whether the key frames path is trivial.
		 */
		public function isTrivial(thresholdMagnitude:Number):Boolean
		{
			// case: nuumber of points is 0;
			// return that key frames path is trivial
			if(points.length == 0)
				return true;
			
			// case: number of points is negative;
			// throw an error since key frames path is impossible
			if(thresholdMagnitude < 0)
				throw new Error("KPath.isTrivial: One does not simply give a negative threshold magnitude." +
					"It is known to cause time-space distortions and can destroy the world");
			
			var i:int;										// for-loop variable
			var length:int = points.length;					// number of points
			var pathMagnitude:Number = 0;					// total path distance
			var previousPoint:KTimedPoint = points[0];		// previous point
			var currentPoint:KTimedPoint;					// current point
			var dx:Number;									// x-position change
			var dy:Number;									// y-position change
			
			// iterate through each point in the path
			for(i=1; i<length; i++)
			{
				currentPoint  = points[i];						// extract the current point
				dx = currentPoint.x - previousPoint.x;			// calculate the x-position change
				dy = currentPoint.y - previousPoint.y;			// calculate the y-position change
				pathMagnitude += Math.sqrt((dx*dx)+(dy*dy));	// increment the path distance
				previousPoint = currentPoint;					// set the current point as the previous point now
			}
			
			// case: the total path distance is too short
			// return that key frames path is trivial
			if(pathMagnitude <= thresholdMagnitude)
				return true;
			
			// case: after exhausting all cases, the key frames path is satsified as being non-trivial
			return false;
		}
		
		/**
		 * Gets the amount of time that has passed with the key frames path.
		 * In other words, the amount of time that has passed between the start
		 * of the path and the latest collected point of the path.
		 * 
		 * @return The amount of time that has passed with the key frames path.
		 */
		public function get pathDuration():int
		{
			// case: zero-length path since no path exists yet
			// return a zero-time
			if(length == 0)
				return 0;
			
			// case: single-point path since only the first point of the path has been recorded
			// return the time of the single point recorded
			else if (length == 1)
				return points[0].time;
			
			// case: positive-length path
			// return the time duration between the first and last point
			else
				return points[length-1].time - points[0].time;;			
		}
		
		/**
		 * Gets the number of points in the path. Note that this is
		 * very different from the physical distance of the path.
		 * 
		 * @param The number of points in the path.
		 */
		public function get length():int
		{
			return points.length;
		}
		
		/**
		 * Adds a point to the end of the key frames path.
		 * 
		 * @param x The point's x-position.
		 * @param y The point's y-position.
		 * @param time The point's time.
		 */
		public function push(x:Number=0,y:Number=0,time:int=0):void
		{
			points.push(new KTimedPoint(x,y,time));
		}
		
		/**
		 * Finds a point in the path located from the value
		 * that is proportional to the total time duration
		 * of the key frames path. If the proportional value
		 * is located in-between two recorded times, then the
		 * interpolated point is return. Empty paths return null.
		 * 
		 * @param proportion The target value proportional to
		 * the total duration of time of the key frames path.
		 * @return The timed point located at the given
		 * proportional value relative to the key frames path's
		 * total time; else null if the path is empty.
		 */
		public function find_Point(proportion:Number):KTimedPoint
		{	
			// case: the path is empty
			// return no points (i.e., null)
			if(length == 0)
				return null;
			
			// case: the proportion equal or greater than 1
			// return the last point 
			if(1 <= proportion)
				return points[length-1];
			
			// get the total time duration
			var duration:int = points[length-1].time - points[0].time;
			
			// case: there is no elapsed time in the duration
			// return the last point
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
		 * Finds the timed point at the given proportional time
		 * of the key frames path. If the proportional timed point
		 * lies in-between two recorded times, it will return the
		 * interpolated point. Otherwise, it will return null for
		 * an empty path.
		 * 
		 * @param proportion The target proportional time.
		 * @return The timed point at the given proportional time.
		 */
		public function find_Point_By_Magnitude(proportion:Number):KTimedPoint
		{
			if(points.length < 2)
				return new KTimedPoint(0,0,0);
			
			var i:int;														// the loop variable
			var length:int = points.length;									// the number of points in the key frames path
			var pathMagnitude:Number = 0;									// the length of the path distance
			var previousPoint:KTimedPoint = points[0];						// the previous point in the key frames path
			var magnitudeTable:Vector.<Number> = new Vector.<Number>;		// the list of each updated path distance
			var currentPoint:KTimedPoint;									// the current point in the key frames path
			var dx:Number;													// the incremented x-distance
			var dy:Number;													// the incremented y-distance
			
			// iterate through each point to store each incremental distance
			magnitudeTable.push(0);
			for(i=1; i<length; i++)
			{
				currentPoint  = points[i];							// set the current point
				dx = currentPoint.x - previousPoint.x;				// calculate the incremented x-distance
				dy = currentPoint.y - previousPoint.y;				// calculate the incremented y-distance
				pathMagnitude += Math.sqrt((dx*dx)+(dy*dy));		// calculate and add the incremented distance
				magnitudeTable.push(pathMagnitude);					// add the latest path distance to the table
				previousPoint = currentPoint;						// set the previous point as the current point
			}
			
			// case: zero-length path distance
			// return the origin
			if(pathMagnitude == 0)
				return new KTimedPoint(0,0,0);
			
			// get the proportional path distance
			var queriedMagnitude:Number = proportion * pathMagnitude;
			
			// itereate through each incremental distance until it exceeds proportional path distance
			for(i = 0; i < length-1; i++)
			{
				if(queriedMagnitude <= magnitudeTable[i])
					break;
			}

			// decrement loop variable to last incremental distance below proportional path distance
			var startIndex:int = i - 1;

			// case: the index is the first point
			if(startIndex < 0)
				startIndex = 0;
			
			var startPoint:KTimedPoint = points[startIndex];
			
			// case: timed point's equals given time
			// return without interpolation (note: no need to interpolate for last point)
			if(startIndex == points.length -1)
				return startPoint;
			
			// interpolate the timed point
			var nextPoint:KTimedPoint = points[startIndex+1];
			var denominator:Number = magnitudeTable[startIndex+1]-magnitudeTable[startIndex];
			var proportionDifference:Number;
				
			proportionDifference = (queriedMagnitude-magnitudeTable[startIndex])/denominator;

			// interpolate by difference
			var finalX:Number = startPoint.x+(nextPoint.x - startPoint.x)*proportionDifference;
			var finalY:Number = startPoint.y+(nextPoint.y - startPoint.y)*proportionDifference;
			var finalZ:Number = pathDuration*proportion;
			
			// return the point at the given proprotion of time
			return new KTimedPoint(finalX, finalY, finalZ);
		}
		
		/**
		 * Finds the index of the point whose total distance from the starting point is
		 * most closest below the given proportional distance.
		 * 
		 * @param proportion The target proportional time.
		 * @return The index of the point whose total distance from the starting point is
		 * most closest below the given proportional distance.
		 */
		public function find_IndexByMagnitudeProportion(proportion:Number):int
		{
			var i:int;													// the loop variable
			var length:int = points.length;								// the number of points in the key frames path
			var pathMagnitude:Number = 0;								// the length of the path distance
			var previousPoint:KTimedPoint = points[0];					// the previous point in the key frames path
			var magnitudeTable:Vector.<Number> = new Vector.<Number>;	// the list of each updated path distance
			var currentPoint:KTimedPoint;								// the current point in the key frames path
			var dx:Number;												// the incremented x-distance
			var dy:Number;												// the incremented y-distance
			
			// iterate through each point to store each incremental distance
			magnitudeTable.push(0);
			for(i=1; i<length; i++)
			{
				currentPoint  = points[i];						// set the current point
				dx = currentPoint.x - previousPoint.x;			// calculate the incremented x-distance
				dy = currentPoint.y - previousPoint.y;			// calculate the incremented y-distance
				pathMagnitude += Math.sqrt((dx*dx)+(dy*dy));	// calculate and add the incremented distance
				magnitudeTable.push(pathMagnitude);				// add the latest path distance to the table
				previousPoint = currentPoint;					// set the previous point as the current point
			}
			
			// get the proportional path distance
			var queriedMagnitude:Number = proportion * pathMagnitude;
			
			// itereate through each incremental distance until it exceeds proportional path distance
			for(i = 0; i < length-1; i++)
			{
				if(queriedMagnitude <= magnitudeTable[i])
					break;
			}
			
			// decrement loop variable to last incremental distance below proportional path distance
			var startIndex:int = i - 1;
			
			// case: the index is the first point
			if(startIndex < 0)
				startIndex = 0;
			
			// return the index of the point whose total distance from the starting point is
			// most closest below the proportional distance
			return startIndex;
		}
		
		/**
		 * Finds the index of the point whose time is at or closest under the given proportional time.
		 * 
		 * @param proportion The target proportional time.
		 * @return The index of the point whose time is at or closest under the given proportional time.
		 */
		public function find_IndexAtOrBeforeProportion(proportion:Number):int
		{
			// case: the key frames path is empty
			// throws an error message
			if(length == 0)
				throw new Error("This is an empty path!");
			
			// calculate the total time duration
			var duration:int = points[length-1].time - points[0].time;
			
			// calculate the proportional time
			var proportionDuration:int = proportion * duration;

			var i:int;
			var indexBeforeProp:int = 0;
	
			// iterate through each point in the key frames path until the
			// current point's time exceeds the calculated proportional time
			for(i = 0; i < length; i++)
			{	
				if(points[i].time <= proportionDuration)
					indexBeforeProp = i;
				else
					break;
			}
			
			// return the index of the point in the key frames path located
			// at or before the proportional time
			return indexBeforeProp;
		}
		
		/**
		 * Splits the original key frame path into two portions based on the
		 * given proportional value. The front portion of the split key frame
		 * path is returned, while the back portion of the split key frame
		 * path becomes the new key frame path. The last point of the front
		 * split key frame path is also the same as the first point of the
		 * back split key frame path.
		 * Special Cases:
		 * 1) Path Length = 0 or Path Length = 1: Returns empty path. Does not split path
		 * 2) Proportion = 0: Returns empty path. Does not split path
		 * 3) Proportion = 1: Returns The whole path. Replaces path on this KPath with empty path
		 * Note:
		 * Remember to set replace key frame operations before this happen.
		 * 
		 * @param proportional The proportional value of the key frames path; based either
		 * on the distance or the time depending on whether the flag for discarding
		 * transition times are set.
		 * @return The front split key frame path of the original key frame path.
		 */
		public function splitPath(proportion:Number):KPath
		{
			// create the front split path
			var frontPath:KPath = new KPath();
			
			// handle special cases by optimizing the special cases
			// case: no proportional value
			// return an empty path as the front split key frames path
			if(proportion == 0)
			{
				return frontPath;
			}
			// case: full proportional value single-point path
			// return the existing full path as the front split key frames path
			else if(proportion == 1 || length <2)
			{
				// set the front split key frames path's points as the original key frames path's points
				frontPath.points = points;
				
				// empty the list of points for the eventual back split key frames path
				// (previously the list of points for the original key frames path)
				points = new Vector.<KTimedPoint>();
				
				// return the front split key frames path
				return frontPath;
			}
		
			// calculate the index before the proportional value
			// dependent on whether transition timings are discarded
			// case #1: discard the transition timings
			// set the index as the proportional distance
			// case #2: keep the transition timings
			// set the index as the proportional time
			var indexBeforeProp:int = KSketch2.discardTransitionTimings?
										find_IndexByMagnitudeProportion(proportion):
										find_IndexAtOrBeforeProportion(proportion);
			
			// find the splice point between the front and back split key frame paths
			var splitPoint:KTimedPoint = find_Point(proportion);
			
			// initialize the front split key frames paths as the set of points
			// from the first index to the index before the proportional value
			// of the points in the original complete key frames paths
			var frontPoints:Vector.<KTimedPoint> = points.splice(0,indexBeforeProp+1);
			
			// case: the last point in the front split key frames path is not the split point
			if(!frontPoints[frontPoints.length-1].isEqualsTo(splitPoint))
				frontPoints.push(splitPoint.clone());
			
			// case: the back split key frames path is non-empty
			if(points.length != 0)
			{
				// case: the first point of the back split key frames path is not the splice point
				if(!points[0].isEqualsTo(splitPoint))
				{
					// add a duplicate splice point to the front of the back split key frames path
					points.unshift(splitPoint.clone());
				}
				
				var i:int = 0;							// the loop variable
				var pathLength:int = points.length;		// the path distance
				var currentPoint:KTimedPoint;			// the current timed point
				
				// since all the paths are supposed to have their deltas start from 0
				// the loop subtracts from the splice points' values to reset those values
				// for clean-up
				for(i = 0; i<pathLength; i++)
				{
					currentPoint = points[i];
					currentPoint.x -= splitPoint.x;
					currentPoint.y -= splitPoint.y;
					currentPoint.time -= splitPoint.time;
				}
			}

			// set the front split key frame path's points
			frontPath.points = frontPoints;
			
			// return the split front key frame path
			return frontPath;
		}
		
		/**
		 * Merge the the other key frame path from the start of the proportional value
		 * into the key frame path until the end of the key frame path. The source path
		 * will be linearly compressed.
		 * 
		 * @param sourchPath The other key frame path to merge with.
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
		 * Appends the other key frame path into the key frame path.
		 * 
		 * @param toBeAppendedPath The other key frame path to be appended from.
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
		 * Gets a clone of the key frame path.
		 * 
		 * @return A clone of the key frame path.
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
		
		/**
		 * Serializes the key frame path to an XML object.
		 * 
		 * @return The serialized XML object of the key frame path.
		 */
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
		
		/**
		 * Debugs the key frame path object by outputting a
		 * string representation of the points in the path.
		 */
		public function debug():void
		{
			for(var i:int = 0; i < points.length; i++)
			{
				points[i].print();
			}
		}
		
		/**
		 * Deserializes the XML object to a key frame path.
		 * 
		 * @param The target XML object.
		 */
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