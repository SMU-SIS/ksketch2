/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.operators
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.events.KObjectEvent;
	import sg.edu.smu.ksketch2.model.data_structures.IKeyFrame;
	import sg.edu.smu.ksketch2.model.data_structures.ISpatialKeyFrame;
	import sg.edu.smu.ksketch2.model.data_structures.KPath;
	import sg.edu.smu.ksketch2.model.data_structures.KReferenceFrame;
	import sg.edu.smu.ksketch2.model.data_structures.KSpatialKeyFrame;
	import sg.edu.smu.ksketch2.model.data_structures.KTimedPoint;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;
	import sg.edu.smu.ksketch2.operators.operations.KInsertKeyOperation;
	import sg.edu.smu.ksketch2.operators.operations.KRemoveKeyOperation;
	import sg.edu.smu.ksketch2.operators.operations.KReplacePathOperation;
	import sg.edu.smu.ksketch2.utils.KPathProcessing;
	
	public class KSingleReferenceFrameOperator implements ITransformInterface
	{
		public static const TRANSLATE_THRESHOLD:Number = 3;
		public static const ROTATE_THRESHOLD:Number = 0.3;
		public static const SCALE_THRESHOLD:Number = 0.1;
		public static const EPSILON:Number = 0.05;
		
		protected var _object:KObject;
		protected var _refFrame:KReferenceFrame;
		protected var _dirty:Boolean = true;
		protected var _lastQueryTime:int;
		protected var _cachedMatrix:Matrix = new Matrix();
		
		protected var _interpolationKey:KSpatialKeyFrame;
		protected var _TStoredPath:KPath;
		protected var _RStoredPath:KPath;
		protected var _SStoredPath:KPath;
		
		protected var _nextInterpolationKey:KSpatialKeyFrame;
		protected var _TStoredPath2:KPath;
		protected var _RStoredPath2:KPath;
		protected var _SStoredPath2:KPath;
		
		protected var _startTime:int;
		protected var _startMatrix:Matrix;
		protected var _inTransit:Boolean
		protected var _transitionType:int;
		
		protected var _transitionX:Number;
		protected var _transitionY:Number;
		protected var _transitionTheta:Number;
		protected var _transitionSigma:Number;
		
		protected var _magX:Number;
		protected var _magY:Number;
		protected var _magTheta:Number;
		protected var _magSigma:Number;

		protected var _cachedX:Number;
		protected var _cachedY:Number;
		protected var _cachedTheta:Number;
		protected var _cachedScale:Number;
		
		protected var _cutTranslateTime:int;
		protected var _cutTranslate:Boolean;
				
		protected var _cutRotate:Boolean;
		protected var _cutRotateTime:int;
		
		protected var _cutScale:Boolean;
		protected var _cutScaleTime:int;
		
		/**
		 * KSingleReferenceFrame is the transform interface dealing with the single reference frame model
		 */
		public function KSingleReferenceFrameOperator(object:KObject)
		{
			if(!object)
				throw new Error("Transform interface says: Dude, no object given!");
			_refFrame = new KReferenceFrame();
			_object = object;
			_inTransit = false;
			
			//Oh yeah, since we are doing static grouping, lets create the keys at zero to make our lives easier!
//			var headerKey:KSpatialKeyFrame = new KSpatialKeyFrame(0, object.centroid);
//			_refFrame.insertKey(headerKey);
			
			_lastQueryTime = 0;
			_transitionX = 0;
			_transitionY = 0;
			_transitionTheta = 0;
			_transitionSigma = 0;

		}
		
		public function set dirty(value:Boolean):void
		{
			_dirty = value;
		}
		
		public function get transitionType():int
		{
			return _transitionType;
		}
		
		/**
		 * Returns the time value of the first key in the reference frame this transform operator handles
		 */
		public function get firstKeyTime():int
		{
			if(_refFrame.head)
				return _refFrame.head.time;
			else
				throw new Error("Reference frame for "+_object.id.toString()+" doesn't have a key!");
		}
		
		/**
		 * Returns the time value of the last key in the reference frame this transform operator handles
		 */
		public function get lastKeyTime():int
		{
			var key:IKeyFrame = _refFrame.lastKey;
			
			if(key)
				return _refFrame.lastKey.time;
			else
				throw new Error("Reference frame for "+_object.id.toString()+" doesn't have a key!");
		}
		
		/**
		 * Returns the key in effect at given time
		 */
		public function getActiveKey(time:int):IKeyFrame
		{
			var activeKey:IKeyFrame = _refFrame.getKeyAtTime(time);
			
			if(!activeKey)
				activeKey = _refFrame.getKeyAftertime(time);
			
			return activeKey;
		}
		
	
		/**
		 * Returns the transform matrix of the reference frame that this interface provides access to
		 */
		public function matrix(time:int):Matrix
		{
			if(_inTransit)
			{
				if(_transitionType == KSketch2.TRANSITION_DEMONSTRATED)
					return _transitionMatrix(time);
			}
			

			if(!_dirty && _lastQueryTime == time)
				return _cachedMatrix.clone();
			
			//Extremely hardcoded matrix
			//Iterate through the key list and add up the rotation, scale, dx dy values
			//Pump these values into the matrix after wards
			var currentKey:KSpatialKeyFrame = _refFrame.head as KSpatialKeyFrame;
			
			if(!currentKey)
				return new Matrix();
			
			var x:Number = 0;
			var y:Number = 0;
			var theta:Number = 0;
			var sigma:Number = 1;
			var point:KTimedPoint;
			
			while(currentKey)
			{
				if(currentKey.startTime <= time)
				{
					var proportionKeyFrame:Number = currentKey.findProportion(time);
					point = currentKey.translatePath.find_Point(proportionKeyFrame);
					if(point)
					{
						x += point.x;
						y += point.y;
					}
					
					point = currentKey.rotatePath.find_Point(proportionKeyFrame);
					if(point)
						theta += point.x;
					
					point = currentKey.scalePath.find_Point(proportionKeyFrame);
					if(point)
						sigma += point.x;
				}
				
				currentKey = currentKey.next as KSpatialKeyFrame;
			}
			
			var result:Matrix = new Matrix();
			result.translate(-_object.centroid.x,-_object.centroid.y);
			result.rotate(theta);
			result.scale(sigma, sigma);
			result.translate(_object.centroid.x, _object.centroid.y);
			result.translate(x, y);
			
			_cachedMatrix = result.clone();
			_lastQueryTime = time;
			_dirty = false;
			
			return result;
		}
		
		private function _transitionMatrix(time:int):Matrix
		{
			var x:Number = _transitionX;
			var y:Number = _transitionY;
			var theta:Number = _transitionTheta;
			var sigma:Number = 1 + _transitionSigma;
			var point:KTimedPoint;
			var proportionKeyFrame:Number;
			var computeTime:int;
			
			var currentKey:KSpatialKeyFrame = _refFrame.getKeyAftertime(_startTime) as KSpatialKeyFrame;
			
			while(currentKey)
			{
				
				
				proportionKeyFrame = currentKey.findProportion(time);
				
				if(!_cutTranslate)
				{
					point = currentKey.translatePath.find_Point(proportionKeyFrame);
					if(Math.abs(_transitionX) <= EPSILON || Math.abs(_transitionY) <= EPSILON)
					{
						if(point)
						{
							x += point.x;
							y += point.y;
						}
					}
					else
					{
						if(point)
						{
							_cachedX += point.x;
							_cachedY += point.y;
						}

						_cutTranslate = true;
					}
				}
				
				if(!_cutRotate)
				{
					point = currentKey.rotatePath.find_Point(proportionKeyFrame);
					if(_magTheta <= EPSILON)
					{
						if(point)
							theta += point.x;
					}
					else
					{
						if(point)
							_cachedTheta += point.x;
						
						_cutRotate = true;
					}
				}
				
				if(!_cutScale)
				{
					point = currentKey.scalePath.find_Point(proportionKeyFrame);
					if(_magSigma <= EPSILON)
					{
						if(point)
							sigma += point.x;
					}
					else
					{
						if(point)
							_cachedScale += point.x;
						
						_cutScale = true;
					}
				}
				
				currentKey = currentKey.next as KSpatialKeyFrame;
			}
			
			var result:Matrix = new Matrix();
			result.translate(-_object.centroid.x,-_object.centroid.y);
			result.rotate(theta+_cachedTheta);
			result.scale(sigma+_cachedScale, sigma+_cachedScale);
			result.translate(_object.centroid.x, _object.centroid.y);
			result.translate(x+_cachedX, y+_cachedY);
			return result;	
		}
		
		/**
		 * Identifies if the object has active transforms at given time
		 * Returns true if there is a transform
		 */
		public function canInterpolate(time:int):Boolean
		{
			var activeKey:ISpatialKeyFrame;
			
			switch(KSketch2.studyMode)
			{
				case KSketch2.STUDY_P:
					//We just need the object to exist
					if(_refFrame.head)
					{
						if(_refFrame.head.time <= time)
							return true;
					}
					break;
				case KSketch2.STUDY_K:
				case KSketch2.STUDY_PK:

					//Allow interpolation only if there is a key present of if there are transitions
					activeKey = _refFrame.getKeyAftertime(time-1) as ISpatialKeyFrame;
					if(activeKey)
					{
						if(activeKey.time == time)
							return true;
						
						return activeKey.hasActivityAtTime();
					}
			}
			return false;
		}
		
		/**
		 * Returns a boolean denoting whether it is possible to insert a key
		 * into this operator's key list
		 */
		public function canInsertKey(time:int):Boolean
		{
			var hasKeyAtTime:Boolean = (_refFrame.getKeyAtTime(time) as KSpatialKeyFrame != null);
		
			if(hasKeyAtTime)
				return false;
			
			if(KSketch2.studyMode == KSketch2.STUDY_P)
			{
				var activeKey:ISpatialKeyFrame = _refFrame.getKeyAftertime(time) as ISpatialKeyFrame;
				
				if(activeKey)
					return activeKey.hasActivityAtTime();
				else
					return false;
			}
			
			return true;
		}
		
		/**
		 * Preps the object for transition
		 * Checks for errors and inconsistencies and complains if the object is not in a magical state
		 * --- THe previous operation did not clean up the object
		 */
		public function beginTransition(time:int, transitionType:int, op:KCompositeOperation):void
		{
			_transitionType = transitionType;
			_startTime = time;

			//Initiate transition values and variables first
			_transitionX = 0;
			_transitionY = 0;
			_transitionTheta = 0;
			_transitionSigma = 0;
			
			_magX = 0;
			_magY = 0;
			_magTheta = 0;
			_magSigma = 0;
			
			if(_transitionType == KSketch2.TRANSITION_DEMONSTRATED)
			{
				_TStoredPath = new KPath();
				_TStoredPath.push(0,0,0);
				_RStoredPath = new KPath();
				_RStoredPath.push(0,0,0);
				_SStoredPath = new KPath();
				_SStoredPath.push(0,0,0);
			}
			else
			{
				_beginTransition_process_interpolation(time, op);
			}
			
			//Because all transform values before start time will remain the same
			//Cache them to avoid unnecessary computations
			//Future matrix will only need to compute the active key's transforms
			_cachedX = 0;
			_cachedY = 0;
			_cachedTheta = 0;
			_cachedScale = 0;
			
			var currentProportion:Number = 1;
			var point:KTimedPoint;
			var currentKey:KSpatialKeyFrame = _refFrame.head as KSpatialKeyFrame;
			
			while(currentKey)
			{
				if( _startTime < currentKey.time)
					break;
				
				point = currentKey.translatePath.find_Point(1);
				if(point)
				{
					_cachedX += point.x;
					_cachedY += point.y;
				}

				point = currentKey.rotatePath.find_Point(1);
				if(point)
					_cachedTheta += point.x;
				
				point = currentKey.scalePath.find_Point(1);
				if(point)
					_cachedScale += point.x;
				
				currentKey = currentKey.next as KSpatialKeyFrame;
			}
			
			_cutTranslate = false;
			_cutScale = false;
			_cutRotate = false;
			_inTransit = true;
			
			_dirty = true;
			_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_BEGIN, _object, time));

		}
		
		public function updateTransition(time:int, dx:Number, dy:Number, dTheta:Number, dScale:Number):void
		{
			var changeX:Number = dx - _transitionX;
			var changeY:Number = dy - _transitionY;
			var changeTheta:Number = dTheta - _transitionTheta;
			var changeScale:Number = dScale - _transitionSigma;
			
			_magX += Math.abs(dx - _transitionX);
			_magY += Math.abs(dy - _transitionY);
			_magTheta += Math.abs(dTheta - _transitionTheta);
			_magSigma += Math.abs(dScale - _transitionSigma);
			
			_transitionX = dx;
			_transitionY = dy;
			_transitionTheta = dTheta;
			_transitionSigma = dScale;
			
			if(_transitionType == KSketch2.TRANSITION_DEMONSTRATED)
			{
				var elapsedTime:int = time - _startTime;
				_TStoredPath.push(dx, dy, elapsedTime);
				_RStoredPath.push(dTheta, 0, elapsedTime);
				_SStoredPath.push(dScale, 0, elapsedTime);			
			}
			else
			{
				if(!_interpolationKey)
					throw new Error("No Keys to interpolate!");
				
				//Then we just dump the transition values into the key
				if((Math.abs(_transitionX) > EPSILON) || (Math.abs(_transitionY) > EPSILON))
					_interpolate(changeX, changeY, _interpolationKey, KSketch2.TRANSFORM_TRANSLATION, time);
				if(Math.abs(_transitionTheta) > EPSILON)
					_interpolate(changeTheta, 0, _interpolationKey, KSketch2.TRANSFORM_ROTATION, time);
				if(Math.abs(_transitionSigma) > EPSILON)
					_interpolate(changeScale, 0, _interpolationKey, KSketch2.TRANSFORM_SCALE, time);
				
				if(_nextInterpolationKey)
				{
					if((Math.abs(_transitionX) > EPSILON) || (Math.abs(_transitionY) > EPSILON))
						_interpolate(-changeX,-changeY, _nextInterpolationKey, KSketch2.TRANSFORM_TRANSLATION, _nextInterpolationKey.time);
					if(Math.abs(_transitionTheta) > EPSILON)
						_interpolate(-changeTheta, 0, _nextInterpolationKey, KSketch2.TRANSFORM_ROTATION, _nextInterpolationKey.time);
					if(Math.abs(_transitionSigma) > EPSILON)
						_interpolate(-changeScale, 0, _nextInterpolationKey, KSketch2.TRANSFORM_SCALE, _nextInterpolationKey.time);	
				}					
				
				_dirty = true;
				_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_CHANGED, _object, time)); 
				_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_UPDATING, _object, time)); 
			}
		}
		
		public function endTransition(time:int, op:KCompositeOperation):void
		{
			_dirty = true;
			
			switch(KSketch2.studyMode)
			{
				case KSketch2.STUDY_P:
					_endTransition_process_ModeD(time, op);
					break;
				case KSketch2.STUDY_K:
				case KSketch2.STUDY_PK:
					_endTransition_process_ModeDI(time, op);
					break;
			}

			_inTransit = false;
			_dirty = true;
			//Dispatch a transform finalised event
			//Application level components can listen to this event to do updates
			_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_ENDED, _object, time)); 
			_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_FINALISED, _object, time));
		}

		private function _beginTransition_process_interpolation(time:int, op:KCompositeOperation):void
		{
			if(_transitionType == KSketch2.TRANSITION_INTERPOLATED)
			{
				//After inserting a key, will be pretty sure there is a key at time.
				//Just get the key at time
				_interpolationKey = _refFrame.getKeyAftertime(time-1) as KSpatialKeyFrame;
				
				//Only 1 case, where time is greater than the reference frame's end time
				//Use the last key if this happens
				if(!_interpolationKey)
				{
					//Handle study mode case for D
					if(KSketch2.studyMode == KSketch2.STUDY_P)
					{
						_interpolationKey = _refFrame.lastKey as KSpatialKeyFrame;
					}
					else
					{
						insertBlankKeyFrame(time, op);
						_interpolationKey = _refFrame.getKeyAtTime(time) as KSpatialKeyFrame;
					}
				}
				
				//Handle study mode case for D
				if(KSketch2.studyMode == KSketch2.STUDY_P)
					_interpolationKey = lastKeyWithTransform(_interpolationKey);
				else
				{
					if(_interpolationKey.time == time)
					{
						_nextInterpolationKey = _interpolationKey.next as KSpatialKeyFrame;
						
						if(_nextInterpolationKey)
						{
							_TStoredPath2 = _nextInterpolationKey.translatePath.clone();
							_RStoredPath2 = _nextInterpolationKey.rotatePath.clone();
							_SStoredPath2 = _nextInterpolationKey.scalePath.clone();
						}
					}
					else
						_nextInterpolationKey = null;
				}
				
				_TStoredPath = _interpolationKey.translatePath.clone();
				_RStoredPath = _interpolationKey.rotatePath.clone();
				_SStoredPath = _interpolationKey.scalePath.clone();
			}
		}
		
		private function _endTransition_process_interpolation(time:int, op:KCompositeOperation):void
		{
			if(_transitionType == KSketch2.TRANSITION_INTERPOLATED)
			{
				op.addOperation(new KReplacePathOperation(_interpolationKey, _interpolationKey.translatePath, _TStoredPath, KSketch2.TRANSFORM_TRANSLATION));
				op.addOperation(new KReplacePathOperation(_interpolationKey, _interpolationKey.rotatePath, _RStoredPath, KSketch2.TRANSFORM_ROTATION));
				op.addOperation(new KReplacePathOperation(_interpolationKey, _interpolationKey.scalePath, _SStoredPath, KSketch2.TRANSFORM_SCALE));
				
				if(_nextInterpolationKey)
				{
					op.addOperation(new KReplacePathOperation(_nextInterpolationKey, _nextInterpolationKey.translatePath, _TStoredPath2, KSketch2.TRANSFORM_TRANSLATION));
					op.addOperation(new KReplacePathOperation(_nextInterpolationKey, _nextInterpolationKey.rotatePath, _RStoredPath2, KSketch2.TRANSFORM_ROTATION));
					op.addOperation(new KReplacePathOperation(_nextInterpolationKey, _nextInterpolationKey.scalePath, _SStoredPath2, KSketch2.TRANSFORM_SCALE));
				}
			}
		}
		
		private function _endTransition_process_ModeD(time:int, op:KCompositeOperation):void
		{
			if(_transitionType == KSketch2.TRANSITION_DEMONSTRATED)
				_demonstrate(time, op);	
			else
				_endTransition_process_interpolation(time, op);
		}
		
		private function _endTransition_process_ModeDI(time:int, op:KCompositeOperation):void
		{
			if(_transitionType == KSketch2.TRANSITION_DEMONSTRATED)
				_demonstrate(time, op);	
			else
				_endTransition_process_interpolation(time, op);
		}
		
		private function _demonstrate(time:int, op:KCompositeOperation):void
		{
			//Process the paths here first
			//Do w/e you want to the paths here!
			if(KSketch2.discardTransitionTimings)
			{
				KPathProcessing.discardPathTimings(_TStoredPath);
				KPathProcessing.discardPathTimings(_RStoredPath);
				KPathProcessing.discardPathTimings(_SStoredPath);
			}

			//Path validity will be tested in _normaliseForOverwriting
			//If path is valid, the object's future for that transform type will be discarded
			_normaliseForOverwriting(_startTime, op);
			
			//Then I need to put the usable paths into the object
			if((TRANSLATE_THRESHOLD < _magX) || (TRANSLATE_THRESHOLD < _magY))
				_replacePathOverTime(_TStoredPath, _startTime, time, KSketch2.TRANSFORM_TRANSLATION, op); //Optimise replace algo
			
			if(ROTATE_THRESHOLD < _magTheta)
				_replacePathOverTime(_RStoredPath, _startTime, time, KSketch2.TRANSFORM_ROTATION, op);
			
			if(SCALE_THRESHOLD < _magSigma)
				_replacePathOverTime(_SStoredPath, _startTime, time, KSketch2.TRANSFORM_SCALE, op);
			
			_clearEmptyKeys(op);
		}
		
		public function lastKeyWithTransform(targetKey:KSpatialKeyFrame):KSpatialKeyFrame
		{
			var targetPath:KPath;
			
			//Loop through everything before time to find the correct key with a transform
			while(targetKey)
			{				
				if(targetKey.hasActivityAtTime())
					return targetKey;
				
				targetKey = targetKey.previous as KSpatialKeyFrame;
			}
			
			//Return the reference frame's header if there's nothing.
			return _refFrame.head as KSpatialKeyFrame;
		}
		
		/**
		 * Adds a dx, dy interpolation to targetKey
		 * target key should be a key at or before time;
		 */
		private function _interpolate(dx:Number, dy:Number, targetKey:KSpatialKeyFrame, 
										 transformType:int, time:int):void
		{
			if(!targetKey)
				throw new Error("No Key to interpolate!");
			
			if((time > targetKey.time) && (KSketch2.studyMode != KSketch2.STUDY_P))
				throw new Error("Unable to interpolate a key if the interpolation time is greater than targetKey's time");
			
			var targetPath:KPath;
			
			switch(transformType)
			{
				case KSketch2.TRANSFORM_TRANSLATION:
					targetPath = targetKey.translatePath;
					break;
				case KSketch2.TRANSFORM_ROTATION:
					targetPath = targetKey.rotatePath;
					break;
				case KSketch2.TRANSFORM_SCALE:
					targetPath = targetKey.scalePath;
					break;
				default:
					throw new Error("Unable to replace path because an unknown transform type is given");
			}
			
			var proportionElapsed:Number;
			
			if(targetKey.duration == 0)
				proportionElapsed = 1;
			else
			{
				proportionElapsed = (time-targetKey.startTime)/targetKey.duration;
				
				if(proportionElapsed > 1)
					proportionElapsed = 1;
			}
			
			var unInterpolate:Boolean = false;
			//var oldPath:KPath = targetPath.clone();
			
			//Case 1
			//Key frames without transition paths of required type
			if(targetPath.length < 2)
			{
				if(targetPath.length != 0)
					throw new Error("Someone created a path with 1 point somehow! Better check out the path functions");
				
				//Provide the empty path with the positive interpolation first
				targetPath.push(0,0,0);
				targetPath.push(dx,dy,targetKey.duration * proportionElapsed);
				
				//If the interpolation is performed in the middle of a key, "uninterpolate" it to 0 interpolation
				if(time != targetKey.time)
				{
					if(KSketch2.studyMode != KSketch2.STUDY_P)
					{
						targetPath.push(0,0,targetKey.duration);
					}
					else
						targetPath.push(dx, dy, targetKey.duration);
				}
				
				//Should fill the paths with points here
				KPathProcessing.normalisePathDensity(targetPath);
			}
			else
			{
				if(targetKey.time == time) //Case 2:interpolate at key time
					KPathProcessing.interpolateSpan(targetPath, 0,proportionElapsed,dx, dy);
				else
				{
					//case 3:interpolate between two keys
					KPathProcessing.interpolateSpan(targetPath,0,proportionElapsed,dx, dy);
					
					if(KSketch2.studyMode != KSketch2.STUDY_P)
						KPathProcessing.interpolateSpan(targetPath,proportionElapsed,1, -dx, -dy);
				}
			}	
		}
		
		/**
		 * Inserts a key ONLY WHEN THERE IS A KEY after time and that key HAS TRANSITIONS in it!
		 */
		public function insertBlankKeyFrame(time:int, op:KCompositeOperation):void
		{
			var key:KSpatialKeyFrame = _refFrame.getKeyAftertime(time) as KSpatialKeyFrame;
			
			//if there's a key after time, we need to split it
			if(key)
				key = key.splitKey(time, op) as KSpatialKeyFrame;
			else
			{
				//Else we will need to insert a key at time
				key = new KSpatialKeyFrame(time, _object.centroid);
				_refFrame.insertKey(key);
				if(op)
					op.addOperation(new KInsertKeyOperation(key.previous, key.next, key));		
			}
			_dirty = true;
			_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_ENDED, _object, time)); 
		}
		
		public function clearAllMotionsAfterTime(time:int, op:KCompositeOperation):void
		{
			if(getActiveKey(time))
			{
				if(canInsertKey(time))
					insertBlankKeyFrame(time, op);
				
				var currentKey:KSpatialKeyFrame = _refFrame.lastKey as KSpatialKeyFrame;
				
				while(currentKey)
				{
					if(time < currentKey.time && (currentKey != _refFrame.head))
					{
						var removeKeyOp:KRemoveKeyOperation = new KRemoveKeyOperation(currentKey.previous, currentKey.next, currentKey);
						var nextCurrentKey:KSpatialKeyFrame = currentKey.previous as KSpatialKeyFrame;
						_refFrame.removeKeyFrom(currentKey);
						currentKey = nextCurrentKey;
						op.addOperation(removeKeyOp);
					}
					else
						currentKey = currentKey.previous as KSpatialKeyFrame;
				}
				_dirty = true;
				_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_ENDED, _object, time)); 
			}
		}
		
		/**
		 * Return a list of headers for key frame linked lists
		 */
		public function getAllKeyFrames():Vector.<IKeyFrame>
		{
			var allKeys:Vector.<IKeyFrame> = new Vector.<IKeyFrame>();
			allKeys.push(_refFrame.head);
			return allKeys;
		}
		
		/**
		 * Merges the transform from the source object into this operator's key list's keys
		 */
		public function mergeTransform(sourceObject:KObject, stopMergeTime:int, op:KCompositeOperation):void
		{
			var sourceInterface:KSingleReferenceFrameOperator = sourceObject.transformInterface.clone() as KSingleReferenceFrameOperator;
			var oldInterface:KSingleReferenceFrameOperator = this.clone() as KSingleReferenceFrameOperator;
			var toMergeRefFrame:KReferenceFrame = new KReferenceFrame();
			var toModifyKey:KSpatialKeyFrame;
			var currentKey:KSpatialKeyFrame = sourceInterface.getActiveKey(-1) as KSpatialKeyFrame;

			//Clone the source object's reference frame and modify the this operator's reference frame 
			//Such that it is the same as the source reference frame
			//The following loop makes sure that this operator's reference frame
			//Has keys at the key times of the source key list
			while(currentKey && currentKey.time <= stopMergeTime)
			{
				//To Merge Ref Frame is a new reference frame
				//This insert key op is basically adding a cloned key from the source into it
				toMergeRefFrame.insertKey(currentKey.clone());
				
				//To Modify key is a key from this operator's reference frame at the cloned key's time
				toModifyKey = _refFrame.getKeyAtTime(currentKey.time) as KSpatialKeyFrame;
				
				//If there is a key then we can move on to the next key
				if(!toModifyKey)
				{
					//Else we need to split the next key at this time to make sure a key exists at this time
					toModifyKey = _refFrame.getKeyAftertime(currentKey.time) as KSpatialKeyFrame;
					
					if(toModifyKey)
						toModifyKey.splitKey(currentKey.time, dummyOp);
					else
					{
						//Else we just insert a new one at time
						toModifyKey = new KSpatialKeyFrame(currentKey.time, _object.centroid);
						op.addOperation(new KInsertKeyOperation(_refFrame.getKeyAtBeforeTime(currentKey.time), null, toModifyKey));
						_refFrame.insertKey(toModifyKey);
					}
				}
				
				currentKey = currentKey.next as KSpatialKeyFrame;
			}
			
			//Deal with the keys that may be missed if the source key list has a time after
			//This operator's last time
			toModifyKey = _refFrame.getKeyAtTime(stopMergeTime) as KSpatialKeyFrame;
			if(!toModifyKey)
			{
				toModifyKey = _refFrame.getKeyAftertime(stopMergeTime) as KSpatialKeyFrame;
				
				if(toModifyKey)
					toModifyKey.splitKey(currentKey.time, dummyOp);
				else
				{
					toModifyKey = new KSpatialKeyFrame(stopMergeTime, _object.centroid);
					op.addOperation(new KInsertKeyOperation(_refFrame.getKeyAtBeforeTime(stopMergeTime), null, toModifyKey));
					_refFrame.insertKey(toModifyKey);
				}
			}
			
			currentKey = _refFrame.head as KSpatialKeyFrame;			
			var dummyOp:KCompositeOperation = new KCompositeOperation();
			//Modify the source key list to be the same as this operator's key list
			while(currentKey && currentKey.time <= stopMergeTime)
			{
				toModifyKey = toMergeRefFrame.getKeyAtTime(currentKey.time) as KSpatialKeyFrame;
				if(!toModifyKey)
				{
					toModifyKey = toMergeRefFrame.getKeyAftertime(currentKey.time) as KSpatialKeyFrame;
					
					if(toModifyKey)
						toModifyKey.splitKey(currentKey.time, dummyOp);
				}
				
				currentKey = currentKey.next as KSpatialKeyFrame;
			}
			
			//Merge the two key lists
			currentKey = toMergeRefFrame.head as KSpatialKeyFrame;
			var oldPath:KPath;
			while(currentKey && currentKey.time <= stopMergeTime)
			{
				toModifyKey = _refFrame.getKeyAtTime(currentKey.time) as KSpatialKeyFrame;
				
				oldPath = toModifyKey.rotatePath.clone();
				toModifyKey.rotatePath.mergePath(currentKey.rotatePath);
				op.addOperation(new KReplacePathOperation(toModifyKey, toModifyKey.rotatePath, oldPath, KSketch2.TRANSFORM_ROTATION));

				oldPath = toModifyKey.scalePath.clone();
				toModifyKey.scalePath.mergePath(currentKey.scalePath);
				op.addOperation(new KReplacePathOperation(toModifyKey, toModifyKey.scalePath, oldPath, KSketch2.TRANSFORM_SCALE));

				oldPath = toModifyKey.translatePath.clone();
				toModifyKey.translatePath.mergePath(currentKey.translatePath);
				op.addOperation(new KReplacePathOperation(toModifyKey, toModifyKey.translatePath, oldPath, KSketch2.TRANSFORM_TRANSLATION));
				
				currentKey = currentKey.next as KSpatialKeyFrame;
			}
			
			//Now correct the path that resulted from the difference between different rotation and scale centers.
			currentKey = toMergeRefFrame.head as KSpatialKeyFrame;
			var matrixBefore:Matrix;
			var matrixAfter:Matrix;
			var positionBefore:Point;
			var positionAfter:Point;
			var positionDifference:Point;
			while(currentKey && currentKey.time <= stopMergeTime)
			{
				toModifyKey = _refFrame.getKeyAtTime(currentKey.time) as KSpatialKeyFrame;
				matrixBefore = oldInterface.matrix(currentKey.time);
				matrixBefore.concat(sourceInterface.matrix(currentKey.time));
				matrixAfter = matrix(currentKey.time);
				positionBefore = matrixBefore.transformPoint(_object.centroid);
				positionAfter = matrixAfter.transformPoint(_object.centroid);
				
				positionDifference = positionBefore.subtract(positionAfter);
				//_interpolateKey(positionDifference.x, positionDifference.y, currentKey, KSketch2.TRANSFORM_TRANSLATION, currentKey.time, op, true);
				currentKey = currentKey.next as KSpatialKeyFrame;
			}
			
			_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_CHANGED, _object, stopMergeTime));
			_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_FINALISED, _object, stopMergeTime));
		}
		
		/**
		 * Make source path the transition path of type for this operator's key list.
		 * Will split the source path to fit the time range
		 * Replaces all current paths of given type
		 */
		protected function _replacePathOverTime(sourcePath:KPath, startTime:int, endTime:int, transformType:int, op:KCompositeOperation):void
		{
			if(sourcePath.length == 0)
				return;
			
			var sourceHeader:KSpatialKeyFrame = new KSpatialKeyFrame(startTime, _object.centroid);
			var sourceKey:KSpatialKeyFrame = new KSpatialKeyFrame(endTime, _object.centroid);
			sourceHeader.next = sourceKey;
			sourceKey.previous = sourceHeader;
			
			switch(transformType)
			{
				case KSketch2.TRANSFORM_TRANSLATION:
					sourceKey.translatePath = sourcePath;
					break;
				case KSketch2.TRANSFORM_ROTATION:
					sourceKey.rotatePath = sourcePath;
					break;
				case KSketch2.TRANSFORM_SCALE:
					sourceKey.scalePath = sourcePath;
					break;
				default:
					throw new Error("Wrong transform type given!");
			}
			
			var toMergeKey:KSpatialKeyFrame;
			var currentKey:KSpatialKeyFrame = _refFrame.getKeyAftertime(startTime) as KSpatialKeyFrame;
			var targetPath:KPath;
			var oldPath:KPath;
			
			while(currentKey && sourceKey != toMergeKey)
			{
				if(sourceKey.time < currentKey.time)
					currentKey = currentKey.splitKey(sourceKey.time, op) as KSpatialKeyFrame;
				
				if(currentKey.time <= sourceKey.time)
				{
					if(currentKey.time < sourceKey.time)
						toMergeKey = sourceKey.splitKey(currentKey.time, new KCompositeOperation()) as KSpatialKeyFrame;
					else
						toMergeKey = sourceKey;
					
					switch(transformType)
					{
						case KSketch2.TRANSFORM_TRANSLATION:
							targetPath = toMergeKey.translatePath;
							oldPath = currentKey.translatePath;
							currentKey.translatePath = targetPath;
							break;
						case KSketch2.TRANSFORM_ROTATION:
							targetPath = toMergeKey.rotatePath;
							oldPath = currentKey.rotatePath;
							currentKey.rotatePath = targetPath;
							break;
						case KSketch2.TRANSFORM_SCALE:
							targetPath = toMergeKey.scalePath;
							oldPath = currentKey.scalePath;
							currentKey.scalePath = targetPath;
							break;
						default:
							throw new Error("Wrong transform type given!");
					}
					op.addOperation(new KReplacePathOperation(currentKey, targetPath, oldPath, transformType));
				}
				
				currentKey = currentKey.next as KSpatialKeyFrame;
			}
			
			if(sourceKey != toMergeKey)
			{
				_refFrame.insertKey(sourceKey);
				op.addOperation(new KInsertKeyOperation(sourceKey.previous, sourceKey.next, sourceKey));
			}
		}
		
		/**
		 * Makes sure the object/model is in a magical state in order for transition
		 * paths to be added to the model
		 */
		protected function _normaliseForOverwriting(time:int, op:KCompositeOperation):void
		{
			var key:KSpatialKeyFrame = _refFrame.getKeyAtTime(time) as KSpatialKeyFrame;
			//If there's a key there. Perfect! No need to do anything right now
			//Else we need a key here some how
			if(!key)
			{
				key = _refFrame.getKeyAftertime(time) as KSpatialKeyFrame;
				
				//if there's a key after time, we need to split it
				if(key)
					key = key.splitKey(time, op) as KSpatialKeyFrame;
				else
				{
					//Else we will need to insert a key at time
					key = new KSpatialKeyFrame(time, _object.centroid);
					_refFrame.insertKey(key);
					op.addOperation(new KInsertKeyOperation(key.previous, key.next, key));
				}
			}

			if(!key)
				throw new Error("Normaliser's magic is failing! Check if your object is available for demonstration!");
			
			//FUTURE OVERWRITING IS DONE HERE
			//IF YOU WANT TO CHANGE IMPLEMENTATION FOR FUTURE, DO IT HERE
			var currentKey:KSpatialKeyFrame = key;
			var oldPath:KPath;
			var newPath:KPath;
			
			var validTranslate:Boolean = (TRANSLATE_THRESHOLD < _magX) || (TRANSLATE_THRESHOLD < _magY);
			var validRotate:Boolean = ROTATE_THRESHOLD < _magTheta;
			var validScale:Boolean = SCALE_THRESHOLD < _magSigma;
			
			while(currentKey.next)
			{
				currentKey = currentKey.next as KSpatialKeyFrame;
				
				if(validTranslate)	
				{
					oldPath = currentKey.translatePath;
					currentKey.translatePath = new KPath();
					newPath = currentKey.translatePath;
					op.addOperation(new KReplacePathOperation(currentKey, newPath, oldPath, KSketch2.TRANSFORM_TRANSLATION));
				}
				
				if(validRotate)
				{
					oldPath = currentKey.rotatePath;
					currentKey.rotatePath = new KPath();
					newPath = currentKey.rotatePath;
					op.addOperation(new KReplacePathOperation(currentKey, newPath, oldPath, KSketch2.TRANSFORM_ROTATION));
				}
				
				if(validScale)
				{
					oldPath = currentKey.scalePath;
					currentKey.scalePath = new KPath();
					newPath = currentKey.scalePath;
					op.addOperation(new KReplacePathOperation(currentKey, newPath, oldPath, KSketch2.TRANSFORM_SCALE));
				}
			}
		}
		
		//Cleans up the model after a transition.
		//Splits key frames up if a key frame has a path that does not fill its time span fully.
		//Removes empty key frames
		protected function _clearEmptyKeys(op:KCompositeOperation):void
		{
			var currentKey:KSpatialKeyFrame = _refFrame.lastKey as KSpatialKeyFrame;

			while(currentKey)
			{
				if(!currentKey.isUseful() && (currentKey != _refFrame.head))
				{
					var removeKeyOp:KRemoveKeyOperation = new KRemoveKeyOperation(currentKey.previous, currentKey.next, currentKey);
					var nextCurrentKey:KSpatialKeyFrame = currentKey.previous as KSpatialKeyFrame;
					_refFrame.removeKeyFrom(currentKey);
					currentKey = nextCurrentKey;
					op.addOperation(removeKeyOp);
				}
				else
					currentKey = currentKey.previous as KSpatialKeyFrame;
			}
		}
		
		public function serializeTransform():XML
		{
			var transformXML:XML = <transform type="single"/>;
			
			var keyListXML:XML = _refFrame.serialize();
			transformXML.appendChild(keyListXML);
			
			return transformXML;
		}
		
		public function deserializeTransform(xml:XML):void
		{
			_refFrame = new KReferenceFrame();
			var keyListXML:XMLList = xml.keylist.spatialkey;
			
			for(var i:int = 0; i<keyListXML.length(); i++)
			{
				var currentKeyXML:XML = keyListXML[i];
				var newCenter:Point = new Point();
				var centerValues:Array = (currentKeyXML.@center.toString()).split(",");
				newCenter.x = Number(centerValues[0]);
				newCenter.y = Number(centerValues[1]);
				var newKey:KSpatialKeyFrame = new KSpatialKeyFrame(currentKeyXML.@time, new Point());
				newKey.deserialize(currentKeyXML);
				_refFrame.insertKey(newKey);
			}
		}
		
		public function clone():ITransformInterface
		{
			var newTransformInterface:KSingleReferenceFrameOperator = new KSingleReferenceFrameOperator(_object);
			var clonedKeys:KReferenceFrame = _refFrame.clone() as KReferenceFrame;
			
			newTransformInterface._refFrame = clonedKeys;
			
			return newTransformInterface;
		}
		
		public function debug():void
		{
			_refFrame.debug();
		}
	}
}