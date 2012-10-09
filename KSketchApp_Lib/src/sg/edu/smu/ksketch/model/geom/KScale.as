/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package sg.edu.smu.ksketch.model.geom
{
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch.model.implementations.KSpatialKeyFrame;
	import sg.edu.smu.ksketch.operation.KTransformMgr;
	import sg.edu.smu.ksketch.utilities.KAppState;
	import sg.edu.smu.ksketch.utilities.KMathUtil;

	public class KScale
	{
		private var _motionPath:KPath;
		private var _transitionPath:K2DPath;
		private var _hasTransform:Boolean;
	
		private var _currentScale:Number;
		private var _currentScalePoints:K3DPath;
		private var _oldTransformClone:KScale;
		
		public function KScale()
		{
			_motionPath = new KPath();
			_transitionPath = new K2DPath();
			_currentScale = 0;
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
						_transitionPath.push(scale-1, currentVector.z);
					}
					
				}
			}
			else
			{
				//Transformation exists, so have to deal with the existing transformation via refactoring
				//or interpolation of existing paths
				
				//Need to do refactoring here
				KPathProcessor.interpolateScaleTransitionPath(_transitionPath.points, _currentScale);
			}
			
			if(_transitionPath)
				cleanUpPath();
			
			_currentScale = 0;
			_currentScalePoints = new K3DPath();
		}
		
		public function getTransform(proportion:Number):Number
		{
			if(_transitionPath.length == 0)
				return (1+_currentScale);
			var pathPoint:K2DVector = _transitionPath.getPoint(proportion);
			
			var result:Number = 1 + pathPoint.x + _currentScale;

			if(result < 0)
				result *= -1;
			
			return result;
		}
		
		/**
		 * Splits this transform into two parts and returns the front portion
		 */
		public function splitTransform(proportion:Number, shift:Boolean = false):KScale
		{
			var frontTransform:KScale = new KScale();
			var frontTransitionPath:K2DPath = _transitionPath.split(proportion, shift);
			
			frontTransform.transitionPath = frontTransitionPath;
			cleanUpPath();
			frontTransform.cleanUpPath();
			
			return frontTransform;
		}

		public function mergeTransform(transform:KScale):KScale
		{
			_oldTransformClone = this.clone();
			var scale:KScale = new KScale();
			scale.transitionPath = KPathProcessor.mergeScaleTransitionPath(
				_transitionPath, transform.transitionPath);
			KPathProcessor.resample2DPath(scale.transitionPath);
			scale.motionPath = KPathProcessor.generateScaleMotionPath(scale.transitionPath);
			return scale;		
		}
		
		/**
		 * Returns an exact copy of this KScale
		 */
		public function clone():KScale
		{
			var clone:KScale = new KScale();
			clone.transitionPath = _transitionPath.clone();
			clone.cleanUpPath();
			return clone;
		}
		
		public function addInterpolatedTransform(dScale:Number):void
		{
			//Perform Interpolation on current Path
			//KPathProcessor.interpolateScaleMotionPath(_path.path,dScale,);
			KPathProcessor.interpolateScaleTransitionPath(_transitionPath.points,dScale);
			cleanUpPath();
		}
		
		public function resampleMotion():void
		{
			KPathProcessor.resample2DPath(_transitionPath);
			KPathProcessor.generateScaleMotionPath(_transitionPath);
		}
		
		public function setLine(time:Number):void
		{
			_transitionPath.push(1,0);
			_transitionPath.push(1,time);
		}
		
		/**
		 * Removes excess points (points near each other, points too close in time)
		 */
		public function cleanUpPath():void
		{
			KPathProcessor.cleanUp2DPath(_transitionPath);
			_motionPath = KPathProcessor.generateRotationMotionPath(_transitionPath);
			_transitionPath.generateMagnitudeTable();
		}
	}
}