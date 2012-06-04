/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.gestures
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Recognizer
	{
		[Bindable]
		public static var ACCEPT_SCORE:Number = 0.8;
		
		private static const PHI:Number = ( -1 + Math.sqrt(5)) / 2;
		
		private static const ORIGIN:Point = new Point();
		
		private static const N:int = 64;
		private static const SIZE:int = 100;
		private static const THRESHOLD_0D_PIXALS:int = 20;
		private static const THRESHOLD_1D_PORTION:Number = 0.3;
		private static const I:int = 12;
		private static const THETA:Number = Math.PI / 4;
		private static const THRESHOLD_THETA:Number = 2 / 180 * Math.PI;
		
		private var _library:Library;
		
		public function Recognizer(library:Library)
		{
			_library = library;
		}
		
		public function set library(value:Library):void
		{
			_library = value;
		}

		public function get library():Library
		{
			return _library;
		}

		public function recognizeGesture(gesture:Vector.<Point>):RecognizeResult
		{
			var result:RecognizeResult = bestResult(gesture);
			
			if(result.score > ACCEPT_SCORE)
				return result;
			return RecognizeResult.UNDEFINED;
		}
		
		public function bestResult(gesture:Vector.<Point>):RecognizeResult
		{
			gesture = prepare(gesture);
			
			var result:RecognizeResult = recognize(gesture, _library.templates, SIZE);
			
			return result;
		}
		
		public static function isTap(rawPoints:Vector.<Point>):Boolean
		{
			var bounding:Rectangle = boundingBox(rawPoints);
			
			if(bounding.width < THRESHOLD_0D_PIXALS && bounding.height < THRESHOLD_0D_PIXALS)
				return true;
			return false;
		}
		
		public static function generateTemplate(type:String, rawPoints:Vector.<Point>):Vector.<Point>//, rotationInv:Boolean):Gesture
		{
			var points:Vector.<Point> = prepare(rawPoints);
			return points;
		}
		
		private static function prepare(points:Vector.<Point>):Vector.<Point>
		{
			
			points = resample(points, N);
			
			var indicativeAngle:Number = indicativeAngle(points);
			points = rotateBy(points, -indicativeAngle);
			
			points = scaleDimTo(points, SIZE, THRESHOLD_1D_PORTION);
			points = rotateBy(points, indicativeAngle);
			translateCentroidTo(points, ORIGIN);
			
			return points;
		}
		
		private static function resample(points:Vector.<Point>, n:int):Vector.<Point>
		{
			var iDist:Number = pathLength(points) / (n - 1);
			var newPoints:Vector.<Point> = new Vector.<Point>();
			if(iDist == 0)
			{
				for(var index:int = 0; index<n; index++)
					newPoints.push(points[0].clone());
				return newPoints;
			}
			
			var sumDist:Number = 0;
			
			var d:Number;
			var newP:Point;
			var prev:Point = points[0];
			var p:Point;
			newPoints.push(points[0].clone());
			var length:uint = points.length;
			for(var i:uint = 1;i<length;i++)
			{
				p = points[i];
				d = distance(prev, p);
				if((sumDist + d) >= iDist)
				{
					newP = new Point();
					newP.x = prev.x + ((iDist - sumDist) / d) * (p.x - prev.x);
					newP.y = prev.y + ((iDist - sumDist) / d) * (p.y - prev.y);
					newPoints.push(newP);
					prev = newP;
					i--;
					sumDist = 0;
				}
				else
				{
					sumDist += d;
					prev = p;
				}
			}
			if(newPoints.length != n && newPoints.length != n-1)
				throw new Error("resample algorithm error: expected sample length = "+ n + " but was " + newPoints.length);
			
			if(newPoints.length < n)
				newPoints.push(p.clone());
			return newPoints;
		}

		private static function distance(p1:Point, p2:Point):Number
		{
			return Math.sqrt( (p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y) );
		}
		
		private static function pathLength(points:Vector.<Point>):Number
		{
			var length:uint = points.length;
			var d:Number = 0;
			for(var i:int = 1;i<length;i++)
				d += distance(points[i-1], points[i]);
			return d;
		}
		
		private static function indicativeAngle(points:Vector.<Point>):Number
		{
			var c:Point = centroid(points);
			var start:Point = points[0];
			return Math.atan2(c.y - start.y, c.x - start.x);
		}
		
		private static function centroid(points:Vector.<Point>):Point
		{
			var length:uint = points.length;
			var sumX:Number = 0;
			var sumY:Number = 0;
			for each(var p:Point in points)
			{
				sumX += p.x;
				sumY += p.y;
			}
			return new Point(sumX / length, sumY / length);
		}
		
		private static function rotateBy(points:Vector.<Point>, angle:Number):Vector.<Point>
		{
			var c:Point = centroid(points);
			var m:Matrix = new Matrix();
			m.translate(-c.x, -c.y);
			m.rotate(angle);
			m.translate(c.x, c.y);
			var length:uint = points.length;
			var newPoints:Vector.<Point> = new Vector.<Point>();
			for(var i:int = 0;i<length;i++)
				newPoints.push(m.transformPoint(points[i]));
			return newPoints;
		}
		
		private static function scaleDimTo(points:Vector.<Point>, size:int, threshold:Number):Vector.<Point>
		{
			var bounding:Rectangle = boundingBox(points);
			
			if(bounding.width < THRESHOLD_0D_PIXALS && bounding.height < THRESHOLD_0D_PIXALS)
				return points;
			
			for each(var p:Point in points)
			{
				if(Math.min(bounding.width / bounding.height, bounding.height / bounding.width) <= THRESHOLD_1D_PORTION)
				{
					p.x = p.x * size / Math.max(bounding.width, bounding.height);
					p.y = p.y * size / Math.max(bounding.width, bounding.height);
				}
				else
				{
					p.x = p.x * size / bounding.width;
					p.y = p.y * size / bounding.height;
				}
			}
			return points;
		}
		
		private static function boundingBox(points:Vector.<Point>):Rectangle
		{
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
		
		private static function translateCentroidTo(points:Vector.<Point>, to:Point):Vector.<Point>
		{
			var c:Point = centroid(points);
			var offset:Point = new Point(to.x - c.x, to.y - c.y);
			for each(var p:Point in points)
				p.offset(offset.x, offset.y);
			return points;
		}
		
		private static function recognize(points:Vector.<Point>, templates:Vector.<Template>, size:Number):RecognizeResult
		{
			if(templates.length == 0)
				return RecognizeResult.UNDEFINED;
			
			var bestDist:Number = Number.MAX_VALUE;
			var dist:Number;
			var bestT:Template;
			for each(var template:Template in templates)
			{
				dist = distanceAtBestAngle(points, template, -THETA, THETA, THRESHOLD_THETA);
				if(dist < bestDist)
				{
					bestT = template;
					bestDist = dist;
				}
			}
			return new RecognizeResult(bestT.name, 1 - bestDist / (0.5 * Math.sqrt( 2 * size * size )));
		}
		
		private static function distanceAtBestAngle(points:Vector.<Point>, template:Template, thetaA:Number, thetaB:Number, threshold:Number):Number
		{
			var x1:Number = PHI * thetaA + (1 - PHI) * thetaB;
			var f1:Number = distanceAtAngle(points, template, x1);
			var x2:Number = (1 - PHI) * thetaA + PHI * thetaB;
			var f2:Number = distanceAtAngle(points, template, x2);
			
			while(Math.abs(thetaA - thetaB) > threshold)
			{
				if(f1<f2)
				{
					thetaB = x2;
					x2 = x1;
					f2 = f1;
					x1 = PHI * thetaA + (1 - PHI) * thetaB;
					f1 = distanceAtAngle(points, template, x1);
				}
				else
				{
					thetaA = x1;
					x1 = x2;
					f1 = f2;
					x2 = (1 - PHI) * thetaA + PHI * thetaB;
					f2 = distanceAtAngle(points, template, x2);
				}
			}
			return Math.min(f1, f2);
		}
		
		private static function distanceAtAngle(points:Vector.<Point>, template:Template, theta:Number):Number
		{
			var newPoints:Vector.<Point> = rotateBy(points, theta);
			return pathDistance(newPoints, template);
		}
		
		private static function pathDistance(points:Vector.<Point>, gesture:Template):Number
		{
			var d:Number = 0;
			var length:uint = points.length;
			for(var i:int = 0;i<length;i++)
				d += distance(points[i], gesture.points[i]);
			return d / length;
		}
	}
}