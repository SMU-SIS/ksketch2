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
	
	import sg.edu.smu.ksketch2.model.data_structures.KTimedPoint;
	
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
		 * Specifies uniform parameterization for Catmull-Rom curves.
		 */		
		public static const UNIFORM:uint = 0;

		/**
		 * Specifies chordal parameterization for Catmull-Rom curves.
		 */		
		public static const CHORDAL:uint = 1;

		/**
		 * Specifies centripetal parameterization for Catmull-Rom curves.
		 */		
		public static const CENTRIPETAL:uint = 2;
		
		/**
		 * Specifies natural parameterization for Catmull-Rom curves.
		 */		
		public static const NATURAL:uint = 3;
		
		/**
		 * A special value used to comput cubic bezier curve control points for circular arcs.
		 */
		private static const ARC_BEZIER_CONTROL_POINT_LENGTH:Number = (4.0/3.0) * (Math.SQRT2 - 1);
		
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
		
		/**
		 * Calculates the point at time t on the Catmull-Rom curve between p1 and p2. 
		 * Points p0 and p3 are needed to get the derivatives at the beginning and end of the curve.
		 * All points p0, p1, p2, and p3 must have different times. 
		 * If p0 is null, then the computation assumes that p0 = p1 - (p2 - p1).
		 * If p3 is null, then the computation assumes that p3 = p2 + (p2 - p1).
		 * 
		 * See this paper for an explanation of how this works:
		 * On the Parameterization of Catmull-Rom Curves, by Cem Yuksel, Scott Schaefer, and John Keyser
		 * 2009 SIAM/ACM Joint Conference on Geometric and Physical Modeling, Pages 47-53 
		 * 	 
		 * @param t The time, which must satisfy p1.time <= t <= p2.time 
		 * @param p0 Interpolated point p0 (or null)
		 * @param p1 Interpolated point p1
		 * @param p2 Interpolated point p2
		 * @param p3 Interpolated point p3 (or null)
		 * @return A new point on the curve at time t.
		 */
		public static function catmullRomC1CurvePoint(t:Number, p0:KTimedPoint, p1:KTimedPoint, 
													p2:KTimedPoint, p3:KTimedPoint,
													parameterization:uint = NATURAL): KTimedPoint
		{
			// Check for the degenerate case where p0 and p1 are the same.
			if (p0 && Math.abs(p1.x - p0.x) < EPSILON && Math.abs(p1.y - p0.y) < EPSILON)
			{
				p0 = null;
			}
			// Check for the degenerate case where p1 and p2 are the same.
			if (Math.abs(p2.x - p1.x) < EPSILON && Math.abs(p2.y - p1.y) < EPSILON)
			{
				return new KTimedPoint(p1.x, p1.y, t);
			}
			// Check for the degenerate case where p2 and p3 are the same.
			if (p3 && Math.abs(p3.x - p2.x) < EPSILON && Math.abs(p3.y - p2.y) < EPSILON)
			{
				p3 = null;
			}
			//trace("-------- catmullRomC1CurvePoint (param = " + parameterization + ") (As received) -------------------")
			//trace("t  = " + t)
			//trace("p0 = (" + (p0 ? p0.x + ", " + p0.y + ", " + p0.time : "null") + ")");
			//trace("p1 = (" + (p1 ? p1.x + ", " + p1.y + ", " + p1.time : "null") + ")");
			//trace("p2 = (" + (p2 ? p2.x + ", " + p2.y + ", " + p2.time : "null") + ")");
			//trace("p3 = (" + (p3 ? p3.x + ", " + p3.y + ", " + p3.time : "null") + ")");

			// Use local variables to avoid allocating new points on the heap.
			var x0:Number, y0:Number, t0:Number
			if (p0)
			{
				x0 = p0.x;
				y0 = p0.y;
				t0 = p0.time;
			}
			else
			{
				// Set p0 = p1 - 0.5*(p2 - p1)
				x0 = p1.x - 0.5*(p2.x - p1.x);
				y0 = p1.y - 0.5*(p2.y - p1.y);
				t0 = p1.time - (p2.time - p1.time);
			}
			
			var x1:Number = p1.x;
			var y1:Number = p1.y;
			var t1:Number = p1.time;
			
			var x2:Number = p2.x;
			var y2:Number = p2.y;
			var t2:Number = p2.time;

			var x3:Number, y3:Number, t3:Number
			if (p3)
			{
				x3 = p3.x;
				y3 = p3.y;
				t3 = p3.time;
			}
			else
			{
				// Set p3 = p2 + 0.5*(p2 - p1)
				x3 = p2.x + 0.5*(p2.x - p1.x);
				y3 = p2.y + 0.5*(p2.y - p1.y);
				t3 = p2.time + (p2.time - p1.time);
			}

			//trace("-------- catmullRomC1CurvePoint (null points filled in) -------------------")
			//trace("t  = " + t)
			//trace("p0 = (" + x0 + ", " + y0 + ", " + t0 + ")");
			//trace("p1 = (" + x1 + ", " + y1 + ", " + t1 + ")");
			//trace("p2 = (" + x2 + ", " + y2 + ", " + t2 + ")");
			//trace("p3 = (" + x3 + ", " + y3 + ", " + t3 + ")");

			var tScaled:Number = t;
			
			// Modify the times, if necessary.
			if (parameterization != NATURAL)
			{
				var d1:Number, d2:Number, d3:Number;
				if (parameterization == UNIFORM)
				{
					d1 = d2 = d3 = 1;
				}
				else 
				{
					var x:Number, y:Number;
					
					x = x1 - x0;
					y = y1 - y0;
					d1 = Math.sqrt(x*x + y*y); 
					
					x = x2 - x1;
					y = y2 - y1;
					d2 = Math.sqrt(x*x + y*y); 
					
					x = x3 - x2;
					y = y3 - y2;
					d3 = Math.sqrt(x*x + y*y); 
					
					if (parameterization == CENTRIPETAL)
					{
						d1 = Math.sqrt(d1);
						d2 = Math.sqrt(d2);
						d3 = Math.sqrt(d3);
					}
				}
				
				t0 = 0;
				t1 = d1;
				t2 = t1 + d2;
				t3 = t2 + d3;
				tScaled = t1 + (t - p1.time)*(d2/(p2.time-p1.time));
			}

			//trace("-------- catmullRomC1CurvePoint (Re-parameterized) -------------------")
			//trace("t  = " + tScaled)
			//trace("p0 = (" + x0 + ", " + y0 + ", " + t0 + ")");
			//trace("p1 = (" + x1 + ", " + y1 + ", " + t1 + ")");
			//trace("p2 = (" + x2 + ", " + y2 + ", " + t2 + ")");
			//trace("p3 = (" + x3 + ", " + y3 + ", " + t3 + ")");
			
			// Compute the point
			var cP0b:Number   = (t1 - tScaled)/(t1 - t0);
			var cP1a:Number   = (tScaled - t0)/(t1 - t0);
			var cP1b:Number   = (t2 - tScaled)/(t2 - t1);
			var cP2a:Number   = (tScaled - t1)/(t2 - t1);
			var cP2b:Number   = (t3 - tScaled)/(t3 - t2);
			var cP3a:Number   = (tScaled - t2)/(t3 - t2);
			var cL01b:Number  = (t2 - tScaled)/(t2 - t0);
			var cL12a:Number  = (tScaled - t0)/(t2 - t0);
			var cL12b:Number  = (t3 - tScaled)/(t3 - t1);
			var cL23a:Number  = (tScaled - t1)/(t3 - t1);
			var cL012b:Number = (t2 - tScaled)/(t2 - t1);
			var cL123a:Number = (tScaled - t1)/(t2 - t1);
			
			var l01x:Number  = cP0b   * x0  + cP1a   * x1;
			var l12x:Number  = cP1b   * x1  + cP2a   * x2;
			var l23x:Number  = cP2b   * x2  + cP3a   * x3;
			var l012x:Number = cL01b  * l01x  + cL12a  * l12x;
			var l123x:Number = cL12b  * l12x  + cL23a  * l23x;
			var c12x:Number  = cL012b * l012x + cL123a * l123x;
			
			var l01y:Number  = cP0b   * y0  + cP1a   * y1;
			var l12y:Number  = cP1b   * y1  + cP2a   * y2;
			var l23y:Number  = cP2b   * y2  + cP3a   * y3;
			var l012y:Number = cL01b  * l01y  + cL12a  * l12y;
			var l123y:Number = cL12b  * l12y  + cL23a  * l23y;
			var c12y:Number  = cL012b * l012y + cL123a * l123y;
			
			return new KTimedPoint(c12x, c12y, t);
		}
		
		/**
		 * Calculates cubic bezier control points that correspond to the Catmull-Rom curve 
		 * that extends between p1 and p2. 
		 * Points p0 and p3 are needed to get the derivatives at the beginning and end of the curve.
		 * If p0 is null, then the computation assumes that p0 = p1 - (p2 - p1).
		 * If p3 is null, then the computation assumes that p3 = p2 + (p2 - p1).
		 * 
		 * See this paper for an explanation of how this works:
		 * On the Parameterization of Catmull-Rom Curves, by Cem Yuksel, Scott Schaefer, and John Keyser
		 * 2009 SIAM/ACM Joint Conference on Geometric and Physical Modeling, Pages 47-53 
		 * 
		 * @param p0 Interpolated point p0 (or null)
		 * @param p1 Interpolated point p1
		 * @param p2 Interpolated point p2
		 * @param p3 Interpolated point p3 (or null)
		 * @param param The parameterization to use (KMathUtil.UNIFORM, KMathUtil.CHORDAL, or KMathUtil.CENTRIPETAL).
		 * @param b0 Set to bezier control point b0 when the function completes (if there is a curve to render)
		 * @param b1 Set to bezier control point b1 when the function completes (if there is a curve to render)
		 * @param b2 Set to bezier control point b2 when the function completes (if there is a curve to render)
		 * @param b3 Set to bezier control point b3 when the function completes (if there is a curve to render)
		 * @return true iff there is a curve to render (i.e. if p1 != p2)
		 */
		public static function catmullRomToBezier(p0:Point, p1:Point, p2:Point, p3:Point, 
												  b0:Point, b1:Point, b2:Point, b3:Point, param:uint=CHORDAL): Boolean
		{
			// Check for degenerate cases
			if (Math.abs(p2.x - p1.x) < EPSILON && Math.abs(p2.y - p1.y) < EPSILON)
			{
				return false;
			}
			if (p0 && Math.abs(p1.x - p0.x) < EPSILON && Math.abs(p1.y - p0.y) < EPSILON)
			{
				p0 = null;
			}
			if (p3 && Math.abs(p3.x - p2.x) < EPSILON && Math.abs(p3.y - p2.y) < EPSILON)
			{
				p3 = null;
			}
			
			// Calculate p0 or p3 if they are null.
			if (p0 == null)
			{
				// Set p0 = p1 - 0.5(p2 - p1)
				// Use p0 to hold (p2-p1) temporarily. (Avoids allocating more memory)
				p0 = p2.subtract(p1);
				p0.x = p1.x - (0.5*p0.x);
				p0.y = p1.y - (0.5*p0.y);
			}
			if (p3 == null)
			{
				// Set p3 = p2 + 0.5(p2 - p1)
				// Use p3 to hold (p2-p1) temporarily. (Avoids allocating more memory)
				p3 = p2.subtract(p1);
				p3.x = p2.x + (0.5*p3.x);
				p3.y = p2.y + (0.5*p3.y);
			}
			
			// Find the control points.
			b0.setTo(p1.x,p1.y);
			b3.setTo(p2.x, p2.y);

			var d1:Number, d2:Number, d3:Number;
			if (param == UNIFORM)
			{
				d1 = d2 = d3 = 1;
			}
			else if (param == CHORDAL)
			{
				d1 = p1.subtract(p0).length;
				d2 = p2.subtract(p1).length;
				d3 = p3.subtract(p2).length;
			}
			else
			{
				d1 = Math.sqrt(p1.subtract(p0).length);
				d2 = Math.sqrt(p2.subtract(p1).length);
				d3 = Math.sqrt(p3.subtract(p2).length);
			}
			KMathUtil._catmullRomToBezierB1B2(p0.x, p0.y, p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, d1, d2, d3, b1, b2);
			
			return true;
		}
		

		/**
		 * Helper function that calculates cubic bezier control points B1 and B2 that correspond to 
		 * the Catmull-Rom curve that extends between p1 and p2. 
		 * Points p0 and p3 are needed to get the derivatives at the beginning and end of the curve.
		 * 
		 * This helper function can be used with any parameterization of the Catmull-Rom curve, because
		 * the times between each point are passed as separate arguments. 
		 * 
		 * See this paper for an explanation of how this works:
		 * On the Parameterization of Catmull-Rom Curves, by Cem Yuksel, Scott Schaefer, and John Keyser
		 * 2009 SIAM/ACM Joint Conference on Geometric and Physical Modeling, Pages 47-53 
		 * 
		 * @param p0x The x coordinate of interpolated point p0
		 * @param p0x The y coordinate of interpolated point p0
		 * @param p1x The x coordinate of interpolated point p1
		 * @param p1x The y coordinate of interpolated point p1
		 * @param p2x The x coordinate of interpolated point p2
		 * @param p2x The y coordinate of interpolated point p2
		 * @param p3x The x coordinate of interpolated point p3
		 * @param p3x The y coordinate of interpolated point p3
		 * @param d1 The time between p0 and p1
		 * @param d2 The time between p1 and p2
		 * @param d3 The time between p2 and p3
		 * @param b1 Set to bezier control point b1 when the function completes
		 * @param b2 Set to bezier control point b2 when the function completes
		 */
		private static function _catmullRomToBezierB1B2(p0x:Number, p0y:Number, p1x:Number, p1y:Number, 
													  p2x:Number, p2y:Number, p3x:Number, p3y:Number, 
													  d1:Number, d2:Number, d3:Number, b1:Point, b2:Point): void
		{
			var b1denom:Number = 3 * d1 * (d1 + d2);
			var b2denom:Number = 3 * d3 * (d3 + d2);

			var b1cP2:Number = d1 * d1;
			var b2cP1:Number = d3 * d3;
			
			var b1cP0:Number = -d2 * d2;
			var b2cP3:Number = b1cP0;
			
			var b1cP1:Number = 2 * d1 * d1  +  3 * d1 * d2  +  d2 * d2;
			var b2cP2:Number = 2 * d3 * d3  +  3 * d3 * d2  +  d2 * d2;
			
			var b1x:Number = (b1cP2 * p2x  +  b1cP0 * p0x  +  b1cP1 * p1x) / b1denom;
			var b2x:Number = (b2cP1 * p1x  +  b2cP3 * p3x  +  b2cP2 * p2x) / b2denom;

			var b1y:Number = (b1cP2 * p2y  +  b1cP0 * p0y  +  b1cP1 * p1y) / b1denom;
			var b2y:Number = (b2cP1 * p1y  +  b2cP3 * p3y  +  b2cP2 * p2y) / b2denom;
			
			b1.setTo(b1x, b1y);
			b2.setTo(b2x, b2y);
		}
	
		
		/**
		 * Calculates cubic bezier control points that approximate a spiral arc about
		 * center (cx, cy) that starts at polar coordinates (theta0, r0) and continues to (theta1, r1).
		 * If |theta1-theta0| > pi/2 then throws a RangeError.
		 * 
		 * See this web page for an explanation of how this works:
		 * http://en.wikipedia.org/wiki/B%C3%A9zier_spline#Approximating_circular_arcs
		 * 
		 * @param c The center (cartesian coordinates)
		 * @param theta0 The angle of the first arc point (polar coordinate about center (cx, cy))
		 * @param r0 The radius of the first arc point (polar coordinate about center (cx, cy))
		 * @param theta1 The angle of the second arc point (polar coordinate about center (cx, cy))
		 * @param r1 The radius of the second arc point (polar coordinate about center (cx, cy)) 
		 * @param b0 Set to bezier control point b0 when the function completes (if there is a curve to render)
		 * @param b1 Set to bezier control point b1 when the function completes (if there is a curve to render)
		 * @param b2 Set to bezier control point b2 when the function completes (if there is a curve to render)
		 * @param b3 Set to bezier control point b3 when the function completes (if there is a curve to render)
		 * @return true iff there is a curve to render (i.e. if |theta1-theta0| <= pi/2 && (theta0 != theta1 || r0 != r1)
		 */
		public static function spiralArcToBezier(c:Point, theta0:Number, r0:Number, theta1:Number, r1:Number, 
												 b0:Point, b1:Point, b2:Point, b3:Point): Boolean
		{
			if (Math.PI/2 + EPSILON < Math.abs(theta1 - theta0))
			{
				// Can't handle angles greater than PI/2
				throw new RangeError("KMathUtil.spiralArcToBezier can't handle (theta1 - theta0) of " + (theta1 - theta0));
			}
			if (Math.abs(theta0 - theta1) < EPSILON  && Math.abs(r0 - r1) < EPSILON)
			{
				// Nothing to show. Skip.
				return false;				
			}
			
			// Find the end points with center at 0.
			var proportion:Number = (theta1 - theta0)/(Math.PI/2);
			b0.setTo(r0 * Math.cos(theta0), r0 * Math.sin(theta0));
			b3.setTo(r1 * Math.cos(theta1), r1 * Math.sin(theta1));
			
			// Get the scaled tanget vactor for each end point.
			b1.setTo(-b0.y * proportion * ARC_BEZIER_CONTROL_POINT_LENGTH,  b0.x * proportion * ARC_BEZIER_CONTROL_POINT_LENGTH);
			b2.setTo( b3.y * proportion * ARC_BEZIER_CONTROL_POINT_LENGTH, -b3.x * proportion * ARC_BEZIER_CONTROL_POINT_LENGTH);
			
			// Find the end points with center at c. 
			b0.setTo(b0.x + c.x, b0.y + c.y);
			b3.setTo(b3.x + c.x, b3.y + c.y);
			
			// Find the additional control ppints by adding the scaled tangent vectors.
			b1.setTo(b0.x + b1.x, b0.y + b1.y);
			b2.setTo(b3.x + b2.x, b3.y + b2.y);
			
			return true;
		}

		
	}
}