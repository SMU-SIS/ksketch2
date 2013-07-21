/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.utils
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/**
	 * The KMathUtil class contains methods that support basic geometry operations.
	 * All the methods of the this class are static and must be called using the 
	 * syntax KMathUtil.method(parameter).
	 */	
	public class KMathUtil
	{
		/**
		 * A special value representing a very small positive number.
		 */		
		public static const EPSILON:Number = 1.0e-6;
		
		/**
		 * Computes the distance between two points.
		 * 
		 * @param p1 The first point.
		 * @param p2 The second point.
		 * @return The distance between the two points.
		 */		
		public static function distanceOf(p1:Point, p2:Point):Number
		{
			return Math.sqrt((p1.x-p2.x)*(p1.x-p2.x) + (p1.y-p2.y)*(p1.y-p2.y));
		}
		
		/**
		 * Computes the magnitude of the point.
		 * 
		 * @param x The x-position.
		 * @param y The y-position.
		 * @return The magnitude of the point.
		 */
		public static function magnitude(x:Number, y:Number):Number
		{
			return Math.sqrt((x*x)+(y*y));
		}
		
		/**
		 * Computes the angle (in radians) from one vector to another.
		 * 
		 * @param startVector The first vector.
		 * @param endVector The second vector.
		 * @return The angle in radius from the start vector to the end vector.
		 */		
		public static function angleOf(startVector:Point, endVector:Point):Number
		{
			var s:Point = startVector.clone();
			s.normalize(1);
			var e:Point = endVector.clone();
			e.normalize(1);
			var acos:Number = s.x * e.x + s.y * e.y;
			var angle:Number;
			
			if(Math.abs(acos - 1) <= EPSILON)
				angle = 0.0;
			else if(Math.abs(acos + 1) <= EPSILON)
				angle = Math.PI;
			else
			{
				angle = Math.acos(acos);
				if(s.x * e.y - s.y * e.x < 0)
					angle = Math.PI * 2 - angle;
			}
			return angle;
		}
		
		/**
		 * Computes the ratio of the magnitute of one vector compare to another.
		 * Division by zero error will be thrown if the startVector is zero.
		 * 
		 * @param startVector The first vector.
		 * @param endVector The second vector.
		 * @return Ratio of |endVector|/|startVector|.
		 */		
		public static function scaleOf(startVector:Point, endVector:Point):Number
		{
			var startDis:Number = KMathUtil.distanceOf(startVector, new Point());
			var endDis:Number = KMathUtil.distanceOf(endVector, new Point());
			return endDis / startDis;
		}
		
		/**
		 * Gets the translational vector of the matrix.
		 * 
		 * @param m The target matrix; the translation vector will be extracted from this matrix.
		 * @return The translational vector in the form of (tx,ty).
		 */
		public static function getOffset(m:Matrix):Point
		{
			return new Point(m.tx, m.ty);
		}
		
		/**
		 * Gets the scale value of the matrix in the range [0,1].
		 * 
		 * @param m The target matrix; The scale will be extracted from this matrix.
		 * @return The scale value in the range [0,1].
		 */		
		public static function getScale(m:Matrix):Number
		{
			return distanceOf(m.transformPoint(new Point()), m.transformPoint(new Point(1,0)));
		}
		
		/**
		 * Gets the rotational value of the matrix in degrees; the value will be in [0, 360).
		 * 
		 * @param m The target matrix; the angle will be extracted from this matrix.
		 * @return The rotational value in degrees.
		 */		
		public static function getRotation(m:Matrix):Number
		{
			var p1:Point = new Point(0, 0);
			var p2:Point = new Point(1, 0);
			var tp1:Point = m.transformPoint(p1);
			var tp2:Point = m.transformPoint(p2);
			
			var dy:Number = Math.abs(tp2.y - tp1.y);
			var l:Number = distanceOf(tp1, tp2);
			var rotation:Number = Math.asin(dy / l);
			
			// correct for quadrant
			if(tp2.y - tp1.y > 0)
			{
				if(tp2.x - tp1.x < 0)
					rotation = Math.PI - rotation;
			}
			else
			{
				if(tp2.x - tp1.x > 0)
					rotation = 2 * Math.PI - rotation;
				else
					rotation = rotation + Math.PI;
			}
			
			// convert to degrees
			return rotation==2*Math.PI ? 0 : rotation * (180 / Math.PI);
		}
		
		/**
		 * Computes the area of a polygon represented by coordinates of points
		 * using the formula 0.5*abs(x1*y2-y1*x2+x2*y3-y2*x3+...+xn*y1-yn*x1).
		 * 
		 * @param polygon The coordinates of the vertices of the target polygon.
		 * @return The area of the target polygon.
		 */		
		public static function area(polygon:Vector.<Point>):Number
		{
			var a:Number = 0;
			var length:uint = polygon.length;
			var p2:Point = polygon[length-1];
			var p1:Point;
			for(var i:uint = 0;i<length;i++)
			{
				p1 = p2;
				p2 = polygon[i];
				a += p1.x * p2.y - p1.y * p2.x;
			}
			a = Math.abs(a);
			a = a * 0.5;
			return a;
		}
		
		/**
		 * Computes the perimeter of a polygon represented by the coordinates of points.
		 * 
		 * @param polygon The coordinates of the vertices of the target polygon.
		 * @return The perimeter of the target polygon.
		 */		
		public static function perimeter(polygon:Vector.<Point>):Number
		{
			var p:Number = 0;
			var length:uint = polygon.length;
			for(var i:uint = 0;i<length-1;i++)
				p += KMathUtil.distanceOf(polygon[i], polygon[i+1]);
			p += KMathUtil.distanceOf(polygon[length-1], polygon[0]);
			return p;
		}
		
		/**
		 * Determines if two line segments are crossed.
		 * 
		 * @param seg1p1 The start coordinate of the 1st line segment.
		 * @param seg1p2 The end coordinate of the 1st line segment.
		 * @param seg2p1 The start coordinate of the 2nd line segment.
		 * @param seg2p2 The end coordinate of the 2nd line segment.
		 * @return The boolean value indicating if the line segments are crossed.
		 */		
		public static function lineSegmentCross(seg1p1:Point, seg1p2:Point, 
												seg2p1:Point, seg2p2:Point):Boolean
		{
			// p=x1(y3-y2)+x2(y1-y3)+x3(y2-y1), 
			// p<0: (x3, y3) on the leftside of segment(x1, y1)->(x2, y2), 
			// p==0, on the segment, p>0, rightside
			
			var linep1:Number, linep2:Number;
			
			linep1 = seg1p1.x * (seg2p1.y - seg1p2.y) + 
				seg1p2.x * (seg1p1.y - seg2p1.y) + 
				seg2p1.x * (seg1p2.y - seg1p1.y);
			linep2 = seg1p1.x * (seg2p2.y - seg1p2.y) + 
				seg1p2.x * (seg1p1.y - seg2p2.y) + 
				seg2p2.x * (seg1p2.y - seg1p1.y);
			if ( (linep1>0 && linep2>0) || (linep1<0 && linep2<0) || 
				(Math.abs(linep1)<KMathUtil.EPSILON && Math.abs(linep2)<KMathUtil.EPSILON) )
				return false;
			
			linep1 = seg2p1.x * (seg1p1.y - seg2p2.y) + 
				seg2p2.x * (seg2p1.y - seg1p1.y) + 
				seg1p1.x * (seg2p2.y - seg2p1.y); 
			linep2 = seg2p1.x * (seg1p2.y - seg2p2.y) + 
				seg2p2.x * (seg2p1.y - seg1p2.y) + 
				seg1p2.x * (seg2p2.y - seg2p1.y);
			if ( (linep1>0 && linep2>0) || (linep1<0 && linep2<0) || 
				(Math.abs(linep1)<KMathUtil.EPSILON && Math.abs(linep2)<KMathUtil.EPSILON) )
				return false;
			
			return true;
		}
		
		/**
		 * Computes the coordinate of the intersection of two line segments.
		 * An exception will be thrown if the lines are parallel.
		 * 
		 * @param p1 The start coordinate of the 1st line segment.
		 * @param p2 The end coordinate of the 1st line segment.
		 * @param q1 The start coordinate of the 2nd line segment.
		 * @param q2 The end coordinate of the 2nd line segment.
		 * @return The ccoordinate of the interesction of the two line segments.
		 */		
		public static function segmentIntersection(p1:Point, p2:Point, q1:Point, q2:Point):Point
		{
			if(!lineSegmentCross(p1, p2, q1, q2))
				throw new Error("No intersection for parallel lines.");
			/*根据两点式化为标准式，进而求线性方程组*/
			var crossPoint:Point = new Point();
			var tempLeft:Number, tempRight:Number;
			//求x坐标
			tempLeft = (q2.x - q1.x) * (p1.y - p2.y) - (p2.x - p1.x) * (q1.y - q2.y);
			tempRight = (p1.y - q1.y) * (p2.x - p1.x) * (q2.x - q1.x) + 
				q1.x * (q2.y - q1.y) * (p2.x - p1.x) - p1.x * (p2.y - p1.y) * (q2.x - q1.x);
			crossPoint.x = tempRight / tempLeft;
			//求y坐标 
			tempLeft = (p1.x - p2.x) * (q2.y - q1.y) - (p2.y - p1.y) * (q1.x - q2.x);
			tempRight = p2.y * (p1.x - p2.x) * (q2.y - q1.y) + 
				(q2.x- p2.x) * (q2.y - q1.y) * (p1.y - p2.y) - q2.y * (q1.x - q2.x) * (p2.y - p1.y);
			crossPoint.y = tempRight / tempLeft;
			return crossPoint;
		}
		
		/**
		 * Determines if a point falls on a line segment.
		 * 
		 * @param point The coordinate of the point.
		 * @param segStart The start coordinate of the line segment.
		 * @param segEnd The end coordinate of the line segment.
		 * @return The boolean value indicating if the point falls on the line segment.
		 */		
		public static function hasIntersection(point:Point, segStart:Point, segEnd:Point):Boolean
		{
			if(((segStart.y > point.y) != (segEnd.y > point.y)) && 
				(point.x < (segStart.x-segEnd.x) * (point.y-segEnd.y) / (segStart.y-segEnd.y) + segEnd.x))
				return true;
			return false;
		}
		
		/**
		 * Determines if two points falls on the same side of a line.
		 * 
		 * @param p1 The coordinate of the first point.
		 * @param p2 The coordinate of the second point.
		 * @param v The direction vector of the line.
		 * @return 1 if both points falls on the same side of the line, 
		 * -1 if they falls on opposite side, 0 otherwise.
		 */		
		public static function segcross(p1:Point, p2:Point, v:Point):int
		{
			var p1ToV:Number = KMathUtil.angleOf(p1, v);
			var vToP2:Number = KMathUtil.angleOf(v, p2);
			if(p1ToV == 0)
			{
				if(vToP2 > Math.PI)
					return -1;
				return 0;
			}
			if(vToP2 == 0)
			{
				if(p1ToV > 0 && p1ToV < Math.PI)
					return 1;
				return 0;
			}
			if(p1ToV < Math.PI && vToP2 < Math.PI && (p1ToV + vToP2) < Math.PI)
				return 1;
			if(p1ToV > Math.PI && vToP2 > Math.PI && (p1ToV + vToP2) > 3 * Math.PI)
				return -1;
			return 0;
		}
		
		/**
		 * Converts Cartesian coordinates into polar coordinates.
		 * 
		 * @point The target point.
		 * @point The target center.
		 * @return The converted polar coordinations.
		 */
		public static function cartesianToPolar(point:Point, center:Point = null):Point
		{
			if(!center)
				center = new Point();
			
			var r:Number = distanceOf(point, new Point());
			var theta:Number = Math.atan2((point.y-center.y),(point.x-center.x));
			
			return new Point(r, theta);
		}
	}
}