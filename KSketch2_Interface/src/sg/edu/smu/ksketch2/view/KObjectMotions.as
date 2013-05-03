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
		public static var transformer:Sprite = new Sprite();
		
		private var _object:KObject;
		private var _pathPoints:Dictionary;
		private var _rotations:Dictionary;
		private var _motionPath:Shape;
		
		/**
		 *	Display class for motion paths and static ghosts.
		 *	Supposed to help in micromanaging object motion paths
		 * 	Static ghosts show the objects' position, orientation and size
		 *	at the end of the active key frame.
		 */
		public function KObjectMotions()
		{
			//So in essence, the object's motions are represented by a ghost and a motion path
			//The motion path will show the user how the object gets to the ghost
			//While the ghostill show how to t
			
			super();
			
			_motionPath = new Shape();
			addChild(_motionPath);
			
			_pathPoints = new Dictionary(true);
			_rotations = new Dictionary(true);
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
			//Init ghosts here?
			
			if(_object.transformInterface.transitionType == KSketch2.TRANSITION_DEMONSTRATED)
			{
				_motionPath.visible = false;
				
				var currentKey:KSpatialKeyFrame = _object.transformInterface.getActiveKey(event.time) as KSpatialKeyFrame;			
				
				while(currentKey)
				{
					delete(_pathPoints[currentKey]);
					currentKey = currentKey.next as KSpatialKeyFrame;
				}
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
				_updateMotionPath(event.time);
			}
		}
		
		private function _transformEnd(event:KObjectEvent):void
		{				
			_motionPath.visible = true;
			
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
			
			if(!activeKey)
				return;
			
			_motionPath.graphics.clear();
			
			if(!_pathPoints[activeKey])
				_generateMotionPath(activeKey);
			
			var path:Vector.<Point> = _pathPoints[activeKey];

			if(path)
				_drawPath(path);
			
			if(activeKey.next)
			{
				path = null;				
				path = _pathPoints[activeKey];
				
				if(!path)
					path = _generateMotionPath(activeKey);

				if(path)
					_drawPath(path);
			}
		}
		
		private function _drawPath(path:Vector.<Point>):void
		{
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
			if(!key)
				throw new Error("Unable to generate a motion path if there is no active key");
			
			var path:Vector.<Point>= new Vector.<Point>();			
			var matrix:Matrix;
			var currentTime:int = key.startTime;
			var currentKeyElapsedTime:int = 0;
			var centroid:Point = _object.centroid;
			var position:Point;
			
			var proportion:int;
			var accumulatedRotation:Number = 0;
			var currentRotation:Number;
			var prevRotation:Number = 0;
			
			while(currentTime <= key.time)
			{
				matrix = _object.fullPathMatrix(currentTime);
				position = matrix.transformPoint(centroid);
				path.push(position);
				currentTime += KSketch2.ANIMATION_INTERVAL;	
			}
			
			if(path.length > 0)
			{
				_pathPoints[key] = path;				
				return path;	
			}
			else
				return null;
		}
	}
}