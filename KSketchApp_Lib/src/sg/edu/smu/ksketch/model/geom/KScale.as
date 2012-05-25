/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.model.geom
{
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch.model.implementations.KSpatialKeyFrame;
	import sg.edu.smu.ksketch.operation.KTransformMgr;
	import sg.edu.smu.ksketch.utilities.KAppState;
	import sg.edu.smu.ksketch.utilities.KMathUtil;

	public class KScale
	{
		private var _path:KPath;
		private var _transitionPath:K2DPath;
		private var _hasTransform:Boolean;
	
		private var _currentScale:Number;
		private var _currentScalePoints:K3DPath;
		private var _oldTransformClone:KScale;
		
		public function KScale()
		{
			_path = new KPath();
			_transitionPath = new K2DPath();
			_currentScale = 0;
			_hasTransform = false;
		}
		
		public function get hasTransform():Boolean
		{
			return _hasTransform;
		}
		
		public function get path():KPath
		{
			return _path;
		}
		
		public function set path(value:KPath):void
		{
			_path = value;
		}
		
		public function get transitionPath():K2DPath
		{
			return _transitionPath;
		}
		
		public function set transitionPath(value:K2DPath):void
		{
			_transitionPath = value;
			
			if(_transitionPath.length > 0)
				_hasTransform = true;
			else
				_hasTransform = false;
		}
		
		public function get oldTransform():KScale
		{
			return _oldTransformClone;
		}
		
		/**
		 * Prepares this KScale for a transformation operation
		 */
		public function setUpCurrentTransform():void
		{
			_currentScale = 0;
			_currentScalePoints = new K3DPath();
			_oldTransformClone = clone();
		}
		
		/**
		 * Update and record the details of the current rotation operation
		 */
		public function updateTransform(x:Number, y:Number, scale:Number, time:Number):void
		{
			_hasTransform = true;
			_currentScalePoints.push(x,y,time);
			_currentScale = scale;
		}
		
		/**
		 * Processes the points recorded during the rotation operation into usable
		 * transformation values.
		 */
		public function endCurrentTransform(transitionType:int, center:Point):void
		{
			if(_transitionPath.length == 0)
			{
				if(transitionType == KAppState.TRANSITION_INTERPOLATED)
				{
					if(_currentScalePoints.length == 0)
						return;
					
					//Generate a rotation circle from the final angle
					var duration:Number = _currentScalePoints.points[_currentScalePoints.length-1].z;
					
					if(duration != 0)
					{
						_path = new KPath();
						_path.addPoint(KSpatialKeyFrame.INTERPOLATION_RADIUS, KSpatialKeyFrame.INTERPOLATION_RADIUS, 0);
						_path.addPoint(KSpatialKeyFrame.INTERPOLATION_RADIUS*_currentScale, KSpatialKeyFrame.INTERPOLATION_RADIUS*_currentScale
										,duration);	
					}
					
					//If the rotation is an instant transformation
					//Ignore motion paths and just set the angle.
					_transitionPath.push(0,0);
					_transitionPath.push(_currentScale, duration);
					
				}
				else
				{
					//Compute the angle values for the transition paths
					var i:int= 0;
					var length:int = _currentScalePoints.length;
					
					var scale:Number;
					var currentVector:K3DVector;
					var currentPoint:Point;
					
					var startVector:K3DVector = _currentScalePoints.points[0];
					var startPoint:Point = new Point(startVector.x, startVector.y);
					var origin:Point = new Point();
					var startDistance:Number = KMathUtil.distanceOf(origin, startPoint);
					
					for(i; i<length; i++)
					{
						currentVector = _currentScalePoints.points[i];
						currentPoint = new Point(currentVector.x, currentVector.y);
						
						scale = KMathUtil.distanceOf(origin, currentPoint)/startDistance;
						_path.addPoint(currentVector.x, currentVector.y, currentVector.z);
						_transitionPath.push(scale-1, currentVector.z);
					}
					
				}
			}
			else
			{
				//Transformation exists, so have to deal with the existing transformation via refactoring
				//or interpolation of existing paths
				
				//Need to do refactoring here
				KPathProcessor.interpolateScaleMotionPath(_path.path, _currentScale, center);
				KPathProcessor.interpolateScaleTransitionPath(_transitionPath.points, _currentScale);
			}
			
			_currentScale = 0;
			_currentScalePoints = new K3DPath();
		}
		
		public function getTransform(proportion:Number):Number
		{
			if(_transitionPath.length == 0)
				return (1+_currentScale);
			var pathPoint:K2DVector = _transitionPath.getPoint(proportion);
			
			var result:Number = 1 + pathPoint.x + _currentScale;
			return absolute(result);
		}
		
		/**
		 * Splits this transform into two parts and returns the front portion
		 */
		public function splitTransform(proportion:Number, shift:Boolean = false):KScale
		{
			var frontTransform:KScale = new KScale();
			var frontMotionPath:KPath = _path.split(proportion, shift);
			var frontTransitionPath:K2DPath = _transitionPath.split(proportion, shift);
			
			frontTransform.path = frontMotionPath;
			frontTransform.transitionPath = frontTransitionPath;
			
			return frontTransform;
		}

		public function mergeTransform(transform:KScale):KScale
		{
			var scale:KScale = new KScale();
			scale.path = KPathProcessor.mergeScaleMotionPath(_path, transform.path);
			scale.transitionPath = KPathProcessor.mergeScaleTransitionPath(
				_transitionPath, transform.transitionPath);
			
			return scale;		
		}
		
		/**
		 * Returns an exact copy of this KScale
		 */
		public function clone():KScale
		{
			var clone:KScale = new KScale();
			clone.path = _path.clone();
			clone.transitionPath = _transitionPath.clone();
			return clone;
		}
		
		public function addInterpolatedTransform(dScale:Number):void
		{
			//Perform Interpolation on current Path
			//KPathProcessor.interpolateScaleMotionPath(_path.path,dScale,);
			KPathProcessor.interpolateScaleTransitionPath(_transitionPath.points,dScale);
		}
		
		public function setLine(time:Number):void
		{
			//_path.addPoint(0,0);
			//_path.addPoint(0,time);
			_transitionPath.push(1,0);
			_transitionPath.push(1,time);
		}
		
		private function absolute(value:Number):Number
		{
			if(value < 0)
				value *= -1;
			
			return value;
		}
	}
}