/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.model.implementations
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch.model.IKeyFrame;
	import sg.edu.smu.ksketch.model.ISpatialKeyframe;
	import sg.edu.smu.ksketch.model.geom.KRotation;
	import sg.edu.smu.ksketch.model.geom.KScale;
	import sg.edu.smu.ksketch.model.geom.KTranslation;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	import sg.edu.smu.ksketch.operation.KTransformMgr;
	import sg.edu.smu.ksketch.operation.implementations.KCompositeOperation;
	import sg.edu.smu.ksketch.operation.implementations.KReplaceTransformOperation;
	
	public class KSpatialKeyFrame extends KKeyFrame implements ISpatialKeyframe
	{
		public static const INTERPOLATE_CURRENT:int = 0;
		public static const INTERPOLATE_FULL:int = 1;
		public static const INSTANT_TRANSFORM:int = 2;
		public static const INTERPOLATION_RADIUS:Number = 100;
		public static const EPSILON:Number = 0.05;
		
		private var _center:Point;
		private var _translateTransform:KTranslation;
		private var _rotateTransform:KRotation;
		private var _scaleTransform:KScale;
		private var _isDirty:Boolean;
		private var _cachedMatrix:Matrix;
		private var _cachedTime:Number;
		
		public function KSpatialKeyFrame(time:Number, center:Point)
		{
			super(time);
			
			_center = center.clone();
			_translateTransform = new KTranslation();
			_rotateTransform = new KRotation();
			_scaleTransform = new KScale();
			_isDirty = true;
			_cachedMatrix = new Matrix();
		}
		
		/**
		 * Defines the center of this key frame
		 */	
		public function get center():Point
		{
			return _center.clone();
		}
		
		public function set center(point:Point):void
		{
			_center = point.clone();
		}
		
		public function get translate():KTranslation
		{
			return _translateTransform.clone();
		}
		
		public function set translate(transform:KTranslation):void
		{
			_translateTransform = transform;
		}
		
		public function get rotate():KRotation
		{
			return _rotateTransform.clone();
		}
		
		public function set rotate(transform:KRotation):void
		{
			_rotateTransform = transform;
		}
		
		public function get scale():KScale
		{
			return _scaleTransform.clone();
		}
		
		public function set scale(transform:KScale):void
		{
			_scaleTransform = transform;
		}
		
		/**
		 * Returns the translation defined by this key frame's path at the given time.
		 */
		public function getTranslation(proportion:Number):Point
		{
			return _translateTransform.getTransform(proportion);
		}
		
		/**
		 * Returns the rotation(in Radians) defined by this key frame's path at the given time.
		 */
		public function getRotation(proportion:Number):Number
		{
			return _rotateTransform.getTransform(proportion);
		}
		
		/**
		 * Returns the scale defined by this key frame's path at the given time.
		 */
		public function getScale(proportion:Number):Number
		{
			return _scaleTransform.getTransform(proportion);
		}
		
		/**
		 * Returns the complete matrix of this key frame,
		 * concatenated with the matrices of the preceding key frames
		 */
		public function getFullMatrix(kskTime:Number, matrix:Matrix):Matrix
		{	
			if(_cachedTime != kskTime)
				dirtyKey();
			
			if(_previous)
			{
				(_previous as KSpatialKeyFrame).getFullMatrix(kskTime, matrix);
			}
			
			if(_isDirty)
			{
				getPartialMatrix(kskTime, matrix);
				
				_isDirty = false;
				_cachedTime = kskTime;
				_cachedMatrix = matrix.clone();
			}
			else
			{
				matrix.identity();
				matrix.concat(_cachedMatrix.clone());
			}
			
			return matrix;
		}
		
		/**
		 * Returns the matrix of this key frame at kskTime
		 */
		public function getPartialMatrix(kskTime:Number, matrix:Matrix):Matrix
		{
			var proportion:Number = _findProportion(kskTime);
			var newCenter:Point = matrix.transformPoint(center);
			var theta:Number = getRotation(proportion);
			var sigma:Number = getScale(proportion);
			var dxdy:Point = getTranslation(proportion);
			
			var transform:Matrix = new Matrix();
			transform.translate(-newCenter.x, -newCenter.y);
			transform.rotate(theta);
			transform.scale(sigma, sigma);
			transform.translate(newCenter.x, newCenter.y);
			
			matrix.concat(transform);
			matrix.translate(dxdy.x, dxdy.y);
			
			return matrix;
		}
		
		/**
		 * Function to set matrix to dirty
		 */
		public function dirtyKey():void
		{
			_isDirty = true;
			_cachedMatrix = new Matrix();
			
			if(_next)
				(_next as KSpatialKeyFrame).dirtyKey();
		}
		
		/**
		 * Prepares this keyframe for transformation
		 */
		public function beginTransform():void
		{
			_translateTransform.setUpCurrentTransform();
			_rotateTransform.setUpCurrentTransform();
			_scaleTransform.setUpCurrentTransform();
			dirtyKey();
		}
		
		/**
		 * Appends a point to the end of the translation path
		 */
		public function addToTranslation(x:Number, y:Number, time:Number):void
		{
			_translateTransform.updateTransform(x,y,time-startTime());
			dirtyKey();
		}
		
		/**
		 * Call at the end of every translation operation
		 * Will invoke path processing functions to optimise the paths recorded during the 
		 * operations and generate the appropriate transforms from the optimised paths.
		 */
		public function endTranslation(transitionType:int):void
		{
			_translateTransform.endCurrentTransform(transitionType);
			dirtyKey();
		}
		
		/**
		 * Appends a point to the end of the rotation path
		 */
		public function addToRotation(x:Number, y:Number, angle:Number, time:Number):void
		{
			_rotateTransform.updateTransform(x,y,angle,time-startTime());
			dirtyKey();
		}
		
		public function endRotation(transitionType:int):void
		{
			_rotateTransform.endCurrentTransform(transitionType, _center.clone());
			dirtyKey();
		}
		
		/**
		 * Appends a point to the end of the scale path
		 */
		public function addToScale(x:Number, y:Number, scale:Number ,time:Number):void
		{
			_scaleTransform.updateTransform(x,y,scale,time-startTime());
			dirtyKey();
		}
		
		public function endScale(transitionType:int):void
		{
			_scaleTransform.endCurrentTransform(transitionType, _center.clone());
			dirtyKey();
		}
		
		/**
		 * Creates a clone of this spatial key frame
		 */
		override public function clone():IKeyFrame
		{
			var cloneKey:KSpatialKeyFrame = new KSpatialKeyFrame(endTime, center.clone());
			cloneKey.translate = translate;
			cloneKey.rotate = rotate;
			cloneKey.scale = scale;
			
			return cloneKey;
		}
		
		/**
		 * Takes in the elapsed time of the key frame,
		 * Splits the keyframe and returns the front portion.
		 */
		public function splitKey(time:Number, operation:KCompositeOperation, 
								 currentCenter:Point = null):Vector.<IKeyFrame>
		{
			//Find the proportion
			var proportion:Number = _findProportion(time);
			
			//Create a new key frame and clone the transforms
			var newKey:KSpatialKeyFrame = new KSpatialKeyFrame(time, center);
			var oldTranslate:KTranslation = _translateTransform.clone();
			var oldRotate:KRotation = _rotateTransform.clone();
			var oldScale:KScale = _scaleTransform.clone();
			
			//Split the transforms and assign them to the new keys
			newKey.translate = _translateTransform.splitTransform(proportion, true);
			newKey.rotate = _rotateTransform.splitTransform(proportion);
			newKey.scale = _scaleTransform.splitTransform(proportion);
			
			//Create a new operation for the split
			var splitTransformOp:KReplaceTransformOperation = new KReplaceTransformOperation(
				this, oldTranslate, _translateTransform.clone(),
				oldRotate, _rotateTransform.clone(),
				oldScale, _scaleTransform.clone());
			operation.addOperation(splitTransformOp);
			
			//Order the link list accordingly
			if(previous)
				(previous as KSpatialKeyFrame).next = newKey;
			newKey.next = this;
			newKey.previous = previous;
			previous = newKey;
			
			var returnVector:Vector.<IKeyFrame> = new Vector.<IKeyFrame>();
			returnVector.push(newKey);
			returnVector.push(this);
			
			//Dirty the key frame
			if(newKey.previous)
				(newKey.previous as KSpatialKeyFrame).dirtyKey();
			return returnVector;
		}
		
		public function mergeKey(key:ISpatialKeyframe, type:int):IModelOperation
		{
			switch(type)
			{
				case KTransformMgr.TRANSLATION_REF:
					translate = translate.mergeTransform(key.translate);
					break;
				case KTransformMgr.ROTATION_REF:
					rotate = rotate.mergeTransform(key.rotate);
					break;
				case KTransformMgr.SCALE_REF:
					scale = scale.mergeTransform(key.scale);
					break;
			}
			dirtyKey();
			return getTransformOperation();
		}
		
		/**
		 * Returns a replace transform operation with the clones as 
		 * the old keys and the current transforms as the new keys.
		 */
		public function getTransformOperation():IModelOperation
		{
			return new KReplaceTransformOperation(this,
				_translateTransform.oldTransform, translate,
				_rotateTransform.oldTransform, rotate,
				_scaleTransform.oldTransform, scale);
		}
		
		public function hasTransform():Boolean
		{
			if(!_previous)
				return false;
			
			var currentMatrix:Matrix = getFullMatrix(_endTime, new Matrix());
			var previousMatrix:Matrix = (_previous as KSpatialKeyFrame).getFullMatrix(_previous.endTime, new Matrix());
			
			if( currentMatrix.a - previousMatrix.a != 0 ||
				currentMatrix.b - previousMatrix.b != 0 ||
				currentMatrix.c - previousMatrix.c != 0 ||
				currentMatrix.d - previousMatrix.d != 0 ||
				currentMatrix.tx - previousMatrix.tx != 0 ||
				currentMatrix.ty - previousMatrix.ty != 0)
				return true;
			
			return false;
		}
		
		public function interpolateTranslate(dx:Number, dy:Number, operation:KCompositeOperation):void
		{
			//Create a new key frame and clone the transforms
			var oldTranslate:KTranslation = _translateTransform.clone();
			var oldRotate:KRotation = _rotateTransform.clone();
			var oldScale:KScale = _scaleTransform.clone();
			
			if(_translateTransform.transitionPath.length<2)
				_translateTransform.setLine(_endTime-startTime());
			
			_translateTransform.addInterpolatedTransform(dx,dy);			
			
			var interpolateOp:KReplaceTransformOperation = new KReplaceTransformOperation(
				this, oldTranslate, _translateTransform.clone(),
				oldRotate, _rotateTransform.clone(),
				oldScale, _scaleTransform.clone());
			operation.addOperation(interpolateOp);
			dirtyKey();
		}
		
		public function interpolateRotate(dTheta:Number, operation:KCompositeOperation):void
		{
			//Create a new key frame and clone the transforms
			var oldTranslate:KTranslation = _translateTransform.clone();
			var oldRotate:KRotation = _rotateTransform.clone();
			var oldScale:KScale = _scaleTransform.clone();
			
			//Create a new operation for the split
			if(_rotateTransform.transitionPath.length<2)
				_rotateTransform.setLine(_endTime-startTime());
			
			_rotateTransform.addInterpolatedTransform(dTheta);
			
			var interpolateOp:KReplaceTransformOperation = new KReplaceTransformOperation(
				this, oldTranslate, _translateTransform.clone(),
				oldRotate, _rotateTransform.clone(),
				oldScale, _scaleTransform.clone());
			
			operation.addOperation(interpolateOp);
			dirtyKey();
		}
		
		public function interpolateScale(dScale:Number, operation:KCompositeOperation):void
		{
			//Create a new key frame and clone the transforms
			var oldTranslate:KTranslation = _translateTransform.clone();
			var oldRotate:KRotation = _rotateTransform.clone();
			var oldScale:KScale = _scaleTransform.clone();
			
			//Create a new operation for the split
			if(_rotateTransform.transitionPath.length<2)
				_rotateTransform.setLine(_endTime-startTime());
			
			_scaleTransform.addInterpolatedTransform(dScale);
			
			var interpolateOp:KReplaceTransformOperation = new KReplaceTransformOperation(
				this, oldTranslate, _translateTransform.clone(),
				oldRotate, _rotateTransform.clone(),
				oldScale, _scaleTransform.clone());
			operation.addOperation(interpolateOp);
			dirtyKey();
		}
		
		private function _findProportion(time:Number):Number
		{
			var startTimeOffset:Number = 0;
			var startTime:Number = startTime() + startTimeOffset;
			var time:Number = (time-startTime);
			var duration:Number = _endTime - startTime;
			var proportionKeyframe:Number;
			
			if(duration == 0)
				proportionKeyframe = 1;
			else
				proportionKeyframe = time/duration;
			
			return proportionKeyframe;
		}
	}
}