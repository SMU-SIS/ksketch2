/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package sg.edu.smu.ksketch.gestures
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import sg.edu.smu.ksketch.geom.KTimestampPoint;
	import sg.edu.smu.ksketch.utilities.KMathUtil;
	
	import spark.primitives.Rect;

	public class PigtailDetector
	{
		public static const THRESHOLD_T:Number = 1000;
		public static const THRESHOLD_A:Number = 15000;
		public static const THRESHOLD_A_FLOOR:Number = 500;
		public static const THRESHOLD_P:Number = 400;
		public static const THRESHOLD_P_FLOOR:Number = 70;
		
		/* new threshold for crossing the selection loop after flicking.
		 * In this case, the celling thresholds of area and perimeter are much larger in practice  
		 */
		public static const NEW_THRESHOLD_A:Number = 30000;
		public static const NEW_THRESHOLD_P:Number = 800;
		
		private var _points:Vector.<KTimestampPoint>;
		private var _intersectionPoint:Point;		
		
		public function PigtailDetector()
		{
			_points = new Vector.<KTimestampPoint>();
			_intersectionPoint = new Point();
		}
		
		public function clearPoints():void
		{
			_points = new Vector.<KTimestampPoint>();
		}
		
		public function newPoint(point:Point):Vector.<KTimestampPoint>
		{
			var currentTime:Number = new Date().time;
			
			var p:KTimestampPoint;
			
			while(_points.length > 0)
			{
				p = _points[0];
				if(p.timeStamp < currentTime - THRESHOLD_T)
					_points.shift();
				else
					break;
			}
			_points.push(new KTimestampPoint(currentTime, point.x, point.y));
			
			var length:uint = _points.length;
			var index:int = hasSelfIntersection(_points);
			if(index < 0)
				return null;
			
			var intersection:Point = KMathUtil.segmentIntersection(_points[index], _points[index+1], _points[length-2], _points[length-1]);
			
			var polygon:Vector.<KTimestampPoint> = new Vector.<KTimestampPoint>();
			polygon.push(new KTimestampPoint(_points[index].timeStamp, intersection.x, intersection.y));
			for(var i:uint = index+1;i<length-1;i++)
				polygon.push(_points[i]);
			
			var perimeter:Number = KMathUtil.perimeter(Vector.<Point>(polygon));
			if(perimeter > THRESHOLD_P || perimeter < THRESHOLD_P_FLOOR)
				return null;
			
			var area:Number = KMathUtil.area(Vector.<Point>(polygon));
			if(area > THRESHOLD_A || area < THRESHOLD_A_FLOOR)
				return null;
			polygon.splice(0, 1, _points[index]); // change the intersection to the raw point
			polygon.push(_points[length-1]); // add the new point
			return polygon;
		}
		
		public function hasSelfIntersection(points:Vector.<KTimestampPoint>):int
		{
			var length:uint = points.length;
			if(length < 4)
				return -1;

			var start:Point = points[length-2];
			var newAdded:Point = points[length-1];
			for(var i:uint = 0; i < length-3 ; i++)
				if(KMathUtil.lineSegmentCross(points[i], points[i+1], start, newAdded))
				{
					//since line segments intersect, we can assume that they form an X of some sort
					//so find centroid of these 4 points and use it as an estimate of the real intersection
					//line segments are small so the intersection point will not differ much from real intersection
					//unless we are talking about really small pig tails, then the estimate will be wrong.
					var maxX:int = Math.max(Math.max(points[i].x,points[i+1].x),Math.max(start.x,newAdded.x));
					var minX:int = Math.min(Math.min(points[i].x,points[i+1].x),Math.min(start.x,newAdded.x));
					var maxY:int = Math.max(Math.max(points[i].y,points[i+1].y),Math.max(start.y,newAdded.y));
					var minY:int = Math.min(Math.min(points[i].y,points[i+1].y),Math.min(start.y,newAdded.y));
					
					_intersectionPoint.x = (maxX+minX)/2;
					_intersectionPoint.y = (maxY+minY)/2;
					
					return i;
				}
							
			
			return -1;
		}
		
		// find the self-intersection of selection loop and pigtail loop
		public function hasSelfIntersection_New(points:Vector.<KTimestampPoint>,selectionLooplength:uint):int
		{
			var length:uint = points.length;
			if(length < 4)
				return -1;
			
			var start:Point = points[length-2];
			var newAdded:Point = points[length-1];
			for(var i:uint = 0; i < selectionLooplength-1; i++)
				if(KMathUtil.lineSegmentCross(points[i], points[i+1], start, newAdded))
				{
					//since line segments intersect, we can assume that they form an X of some sort
					//so find centroid of these 4 points and use it as an estimate of the real intersection
					//line segments are small so the intersection point will not differ much from real intersection
					//unless we are talking about really small pig tails, then the estimate will be wrong.
					var maxX:int = Math.max(Math.max(points[i].x,points[i+1].x),Math.max(start.x,newAdded.x));
					var minX:int = Math.min(Math.min(points[i].x,points[i+1].x),Math.min(start.x,newAdded.x));
					var maxY:int = Math.max(Math.max(points[i].y,points[i+1].y),Math.max(start.y,newAdded.y));
					var minY:int = Math.min(Math.min(points[i].y,points[i+1].y),Math.min(start.y,newAdded.y));
					
					_intersectionPoint.x = (maxX+minX)/2;
					_intersectionPoint.y = (maxY+minY)/2;
					
					return i;
				}
			
			
			return -1;
		}

		public function pigtailBoundingBox(points:Vector.<KTimestampPoint>):Rectangle{
			
			var minx:int = int.MAX_VALUE;
			var miny:int = int.MAX_VALUE;
			var maxx:int = int.MIN_VALUE;
			var maxy:int = int.MIN_VALUE;
			for each(var p:Point in points)
			{
				if(p.x < minx)
					minx = p.x;
				if(p.x > maxx)
					maxx = p.x;
				if(p.y < miny)
					miny = p.y;
				if(p.y > maxy)
					maxy = p.y;
			}
			
			return new Rectangle(minx, miny, maxx-minx+1, maxy-miny+1);
			
		}
		
		public function get intersectionPoint():Point
		{
	
			return _intersectionPoint;
		}
		
		//used for crossing the selection loop BEFORE flicking is recognized
		public function newPoint1(point:Point,selectionLoopLength:uint):Vector.<KTimestampPoint>
		{
			var currentTime:Number = new Date().time;
			
			_points.push(new KTimestampPoint(currentTime, point.x, point.y));
			
			var length:uint = _points.length;
			var index:int = hasSelfIntersection_New(_points,selectionLoopLength);
			if(index < 0)
				return null;
			
			var intersection:Point = KMathUtil.segmentIntersection(_points[index], _points[index+1], _points[length-2], _points[length-1]);
			var polygon:Vector.<KTimestampPoint> = new Vector.<KTimestampPoint>();
			polygon.push(new KTimestampPoint(_points[index].timeStamp, intersection.x, intersection.y));
			for(var i:uint = index+1;i<length-1;i++)
				polygon.push(_points[i]);
			
			var perimeter:Number = KMathUtil.perimeter(Vector.<Point>(polygon));
			if(perimeter > THRESHOLD_P || perimeter < THRESHOLD_P_FLOOR)
				return null;
			
			var area:Number = KMathUtil.area(Vector.<Point>(polygon));
			if(area > THRESHOLD_A || area < THRESHOLD_A_FLOOR)
				return null;
			polygon.splice(0, 1, _points[index]); // change the intersection to the raw point
			polygon.push(_points[length-1]); // add the new point
			return polygon;
		}
		
		public function newPoint2(point:Point):Vector.<KTimestampPoint>
		{
			var currentTime:Number = new Date().time;
			
			_points.push(new KTimestampPoint(currentTime, point.x, point.y));
			
			var length:uint = _points.length;
			var index:int = hasSelfIntersection(_points);
			if(index < 0)
				return null;
			
			var intersection:Point = KMathUtil.segmentIntersection(_points[index], _points[index+1], _points[length-2], _points[length-1]);
			var polygon:Vector.<KTimestampPoint> = new Vector.<KTimestampPoint>();
			polygon.push(new KTimestampPoint(_points[index].timeStamp, intersection.x, intersection.y));
			for(var i:uint = index+1;i<length-1;i++)
				polygon.push(_points[i]);
			
			var perimeter:Number = KMathUtil.perimeter(Vector.<Point>(polygon));
			if(perimeter > THRESHOLD_P || perimeter < THRESHOLD_P_FLOOR)
				return null;
			
			var area:Number = KMathUtil.area(Vector.<Point>(polygon));
			if(area > THRESHOLD_A || area < THRESHOLD_A_FLOOR)
				return null;
			
			polygon.splice(0, 1, _points[index]); // change the intersection to the raw point
			polygon.push(_points[length-1]); // add the new point
			return polygon;
		}
		
		//set _points
		public function set points(points:Vector.<KTimestampPoint>):void
		{
			_points = points;
		}
		
		public function get points():Vector.<KTimestampPoint>
		{
			return _points;
		}
	}
}