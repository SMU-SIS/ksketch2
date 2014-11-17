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
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
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
	import sg.edu.smu.ksketch2.operators.operations.KModifyPassthroughOperation;
	import sg.edu.smu.ksketch2.operators.operations.KRemoveKeyOperation;
	import sg.edu.smu.ksketch2.operators.operations.KReplacePathOperation;
	import sg.edu.smu.ksketch2.utils.KPathProcessing;
	import sg.edu.smu.ksketch2.utils.iterators.INumberIterator;
	
	//Yay monster class! Good luck reading this
	
	/**
	 * Serves as the transform interface for dealing with the
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
		public static const STUDYMODE_K:int = 0;						// Version K value
		public static const STUDYMODE_P:int = 1;						// Version P value
		public static const STUDYMODE_KP:int = 2;						// Version KP value
		public static const STUDYMODE_KP2:int = 3;						// Version KP2 value
		
		private static const MAX_ROTATE_STEP:Number = Math.PI - 0.1;
		
		public static var studyMode: int = STUDYMODE_KP2;				// default study mode set to 3
		public static var always_allow_interpolate:Boolean = false;		// always interpolate state flag
		
		// miscellaneous state variables
		protected var _object:KObject;									// active object
		protected var _refFrame:KReferenceFrame;						// active reference frame
		protected var _dirty:Boolean = true;							// dirty state flag
		protected var _lastQueryTime:Number;								// previous query time 
		protected var _cachedMatrix:Matrix = new Matrix();				// cached matrix 
		
		// current transformation storage variables
		protected var _interpolationKey:KSpatialKeyFrame;				// Spatial key frame at the current time (to be interpolated)
		protected var _nextInterpolationKey:KSpatialKeyFrame;			// Holds the first interpolation (passthrough == false) spatial key frame after the current time (if any)
		protected var _TStoredPath:KPath;								// stored translation path for interpolation before current time
		protected var _RStoredPath:KPath;								// stored rotation path for interpolation before current time
		protected var _SStoredPath:KPath;								// stored scaling path for interpolation before current time

		// params: type:int, keys:Vector.<KSpatialKeyFrame>, sourcePaths:Dictionary[KSpatialKeyFrame:KPath], 
		//         targetPaths:Dictionary[KSpatialKeyFrame:KPath], startPoints:Dictionary[KSpatialKeyFrame:Point], 
		//         sX:Number, sY:Number, eX:Number, eY:Number, dirty:Boolean
		private   var _stretchTransParams:Dictionary;					// Parameters used for stretching translation paths before current time
		private   var _stretchRotParams:Dictionary;						// Parameters used for stretching rotation paths before current time
		private   var _stretchScaleParams:Dictionary;					// Parameters used for stretching scale paths before current time
		private   var _stretchTrans2Params:Dictionary;					// Parameters used for stretching translation paths after current time
		private   var _stretchRot2Params:Dictionary;					// Parameters used for stretching rotation paths after current time
		private   var _stretchScale2Params:Dictionary;					// Parameters used for stretching scale paths after current time
		
		
//		// subsequent transformation storage variables
//		protected var _nextInterpolationKey:KSpatialKeyFrame;			// First interpolation (passthrough == false) spatial key frame after the current time (if any)
//		protected var _TStoredPath2:KPath;								// stored translation path for interpolation after current time
//		protected var _RStoredPath2:KPath;								// stored rotation path for interpolation after current time
//		protected var _SStoredPath2:KPath;								// stored scaling path for interpolation after current time
		
//		private   var _stretchTransParams:Point;						// Parameters used for stretching translation paths
//		private   var _stretchRotParams:Point;							// Parameters used for stretching rotation paths
//		private   var _stretchScaleParams:Point;						// Parameters used for stretching scale paths
//		private   var _stretchTransVector:Point;						// Vector used for stretching translation paths
//		private   var _stretchRotVector:Point;							// Vector used for stretching rotation paths
//		private   var _stretchScaleVector:Point;						// Vector used for stretching scale paths
		
		// transition time variables
		protected var _startTime:Number;									// starting time
		protected var _startMatrix:Matrix;								// starting matrix
		protected var _inTransit:Boolean								// in-transition state flag
		protected var _transitionType:int;								// transition state type
		
		// transition space variables
		protected var _transitionX:Number;								// Current x difference from when interaction started.
		protected var _transitionY:Number;								// Current y difference from when interaction started.
		protected var _transitionTheta:Number;							// Current theta difference from when interaction started.
		protected var _transitionSigma:Number;							// Current sigma difference from when interaction started.
		
		// magnitude variables
		protected var _magX:Number;										// The sum of all horizontal distance (x) changes (absolute value) since interaction started.
		protected var _magY:Number;										// The sum of all horizontal distance (x) changes (absolute value) since interaction started.
		protected var _magTheta:Number;									// The sum of all rotational (theta) changes (absolute value) since interaction started.
		protected var _magSigma:Number;									// The sum of all scaling (sigma) changes (absolute value) since interaction started.

		// cache variables
		protected var _cachedX:Number;									// cache of x-vaue at the time interaction began
		protected var _cachedY:Number;									// cache of y-value at the time interaction began
		protected var _cachedTheta:Number;								// cache of rotation (theta) value at the time interaction began
		protected var _cachedSigma:Number;								// cache of scale (sigma) value at the time interaction began
		
		// transformation state flag variables
		public var hasTranslate:Boolean;								// transition state flag
		public var hasRotate:Boolean;									// rotation state flag
		public var hasScale:Boolean;									// scaling state flag
		
		
		public var tempArr: ArrayCollection = new ArrayCollection();
		public var interpolationKeylist:ArrayCollection = new ArrayCollection();   // All interpolation spatial key frames after the current time.
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
	
			// params: type:int, keys:Vector.<KSpatialKeyFrame>, sourcePaths:Dictionary[KSpatialKeyFrame:KPath], 
			//         targetPaths:Dictionary[KSpatialKeyFrame:KPath], startPoints:Dictionary[KSpatialKeyFrame:Point], 
			//         sX:Number, sY:Number, eX:Number, eY:Number

			// Allocate temporary variables
			_stretchTransParams = new Dictionary();		
			_stretchRotParams = new Dictionary();	
			_stretchScaleParams = new Dictionary();
			_stretchTrans2Params = new Dictionary();		
			_stretchRot2Params = new Dictionary();	
			_stretchScale2Params = new Dictionary();


//			_stretchTransParams = new Point();		
//			_stretchRotParams = new Point();	
//			_stretchScaleParams = new Point();
//			_stretchTransVector = new Point();
//			_stretchRotVector = new Point();
//			_stretchScaleVector = new Point();
//			
//			_TStoredPathStart = new Point();
//			_RStoredPathStart = new Point();
//			_SStoredPathStart = new Point();
//			_TStoredPath2Start = new Point();
//			_RStoredPath2Start = new Point();
//			_SStoredPath2Start = new Point();
		}
		
		
		
		// ##########################
		// # Accessors and Mutators #
		// ##########################
		
		public function set dirty(value:Boolean):void
		{
			// set the dirty state flag to the given value
			_dirty = value;
		}
		
		public function matrix(time:Number):Matrix
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
					point = currentKey.translatePath.find_Point(proportionKeyFrame, currentKey);
					// case: the located point is not null
					// extract the located point's x- and y-positions
					if(point)
					{
						x += point.x;
						y += point.y;
					}
					
					// locate the point in the current key frame's rotated path at the proportional value
					point = currentKey.rotatePath.find_Point(proportionKeyFrame, currentKey);
					
					// case: the located point is not null
					// increment the rotational value
					if(point)
						theta += point.x;
					
					// locate the point in the current key frame's scaled path at the proportional value
					point = currentKey.scalePath.find_Point(proportionKeyFrame, currentKey);
					
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
		
		public function get firstKeyTime():Number
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
		
		public function get lastKeyTime():Number
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
		
		public function getActiveKey(time:Number):IKeyFrame
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
		private function _transitionMatrix(time:Number):Matrix
		{
			var x:Number = _transitionX;
			var y:Number = _transitionY;
			var theta:Number = _transitionTheta;
			var sigma:Number = 1 + _transitionSigma;
			var point:KTimedPoint;
			var proportionKeyFrame:Number;
			var computeTime:Number;
			
			var currentKey:KSpatialKeyFrame = _refFrame.getKeyAftertime(_startTime) as KSpatialKeyFrame;
			
			while(currentKey)
			{
				proportionKeyFrame = currentKey.findProportion(time);
				
				if(!hasTranslate)
				{
					point = currentKey.translatePath.find_Point(proportionKeyFrame, currentKey);
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
					point = currentKey.rotatePath.find_Point(proportionKeyFrame, currentKey);
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
					point = currentKey.scalePath.find_Point(proportionKeyFrame, currentKey);
					if(_magSigma <= EPSILON)
					{
						if(point)
							sigma += point.x;
					}
					else
					{
						if(point)
							_cachedSigma += point.x;
						
						hasScale = true;
					}
				}
				
				currentKey = currentKey.next as KSpatialKeyFrame;
			}
			
			var result:Matrix = new Matrix();
			result.translate(-_object.center.x,-_object.center.y);
			result.rotate(theta+_cachedTheta);
			result.scale(sigma+_cachedSigma, sigma+_cachedSigma);
			result.translate(_object.center.x, _object.center.y);
			result.translate(x+_cachedX, y+_cachedY);
			return result;	
		}
		
		

		
		
		// ##############
		// # Permitters #
		// ##############

		public function canInterpolate(time:Number):Boolean
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
		
		public function canInsertKeyFrame(time:Number):Boolean
		{
			// get the key frame at the given time and check if the extacted key frame exists
			var hasKeyAtTime:Boolean = (_refFrame.getKeyAtTime(time) as KSpatialKeyFrame != null);
			var canInsert:Boolean = true;
			
			if(hasKeyAtTime)
				if(!(_refFrame.getKeyAtTime(time) as KSpatialKeyFrame).passthrough)
					canInsert = false;
			
			// return whether the extracted key frame exists
			return canInsert;
		}
		
		public function canInsertKey(time:Number):Boolean
		{
			// get the key frame at the given time and check if the extacted key frame exists
			var hasKeyAtTime:Boolean = (_refFrame.getKeyAtTime(time) as KSpatialKeyFrame != null);
			
			// return whether the extracted key frame exists
			return !hasKeyAtTime;
		}
		
		public function canRemoveKey(time:Number):Boolean
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
				{
					if(key.passthrough)
						canRemove = false;	
				}
					
				if(key == _refFrame.head)
					canRemove = false;
			}
			
			// return the remove key frame check
			return canRemove;
		}
		
		public function canClearKeys(time:Number):Boolean
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
		public function beginTransition(time:Number, transitionType:int, op:KCompositeOperation):void
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
				_TStoredPath = new KPath(KPath.TRANSLATE);
				_TStoredPath.push(0,0,0);
				_RStoredPath = new KPath(KPath.ROTATE);
				_RStoredPath.push(0,0,0);
				_SStoredPath = new KPath(KPath.SCALE);
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
			_cachedSigma = 0;
			
			var currentProportion:Number = 1;
			var point:KTimedPoint;
			var currentKey:KSpatialKeyFrame = _refFrame.head as KSpatialKeyFrame;
			
			while(currentKey)
			{
				
				if( _startTime < currentKey.time)
					break;
				
				point = currentKey.translatePath.find_Point(1, currentKey);
				if(point)
				{
					_cachedX += point.x;
					_cachedY += point.y;
				}
				
				point = currentKey.rotatePath.find_Point(1, currentKey);
				if(point)
					_cachedTheta += point.x;
				
				point = currentKey.scalePath.find_Point(1, currentKey);
				if(point)
					_cachedSigma += point.x;
				
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
		 * @param dx The x-position displacement from when the interaction began.
		 * @param dy The y-position displacement from when the interaction began.
		 * @param dTheta The rotation displacement from when the interaction began.
		 * @param dScale The scaling displacement from when the interaction began.
		 */
		public function updateTransition(time:Number, dx:Number, dy:Number, dTheta:Number, dScale:Number):void
		{
			var changeX:Number = dx - _transitionX;
			var changeY:Number = dy - _transitionY;
			var changeTheta:Number = dTheta - _transitionTheta;
			var changeSigma:Number = dScale - _transitionSigma;
			
			_magX += Math.abs(changeX);
			_magY += Math.abs(changeY);
			_magTheta += Math.abs(changeTheta);
			_magSigma += Math.abs(changeSigma);
			
			_transitionX = dx;
			_transitionY = dy;
			_transitionTheta = dTheta;
			_transitionSigma = dScale;
			
			if(_transitionType == KSketch2.TRANSITION_DEMONSTRATED)
			{
				var elapsedTime:Number;
				
				//if studyMode is set to K, store it in an array first. Do not push. only push when endTransition
				if(studyMode == STUDYMODE_K) 
				{
					var tempObj: Object = new Object();
					//Just dump the new values in for demonstrated transitions
					elapsedTime = time - _startTime;
					
					tempObj.elapsedTime = elapsedTime;
					tempObj.dx = dx;
					tempObj.dy = dy;
					tempObj.dTheta = dTheta;
					tempObj.dScale = dScale;
					
					tempArr.addItem(tempObj);
				}
				//if studyMode is set to P, KP or KP2, make sure to do real time performance
				else
				{
					//Just dump the new values in for demonstrated transitions
					elapsedTime = time - _startTime;
					
					if(elapsedTime != 0)
					{
						_TStoredPath.push(dx, dy, elapsedTime);
						_RStoredPath.push(dTheta, 0, elapsedTime);
						_SStoredPath.push(dScale, 0, elapsedTime);
					}
				}
			}
			
			else
			{
				if(!_interpolationKey)
					throw new Error("No Keys to interpolate!");

				//We need to interpolate the relevant keys during every update for interpolated transitions
				//dx:Number, dy:Number, time:Number, params:Dictionary
				if((Math.abs(_transitionX) > EPSILON) || (Math.abs(_transitionY) > EPSILON)) {
					_stretch(_transitionX, _transitionY, time, _stretchTransParams);
					//_interpolate(changeX, changeY, time, _stretchTransParams);
				}
				if(Math.abs(_transitionTheta) > EPSILON) {
					//_stretch(_transitionTheta, 0, time, _stretchRotParams);
					_interpolate(changeTheta, 0, time, _stretchRotParams);
				}
				if(Math.abs(_transitionSigma) > EPSILON) {
					//_stretch(_transitionSigma, 0, time, _stretchScaleParams);
					_interpolate(changeSigma, 0, time, _stretchScaleParams);
				}
									
				//if studymode kp2, then do Interpolation for next frame
				if(studyMode == STUDYMODE_KP2)
				{
					// *****************************************************************
					// *****************************************************************
					// *****************************************************************
					// *****************************************************************
					// *****************************************************************
					// *****************************************************************
					// *****************************************************************
					// *****************************************************************
					// *****************************************************************
					// *****************************************************************
					// *****************************************************************
					
					if (_nextInterpolationKey) {
						if((Math.abs(_transitionX) > EPSILON) || (Math.abs(_transitionY) > EPSILON)) {
							_stretch(-_transitionX, -_transitionY, time, _stretchTrans2Params);
							//_interpolate(-changeX,-changeY, time, _stretchTrans2Params);
						}
						if(Math.abs(_transitionTheta) > EPSILON) {
							//_stretch(-_transitionTheta, 0, time, _stretchRot2Params);
							_interpolate(-changeTheta, 0, time, _stretchRot2Params);
						}
						if(Math.abs(_transitionSigma) > EPSILON) {
							//_stretch(-_transitionSigma, 0, time, _stretchScale2Params);
							_interpolate(-changeSigma, 0, time, _stretchScale2Params);
						}						
					}
					
//					var interpolatePassthrough:Boolean = false;
//					if(interpolationKeylist.length != 0)
//					{
//						for(var i:int = 0; i<interpolationKeylist.length; i++)
//						{
//							var tempKey:KSpatialKeyFrame = interpolationKeylist.getItemAt(i) as KSpatialKeyFrame;
//							interpolatePassthrough = tempKey.passthrough;
//							
//							if(!interpolatePassthrough) 
//							{
//								if((Math.abs(_transitionX) > EPSILON) || (Math.abs(_transitionY) > EPSILON)) {
//									_interpolate(-changeX,-changeY, tempKey, KSketch2.TRANSFORM_TRANSLATION, tempKey.time);
//								}
//								if(Math.abs(_transitionTheta) > EPSILON) {
//									_interpolate(-changeTheta, 0, tempKey, KSketch2.TRANSFORM_ROTATION, tempKey.time);
//								}
//								if(Math.abs(_transitionSigma) > EPSILON) {
//									_interpolate(-changeSigma, 0, tempKey, KSketch2.TRANSFORM_SCALE, tempKey.time);	
//								}
//								break;
//							}
//						}
//					}
				}	
				else if(studyMode != STUDYMODE_P)
				{
					if(_nextInterpolationKey)
					{
						if((Math.abs(_transitionX) > EPSILON) || (Math.abs(_transitionY) > EPSILON))
							_interpolate(-changeX,-changeY, time, _stretchTrans2Params);
						if(Math.abs(_transitionTheta) > EPSILON)
							_interpolate(-changeTheta, 0, time, _stretchRot2Params);
						if(Math.abs(_transitionSigma) > EPSILON)
							_interpolate(-changeSigma, 0, time, _stretchScale2Params);	
					}
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
		public function endTransition(time:Number, op:KCompositeOperation):void
		{
			if(studyMode == STUDYMODE_K)
			{
				if(tempArr != null && tempArr.length > 0)
				{
					var tempObj:Object = tempArr[tempArr.length - 1];
					var dx:Number = tempObj.dx;
					var dy:Number = tempObj.dy;
					var dTheta:Number = tempObj.dTheta;
					var dScale:Number = tempObj.dScale;
					var elapsedTime:Number = tempObj.elapsedTime;
					
					_TStoredPath.push(dx, dy, elapsedTime);
					_RStoredPath.push(dTheta, 0, elapsedTime);
					_SStoredPath.push(dScale, 0, elapsedTime);
				}
			}

			_dirty = true;
			_endTransition_process_ModeDI(time, op);
			_inTransit = false;
			_dirty = true;
			
			// dispatch a transform finalised event
			// application level components can listen to this event to do updates
			_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_ENDED, _object, time)); 
			_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_FINALISED, _object, time));
		}
		
		private function _beginTransition_process_interpolation(time:Number, op:KCompositeOperation):void
		{
			var tmpCurrent:KSpatialKeyFrame, tmpNext:KSpatialKeyFrame, tmpKeyVec:Vector.<KSpatialKeyFrame>, tmpDict:Dictionary;
			var point:KTimedPoint, endKey:KSpatialKeyFrame, afterInerpTime:Boolean, key:Object; 
			var x:Number, y:Number, theta:Number, sigma:Number;
			
			if(_transitionType == KSketch2.TRANSITION_INTERPOLATED)
			{
				//For interpolation, there will always be a key inserted at given time
				//So we just insert a key at time, if there is a need to insert key
				if(canInsertKey(time))
				{
					insertBlankKeyFrame(time, op, false);
				}
				//trace("_beginTransition_process_interpolation");
				//trace(_refFrame);
				//Then we grab that key
				_interpolationKey = _refFrame.getKeyAtTime(time) as KSpatialKeyFrame;
				//trace("_interpolationKey.time = " + _interpolationKey.time);
				
				_TStoredPath = _interpolationKey.translatePath.clone();
				_RStoredPath = _interpolationKey.rotatePath.clone();
				_SStoredPath = _interpolationKey.scalePath.clone();
				
				// params: type:int, keys:Vector.<KSpatialKeyFrame>, sourcePaths:Dictionary[KSpatialKeyFrame:KPath], 
				//         targetPaths:Dictionary[KSpatialKeyFrame:KPath], startPoints:Dictionary[KSpatialKeyFrame:Point], 
				//         sX:Number, sY:Number, eX:Number, eY:Number, dirty:Boolean
				_stretchTransParams["type"] = KSketch2.TRANSFORM_TRANSLATION;		
				tmpKeyVec = new Vector.<KSpatialKeyFrame>();
				tmpKeyVec.push(_interpolationKey);
				_stretchTransParams["keys"] = tmpKeyVec;
				tmpDict = new Dictionary();
				tmpDict[_interpolationKey] = _TStoredPath;
				_stretchTransParams["sourcePaths"] = tmpDict;
				tmpDict = new Dictionary();
				tmpDict[_interpolationKey] = _interpolationKey.translatePath;
				_stretchTransParams["targetPaths"] = tmpDict;
				_stretchTransParams["startPoints"] = new Dictionary();
				_stretchTransParams["dirty"] = false;

				_stretchRotParams["type"] = KSketch2.TRANSFORM_ROTATION;	
				tmpKeyVec = new Vector.<KSpatialKeyFrame>();
				tmpKeyVec.push(_interpolationKey);
				_stretchRotParams["keys"] = tmpKeyVec;
				tmpDict = new Dictionary();
				tmpDict[_interpolationKey] = _RStoredPath;
				_stretchRotParams["sourcePaths"] = tmpDict;
				tmpDict = new Dictionary();
				tmpDict[_interpolationKey] = _interpolationKey.rotatePath;
				_stretchRotParams["targetPaths"] = tmpDict;
				_stretchRotParams["startPoints"] = new Dictionary();
				_stretchRotParams["dirty"] = false;
				
				_stretchScaleParams["type"] = KSketch2.TRANSFORM_SCALE;			
				tmpKeyVec = new Vector.<KSpatialKeyFrame>();
				tmpKeyVec.push(_interpolationKey);
				_stretchScaleParams["keys"] = tmpKeyVec;
				tmpDict = new Dictionary();
				tmpDict[_interpolationKey] = _SStoredPath;
				_stretchScaleParams["sourcePaths"] = tmpDict;
				tmpDict = new Dictionary();
				tmpDict[_interpolationKey] = _interpolationKey.scalePath;
				_stretchScaleParams["targetPaths"] = tmpDict;
				_stretchScaleParams["startPoints"] = new Dictionary();
				_stretchScaleParams["dirty"] = false;


				_nextInterpolationKey = null;
				interpolationKeylist.removeAll();
				if(_interpolationKey.time == time)
				{
					//Then we deal with the interpolation
					
					//Only if study mode is KP2, we need to get all the keys after the selected time
					if(studyMode == STUDYMODE_KP2)
					{
						tmpCurrent = _interpolationKey;
						tmpNext = tmpCurrent.next as KSpatialKeyFrame;
						
						//trace("interpolationKeylist times");
						while(tmpNext)
						{
							interpolationKeylist.addItem(tmpNext);
							//trace(tmpNext.time);
							if (!_nextInterpolationKey) {
								if (!tmpNext.passthrough) {
									_nextInterpolationKey = tmpNext;
								}
							}
							tmpCurrent = tmpNext;
							tmpNext = tmpCurrent.next as KSpatialKeyFrame;
						}
					}
					
					_nextInterpolationKey ? trace("_nextInterpolationKey.time = " + _nextInterpolationKey.time): null;
					
				}
				
				if(_interpolationKey)
				{
					x = 0;
					y = 0;
					theta = 0;
					sigma = 1;
					
					afterInerpTime = false;
					endKey = _nextInterpolationKey ? _nextInterpolationKey.next as KSpatialKeyFrame : _interpolationKey.next as KSpatialKeyFrame;
					tmpCurrent = _refFrame.head as KSpatialKeyFrame;
					
					// params: type:int, keys:Vector.<KSpatialKeyFrame>, sourcePaths:Dictionary[KSpatialKeyFrame:KPath], 
					//         targetPaths:Dictionary[KSpatialKeyFrame:KPath], startPoints:Dictionary[KSpatialKeyFrame:Point], 
					//         sX:Number, sY:Number, eX:Number, eY:Number, dirty:Boolean
					while(tmpCurrent !== endKey) {
						
						if (tmpCurrent === _interpolationKey) {
							// When the first key is found, set the start times
							_stretchTransParams["sX"] = x;
							_stretchTransParams["sY"] = y;
							tmpDict = _stretchTransParams["startPoints"] as Dictionary;
							tmpDict[_interpolationKey] = new Point(x, y);

							_stretchRotParams["sX"] = theta;
							_stretchRotParams["sY"] = 0;
							tmpDict = _stretchRotParams["startPoints"] as Dictionary;
							tmpDict[_interpolationKey] = new Point(theta, 0);

							_stretchScaleParams["sX"] = sigma;
							_stretchScaleParams["sY"] = 0;
							tmpDict = _stretchScaleParams["startPoints"] as Dictionary;
							tmpDict[_interpolationKey] = new Point(sigma, 0);
							
							afterInerpTime = true;
						} else if (afterInerpTime) {
							tmpKeyVec = _stretchTrans2Params["keys"] as Vector.<KSpatialKeyFrame>;
							tmpKeyVec.push(tmpCurrent);
							tmpKeyVec = _stretchRot2Params["keys"] as Vector.<KSpatialKeyFrame>;
							tmpKeyVec.push(tmpCurrent);
							tmpKeyVec = _stretchScale2Params["keys"] as Vector.<KSpatialKeyFrame>;
							tmpKeyVec.push(tmpCurrent);
							
							tmpDict = _stretchTrans2Params["sourcePaths"] as Dictionary;
							tmpDict[tmpCurrent] = tmpCurrent.translatePath.clone();
							tmpDict = _stretchRot2Params["sourcePaths"] as Dictionary;
							tmpDict[tmpCurrent] = tmpCurrent.rotatePath.clone();
							tmpDict = _stretchScale2Params["sourcePaths"] as Dictionary;
							tmpDict[tmpCurrent] = tmpCurrent.scalePath.clone();
							
							tmpDict = _stretchTrans2Params["targetPaths"] as Dictionary;
							tmpDict[tmpCurrent] = tmpCurrent.translatePath;
							tmpDict = _stretchRot2Params["targetPaths"] as Dictionary;
							tmpDict[tmpCurrent] = tmpCurrent.rotatePath;
							tmpDict = _stretchScale2Params["targetPaths"] as Dictionary;
							tmpDict[tmpCurrent] = tmpCurrent.scalePath;
							
							tmpDict = _stretchTrans2Params["startPoints"] as Dictionary;
							tmpDict[tmpCurrent] = new Point(x, y);
							tmpDict = _stretchRot2Params["startPoints"] as Dictionary;
							tmpDict[tmpCurrent] = new Point(theta, 0);
							tmpDict = _stretchScale2Params["startPoints"] as Dictionary;
							tmpDict[tmpCurrent] = new Point(sigma, 0);	
							
							_stretchTrans2Params["dirty"] = false;
							_stretchRot2Params["dirty"] = false;
							_stretchScale2Params["dirty"] = false;
						}
						
						// Update the x, y, theta, and sigma accumulators.
						point = tmpCurrent.translatePath.find_Point(1, tmpCurrent);
						if(point) {
							x += point.x;
							y += point.y;
						}
						point = tmpCurrent.rotatePath.find_Point(1, tmpCurrent);
						if(point) {
							theta += point.x;
						}
						point = tmpCurrent.scalePath.find_Point(1, tmpCurrent);
						if(point) {
							sigma += point.x;
						}

						if (tmpCurrent === _interpolationKey) {
							// If this is the _interpolationKey, set end times for the stretch before the current time.
							_stretchTransParams["eX"] = x;
							_stretchTransParams["eY"] = y;							
							_stretchRotParams["eX"] = theta;
							_stretchRotParams["eY"] = 0;
							_stretchScaleParams["eX"] = sigma;
							_stretchScaleParams["eY"] = 0;
							
							if (_nextInterpolationKey) {
								_stretchTrans2Params["type"] = KSketch2.TRANSFORM_TRANSLATION;	
								_stretchTrans2Params["keys"] = new Vector.<KSpatialKeyFrame>();
								_stretchTrans2Params["sourcePaths"] = new Dictionary();
								_stretchTrans2Params["targetPaths"] = new Dictionary();
								_stretchTrans2Params["startPoints"] = new Dictionary();
								_stretchTrans2Params["sX"] = x;
								_stretchTrans2Params["sY"] = y;

								_stretchRot2Params["type"] = KSketch2.TRANSFORM_ROTATION;
								_stretchRot2Params["keys"] = new Vector.<KSpatialKeyFrame>();
								_stretchRot2Params["sourcePaths"] = new Dictionary();
								_stretchRot2Params["targetPaths"] = new Dictionary();
								_stretchRot2Params["startPoints"] = new Dictionary();
								_stretchRot2Params["sX"] = x;
								_stretchRot2Params["sY"] = y;

								_stretchScale2Params["type"] = KSketch2.TRANSFORM_SCALE;
								_stretchScale2Params["keys"] = new Vector.<KSpatialKeyFrame>();
								_stretchScale2Params["sourcePaths"] = new Dictionary();
								_stretchScale2Params["targetPaths"] = new Dictionary();
								_stretchScale2Params["startPoints"] = new Dictionary();
								_stretchScale2Params["sX"] = x;
								_stretchScale2Params["sY"] = y;
							} else {
								for (key in _stretchTrans2Params) delete _stretchTrans2Params[key];
								for (key in _stretchRot2Params) delete _stretchRot2Params[key];
								for (key in _stretchScale2Params) delete _stretchScale2Params[key];
							}
						} else if (afterInerpTime) {							
							if (tmpCurrent === _nextInterpolationKey) {
								// If this is the _nextInterpolationKey, set end times for the stretch after the current time.
								_stretchTrans2Params["eX"] = x;
								_stretchTrans2Params["eY"] = y;							
								_stretchRot2Params["eX"] = theta;
								_stretchRot2Params["eY"] = 0;
								_stretchScale2Params["eX"] = sigma;
								_stretchScale2Params["eY"] = 0;
							}
						}

						tmpCurrent = tmpCurrent.next as KSpatialKeyFrame;
					}
				}
			}
		}

		private function _endTransition_process_interpolation(time:Number, op:KCompositeOperation):void
		{
			var i:uint, keys:Vector.<KSpatialKeyFrame>, dict:Dictionary;
			if(_transitionType == KSketch2.TRANSITION_INTERPOLATED)
			{
				//original implementation
				if (_stretchTransParams["dirty"] as Boolean === true) 
					op.addOperation(new KReplacePathOperation(_interpolationKey, _interpolationKey.translatePath, _TStoredPath, KSketch2.TRANSFORM_TRANSLATION));
				if (_stretchRotParams["dirty"] as Boolean === true) 
					op.addOperation(new KReplacePathOperation(_interpolationKey, _interpolationKey.rotatePath, _RStoredPath, KSketch2.TRANSFORM_ROTATION));
				if (_stretchScaleParams["dirty"] as Boolean === true) 
					op.addOperation(new KReplacePathOperation(_interpolationKey, _interpolationKey.scalePath, _SStoredPath, KSketch2.TRANSFORM_SCALE));
				
				if(_nextInterpolationKey)
				{
					if (_stretchTrans2Params["dirty"] as Boolean === true) {
						keys = _stretchTrans2Params["keys"] as Vector.<KSpatialKeyFrame>;
						for (i = 0; i < keys.length; i++) {
							dict = _stretchTrans2Params["sourcePaths"] as Dictionary;
							op.addOperation(new KReplacePathOperation(keys[i], keys[i].translatePath, 
								dict[keys[i]] as KPath, KSketch2.TRANSFORM_TRANSLATION));
						}
					}
					if (_stretchRot2Params["dirty"] as Boolean === true) {
						keys = _stretchRot2Params["keys"] as Vector.<KSpatialKeyFrame>;
						for (i = 0; i < keys.length; i++) {
							dict = _stretchRot2Params["sourcePaths"] as Dictionary;
							op.addOperation(new KReplacePathOperation(keys[i], keys[i].rotatePath, 
								dict[keys[i]] as KPath, KSketch2.TRANSFORM_ROTATION));
						}
					}
					if (_stretchScale2Params["dirty"] as Boolean === true) {
						keys = _stretchScale2Params["keys"] as Vector.<KSpatialKeyFrame>;
						for (i = 0; i < keys.length; i++) {
							dict = _stretchScale2Params["sourcePaths"] as Dictionary;
							op.addOperation(new KReplacePathOperation(keys[i], keys[i].scalePath, 
								dict[keys[i]] as KPath, KSketch2.TRANSFORM_SCALE));
						}
					}
				}
			}
		}
		
		private function _endTransition_process_ModeD(time:Number, op:KCompositeOperation):void
		{
			if(_transitionType == KSketch2.TRANSITION_DEMONSTRATED)
				_demonstrate(time, op);	
			else
				_endTransition_process_interpolation(time, op);
		}
		
		private function _endTransition_process_ModeDI(time:Number, op:KCompositeOperation):void
		{
			if(_transitionType == KSketch2.TRANSITION_DEMONSTRATED)
				_demonstrate(time, op);	
			else
				_endTransition_process_interpolation(time, op);
		}

		private function _demonstrate(time:Number, op:KCompositeOperation):void
		{
			//Process the paths here first
			//Do w/e you want to the paths here!
			
			// Spread out the times for these points.
//			_TStoredPath.distributePathPointTimes();
//			_RStoredPath.distributePathPointTimes();
//			_SStoredPath.distributePathPointTimes();
			
			//Make sure there is only one point at one frame
			_TStoredPath.discardRedundantPathPoints();
			_RStoredPath.discardRedundantPathPoints();
			_SStoredPath.discardRedundantPathPoints();			
	
			// Make sure rotation doesn't move too fast, or the motion path won't render correctly.
			KPathProcessing.limitSegmentLength(_RStoredPath, MAX_ROTATE_STEP);
			
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
		
		//*********************************************************************************************************
		//*********************************************************************************************************
		//*********************************************************************************************************
		//*********************************************************************************************************
		//*********************************************************************************************************
		//*********************************************************************************************************
		//*********************************************************************************************************
		//*********************************************************************************************************
		//*********************************************************************************************************
		//*********************************************************************************************************
		
		
//		private function _updateStretchParameters(orig:KPath, dx:Number, dy:Number, transformType:int, params:Point, vec:Point):void
//		{
//			var vX1:Number, vY1:Number, vX2:Number, vY2:Number;
//			var mag1:Number, mag2:Number, rot1:Number, rot2:Number;
//			var m:Number, theta:Number, vX:Number, vY:Number;
//			
//			if (orig && 2 <= orig.length) {
//				// 2 or more points. Return magnitude and rotation for stretching.
//				switch(transformType)
//				{
//					case KSketch2.TRANSFORM_TRANSLATION:
//						vX1 = orig.points[orig.length - 1].x;
//						vY1 = orig.points[orig.length - 1].y;
//						vX2 = vX1 + dx;
//						vY2 = vY1 + dy;
//						mag1 = Math.sqrt(vX1*vX1 + vY1*vY1);
//						mag2 = Math.sqrt(vX2*vX2 + vY2*vY2);
//						rot1 = Math.atan2(vY1, vX1);
//						rot2 = Math.atan2(vY2, vX2);
//
//						m = mag2 / mag1;
//
//						theta = rot2 - rot1;
//						if (Math.PI < theta)
//							theta = -Math.PI + (theta - Math.PI);
//						if (theta <= -Math.PI)
//							theta = Math.PI + (theta + Math.PI);
//						
//						vX = vX2/mag2;
//						vY = vY2/mag2;
//
//						break;
//					case KSketch2.TRANSFORM_ROTATION:
//					case KSketch2.TRANSFORM_SCALE:
//						mag1 = orig.points[orig.length - 1].x;
//						mag2 = mag1 + dx;
//						
//						m = mag2 / mag1;
//						theta = 0;
//						vX = 1;
//						vY = 0;
//						break;
//					default:
//						throw new Error("Unable to replace path because an unknown transform type is given");
//				}
//			} else {
//				// Less than 2 points. Set params to empty values and set vec to (dx, dy).
//				m = 1;
//				theta = 0;
//				vX = dx;
//				vY = dy;
//			}
//			trace("stretch parameters: mag=" + params.x + ", rot=" + params.y); 	
//			
//			params.x = m;
//			params.y = theta;
//			vec.x = vX;
//			vec.y = vY;
//		}

		
		/**
		 * scales and rotates a path Adds a dx, dy interpolation to targetKey
		 * target key should be a key at or before time;
		 */
		private function _stretch(dx:Number, dy:Number, time:Number, params:Dictionary):void
		{			
			// params: type:int, keys:Vector.<KSpatialKeyFrame>, sourcePaths:Dictionary[KSpatialKeyFrame:KPath], 
			//         targetPaths:Dictionary[KSpatialKeyFrame:KPath], startPoints:Dictionary[KSpatialKeyFrame:Point], 
			//         sX:Number, sY:Number, eX:Number, eY:Number

			var vX1:Number, vY1:Number, vX2:Number, vY2:Number;
			var mag1:Number, mag2:Number, rot1:Number, rot2:Number;
			var mag:Number, theta:Number, vX:Number, vY:Number;
			var i:uint, j:uint, ptX:Number, ptY:Number, projectionLen:Number, proportion:Number;
			var targetKey:KSpatialKeyFrame, sourcePath:KPath, targetPath:KPath, startPoint:Point;
			var type:int = params["type"] as int;
			var targetKeys:Vector.<KSpatialKeyFrame> = params["keys"] as Vector.<KSpatialKeyFrame>;
			var sourcePaths:Dictionary = params["sourcePaths"] as Dictionary;
			var targetPaths:Dictionary = params["targetPaths"] as Dictionary; 
			var startPoints:Dictionary = params["startPoints"] as Dictionary;
			var sX:Number = params["sX"] as Number;
			var sY:Number = params["sY"] as Number;
			var eX:Number = params["eX"] as Number;
			var eY:Number = params["eY"] as Number;
			var nonEmptyPaths:Boolean = false;
			var startTime:int = 0;
			var totalDuration:Number = 0;
			
			// Check to make sure that some paths have points
			for (j=0; j<targetKeys.length; j++) {
				targetKey = targetKeys[j] as KSpatialKeyFrame;
				sourcePath = sourcePaths[targetKey] as KPath;
				if (sourcePath && 2 <= sourcePath.length) {
					nonEmptyPaths = true;
					break;
				}
			}
			
			if (targetKeys.length > 0) {
				totalDuration = targetKeys[targetKeys.length-1].time - targetKeys[0].startTime;
			}
			
			if (nonEmptyPaths) {
				// 2 or more points. Return magnitude and rotation for stretching.
				switch(type)
				{
					case KSketch2.TRANSFORM_TRANSLATION:
						vX1 = eX - sX;
						vY1 = eY - sY;
						vX2 = vX1 + dx;
						vY2 = vY1 + dy;
						mag1 = Math.sqrt(vX1*vX1 + vY1*vY1);
						mag2 = Math.sqrt(vX2*vX2 + vY2*vY2);
						rot1 = Math.atan2(vY1, vX1);
						rot2 = Math.atan2(vY2, vX2);
						
						mag = mag2 / mag1;
						
						theta = rot2 - rot1;
						if (Math.PI < theta)
							theta = -Math.PI + (theta - Math.PI);
						if (theta <= -Math.PI)
							theta = Math.PI + (theta + Math.PI);
						
						vX = vX2/mag2;
						vY = vY2/mag2;
						
						break;
					case KSketch2.TRANSFORM_ROTATION:
					case KSketch2.TRANSFORM_SCALE:
						mag1 = eX - sX;
						mag2 = mag1 + dx;
						
						mag = mag2 / mag1;
						theta = 0;
						vX = 1;
						vY = 0;
						break;
					default:
						throw new Error("Unable to replace path because an unknown transform type is given");
				}
			} else {
				// Less than 2 points. Set params to empty values and set vec to (dx, dy).
				mag = 1;
				theta = 0;
				vX = dx;
				vY = dy;
			}
			
			//traceParams(params);
			//trace("     mag:" + mag + " rot:" + theta + " vX:" + vX + " vY:" + vY); 	

			
			for (j=0; j<targetKeys.length; j++) {
				targetKey = targetKeys[j] as KSpatialKeyFrame;
				sourcePath = sourcePaths[targetKey] as KPath;
				targetPath = targetPaths[targetKey] as KPath;
				startPoint = startPoints[targetKey] as Point;
				proportion = (totalDuration === 0) ? 1 : (targetKey.time - targetKey.startTime)/totalDuration;
				
				if((time > targetKey.time) && (KSketch2.studyMode != KSketch2.STUDYMODE_P))
					throw new Error("Unable to stretch a key if the stretch time is greater than targetKey's time");
				
				if(targetPath.length < 2) {
					//Case 1: Key frames without transition paths of required type
					if(targetPath.length != 0)
						throw new Error("Someone created a path with 1 point somehow! Better check out the path functions");
					
					//Provide the empty path with the positive interpolation first
					targetPath.push(0,0,0);
					targetPath.push(vX * proportion, vY * proportion, targetKey.duration);
				} else if (sourcePath.length < 2) {
					//Case 2: Empty sourcePath. Case 1 becomes this after the first update.
					targetPath.points[targetPath.length - 1].x = vX * proportion;
					targetPath.points[targetPath.length - 1].y = vY * proportion;
				} else {
					//Case 3: Transform sourcePath as indicated by params.
					if(targetPath.length != sourcePath.length)
						throw new Error("Target Path and SourcePath are not the same length!");

					for (i=1; i < sourcePath.length; i++) {
						
						// Set ptX and ptY, handling rotation, if any.
						if (theta == 0) {
							ptX = sourcePath.points[i].x;
							ptY = sourcePath.points[i].y;
						} else {
							ptX = sourcePath.points[i].x*Math.cos(theta) - sourcePath.points[i].y*Math.sin(theta); 
							ptY = sourcePath.points[i].x*Math.sin(theta) + sourcePath.points[i].y*Math.cos(theta); 
						}
						
						// Compute the length of the projection on the vector. 
						projectionLen = ptX * vX + ptY * vY;
						ptX = ptX + (vX * projectionLen * (mag - 1));
						ptY = ptY + (vY * projectionLen * (mag - 1));
						
						targetPath.points[i].x = ptX;
						targetPath.points[i].y = ptY;
					}
				}
				
//				trace("Time=" + targetKey.time);
//				trace("Source Path");
//				sourcePath.debug();
//				trace("Target Path");
//				targetPath.debug();
			}	
			
			params["dirty"] = true;
		}
		
		// params: type:int, keys:Vector.<KSpatialKeyFrame>, sourcePaths:Dictionary[KSpatialKeyFrame:KPath], 
		//         targetPaths:Dictionary[KSpatialKeyFrame:KPath], startPoints:Dictionary[KSpatialKeyFrame:Point], 
		//         sX:Number, sY:Number, eX:Number, eY:Number, dirty:Boolean
		private function traceParams(params:Dictionary):void
		{
			var type:int = params["type"] as int;
			var keys:Vector.<KSpatialKeyFrame> = params["keys"] as Vector.<KSpatialKeyFrame>;
			var sourcePaths:Dictionary = params["sourcePaths"] as Dictionary;
			var targetPaths:Dictionary = params["targetPaths"] as Dictionary;
			var startPoints:Dictionary = params["startPoints"] as Dictionary;
			var sX:Number = params["sX"] as Number;
			var sY:Number = params["sY"] as Number;
			var eX:Number = params["eX"] as Number;
			var eY:Number = params["eY"] as Number;
			var dirty:Boolean = params["dirty"] as Boolean;
			var keyStrings:Array = new Array();
			var i:uint, sourcePath:KPath, targetPath:KPath, startPoint:Point;
			
			var typeString:String;
			switch(type)
			{
				case KSketch2.TRANSFORM_TRANSLATION:
					typeString = "Translation";
					break;
				case KSketch2.TRANSFORM_ROTATION:
					typeString = "Rotation";
					break;
				case KSketch2.TRANSFORM_SCALE:
					typeString = "Scale";
					break;
				default:
					typeString = "Unknown";
			}
			
			//trace(typeString + " params   dirty:" + (dirty ? "true " : "false ") + "sX:" + sX + " sY:" + sY + " eX:" + eX + " eY:" + eY);
			for (i=0; i < keys.length; i++) {
				sourcePath = sourcePaths[keys[i]] as KPath; 
				targetPath = targetPaths[keys[i]] as KPath; 
				startPoint = startPoints[keys[i]] as Point; 
				keyStrings.push("  [" + keys[i].time + "   source:" + (sourcePath ? sourcePath.length + "pts " : "null ") +
					"target:" + (targetPath ? targetPath.length + "pts " : "null ") + 
					"start:" + (startPoint ? startPoint.x + "," + startPoint.y: "null") + "]");
			}
			//trace("  ", keyStrings);
		}

		/**
		 * Adds a dx, dy interpolation to targetKey
		 * target key should be a key at or before time;
		 */
		private function _interpolate(dx:Number, dy:Number, time:Number, params:Dictionary):void
		{
			// params: type:int, keys:Vector.<KSpatialKeyFrame>, sourcePaths:Dictionary[KSpatialKeyFrame:KPath], 
			//         targetPaths:Dictionary[KSpatialKeyFrame:KPath], startPoints:Dictionary[KSpatialKeyFrame:Point], 
			//         sX:Number, sY:Number, eX:Number, eY:Number
			//traceParams(params);

			var type:int = params["type"] as int;
			var keys:Vector.<KSpatialKeyFrame> = params["keys"] as Vector.<KSpatialKeyFrame>;
			var sourcePaths:Dictionary = params["sourcePaths"] as Dictionary;
			var targetPaths:Dictionary = params["targetPaths"] as Dictionary;
			var startPoints:Dictionary = params["startPoints"] as Dictionary;
			var sX:Number = params["sX"] as Number;
			var sY:Number = params["sY"] as Number;
			var eX:Number = params["eX"] as Number;
			var eY:Number = params["eY"] as Number;
			var i:uint, targetKey:KSpatialKeyFrame, targetPath:KPath;
			var totalDuration:Number, durationProportion:Number, proportionElapsed:Number;

			if(keys.length === 0)
				throw new Error("No Key to interpolate!");
			totalDuration = keys[keys.length-1].time - keys[0].startTime;

			for (i=0; i<keys.length; i++) {
				targetKey = keys[i];
				targetPath = targetPaths[targetKey] as KPath;
				durationProportion = totalDuration === 0 ? 1 : (targetKey.time - targetKey.startTime)/totalDuration;
				
				if((time > targetKey.time) && (KSketch2.studyMode != KSketch2.STUDYMODE_P))
					throw new Error("Unable to interpolate a key if the interpolation time is greater than targetKey's time");
				
				switch(type)
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
				
				
//				if(targetKey.duration == 0) {
//					proportionElapsed = 1;
//				} else{
//					proportionElapsed = (time-targetKey.startTime)/targetKey.duration;
//					
//					if(proportionElapsed > 1)
//						proportionElapsed = 1;
//				}	
				// RCDavis replaced this, because it we now always insert key frames at movement points. 
				proportionElapsed = 1;
				
				//var unInterpolate:Boolean = false;
				//var oldPath:KPath = targetPath.clone();
				
				//Case 1
				//Key frames without transition paths of required type
				if(targetPath.length < 2)
				{
					if(targetPath.length != 0)
						throw new Error("Someone created a path with 1 point somehow! Better check out the path functions");
					
					//Provide the empty path with the positive interpolation first
					targetPath.push(0,0,0);
					targetPath.push(dx * durationProportion, dy * durationProportion, targetKey.duration * proportionElapsed);
					
					//If the interpolation is performed in the middle of a key, "uninterpolate" it to 0 interpolation
//					if(time != targetKey.time)
//					{
//						targetPath.push(dx, dy, targetKey.duration);
//					}
					
					//Should fill the paths with points here
					//KPathProcessing.normalisePathDensity(targetPath);
				}
				else
				{
					if(targetKey.time == time) //Case 2:interpolate at key time
						KPathProcessing.interpolateSpan(targetPath, 0, proportionElapsed,
							dx * durationProportion, dy * durationProportion);
					else	//case 3:interpolate between two keys
						KPathProcessing.interpolateSpan(targetPath, 0, proportionElapsed,
							dx * durationProportion, dy * durationProportion);
					
					if (targetPath == targetKey.rotatePath)
						KPathProcessing.limitSegmentLength(targetPath, MAX_ROTATE_STEP);
				}	
				
				//trace("Time=" + targetKey.time);
				//trace("Target Path");
				targetPath.debug();
			}
			params["dirty"] = true;
		}
		
		/**
		 * Make source path the transition path of type for this operator's key list.
		 * Will split the source path to fit the time range
		 * Replaces all current paths of given type
		 */
		protected function _replacePathOverTime(sourcePath:KPath, startTime:Number, endTime:Number, transformType:int, op:KCompositeOperation):void
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
		protected function _normaliseForOverwriting(time:Number, op:KCompositeOperation):void
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
					//trace("_normaliseForOverwriting translate");
					oldPath = currentKey.translatePath;
					currentKey.translatePath = new KPath(KPath.TRANSLATE);
					newPath = currentKey.translatePath;
					op.addOperation(new KReplacePathOperation(currentKey, newPath, oldPath, KSketch2.TRANSFORM_TRANSLATION));
				}
				
				if(validRotate)
				{
					//trace("_normaliseForOverwriting rotate");
					oldPath = currentKey.rotatePath;
					currentKey.rotatePath = new KPath(KPath.ROTATE);
					newPath = currentKey.rotatePath;
					op.addOperation(new KReplacePathOperation(currentKey, newPath, oldPath, KSketch2.TRANSFORM_ROTATION));
				}
				
				if(validScale)
				{
					//trace("_normaliseForOverwriting scale");
					oldPath = currentKey.scalePath;
					currentKey.scalePath = new KPath(KPath.SCALE);
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
		public function moveCenter(dx:Number, dy:Number, time:Number):void
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
		
		public function insertBlankKeyFrame(time:Number, op:KCompositeOperation, keyframe:Boolean):void
		{
			var key:KSpatialKeyFrame = _refFrame.getKeyAftertime(time) as KSpatialKeyFrame;
			
			// case: there exists a key frame after the given time
			// need to split the key frame
			if(key)
			{
				key = _refFrame.split(key,time, op) as KSpatialKeyFrame;
				if(keyframe)
					key.passthrough = false;
			}
			// case: there doesn't exist a key frame after the given time
			else
			{
				// need to insert a key frame at the given time
				key = new KSpatialKeyFrame(time, _object.center);
				_refFrame.insertKey(key);
				
				if(keyframe)
					key.passthrough = false;
				
				op.addOperation(new KInsertKeyOperation(key.previous, null, key));	
			}
			
			// enable the dirty state flag due to the object's blank key frame insertion
			_dirty = true;
			
			// end the object's transform operation
			_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_ENDED, _object, time)); 
		}
		
		public function changeKeyPassthrough(time:Number, op:KCompositeOperation, value:Boolean):void
		{
			var key:KSpatialKeyFrame = _refFrame.getKeyAtTime(time) as KSpatialKeyFrame;
			
			if(op && key.time == time)
			{
				key.passthrough = value;
				var keyOp:KModifyPassthroughOperation = new KModifyPassthroughOperation(key);
				op.addOperation(keyOp);
			}
			
			// enable the dirty state flag due to the object's blank key frame insertion
			_dirty = true;
			
			// end the object's transform operation
			_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_ENDED, _object, time)); 
		}
		
		public function removeKey(time:Number, op:KCompositeOperation):void
		{
			// get the key frame after the given time
			var key:KSpatialKeyFrame = _refFrame.getKeyAtTime(time) as KSpatialKeyFrame;
			
			//if this is the last key, check if it is a keyframe
			if(!key.next)
			{
				//if key is a keyframe
				if(!key.passthrough)
				{
					//change keyframe to control point
					changeKeyPassthrough(time, op, true);
					return;
				}
			}
			
			removeKeyFrame(time, op);
		}
		
		private function removeKeyFrame(time:Number, op:KCompositeOperation):void
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
				var proportionKeyFrame:Number = nextKey.findProportion(nextKey.time);
				var point:KTimedPoint = nextKey.translatePath.find_Point(proportionKeyFrame, nextKey);
				
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
		
		public function clearAllMotionsAfterTime(time:Number, op:KCompositeOperation):void
		{
			// case: there exists an active key frame at the given time
			if(getActiveKey(time))
			{
				// case: can insert a key frame at the given time
				// inserts a blank key frame at the given time
				if(canInsertKey(time))
					insertBlankKeyFrame(time, op, false);
				
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
		
		public function mergeTransform(sourceObject:KObject, stopMergeTime:Number, op:KCompositeOperation):void
		{
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
			var keyStartTime:Number;
			var currentTime:Number;
			var oldMatrix:Matrix;
			var newMatrix:Matrix;
			var oldPosition:Point;
			var newPosition:Point;
			var difference:Point;
			
			var centroid:Point = _object.center;
			var centroidDiff:Point = sourceObject.center.subtract(_object.center);
			var alteredTranslatePath:KPath;
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
				if(currentKey.rotatePath.points.length != 0)
					toModifyKey.rotatePath.mergePath(currentKey.rotatePath, currentKey);
				op.addOperation(new KReplacePathOperation(toModifyKey, toModifyKey.rotatePath, oldPath, KSketch2.TRANSFORM_ROTATION));
				
				oldPath = toModifyKey.scalePath.clone();
				if(currentKey.scalePath.points.length != 0)
					toModifyKey.scalePath.mergePath(currentKey.scalePath, currentKey);
				op.addOperation(new KReplacePathOperation(toModifyKey, toModifyKey.scalePath, oldPath, KSketch2.TRANSFORM_SCALE));
				
				oldPath = toModifyKey.translatePath.clone();
				
				keyStartTime = toModifyKey.startTime;
				currentTime = toModifyKey.startTime;
				alteredTranslatePath = new KPath(KPath.TRANSLATE);
				
				alteredTranslatePath.push(0,0,0);
				
				if(currentKey.duration == 0)
				{
					oldPosition = oldInterface.matrix(currentTime).transformPoint(centroid);
					oldPosition = sourceInterface.matrix(currentTime).transformPoint(oldPosition);
					newPosition = matrix(currentTime).transformPoint(centroid);
					difference = oldPosition.subtract(newPosition);
					
					alteredTranslatePath.push(difference.x, difference.y, currentTime-keyStartTime);
				}
				else
				{
					while(currentTime <= toModifyKey.time)
					{
						oldPosition = oldInterface.matrix(currentTime).transformPoint(centroid);
						oldPosition = sourceInterface.matrix(currentTime).transformPoint(oldPosition);
						newPosition = matrix(currentTime).transformPoint(centroid);
						difference = oldPosition.subtract(newPosition);
						
						alteredTranslatePath.push(difference.x, difference.y, currentTime-keyStartTime);
						currentTime += KSketch2.ANIMATION_INTERVAL;
					}
				}
				
				toModifyKey.translatePath.mergePath(alteredTranslatePath, toModifyKey);
				
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
		
		/**
		 * Returns an interator that gives the times of all translate events, in order from beginning to end. 
		 */
		public function translateTimeIterator():INumberIterator
		{
			return _refFrame.translateTimeIterator();
		}
		
		/**
		 * Returns an interator that gives the times of all rotate events, in order from beginning to end. 
		 */
		public function rotateTimeIterator():INumberIterator
		{
			return _refFrame.rotateTimeIterator();
		}
		
		/**
		 * Returns an interator that gives the times of all scale events, in order from beginning to end. 
		 */
		public function scaleTimeIterator():INumberIterator
		{
			return _refFrame.scaleTimeIterator();
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
				
				var newKey:KSpatialKeyFrame = new KSpatialKeyFrame(new Number(currentKeyXML.@time), new Point());
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