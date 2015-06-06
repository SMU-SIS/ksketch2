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
	import flash.geom.Point;
	
	import mx.utils.StringUtil;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.utils.KMathUtil;
	import sg.edu.smu.ksketch2.utils.iterators.INumberIterator;
	import sg.edu.smu.ksketch2.utils.iterators.KNumberIteratorVectorKTimedPoint;

	/**
	 * The KPath class serves as the concrete class that defines the core
	 * implementations of key frame paths in K-Sketch.
	 */
	public class KPath
	{
		public var points:Vector.<KTimedPoint>;		// the set of points in the key frame path
		public var pointProperty:Object;

		private var _type:uint;						// TRANSLATE, ROTATE, or SCALE
		
		public static const TRANSLATE:uint = 0;
		public static const ROTATE:uint = 1;
		public static const SCALE:uint = 2;
		
		public static const LINEAR:uint = 0;
		public static const CATMULL_ROM:uint = 1;
		
		/**
		 * The default constructor for the KPath object. The constructor initializes
		 * an empty list of points in the key frame path.
		 * 
		 * @param keyFrame the key frame that will contain this path.
		 * @param type KPath.TRANSLATE, KPath.ROTATE, or KPath.SCALE.
		 */
		public function KPath(type:uint)
		{
			// initialize an empty list of points in the key frame path
			points = new Vector.<KTimedPoint>();
			
			if (type != TRANSLATE && type != ROTATE && type != SCALE)
			{
				throw new RangeError("KPath does not recognize type " + type + ".");
			}
			_type = type;
		}
		
		/**
		 * Returns the type of this KPath.
		 */
		public function get type():uint
		{
			return _type;
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
			// case: zero or one point path has zero time
			if(length < 2)
				return 0;
			
//			// case: single-point path since only the first point of the path has been recorded
//			// return the time of the single point recorded
//			// RCD: WRONG! This should also return 0 
//			else if (length == 1)
//				return points[0].time;
			
			// case: positive-length path
			// return the time duration between the first and last point
			else
				return points[length-1].time - points[0].time;		
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
		public function push(x:Number,y:Number,time:Number):void
		{
			points.push(new KTimedPoint(x,y,time));
		}
		
		
		/**
		 * Adds an offset value to every point in the path.
		 * 
		 * @param x The x offset.
		 * @param y The y offset.
		 */
		public function offset(x:Number,y:Number):void
		{
			var i:int;						// the loop variable
			var length:int = points.length;	// the number of points in the key frames path
			
			for(i=1; i<length; i++)
			{
				points[i].x += x;
				points[i].y += y;
			}
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
		 * @param keyFrame The spatial key frame that contains this path
		 * @param interpolation The interplation style (KPath.LINEAR or KPath.CATMULL_ROM)
		 * @param parameterization The parmeterization for Catmull-Rom curves 
		 * (KMathUtil.NATURAL, KMathUtil.UNIFORM, KMathUtil.CHORDAL, KMathUtil.CENTRIPETAL) 
		 * @return The timed point located at the given
		 * proportional value relative to the key frames path's
		 * total time; else null if the path is empty.
		 */
		public function find_Point(proportion:Number, keyFrame:KSpatialKeyFrame, interpolation:uint = KPath.CATMULL_ROM, 
								   parameterization:uint = KMathUtil.CHORDAL):KTimedPoint
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
			var p0:KTimedPoint = (0 < baseIndex) ? points[baseIndex-1] : _getPreviousPoint(keyFrame);
			var p1:KTimedPoint = points[baseIndex];
			var p2:KTimedPoint = points[nextIndex];
			var p3:KTimedPoint = (nextIndex < length-1) ? points[nextIndex+1] : _getNextPoint(keyFrame);
			
			var baseProportion:Number = p1.time/duration;
			var numerator:Number = proportion - baseProportion;
			
			if(numerator == 0)
				return p1.clone();
			
			var denominator:Number = (p2.time - p1.time)/duration;
			var interpolationFactor:Number = numerator/denominator;
			
			var newPoint:KTimedPoint;
			if (interpolation == LINEAR)
			{
				newPoint = new KTimedPoint(
					(p2.x-p1.x)*interpolationFactor + p1.x, 
					(p2.y-p1.y)*interpolationFactor + p1.y, 
					(p2.time-p1.time)*interpolationFactor + p1.time);				
			}
			else
			{
				newPoint = KMathUtil.catmullRomC1CurvePoint((p2.time-p1.time)*interpolationFactor + p1.time,
					p0, p1, p2, p3, parameterization);
			}
			
			return newPoint;
		}
		
		/**
		 * Gets the next-last point from the previous key frame, if any.
		 * The point is adjusted so that it
		 * is positioned correctly relative to the current path.
		 * 
		 * @pram keyFrame The key frame that contains this path.
		 * @return the repositioned point, or null.
		 */
		private function _getPreviousPoint(keyFrame:KSpatialKeyFrame):KTimedPoint
		{
			var prevKey:KSpatialKeyFrame = keyFrame.previous as KSpatialKeyFrame;
			if (prevKey == null || prevKey.previous == null)
			{
				// The first key frame for an object should be instantaneous, and
				// the path is used for positioning only, so ignore it. 
				return null;
			}
			
			var prevPath:KPath;
			switch (type)
			{
				case TRANSLATE:
					prevPath = prevKey.translatePath;
					break;
				case ROTATE:
					prevPath = prevKey.rotatePath;
					break;
				case SCALE:
					prevPath = prevKey.scalePath;
					break;
				default:
					throw new Error("KPath._getPreviousPoint encountered unknown type " + type + ".");				
			}

			if (prevPath == null || prevPath.length < 2)
			{
				// In this case, there is no transition in the previous path, so the path should end.
				return null;
			}
			
			var pThisFirst:KTimedPoint = points[0];
			var pThisLast:KTimedPoint = points[points.length-1];
			var pPrevFirst:KTimedPoint = prevPath.points[0];
			var pPrevLast:KTimedPoint = prevPath.points[prevPath.points.length-1];
			var pPrevPenultimate:KTimedPoint = prevPath.points[prevPath.points.length-2];
			
			var actualTimeDiff:Number = (pPrevLast.time - pPrevPenultimate.time)*
				((prevKey.time - prevKey.previous.time)/(pPrevLast.time - pPrevFirst.time));
			var scaledTimeDiff:Number = actualTimeDiff*((pThisLast.time - pThisFirst.time)/(keyFrame.time - prevKey.time));
			
			var previousPoint:KTimedPoint;
			if (type != SCALE)
			{
				// Translates and Rotates are additive.
				previousPoint = new KTimedPoint(
					pThisFirst.x - (pPrevLast.x - pPrevPenultimate.x),
					pThisFirst.y - (pPrevLast.y - pPrevPenultimate.y),
					pThisFirst.time - scaledTimeDiff);
			}
			else
			{
				// Scales are multiplicative
				previousPoint = new KTimedPoint(
					pThisFirst.x * (pPrevPenultimate.x / pPrevLast.x ), // i.e. pThisFirst.x / (pPrevLast.x / pPrevPenultimate.x)
					0,													// Must do this. Otherwise divide by 0.
					pThisFirst.time - scaledTimeDiff);
			}
			
			return previousPoint;
		}

		/**
		 * Gets the second point from the next key frame, if any.
		 * The point is adjusted so that it
		 * is positioned correctly relative to the current path.
		 * 
		 * @pram keyFrame The key frame that contains this path.
		 * @return the repositioned point, or null.
		 */
		private function _getNextPoint(keyFrame:KSpatialKeyFrame):KTimedPoint
		{
			var nextKey:KSpatialKeyFrame = keyFrame.next as KSpatialKeyFrame;
			if (keyFrame.next == null)
			{
				// There really is nothing else, so return null.
				return null;
			}

			var nextPath:KPath;
			switch (type)
			{
				case TRANSLATE:
					nextPath = nextKey.translatePath;
					break;
				case ROTATE:
					nextPath = nextKey.rotatePath;
					break;
				case SCALE:
					nextPath = nextKey.scalePath;
					break;
				default:
					throw new Error("KPath._getNextPoint encountered unknown type " + type + ".");				
			}
			
			if (nextPath == null || nextPath.length < 2)
			{
				// In this case, there is no transition in the next path, so this path should end.
				return null;
			}
			
			var pThisFirst:KTimedPoint = points[0];
			var pThisLast:KTimedPoint = points[points.length-1];
			var pNextFirst:KTimedPoint = nextPath.points[0];
			var pNextLast:KTimedPoint = nextPath.points[nextPath.points.length-1];
			var pNextSecond:KTimedPoint = nextPath.points[1];
			
			var actualTimeDiff:Number = (pNextSecond.time - pNextFirst.time)*
				((nextKey.time - keyFrame.time)/(pNextLast.time - pNextFirst.time));
			var scaledTimeDiff:Number = actualTimeDiff*((pThisLast.time - pThisFirst.time)/(keyFrame.time - keyFrame.previous.time));
			
			var nextPoint:KTimedPoint;
			if (type != SCALE)
			{
				// Translates and Rotates are additive.
				nextPoint = new KTimedPoint(
					pThisLast.x + (pNextSecond.x - pNextFirst.x),
					pThisLast.y + (pNextSecond.y - pNextFirst.y),
					pThisLast.time + scaledTimeDiff);
			}
			else
			{
				// Scales are multiplicative
				nextPoint = new KTimedPoint(
					pThisLast.x * (pNextSecond.x / pNextFirst.x),
					0, // Must do this. Otherwise divide by 0.
					pThisLast.time + scaledTimeDiff);
			}
			
			return nextPoint;
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
			/*
			This method is not being used. Wah liao so confusing!!!
			*/
			
			if(points.length < 2)
			{
				return new KTimedPoint(0,0,0);
			}
				
			
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
		 * closest below the given proportional distance.
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
		public function splitPath(proportion:Number, keyFrame:KSpatialKeyFrame):KPath
		{
			// create the front split path
			var frontPath:KPath = new KPath(type);
			
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
			
			// find the split point between the front and back split key frame paths
			var splitPoint:KTimedPoint = find_Point(proportion, keyFrame);
			
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
				
				// since all the paths are supposed to have their deltas start 
				// from 0 (translation and rotation paths) or from 1 (scale paths)
				// the loop subtracts or divides from the splice points' values 
				// to reset those values for clean-up
				for(i = 0; i<pathLength; i++)
				{
					currentPoint = points[i];
					if (type != SCALE) 
					{
						// Translates and Rotates are additive
						currentPoint.x -= splitPoint.x;
						currentPoint.y -= splitPoint.y;
					} 
					else 
					{
						// Scales are multiplicative
						currentPoint.x /= splitPoint.x;
						//currentPoint.y /= splitPoint.y;	 // Should be 0 for scale				
					}
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
		public function mergePath(sourcePath:KPath, sourcekeyFrame:KSpatialKeyFrame):void
		{
			var i:int;
			var currentPoint:KTimedPoint;	
			var pathLength:int = length;

			if(pathLength == 0) // If this path is empty, just use sourcePath.
			{
				var sourceLength:int = sourcePath.points.length;
				for(i = 0; i<sourceLength; i++)
					points.push(sourcePath.points[i].clone());
			}
			else if(pathDuration==0) // If this path has duration 0, distribute the source points evenly.
			{
				for(i = 0; i<pathLength; i++)
				{
					currentPoint = points[i];
					proportion = i/pathLength;
					if (type != SCALE) 
					{
						// Translates and Rotates are additive
						currentPoint.add(sourcePath.find_Point(proportion, sourcekeyFrame));
					} 
					else
					{
						// Scales are multiplicative
						currentPoint.multiply(sourcePath.find_Point(proportion, sourcekeyFrame));						
					}
						
				}
			}
			else // In the normal case, distribute the source points by time.
			{
				var offSetTime:Number = points[0].time;
				var duration:Number = pathDuration - offSetTime;
				var proportion:Number;
				for(i = 0; i<pathLength; i++)
				{
					currentPoint = points[i];
					proportion = (currentPoint.time - offSetTime)/duration;
					if (type != SCALE) 
					{
						// Translates and Rotates are additive
						currentPoint.add(sourcePath.find_Point(proportion, sourcekeyFrame));
					}
					else
					{
						// Scales are multiplicative
						currentPoint.multiply(sourcePath.find_Point(proportion, sourcekeyFrame));												
					}
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
				if (type != SCALE)
				{
					// Translates and Rotates are additive
					currentPoint.x += lastPoint.x;
					currentPoint.y += lastPoint.y;
				}
				else
				{
					// Scales are multiplicative
					currentPoint.x *= lastPoint.x;
					currentPoint.y *= lastPoint.y;
				}
				points.push(currentPoint);
			}
		}
	
	
		
		/**
		 * Modifies the path to distribute points that have the same time.
		 * Does nothing if all points have the same time.
		 */
		public  function distributePathPointTimes():void
		{
			if (points.length < 2)
			{
				return;
			}
			
			var i:int;
			// Scan to find the first point at a time after points[0].time.
			for (i = 1; i < points.length && points[i].time == points[0].time; i++)
			{
			}

			var firstIdx:int;
			var j:int;
			var step:Number;
			for (; i < points.length; i++) {
				// Here, points[i] should be the first point with points[i].time 
				// (which should be later than points[0].time).
				firstIdx = i;
				
				// Scan to find the last index i that has points[i].time == points[firstIdx].time
				for (; i+1 < points.length && points[i+1].time == points[firstIdx].time; i++)
				{
				}
				
				if (points[0].time == points[firstIdx-1].time && 1 < firstIdx) 
				{
					// Use this in the special case where multiple points have points[0].time
					// Set firstIdx to 1, so the later process will modify the times betweem points[1] and points[i-1].
					firstIdx = 1;
				}
				
				if (i != firstIdx) 
				{
					// Use this in the normal case
					// Modify the times betweem points[firstIdx] and points[i-1].
					step = (points[i].time - points[firstIdx-1].time) / (i + 1 - firstIdx);
					for (j = 0; firstIdx + j < i; j++)
					{
						points[firstIdx+j].time = points[firstIdx-1].time + (j+1)*step;
					}
				}
			}
		}
		
		
		/**
		 * Modifies the path to keep only the first and last point and no more than 
		 * one point for every set of points with the same time.
		 * Will not reduce the number of points to less than 2.
		 */
		public  function discardRedundantPathPoints():void
		{
			if(points.length <= 2)
				return;
			
			var delay:int = 0;
			var i:int;
			
			//Find the delay that should be used (if possible) when choosing the point at each time.
			for (i = points.length-2; i >= 0; i--) {
				if (points[i].time != points[points.length-1].time) {
					delay = points.length - (i+2);
					break;
				}
			}
			
			var newPoints:Vector.<KTimedPoint> = new Vector.<KTimedPoint>();
			newPoints.push(points[0]);

			var currentTime:Number = -1;
			i = 1;
			while (i < points.length) {
				// At this point, points[i] should be the first point with points[i].time
				// (In the first iteration, points[i].time could be the same as points[i-1].time, but it's good enough.
				currentTime = points[i].time;
				
				// If there is a point with the right delay and the right time, 
				//then take it and move to the next time.
				if ((i+delay) < points.length   &&  points[i+delay].time == currentTime) {
					newPoints.push(points[i+delay]);
					for (i = i + delay + 1; i < points.length && points[i].time == currentTime; i++) {
					}
					continue;
				} 
				
				// Otherwise, scan for the last point at the current time, and take that one.
				for (i = i + 1; i < points.length && points[i].time == currentTime; i++) {
				}
				newPoints.push(points[i-1]);			
			}

			points = newPoints;
		}
		

		/**
		 * Returns an iterator that gives the times of points in this KPath.
		 * Times are scaled to start and and at specified moments.
		 * 
		 * @param start The start of the period 
		 * @param end The end of the period.
		 */
		public function timeIterator(start:Number, end:Number):INumberIterator
		{
			return new KNumberIteratorVectorKTimedPoint(points).scale(start,end);
		}

		
		/**
		 * Gets a clone of the key frame path.
		 * 
		 * @return A clone of the key frame path.
		 */
		public function clone():KPath
		{
			var clone:KPath = new KPath(type);
			
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