/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package sg.edu.smu.ksketch2.view
{
	import flash.display.GraphicsPathCommand;
	import flash.display.GraphicsPathWinding;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	import spark.primitives.Graphic;
	
	public class KFilteredLoopView extends Sprite
	{
		private static const DEFULT_RADIUS:Number = 1;
		private static const DEFAULT_COLOR:uint = 0xf38400;
		
		// changed color - "white"
		private static const CHANGED_COLOR:uint = 0x000000;
		
		private static const DEFAULT_THRESHOLD_DISTANCE:int = 10;
		
		private var _lastPoint:Point;
		
		private var _color:uint;
		private var _distance:int;
		private var _radius:Number;
		
		private var _mouseOffsetX:Number = 0;
		private var _mouseOffsetY:Number = 0;
		
		//add a Vector used to store the historical points
		private var _points:Vector.<Point>;
		
		public function KFilteredLoopView(color:uint = DEFAULT_COLOR, distance:int = DEFAULT_THRESHOLD_DISTANCE, radius:Number = DEFULT_RADIUS)
		{
			_color = color;
			_distance = distance;
			_radius = radius;
		}
		
		public function add(point:Point):void
		{	
			if(_lastPoint == null)
			{
				_points = new Vector.<Point>();
				_lastPoint = point;
				
				_points.push(point);
				
				graphics.beginFill(_color);
				graphics.lineStyle(1, _color);
				graphics.drawRect(_lastPoint.x - _radius, _lastPoint.y - _radius, _radius * 2, _radius * 2);
			}
			else
			{
				var dist:Number = Math.sqrt(Math.pow((point.x - _lastPoint.x),2)+Math.pow((point.y - _lastPoint.y),2));
				
				if(dist >= _distance)
				{
					var pnts:int = dist / _distance;
					var p:Point = _lastPoint.clone();
					var percent:Number = _distance / dist;
					var v:Point = new Point(percent * (point.x - _lastPoint.x), percent * (point.y - _lastPoint.y));
					
					while(pnts-- > 0)
					{	
						p.x += v.x
						p.y += v.y;
						
						graphics.drawRect(p.x - _radius, p.y - _radius, _radius * 2, _radius * 2);
						
					}
					
					_lastPoint = p;
					_points.push(p);
				}
			}
		}
		
		private function _renderCollisionShape():void
		{
			
		}
		
		public function clear():void
		{
			graphics.clear();
			_lastPoint = null;
			_points = null;
		}
		
		public function get radius():Number
		{
			return _radius;
		}
	}
}