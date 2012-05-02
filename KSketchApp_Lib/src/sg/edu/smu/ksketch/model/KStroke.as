/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.model
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import sg.edu.smu.ksketch.event.KObjectEvent;
	
	/**
	 * Subclass of KObject that represents drawing stroke and the supporting operations.
	 */
	public class KStroke extends KObject
	{
		protected var _points:Vector.<Point>;
		private var _thickness:Number;
		private var _color:uint;
		private var _cachedCenter:Point;
		
		public function KStroke(id:int, createdTime:Number, points:Vector.<Point> = null)
		{
			super(id,createdTime);
			_points = points;
			if(_points == null)
				_points = new Vector.<Point>();
			_thickness = 1;
			_color = defaultColor;
			defaultBoundingBox = this.getBoundingRect(createdTime);
		}
		
		public function setPoints(points:Vector.<Point>):void
		{
			_points = points;
		}
		
		public function addPoint(x:Number, y:Number):void
		{
			_points.push(new Point(x, y));
			defaultBoundingBox = this.getBoundingRect(createdTime);
			this.dispatchEvent(new KObjectEvent(this, KObjectEvent.EVENT_POINTS_CHANGED, true));
		}
		
		public function endAddingPoint():void
		{
		}
		
		public function get thickness():Number
		{	
			return _thickness;
		}
		public function set thickness(thickness:Number):void
		{	
			_thickness = thickness;
		}
		
		public static function get defaultColor():uint
		{
			return 0x000000;
		}
		
		public function get color():uint
		{
			return _color;
		}
		public function set color(value:uint):void
		{
			_color = value;
			this.dispatchEvent(new KObjectEvent(this, KObjectEvent.EVENT_COLOR_CHANGED));
		}
		
		public function get points():Vector.<Point>
		{
			return _points;
		}
		
		public override function getBoundingRect(kskTime:Number = 0):Rectangle
		{
			if(points.length == 0)
				return new Rectangle(0,0,0,0);
			
			var maxX:Number = points[0].x;
			var minX:Number = points[0].x;
			var maxY:Number = points[0].y;
			var minY:Number = points[0].y;
			
			for(var i:int = 1; i < points.length; i++)
			{
				maxX = Math.max(maxX,points[i].x);
				maxY = Math.max(maxY,points[i].y);
				minX = Math.min(minX,points[i].x);
				minY = Math.min(minY,points[i].y);
			}
			return new Rectangle(minX,minY,maxX-minX,maxY-minY);
		}
		
		public override function get defaultCenter():Point
		{
			if(!_cachedCenter)
			{
				var rect:Rectangle = getBoundingRect();
				_cachedCenter = new Point(rect.x+rect.width/2, rect.y + rect.height/2);
			}
			
			return _cachedCenter.clone();			
		}
	}
}