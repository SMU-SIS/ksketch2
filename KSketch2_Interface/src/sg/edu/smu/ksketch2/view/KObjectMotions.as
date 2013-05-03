package sg.edu.smu.ksketch2.view
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.events.KObjectEvent;
	import sg.edu.smu.ksketch2.model.data_structures.KSpatialKeyFrame;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	
	public class KObjectMotions extends Sprite
	{
		private var _object:KObject;
		private var _pathPoints:Dictionary;
		private var _motionPath:Shape;
		private var _ghostHost:Sprite;			
		
		/**
		 *	Display class for motion paths and ghosts.
		 *	Supposed to help in micromanaging object motion paths
		 */
		public function KObjectMotions()
		{
			super();
			
			_motionPath = new Shape();
			addChild(_motionPath);
			
			_ghostHost = new Sprite();
			addChild(_ghostHost);
			
			_pathPoints = new Dictionary(true);
		}
		
		public function set object(newObject:KObject):void
		{
			_object = newObject;		
			
			if(_object)
				_object.addEventListener(KObjectEvent.OBJECT_TRANSFORM_BEGIN, _transformBegin);
		}
		
		public function get object():KObject
		{
			return object;
		}
		
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
		}
		
		public function _visibilityChanged(event:KObjectEvent):void
		{
			if(!_object)
				return;
			
			if(_object.visibilityControl.alpha(event.time) <= 0)
			{
				visible = false;
				return;
			}
			else
				visible = true;
		}
		
		/**
		 * This thing becomes updated when transform changes
		 * motion paths do not update themselves. They just get retrieved from the motion path cache
		 */
		public function _updateObjectMotion(time:int):void	
		{
			if(_motionPath.visible)
				_updateMotionPath(time);
		}
		
		private function _transformBegin(event:KObjectEvent):void
		{
			//If performance, need to hide paths
			//Init ghosts here
			
			if(_object.transformInterface.transitionType == KSketch2.TRANSITION_DEMONSTRATED)
			{
				_motionPath.visible = false;
			}
			else
			{
				_motionPath.visible = true;
			}
			
			_object.addEventListener(KObjectEvent.OBJECT_TRANSFORM_ENDED, _transformEnd);
			_object.addEventListener(KObjectEvent.OBJECT_TRANSFORM_UPDATING, _transformUpdating);
			_object.removeEventListener(KObjectEvent.OBJECT_TRANSFORM_BEGIN, _transformBegin);
		}
		
		private function _transformUpdating(event:KObjectEvent):void
		{
			if(_motionPath.visible)
			{
				var activeKey:KSpatialKeyFrame = _object.transformInterface.getActiveKey(event.time) as KSpatialKeyFrame;			
				_generateMotionPath(activeKey);
			}
			
			if(_ghostHost.visible)
			{
				
			}
		}
		
		private function _transformEnd(event:KObjectEvent):void
		{
			
			_motionPath.visible = true;
			_ghostHost.visible = false;
			
			_object.removeEventListener(KObjectEvent.OBJECT_TRANSFORM_ENDED, _transformEnd);	
			_object.removeEventListener(KObjectEvent.OBJECT_TRANSFORM_UPDATING, _transformUpdating);
			_object.addEventListener(KObjectEvent.OBJECT_TRANSFORM_BEGIN, _transformBegin);
		}
		
		/**
		 * Generate a motion path at time
		 */
		private function _updateMotionPath(time:int):void
		{
			var activeKey:KSpatialKeyFrame = _object.transformInterface.getActiveKey(time) as KSpatialKeyFrame;			
			var path:Vector.<Point> = _pathPoints[activeKey];
			
			if(!path)
				path = _generateMotionPath(activeKey);
			
			_motionPath.graphics.clear();
			
			if(0 < path.length)
			{
				var currentPoint:Point = path[0];
				_motionPath.graphics.lineStyle(2, 0x2E9AFE);
				_motionPath.graphics.moveTo(currentPoint.x, currentPoint.y);
				
				var i:int = 1;
				var length:int = path.length;
				
				for(i; i<length; i++)
				{
					currentPoint = path[i];
					_motionPath.graphics.lineTo(currentPoint.x, currentPoint.y);
				}
			}	
		}
		
		private function _generateMotionPath(key:KSpatialKeyFrame):Vector.<Point>
		{
			var path:Vector.<Point>= new Vector.<Point>();			
			var matrix:Matrix;
			var currentTime:int = key.startTime;
			var centroid:Point = _object.centroid;
			var position:Point;
			
			while(currentTime < key.time)
			{
				matrix = _object.fullPathMatrix(currentTime);
				position = matrix.transformPoint(centroid);
				path.push(position);				
				currentTime += KSketch2.ANIMATION_INTERVAL;
			}
			
			_pathPoints[key] = path;			
			
			return path;	
		}
		
		private function _updateGhosts(time:int):void
		{
			
		}
	}
}