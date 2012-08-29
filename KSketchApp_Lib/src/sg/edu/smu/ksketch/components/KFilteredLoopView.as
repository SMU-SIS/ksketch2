package sg.edu.smu.ksketch.components
{
	import flash.display.Shape;
	import flash.geom.Point;
	
	import mx.core.Container;
	
	import sg.edu.smu.ksketch.utilities.KMathUtil;
	
	public class KFilteredLoopView extends Shape
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
		
		private var _clone:KFilteredLoopView;
		private var _mouseOffsetX:Number = 0;
		private var _mouseOffsetY:Number = 0;
		
		//add a Vector used to store the historical points
		private var _historyPoints:Vector.<Point>;
		//add a variable to store "null" point, whose distance to the last point is less than threshold
		private var _tempPoint:Point;
		
		public function KFilteredLoopView(color:uint = DEFAULT_COLOR, distance:int = DEFAULT_THRESHOLD_DISTANCE, radius:Number = DEFULT_RADIUS)
		{
			_color = color;
			_distance = distance;
			_radius = radius;
			
			_historyPoints = new Vector.<Point>();
			_tempPoint = new Point();
		}
		
		public function add(point:Point):Point
		{	
			if(_clone != null)
			{
				_clone.add(point);
			}
			
			if(_lastPoint == null)
			{
				_lastPoint = point;
				graphics.beginFill(_color);
				graphics.lineStyle(1, _color);
				graphics.drawRect(_lastPoint.x - _radius, _lastPoint.y - _radius, _radius * 2, _radius * 2);
				
				return _lastPoint;
			}
			else
			{
				var dist:Number = KMathUtil.distanceOf(_lastPoint, point);
				
				if(dist < _distance)
					return null;
				else
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
					
					return _lastPoint;
				}
			}
		}
		
		public function clear():void
		{
			if(_clone != null)
			{
				_clone.clear();
				killClone();
			}
			
			graphics.clear();
			_lastPoint = null;
		}
		
		// get the history point
		public function get historyPoints():Vector.<Point>
		{
			return _historyPoints;
		}
		
		// record the history point with draw it on canvas
		public function record(point:Point):Point
		{	
			if(_lastPoint == null)
			{
				_lastPoint = point;
				
				//add the last point into historical point vector
				_historyPoints.push(_lastPoint);
				
				//store the last point to temporary point
				_tempPoint = _lastPoint.clone();
				
				return _lastPoint;
			}
			else
			{
				var dist:Number = KMathUtil.distanceOf(_lastPoint, point);
				
				if(dist < _distance)
				{
					return null;
				}
				else
				{
					var pnts:int = dist / _distance;
					var p:Point = _lastPoint.clone();
					var percent:Number = _distance / dist;
					var v:Point = new Point(percent * (point.x - _lastPoint.x), percent * (point.y - _lastPoint.y));
					
					while(pnts-- > 0)
					{
						p.x += v.x
						p.y += v.y;
						
						//add the current value of p into history vector
						var point:Point = p.clone();
						_historyPoints.push(point);
					}
					_lastPoint = p;
					
					return _lastPoint;
				}
			}
		}
		
		public function get radius():Number
		{
			return _radius;
		}
		
		public function clone():KFilteredLoopView
		{
			_clone = new KFilteredLoopView();
			visible = false;
			return _clone;
		}
		
		public function killClone():void
		{
			if(_clone != null)
			{
				if(_clone.parent != null)
				{
					_clone.parent.removeChild(_clone);
				}
			}
		}
	}
}