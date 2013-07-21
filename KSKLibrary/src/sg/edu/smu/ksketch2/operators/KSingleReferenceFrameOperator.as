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
	
	//Yay monster class! Good luck reading this
	
	/**
	 * The KChangeCenterOperation class serves as the concrete class for
	 * handling change center operations in K-Sketch. Specifically, the
	 * class serves as the transform interface for dealing with the
	 * single reference frame model.
	 */
	public class KSingleReferenceFrameOperator implements ITransformInterface
	{
		// ##########
		// # Fields #
		// ##########
		
		// static variables
		public static const TRANSLATE_THRESHOLD:Number = 3;				// translation threshold
		public static const ROTATE_THRESHOLD:Number = 0.3;				// rotation threshold
		public static const SCALE_THRESHOLD:Number = 0.1;				// scaling threshold
		public static const EPSILON:Number = 0.05;						// epsilon threshold
		public static var always_allow_interpolate:Boolean = false;		// always interpolate state flag
		
		// miscellaneous state variables
		protected var _object:KObject;									// active object
		protected var _refFrame:KReferenceFrame;						// active reference frame
		protected var _dirty:Boolean = true;							// dirty state flag
		protected var _lastQueryTime:int;								// previous query time 
		protected var _cachedMatrix:Matrix = new Matrix();				// cached matrix 
		
		// current transformation storage variables
		protected var _interpolationKey:KSpatialKeyFrame;				// current interpolation spatial key frame
		protected var _TStoredPath:KPath;								// stored transformation path
		protected var _RStoredPath:KPath;								// stored rotation path
		protected var _SStoredPath:KPath;								// stored scaling path
		
		// subsequent transformation storage variables
		protected var _nextInterpolationKey:KSpatialKeyFrame;			// next interpolation spatial key frame
		protected var _TStoredPath2:KPath;								// other stored transformation path
		protected var _RStoredPath2:KPath;								// other stored rotation path
		protected var _SStoredPath2:KPath;								// other stored scaling path
		
		// transition time variables
		protected var _startTime:int;									// starting time
		protected var _startMatrix:Matrix;								// starting matrix
		protected var _inTransit:Boolean								// in-transition state flag
		protected var _transitionType:int;								// transition state type
		
		// transition space variables
		protected var _transitionX:Number;								// transition's x-value
		protected var _transitionY:Number;								// transition's y-value
		protected var _transitionTheta:Number;							// transition's theta value
		protected var _transitionSigma:Number;							// transition's sigma value
		
		// magnitude variables
		protected var _magX:Number;										// magnitude's x-value
		protected var _magY:Number;										// magnitude's y-value
		protected var _magTheta:Number;									// magnitude's rotational (theta) value
		protected var _magSigma:Number;									// magnitude's scaling (sigma) value

		// cache variables
		protected var _cachedX:Number;									// cached x-vaue
		protected var _cachedY:Number;									// cached y-value
		protected var _cachedTheta:Number;								// cached rotational (theta) value
		protected var _cachedScale:Number;								// cached scaling value [note: why is it not called _cachedSigma?]
		
		// transformation state flag variables
		public var hasTranslate:Boolean;								// transition state flag
		public var hasRotate:Boolean;									// rotation state flag
		public var hasScale:Boolean;									// scaling state flag
		
		
		
		// ###############
		// # Constructor #
		// ###############
		
		/**
		 * The main constructor for the KSingleReferenceFrameOperator class.
		 * 
		 * @param object The target object.
		 */
		public function KSingleReferenceFrameOperator(object:KObject)
		{
			// case: the given object is null
			// throw an error
			if(!object)
				throw new Error("Transform interface says: Dude, no object given!");
			
			// initialize the objects
			_refFrame = new KReferenceFrame();		// initialize the active reference frame
			_object = object;						// initialize the active object
			_inTransit = false;						// initialize the in-transition flag
			
			// set the initial transition information
			_lastQueryTime = 0;						// set the initial previous query time
			_transitionX = 0;						// set the initial transition x-position
			_transitionY = 0;						// set the initial transition y-position
			_transitionTheta = 0;					// set the initial transition's theta
			_transitionSigma = 0;					// set the initial transition's theta

		}
		
		
		
		// ##########################
		// # Accessors and Mutators #
		// ##########################
		
		public function set dirty(value:Boolean):void
		{
			// set the dirty state flag to the given value
			_dirty = value;
		}
		
		public function matrix(time:int):Matrix
		{
			// case: the reference frame is in transition
			if(_inTransit)
			{
				// case: the reference frame is being demonstrated
				// return the transition matrix
				if(_transitionType == KSketch2.TRANSITION_DEMONSTRATED)
					return _transitionMatrix(time);
			}
			
			// case: the reference frame is clean and the given time matches the last queried time
			// return the cached matrix
			// sending the cached matrix is done to improve the interface's performance
			if(!_dirty && _lastQueryTime == time)
				return _cachedMatrix.clone();
			
			// the reference frame is neither in transition nor cached,
			// so calculate an extremely hardcoded matrix
			// iterate through the key frame list and add up the rotation, scale, dx, and dy values,
			// then pump these values into the matrix afterwards
			var currentKey:KSpatialKeyFrame = _refFrame.head as KSpatialKeyFrame;
			
			// case: the reference frame is null
			// return a new matrix
			if(!currentKey)
				return new Matrix();
			
			// set the initial key frame path values
			var x:Number = 0;
			var y:Number = 0;
			var theta:Number = 0;
			var sigma:Number = 1;
			var point:KTimedPoint;
			
			// iterate through each key frame
			while(currentKey)
			{
				// case: the current key frame's is before the queried time
				if(currentKey.startTime <= time)
				{
					// calculate the proportional value
					var proportionKeyFrame:Number = currentKey.findProportion(time);
					
					// locate the point in the current key frame's translated path at the proportional value
					point = currentKey.translatePath.find_Point(proportionKeyFrame);
					
					// case: the located point is not null
					// extract the located point's x- and y-positions
					if(point)
					{
						x += point.x;
						y += point.y;
					}
					
					// locate the point in the current key frame's rotated path at the proportional value
					point = currentKey.rotatePath.find_Point(proportionKeyFrame);
					
					// case: the located point is not null
					// increment the rotational value
					if(point)
						theta += point.x;
					
					// locate the point in the current key frame's scaled path at the proportional value
					point = currentKey.scalePath.find_Point(proportionKeyFrame);
					
					// case: the located point is not null
					// increment the scaling value
					if(point)
						sigma += point.x;
				}
				
				// set the current key frame as the next key frame
				currentKey = currentKey.next as KSpatialKeyFrame;
			}
			
			// create the resultant matrix from the extracted valued
			var result:Matrix = new Matrix();
			result.translate(-_object.center.x,-_object.center.y);
			result.rotate(theta);
			result.scale(sigma, sigma);
			result.translate(_object.center.x, _object.center.y);
			result.translate(x, y);
			
			// set the cached matrix's states
			_cachedMatrix = result.clone();
			_lastQueryTime = time;
			_dirty = false;
			
			// return the resultant matrix
			return result;
		}
		
		public function get firstKeyTime():int
		{
			// case: the reference frame's head (i.e., first key frame) is non-null
			// return the first key frame's time
			if(_refFrame.head)
				return _refFrame.head.time;
			// case: the reference frame's head is null
			// throw an error
			else
				throw new Error("Reference frame for "+_object.id.toString()+" doesn't have a key!");
		}
		
		public function get lastKeyTime():int
		{
			// initialize the key frame as the reference frame's last key frame
			var key:IKeyFrame = _refFrame.lastKey;
			
			// case: the last key frame is non-null
			// return the last key frame's time
			if(key)
				return _refFrame.lastKey.time;
			// case: the reference frame's tail is null
			// throw an error
			else
				throw new Error("Reference frame for "+_object.id.toString()+" doesn't have a key!");
		}
		
		public function getActiveKey(time:int):IKeyFrame
		{
			var activeKey:IKeyFrame = _refFrame.getKeyAtTime(time);
			
			if(!activeKey)
				activeKey = _refFrame.getKeyAftertime(time);
			
			return activeKey;
		}
		
		public function get transitionType():int
		{
			return _transitionType;
		}
		
		/**
		 * The matrix that is give during a performance operation
		 * Caches the values up till transition start time
		 * Will not incorporate a new transform value into the matrix
		 * unless it passes the threshold value
		 */
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
				
				if(!hasTranslate)
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
						
						hasTranslate = true;
					}
				}
				
				if(!hasRotate)
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
						
						hasRotate = true;
					}
				}
				
				if(!hasScale)
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
						
						hasScale = true;
					}
				}
				
				currentKey = currentKey.next as KSpatialKeyFrame;
			}
			
			var result:Matrix = new Matrix();
			result.translate(-_object.center.x,-_object.center.y);
			result.rotate(theta+_cachedTheta);
			result.scale(sigma+_cachedScale, sigma+_cachedScale);
			result.translate(_object.center.x, _object.center.y);
			result.translate(x+_cachedX, y+_cachedY);
			return result;	
		}
		
		

		
		
		// ##############
		// # Permitters #
		// ##############

		public function canInterpolate(time:int):Boolean
		{
			// case: always allow interpolation flag is enabled
			// return true
			if(always_allow_interpolate)
				return true;
			
			// get the first active key frame after the time before the given time
			var activeKey:ISpatialKeyFrame;
			activeKey = _refFrame.getKeyAftertime(time-1) as ISpatialKeyFrame;
			
			// case: the active key frame exists
			if(activeKey)
			{
				// case: the active key frame's time matches the key frame after the time before the given time
				if(activeKey.time == time)
					return true;
				
				// otherwese, return whether the active key frame has activity at that time
				return activeKey.hasActivityAtTime();
			}
			
			// return false when all other possible true cases have failed
			return false;
		}
		
		public function canInsertKey(time:int):Boolean
		{
			// get the key frame at the given time and check if the extacted key frame exists
			var hasKeyAtTime:Boolean = (_refFrame.getKeyAtTime(time) as KSpatialKeyFrame != null);
			
			// return whether the extracted key frame exists
			return !hasKeyAtTime;
		}
		
		public function canRemoveKey(time:int):Boolean
		{
			// get the key frame at the given time
			var key:IKeyFrame = _refFrame.getKeyAtTime(time);
			
			// initially set the remove key frame check as false
			var canRemove:Boolean = false;
			
			// case: the key frame at the given time exists
			if(key)
			{
				canRemove = true;
				
				// case: the key frame either has no next key frame or is the head key frame
				// set the remove key frame check as false false
				if(!key.next)
					canRemove = false;
				if(key == _refFrame.head)
					canRemove = false;
			}
			
			// return the remove key frame check
			return canRemove;
		}
		
		public function canClearKeys(time:int):Boolean
		{
			// get the key frame after the given time
			var hasKeyAfterTime:Boolean = (_refFrame.getKeyAftertime(time) as KSpatialKeyFrame != null);
			
			// return whether the key frame after the given time exists
			return hasKeyAfterTime;
		}
		
		
		
		// ###############
		// # Transitions #
		// ###############
		
		/**
		 * Preps the object for transition by checking for errors and
		 * inconsistencies, and complains if the object is not in the magical
		 * state. Note: the previous operation did not clean up the object.
		 * 
		 * @param time The target time.
		 * @param transitionType The transition type.
		 * @param The corresponding composite operation.
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
			
			hasTranslate = false;
			hasScale = false;
			hasRotate = false;
			_inTransit = true;
			
			_dirty = true;
			_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_BEGIN, _object, time));
		}
		
		/**
		 * Updates the object during the transition.
		 * 
		 * @param time The target time.
		 * @param dx The target x-position.
		 * @param dy The target y-position.
		 * @param dTheta The target rotation value.
		 * @param dScale The target scaling value.
		 */
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
				//Just dump the new values in for demonstrated transitions
				var elapsedTime:int = time - _startTime;
				_TStoredPath.push(dx, dy, elapsedTime);
				_RStoredPath.push(dTheta, 0, elapsedTime);
				_SStoredPath.push(dScale, 0, elapsedTime);
			}
			else
			{
				if(!_interpolationKey)
					throw new Error("No Keys to interpolate!");
				
				//We need to interpolate the relevant keys during every update for interpolated transitions
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
			}
			
			_dirty = true;
			_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_CHANGED, _object, time)); 
			_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_UPDATING, _object, time)); 
		}
		
		/**
		 * Finalizes the object's transition.
		 * 
		 * @param time The target time.
		 * @param op The corresponding composite operation.
		 */
		public function endTransition(time:int, op:KCompositeOperation):void
		{
			_dirty = true;
			_endTransition_process_ModeDI(time, op);
			_inTransit = false;
			_dirty = true;
			
			// dispatch a transform finalised event
			// application level components can listen to this event to do updates
			_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_ENDED, _object, time)); 
			_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_FINALISED, _object, time));
		}
		
		private function _beginTransition_process_interpolation(time:int, op:KCompositeOperation):void
		{
			if(_transitionType == KSketch2.TRANSITION_INTERPOLATED)
			{
				//For interpolation, there will always be a key inserted at given time
				//So we just insert a key at time, if there is a need to insert key
				if(canInsertKey(time))
					insertBlankKeyFrame(time, op);
				
				//Then we grab that key
				_interpolationKey = _refFrame.getKeyAtTime(time) as KSpatialKeyFrame;
				
				//Then we deal with the interpolation
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
			
			//Make sure there is only one point at one frame
			KPathProcessing.normalisePathDensity(_TStoredPath);
			KPathProcessing.normalisePathDensity(_RStoredPath);
			KPathProcessing.normalisePathDensity(_SStoredPath);
			
			
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
				}
			}	
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
			
			var sourceHeader:KSpatialKeyFrame = new KSpatialKeyFrame(startTime, _object.center);
			var sourceKey:KSpatialKeyFrame = new KSpatialKeyFrame(endTime, _object.center);
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
					currentKey = _refFrame.split(currentKey,sourceKey.time, op) as KSpatialKeyFrame;
				
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
					key = _refFrame.split(key,time, op) as KSpatialKeyFrame;
				else
				{
					//Else we will need to insert a key at time
					key = new KSpatialKeyFrame(time, _object.center);
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
		
		
		
		// ############
		// # Modifers #
		// ############
		
		public function moveCenter(dx:Number, dy:Number, time:int):void
		{
			// set the new center of the object
			_object.center = _object.center.add(new Point(dx, dy));
			
			// enable the object's dirty state flag due to the object's changed center
			_dirty = true;
			
			// change the object's transform operation
			_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_CHANGED, _object, time)); 
			
			// update the object's transform operation
			_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_UPDATING, _object, time)); 
		}
		
		public function insertBlankKeyFrame(time:int, op:KCompositeOperation):void
		{
			var key:KSpatialKeyFrame = _refFrame.getKeyAftertime(time) as KSpatialKeyFrame;
			
			// case: there exists a key frame after the given time
			// need to split the key frame
			if(key)
			{
				key = _refFrame.split(key,time, op) as KSpatialKeyFrame;
			}
			// case: there doesn't exist a key frame after the given time
			else
			{
				// need to insert a key frame at the given time
				key = new KSpatialKeyFrame(time, _object.center);
				_refFrame.insertKey(key);
				
				// case: the corresponding composite operation exists
				// update the composite operation
				if(op)
					op.addOperation(new KInsertKeyOperation(key.previous, key.next, key));		
			}
			
			// enable the dirty state flag due to the object's blank key frame insertion
			_dirty = true;
			
			// end the object's transform operation
			_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_ENDED, _object, time)); 
		}
		
		public function removeKeyFrame(time:int, op:KCompositeOperation):void
		{
			// get the key frame after the given time
			var key:KSpatialKeyFrame = _refFrame.getKeyAtTime(time) as KSpatialKeyFrame;
			
			// case: there exists a key frame after the given time
			// split the key frame
			// note: this method should never be called if the conditions are not correct
			if(key)
			{
				var nextKey:KSpatialKeyFrame = key.next as KSpatialKeyFrame;
				
				var oldPath:KPath = nextKey.translatePath.clone();
				nextKey.translatePath = KPathProcessing.joinPaths(key.translatePath, nextKey.translatePath,key.duration, nextKey.duration);
				op.addOperation(new KReplacePathOperation(nextKey, nextKey.translatePath, oldPath, KSketch2.TRANSFORM_TRANSLATION));
				oldPath = nextKey.rotatePath.clone();
				nextKey.rotatePath = KPathProcessing.joinPaths(key.rotatePath, nextKey.rotatePath,key.duration, nextKey.duration);
				op.addOperation(new KReplacePathOperation(nextKey, nextKey.rotatePath, oldPath, KSketch2.TRANSFORM_ROTATION));
				
				oldPath = nextKey.scalePath.clone();
				nextKey.scalePath = KPathProcessing.joinPaths(key.scalePath, nextKey.scalePath,key.duration, nextKey.duration);
				op.addOperation(new KReplacePathOperation(nextKey, nextKey.scalePath, oldPath, KSketch2.TRANSFORM_SCALE));
				
				var removeKeyOp:KRemoveKeyOperation = new KRemoveKeyOperation(key.previous, key.next, key);
				_refFrame.removeKeyFrame(key);
				op.addOperation(removeKeyOp);
			}
			// case: there doesn't exist a key frame after the given time
			// throw an error
			else
			{
				throw new Error("There is no key at time! Cannot remove key");
			}
			
			// enable the dirty state flag due to the object's blank key frame insertion
			_dirty = true;
			
			// end the object's transform operation
			_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_ENDED, _object, time)); 
		}
		
		public function clearAllMotionsAfterTime(time:int, op:KCompositeOperation):void
		{
			// case: there exists an active key frame at the given time
			if(getActiveKey(time))
			{
				// case: can insert a key frame at the given time
				// inserts a blank key frame at the given time
				if(canInsertKey(time))
					insertBlankKeyFrame(time, op);
				
				// set the current key frame as the last key frame in the reference frame
				var currentKey:KSpatialKeyFrame = _refFrame.lastKey as KSpatialKeyFrame;
				
				// iterate backwards through the reference frame while the current key frame exists
				while(currentKey)
				{
					// case: the given time is before the curret key frame's time and the current key frame is not the head key frame
					// remove the current key frame
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
				
				// enable the dirty state flag due to the object's blank key frame insertion
				_dirty = true;
				
				// end the object's transform operation
				_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_ENDED, _object, time)); 
			}
		}
		
		
		
		// #################
		// # Miscellaneous #
		// #################
		
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
			//This function is really very very very very long.
			//It only really became this long because of optimisations, trying to cut loops here and there
			//Now, it is barely good enough to run on ipads, maybe the next better programmer can do better :S
			
			var sourceInterface:KSingleReferenceFrameOperator = sourceObject.transformInterface.clone() as KSingleReferenceFrameOperator;
			var oldInterface:KSingleReferenceFrameOperator = this.clone() as KSingleReferenceFrameOperator;
			var toMergeRefFrame:KReferenceFrame = new KReferenceFrame();
			var toModifyKey:KSpatialKeyFrame;
			var currentKey:KSpatialKeyFrame = sourceInterface.getActiveKey(-1) as KSpatialKeyFrame;
			var dummyOp:KCompositeOperation = new KCompositeOperation();
			
			//Clone the source object's reference frame and modify the this operator's reference frame 
			//Such that it is the same as the source reference frame
			//The following loop makes sure that this operator's reference frame
			//Has keys at the key times of the source key list
			while(currentKey)
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
						_refFrame.split(toModifyKey,currentKey.time, dummyOp);
					else
					{
						//Else we just insert a new one at time
						toModifyKey = new KSpatialKeyFrame(currentKey.time, _object.center);
						op.addOperation(new KInsertKeyOperation(_refFrame.getKeyAtBeforeTime(currentKey.time), null, toModifyKey));
						_refFrame.insertKey(toModifyKey);
					}
				}
				
				currentKey = currentKey.next as KSpatialKeyFrame;
			}
			
			currentKey = _refFrame.head as KSpatialKeyFrame;			
			//Modify the source key list to be the same as this operator's key list
			while(currentKey)
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
			var keyStartTime:int;
			var currentTime:int;
			var oldMatrix:Matrix;
			var newMatrix:Matrix;
			var oldPosition:Point;
			var newPosition:Point;
			var difference:Point;
			
			var centroid:Point = _object.center;
			var centroidDiff:Point = sourceObject.center.subtract(_object.center);
			var alteredPath:KPath;
			var centroidPath:KPath;
			
			while(currentKey && currentKey.time <= stopMergeTime)
			{
				toModifyKey = _refFrame.getKeyAtTime(currentKey.time) as KSpatialKeyFrame;
				
				if(!toModifyKey)
				{
					toModifyKey = new KSpatialKeyFrame(currentKey.time, _object.center);
					op.addOperation(new KInsertKeyOperation(_refFrame.getKeyAtBeforeTime(currentKey.time), null, toModifyKey));
					_refFrame.insertKey(toModifyKey);
				}
				
				oldPath = toModifyKey.rotatePath.clone();
				toModifyKey.rotatePath.mergePath(currentKey.rotatePath);
				op.addOperation(new KReplacePathOperation(toModifyKey, toModifyKey.rotatePath, oldPath, KSketch2.TRANSFORM_ROTATION));
				
				oldPath = toModifyKey.scalePath.clone();
				toModifyKey.scalePath.mergePath(currentKey.scalePath);
				op.addOperation(new KReplacePathOperation(toModifyKey, toModifyKey.scalePath, oldPath, KSketch2.TRANSFORM_SCALE));
				
				oldPath = toModifyKey.translatePath.clone();
				
				keyStartTime = toModifyKey.startTime;
				currentTime = toModifyKey.startTime;
				alteredPath = new KPath();
				alteredPath.push(0,0,0);
				
				if(currentKey.duration == 0)
				{
					oldPosition = oldInterface.matrix(currentTime).transformPoint(centroid);
					oldPosition = sourceInterface.matrix(currentTime).transformPoint(oldPosition);
					newPosition = matrix(currentTime).transformPoint(centroid);
					difference = oldPosition.subtract(newPosition);
					alteredPath.push(difference.x, difference.y, currentTime-keyStartTime);
				}
				else
				{
					while(currentTime <= toModifyKey.time)
					{
						oldPosition = oldInterface.matrix(currentTime).transformPoint(centroid);
						oldPosition = sourceInterface.matrix(currentTime).transformPoint(oldPosition);
						newPosition = matrix(currentTime).transformPoint(centroid);
						difference = oldPosition.subtract(newPosition);
						alteredPath.push(difference.x, difference.y, currentTime-keyStartTime);
						currentTime += KSketch2.ANIMATION_INTERVAL;
					}
				}
				
				toModifyKey.translatePath.mergePath(alteredPath);
				
				op.addOperation(new KReplacePathOperation(toModifyKey, toModifyKey.translatePath, oldPath, KSketch2.TRANSFORM_TRANSLATION));
				
				if(currentKey.time == stopMergeTime)
					break;
				
				currentKey = currentKey.next as KSpatialKeyFrame;
				
				if(currentKey)
				{
					if(stopMergeTime < currentKey.time)
						currentKey = currentKey.splitKey(stopMergeTime,op) as KSpatialKeyFrame;
				}
			}
			
			dirty = true;//This guy is important if it isn't dirtied, the view wont update.
			_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_CHANGED, _object, stopMergeTime));
			_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_FINALISED, _object, stopMergeTime));
		}
		
		public function clone():ITransformInterface
		{
			var newTransformInterface:KSingleReferenceFrameOperator = new KSingleReferenceFrameOperator(_object);
			var clonedKeys:KReferenceFrame = _refFrame.clone() as KReferenceFrame;
			
			newTransformInterface._refFrame = clonedKeys;
			
			return newTransformInterface;
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
		
		public function debug():void
		{
			_refFrame.debug();
		}
	}
}