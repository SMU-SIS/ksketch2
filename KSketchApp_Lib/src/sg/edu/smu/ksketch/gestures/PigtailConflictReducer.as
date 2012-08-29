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
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.geom.Point;

	public class PigtailConflictReducer
	{
		private static const ACCEPTED_RATIO:Number=4;
		private var _loop:Vector.<Point>;
		
		
		public function PigtailConflictReducer()
		{
			_loop = new Vector.<Point>();
		}
		
		public function set loop(loop:Vector.<Point>):void
		{
			for(var i:uint=0;i<loop.length;i++)
			{
				var point:Point = loop[i];
				_loop.push(point);
			}
		}
		
		public function proceed():Boolean
		{	
			var indicativeAngle:Number = indicativeAngle(_loop);
			var points:Vector.<Point> = rotateBy(_loop, -indicativeAngle);
			var pigtailOrNot:Boolean = calculateRatio(points, ACCEPTED_RATIO);
		
			return pigtailOrNot

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
		
		private static function calculateRatio(points:Vector.<Point>,ratio:Number):Boolean
		{
			var bounding:Rectangle = boundingBox(points);
			
			if(bounding.width/bounding.height > ratio)
				return false;
			else
				return true;

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
	}
}