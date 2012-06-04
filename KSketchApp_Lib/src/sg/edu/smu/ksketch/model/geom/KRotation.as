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

	public class KRotation
	{
		private var _motionPath:KPath;
		private var _transitionPath:K2DPath;
		private var _hasTransform:Boolean;
		
		private var _currentAngle:Number;
		private var _currentRotationPoints:K3DPath;
		private var _oldTransformClone:KRotation;
		
		public function KRotation()
		{
			_motionPath = new KPath();
			_transitionPath = new K2DPath();
			_currentAngle = 0;
			_hasTransform = false;
		}
		
		public function get motionPath():KPath
		{
			return _motionPath;
		}
		
		public function set motionPath(value:KPath):void
		{
			_motionPath = value;
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
		
		public function get oldTransform():KRotation
		{
			return _oldTransformClone;
		}
		
		/**
		 * Prepares this KRotation for a transformation operation
		 */
		public function setUpCurrentTransform():void
		{
			_currentAngle = 0;
			_currentRotationPoints = new K3DPath();
			_oldTransformClone = clone();
		}
		
		/**
		 * Update and record the details of the current rotation operation
		 */
		public function updateTransform(x:Number, y:Number, angle:Number, time:Number):void
		{
			_hasTransform = true;
			_currentRotationPoints.push(x,y,time);
			_currentAngle = angle;
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
					if(_currentRotationPoints.length == 0)
						return;
					
					//Generate a rotation circle from the final angle
					var duration:Number = _currentRotationPoints.points[_currentRotationPoints.length-1].z;
					
					if(duration == 0)
					{
						//If the rotation is an instant transformation
						//Ignore motion paths and just set the angle.
						_transitionPath.push(0,0);
						_transitionPath.push(_currentAngle, 0);
					}
					else
					{
						var numSteps:int = duration/KAppState.ANIMATION_INTERVAL;
						var angleStep:Number = _currentAngle/numSteps;
						var timeStep:Number = (duration)/numSteps;
						
						var startVector:K3DVector = _currentRotationPoints.points[0];
						var startPoint:Point = new Point(startVector.x, startVector.y);
						var startAngle:Number = KMathUtil.cartesianToPolar(startPoint).y;
						
						var angleMoved:Number = 0;
						var timeMoved:Number = 0;
						var theta:Number;
						
						while(Math.abs(angleMoved) <  Math.abs(_currentAngle))
						{
							theta = angleMoved + startAngle;
							_transitionPath.push(angleMoved, timeMoved);
							angleMoved += angleStep;
							timeMoved += timeStep;
						}
						
						_transitionPath.push(_currentAngle, timeMoved);
					}
				}
				else
				{
					//Compute the angle values for the transition paths
					var i:int= 0;
					var length:int = _currentRotationPoints.length;
					
					var angle:Number;
					var direction:int;
					var currentVector:K3DVector;
					var currentPoint:Point;
					var previousPoint:Point;
					var rotateAngle:Number = 0;

					for(i; i<length; i++)
					{
						currentVector = _currentRotationPoints.points[i];
						currentPoint = new Point(currentVector.x, currentVector.y);
						
						if(!previousPoint)
							previousPoint = currentPoint.clone();
							
						angle = Math.min(KMathUtil.angleOf(previousPoint,currentPoint),KMathUtil.angleOf(currentPoint,previousPoint));
						direction = KMathUtil.segcross(previousPoint, currentPoint, previousPoint);
						
						if(direction <0)
							angle *= -1;
						
						rotateAngle += angle;
						previousPoint = currentPoint.clone();
						_transitionPath.push(rotateAngle, currentVector.z);			
					}
				}
			}
			else
			{
				//Transformation exists, so have to deal with the existing transformation via refactoring
				//or interpolation of existing paths
				KPathProcessor.interpolateRotationTransitionPath(_transitionPath.points, _currentAngle);
			}
			
			_motionPath = KPathProcessor.generateRotationMotionpath(_transitionPath);
			_currentAngle = 0;
			_currentRotationPoints = new K3DPath();
		}
		
		/**
		 * Returns the current rotation angle of this transform based on time.
		 */
		public function getTransform(proportion:Number):Number
		{
			if(_transitionPath.length == 0)
				return _currentAngle;
			var pathPoint:K2DVector = _transitionPath.getPoint(proportion);
			var result:Number = pathPoint.x + _currentAngle;
			return result
		}
		
		/**
		 * Splits this transform into two parts and returns the front portion
		 */
		public function splitTransform(proportion:Number, shift:Boolean = false):KRotation
		{
			var frontTransform:KRotation = new KRotation();
			var frontTransitionPath:K2DPath = _transitionPath.split(proportion, shift);
			
			frontTransform.transitionPath = frontTransitionPath;
			
			_motionPath = KPathProcessor.generateRotationMotionpath(_transitionPath);
			frontTransform.motionPath = KPathProcessor.generateRotationMotionpath(frontTransitionPath);
			
			return frontTransform;
		}
		
		public function mergeTransform(transform:KRotation):KRotation
		{
			var rotate:KRotation = new KRotation();
			rotate.transitionPath = KPathProcessor.mergeRotationTransitionPath(
				_transitionPath, transform.transitionPath);
			rotate.motionPath = KPathProcessor.generateRotationMotionpath(rotate.transitionPath);
			return rotate;		
		}
		
		/**
		 * Returns an exact copy of this KRotation
		 */
		public function clone():KRotation
		{
			var clone:KRotation = new KRotation();
			clone.motionPath = _motionPath.clone();
			clone.transitionPath = _transitionPath.clone();
			return clone;
		}
		
		public function addInterpolatedTransform(dThetha:Number):void
		{
			//Perform Interpolation on current Path
			//KPathProcessor.interpolateScaleMotionPath(_path.path,dScale,);
			KPathProcessor.interpolateRotationTransitionPath(_transitionPath.points,dThetha);
			_motionPath = KPathProcessor.generateRotationMotionpath(_transitionPath);
		}
		
		public function setLine(time:Number):void
		{
			//_path.addPoint(0,0);
			//_path.addPoint(0,time);
			_transitionPath.push(0,0);
			_transitionPath.push(0,time);
		}
	}
}