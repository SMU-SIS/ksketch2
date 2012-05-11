/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.model.geom
{
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch.operation.KTransformMgr;
	import sg.edu.smu.ksketch.utilities.KAppState;

	public class KTranslation
	{
		private var _motionPath:KPath;
		private var _transitionPath:K3DPath;
		
		private var _hasTransform:Boolean;
		private var _currentTranslation:Point;
		private var _currentTranslationPoints:K3DPath;
		private var _oldTransformClone:KTranslation;
		
		public function KTranslation()
		{
			_motionPath = new KPath();
			_transitionPath = new K3DPath();
			_currentTranslation = new Point();
			_hasTransform = false;
		}
		
		/**
		 * Checks if the KTranslate has a translation
		 */
		public function get hasTransform():Boolean
		{
			return _hasTransform;
		}
		
		/**
		 * returns the motion path for this transform
		 */
		public function get path():KPath
		{
			return _motionPath;
		}
		
		public function set path(value:KPath):void
		{
			_motionPath = value;
		}
		
		public function get transitionPath():K3DPath
		{
			return _transitionPath;
		}
		
		public function set transitionPath(value:K3DPath):void
		{
			_transitionPath = value;
			
			if(_transitionPath.length > 0)
				_hasTransform = true;
			else
				_hasTransform = false;

		}
		
		public function get oldTransform():KTranslation
		{
			return _oldTransformClone;
		}
		
		/**
		 * Adds a new transform coordinate to this KTranslation
		 */
		public function updateTransform(x:Number, y:Number, time:Number):void
		{
			_hasTransform = true;
			_currentTranslation.x = x;
			_currentTranslation.y = y;
			_currentTranslationPoints.push(x,y,time);
		}
		
		/**
		 * Returns the dx and dy of the current active operation
		 */
		public function get currentTransform():Point
		{
			return _currentTranslation.clone();
		}
		
		/**
		 * Prepares this KTranslation for a transform operation
		 */
		public function setUpCurrentTransform():void
		{
			_currentTranslation = new Point();
			_currentTranslationPoints = new K3DPath();
			_oldTransformClone = clone();

		}
		
		/**
		 * Processes the recorded points into usable data after a transformation operation.
		 */
		public function endCurrentTransform(transitionType:int):void
		{
			var i:int;
			
			if(_transitionPath.length == 0)
			{
				if(transitionType == KAppState.TRANSITION_INTERPOLATED)
				{
					var startPoint:K3DVector = _currentTranslationPoints.points[0];
					var endPoint:K3DVector = _currentTranslationPoints.points[_currentTranslationPoints.length-1];
					var duration:Number = endPoint.z;
					
					if(duration != 0)
					{
						//Need to change kPath to K3DPath
						_motionPath.addPoint(startPoint.x, startPoint.y, 0);
						_motionPath.addPoint(endPoint.x, endPoint.y, endPoint.z);
					}
					
					_transitionPath.push(startPoint.x, startPoint.y, 0);
					_transitionPath.push(endPoint.x, endPoint.y, endPoint.z);
				}
				else
				{
					i = 0;
					var length:int = _currentTranslationPoints.length;
					var pathPoint:K3DVector;
					
					for(i; i<length; i++)
					{
						pathPoint = _currentTranslationPoints.points[i];
						
						_motionPath.addPoint(pathPoint.x, pathPoint.y, pathPoint.z);
						
						//Short cut, we will need to do pre-processing on the _motion path before 
						//we add points to the transition path
						_transitionPath.push(pathPoint.x, pathPoint.y, pathPoint.z);			
					}

				}
			}
			else
			{
				//Perform Interpolation on current Path
				KPathProcessor.interpolateTranslationMotionPath(_motionPath.path, _currentTranslation.x, _currentTranslation.y);
				KPathProcessor.interpolateTranslationTransitionPath(_transitionPath.points, _currentTranslation.x, _currentTranslation.y);
			}
			
			_currentTranslation = new Point();
			_currentTranslationPoints = new K3DPath();
		}
		
		/**
		 * Returns the dx and dy of the transformation after processing
		 */
		public function getTransform(proportion:Number):Point
		{
			if(_transitionPath.points.length == 0)
				return (_currentTranslation);
			
			var pathPoint:K3DVector = _transitionPath.getPoint(proportion);
			var result:Point = (new Point(pathPoint.x, pathPoint.y)).add(_currentTranslation);
			return result
		}
		
		/**
		 * Splits this transform into two parts and returns the front portion
		 */
		public function splitTransform(proportion:Number, shift:Boolean = false):KTranslation
		{
			var frontTransform:KTranslation = new KTranslation();
			var frontMotionPath:KPath = _motionPath.split(proportion, shift);
			var frontTransitionPath:K3DPath = _transitionPath.split(proportion, shift);
			
			frontTransform.path = frontMotionPath;
			frontTransform.transitionPath = frontTransitionPath;
			
			return frontTransform;
		}

		public function mergeTransform(transform:KTranslation):KTranslation
		{
			var translate:KTranslation = new KTranslation();
			translate.path = KPathProcessor.mergeTranslationMotionPath(
				_motionPath, transform.path);
			translate.transitionPath = KPathProcessor.mergeTranslationTransitionPath(
				_transitionPath, transform.transitionPath);
			return translate;		
		}
		
		/**
		 * Returns an exact copy of this KTranslation
		 */
		public function clone():KTranslation
		{
			var clone:KTranslation = new KTranslation();
			clone.path = _motionPath.clone();
			clone.transitionPath = _transitionPath.clone();
			clone._currentTranslation = _currentTranslation.clone();
			return clone;
		}
		
		public static function computeTranslate(startPoint:Point, endPoint:Point):Point
		{
			return endPoint.subtract(startPoint);
		}
		
		public function addInterpolatedTransform(dx:Number, dy:Number):void
		{
			//Perform Interpolation on current Path
			KPathProcessor.interpolateTranslationMotionPath(_motionPath.path, dx,dy, false);
			KPathProcessor.interpolateTranslationTransitionPath(_transitionPath.points, dx, dy);
		}
		
		public function setLine(time:Number):void
		{
			_motionPath.addPoint(0,0,0);
			_motionPath.addPoint(0,0,time);
			_transitionPath.push(0,0,0);
			_transitionPath.push(0,0,time);
		}
		
		public function addInstantTransform(dx:Number, dy:Number, time:Number):void
		{
			if(_transitionPath.length < 2)
			{
				_transitionPath.push(0, 0, 0);
				_transitionPath.push(dx, dy, 0);
			}
			else
			{	
				var targetIndex:int = _transitionPath.getIndexAtOrAfterTime(time);
				var targetPoint:K3DVector = _transitionPath.points[targetIndex];
				targetPoint.x += dx;
				targetPoint.y += dy;
			}
		}
	}
}