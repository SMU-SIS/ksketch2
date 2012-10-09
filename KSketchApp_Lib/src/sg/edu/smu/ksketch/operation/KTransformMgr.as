/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package sg.edu.smu.ksketch.operation
{
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch.model.IKeyFrame;
	import sg.edu.smu.ksketch.model.IParentKeyFrame;
	import sg.edu.smu.ksketch.model.IReferenceFrame;
	import sg.edu.smu.ksketch.model.IReferenceFrameList;
	import sg.edu.smu.ksketch.model.ISpatialKeyframe;
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.model.implementations.KKeyFrame;
	import sg.edu.smu.ksketch.model.implementations.KReferenceFrame;
	import sg.edu.smu.ksketch.model.implementations.KReferenceFrameList;
	import sg.edu.smu.ksketch.model.implementations.KSpatialKeyFrame;
	import sg.edu.smu.ksketch.operation.implementations.KCompositeOperation;
	import sg.edu.smu.ksketch.operation.implementations.KReplaceKeyframeOperation;
	import sg.edu.smu.ksketch.utilities.IIterator;
	import sg.edu.smu.ksketch.utilities.KAppState;
	
	public class KTransformMgr
	{
		public static const TRANSLATION_REF:int = 0;
		public static const ROTATION_REF:int = 2;
		public static const SCALE_REF:int = 1;
		public static const ALL_REF:int = 3;
		public static const NO_REF:int = -1;
		
		private var _object:KObject;
		private var _key:ISpatialKeyframe;
		private var _referenceFrameList:KReferenceFrameList;
		
		private var _currentOperation:KCompositeOperation;
		private var _transitionType:int;
		private var _currentTransformType:int;
		private var _oldKeys:Vector.<KKeyFrame>;
		private var _overWrittenKeys:KReferenceFrame;
		private var _prevFullTransform:Matrix;
		private var _prevLatestTime:Number;
		
		private var _startObjectCenter:Point;
		
		private var _currentTranslate:Point;
		private var _currentAngle:Number;
		private var _inputCenter:Point;
		
		public function KTransformMgr(object:KObject,referenceFrameList:KReferenceFrameList)
		{
			_object = object;
			_referenceFrameList = referenceFrameList;
		}
		
		/**
		 * Operation assumption to add 3 spatial keys to this manager's KObject
		 */
		public function addInitialKeys(time:Number):void
		{
			var center:Point = _object.defaultCenter;
			if(!center)
				center = new Point();
			_addKeyFrame(TRANSLATION_REF, time, center.x,center.y);
			_addKeyFrame(ROTATION_REF, time, center.x,center.y);
			_addKeyFrame(SCALE_REF, time, center.x,center.y);
		}
		
		/**
		 * Sets up the conditions for a translation interaction
		 * The following processes can happen here
		 * 1. Searching for the key frame to work on
		 * 2. Splitting of keys if any
		 * 3. Addition of keys required for the transition into the timeline if needed.
		 */
		public function beginTranslation(time:Number, transitionType:int):void
		{
			//Initialise and prepare the variables required for translation
			_initOperation();
			_transitionType = transitionType;
			
			if(_object is KGroup)
				_prepareKeyframe(TRANSLATION_REF, time, (_object as KGroup).getCentroid(time)); 
			else
				_prepareKeyframe(TRANSLATION_REF, time, _object.defaultCenter);
		}
		
		/**
		 * Updates the current translation interaction
		 * Receives information required to update the translate transform in the working key.
		 */
		public function addToTranslation(translateX:Number, translateY:Number, time:Number, 
										 cursorPoint:Point = null):void//call it setTranslation
		{
			//_updateChildrenPositionMatrix(_object, time);
			
			// Add the translate factor to _key's translation
			// All path points should be in object coordinates 
			// Path points for translation paths starts from 0,0 
			// and should be consistent with the current translation's dxdy.
			_key.addToTranslation(translateX, translateY, time);
			_key.endTime = time;
		}
		//add to real time translate
		//when point added, look forward?
		//on real time update, model structure will be correct up to given time t
		//
		
		/**
		 * Returns the current operation back to the caller.
		 * Processes the interpolation of the current translation if required
		 */
		public function endTranslation(time:Number):IModelOperation
		{
			var lastOverWrittenKey:ISpatialKeyframe = _findLastOverWrittenKey();
			if(lastOverWrittenKey)
				_futureMode(lastOverWrittenKey);
			_key.endTranslation(_transitionType);
			return _endOperation();
		}
		
		public function beginRotation(center:Point, time:Number, transitionType:int):void
		{
			//Find the center of rotation in object coordinates
			var inverse:Matrix = _object.getFullPathMatrix(time);
			inverse.invert();
			var keyCenter:Point = inverse.transformPoint(center);
			_inputCenter = center.clone();
			_initOperation();
			_transitionType = transitionType;
			_prepareKeyframe(ROTATION_REF, time, keyCenter);
		}
		
		public function addToRotation(angle:Number, cursorPoint:Point, 
									  time:Number):void//call it setRotation
		{
			//Find the cursor point in object coordinates
			var currentPoint:Point = cursorPoint.subtract(_inputCenter);
			
			//Add the rotate to _key's rotation path
			//Path points should be in object coordinates 
			_key.addToRotation(currentPoint.x, currentPoint.y, angle, time);
			_key.endTime = time;
		}
		
		public function endRotation(time:Number):IModelOperation
		{
			var lastOverWrittenKey:ISpatialKeyframe = _findLastOverWrittenKey();
			
			if(lastOverWrittenKey)
				_futureMode(lastOverWrittenKey);
			
			_key.endRotation(_transitionType);
			
			return _endOperation();
		}
		
		public function beginScale(center:Point, time:Number, transitionType:int):void
		{
			//Find the center of scale in object coordinates
			var inverse:Matrix = _object.getFullPathMatrix(time);
			inverse.invert();
			var keyCenter:Point = inverse.transformPoint(center);

			_inputCenter = center.clone();
			_initOperation();
			_transitionType = transitionType;
			_prepareKeyframe(SCALE_REF, time, keyCenter);
		}
		
		public function addToScale(scale:Number, cursorPoint:Point, time:Number):void//setScale
		{
			//Find the cursor point in object coordinates
			var currentPoint:Point = cursorPoint.subtract(_inputCenter);
			
			//Add the rotate to _key's rotation path
			//Path points should be in object coordinates 
			//_updateChildrenPositionMatrix(_object, time);
			_key.addToScale(currentPoint.x, currentPoint.y, scale, time);
			_key.endTime = time;
			
		}
		
		public function endScale(time:Number):IModelOperation
		{
			var lastOverWrittenKey:ISpatialKeyframe = _findLastOverWrittenKey();
			
			if(lastOverWrittenKey)
				_futureMode(lastOverWrittenKey);
			
			_key.endScale(_transitionType);

			return _endOperation();
		}
		
		public function getKeyFrame(refFrameNumber:int,time:Number):KSpatialKeyFrame
		{
			var ref:KReferenceFrame = _referenceFrameList.getReferenceFrameAt(
				refFrameNumber) as KReferenceFrame;
			var key:KSpatialKeyFrame = ref.lookUp(time) as KSpatialKeyFrame;
			return key;
		}
		
		/**
		 * Adds a spatial key frame to a specified reference frame at kskTime
		 */
		public function addKeyFrame(refFrameNumber:int,kskTime:Number,centerX:Number,
									centerY:Number,ops:KCompositeOperation):IKeyFrame
		{
			return _addKeyFrame(refFrameNumber,kskTime,centerX,centerY,ops);
		}
		
		//Adds a spatial key frame to a specified reference frame at kskTime
		private function _addKeyFrame(refFrameNumber:int,kskTime:Number,centerX:Number,
									  centerY:Number,ops:KCompositeOperation=null):IKeyFrame
		{
			var ref:KReferenceFrame = _referenceFrameList.getReferenceFrameAt(
				refFrameNumber) as KReferenceFrame;
			var key:ISpatialKeyframe = ref.getAtTime(kskTime) as ISpatialKeyframe;
			
			if(key)
				throw new Error("KTransformMgr - _addKeyFrame: " +
					"A Key already exists at "+kskTime.toString());
			else
				key = ref.createSpatialKey(kskTime,centerX,centerY) as ISpatialKeyframe;
			
			var newKeys:Vector.<IKeyFrame> = new Vector.<IKeyFrame>();
			newKeys.push(key);
			
			var insertOp:IModelOperation = new KReplaceKeyframeOperation(_object,ref,null,newKeys);
			if (ops)
				ops.addOperation(insertOp);
			else if(_currentOperation)
				_currentOperation.addOperation(insertOp);
			
			return ref.insertKey(key);
		}
				
		// Function invoked to prepare for a real time transition
		// Puts in place the _key variable that has the correct properties required for the transition
		// Prepares the reference frame
		private function _prepareKeyframe(transformType:int,time:Number, center:Point):void
		{			
			
			//Perform consistency check on the ref frame, make sure there is a key at created time
			var ref:IReferenceFrame = _referenceFrameList.getReferenceFrameAt(transformType);
			var keyHead:IKeyFrame = ref.earliestKey();
			_currentTransformType = transformType;
			_prevLatestTime = _referenceFrameList.latestTime()
			_prevFullTransform = _object.getFullPathMatrix(_prevLatestTime);
			
			_key = ref.lookUp(time) as ISpatialKeyframe;

			if(_key)
			{
				if(_key.endTime < time)
				{
					_key = _addKeyFrame(transformType, time, center.x, center.y) as ISpatialKeyframe;
				}
				else if(_key.endTime > time)
				{
					if(_key == ref.earliestKey())
					{
						if(_object.createdTime < _key.endTime)
							forceKeyAtTime(_object.createdTime, ref, _currentOperation);
					}
					
					var preSplit:Vector.<IKeyFrame> = new Vector.<IKeyFrame>();
					preSplit.push(_key.clone());
					
					var splitKeys:Vector.<IKeyFrame> = _key.splitKey(time, new KCompositeOperation(),center);
					
					_key = splitKeys[0] as ISpatialKeyframe;
					
					var splitOp:KReplaceKeyframeOperation = new KReplaceKeyframeOperation(
						_object, ref, preSplit, splitKeys);
					_currentOperation.addOperation(splitOp);
				}				
			}
			else
			{
				_key = _addKeyFrame(transformType,time,center.x,center.y) as ISpatialKeyframe;
			}
			
			var futureKey:IKeyFrame = _key.next;
			if(futureKey)
			{
				var removedKeys:Vector.<IKeyFrame> = new Vector.<IKeyFrame>();
				
				_overWrittenKeys = new KReferenceFrame();
				var computeTime:Number = time-KAppState.ANIMATION_INTERVAL;
	
				if(computeTime >= 0)
					_overWrittenKeys.append(_overWrittenKeys.createSpatialKey(
						computeTime, _key.center.x, _key.center.y));

				var nextFuture:IKeyFrame;
				
				while(futureKey)
				{
					_overWrittenKeys.append(futureKey.clone());
					nextFuture = futureKey.next;
					removedKeys.push(ref.remove(futureKey));
					futureKey = nextFuture;
				}
				
				var removeFutureOp:KReplaceKeyframeOperation = new KReplaceKeyframeOperation(_object, ref, removedKeys, null);
				_currentOperation.addOperation(removeFutureOp);
			}
			
			if(_transitionType == KAppState.TRANSITION_REALTIME)
			{
				//Add a key after the given time, This will be the key frame that is used for
				//Storing the data of the upcoming transition for real time transitions
				var rtTime:Number = KAppState.nextKey(time);
				_key =  _addKeyFrame(transformType,rtTime,center.x,center.y) as ISpatialKeyframe;
			}
			else
			{
				if(transformType != TRANSLATION_REF)
				{
					var oldCenterKey:Vector.<IKeyFrame> = new Vector.<IKeyFrame>();
					oldCenterKey.push(_key.clone());
					var newCenterKey:Vector.<IKeyFrame> = new Vector.<IKeyFrame>();
					newCenterKey.push(_key);
					var changeCenterOp:KReplaceKeyframeOperation = new KReplaceKeyframeOperation(
						_object, ref, oldCenterKey, newCenterKey);
					_currentOperation.addOperation(changeCenterOp);
					updateCenter(_key,center, time, _currentOperation);
				}
			}

			(_key as ISpatialKeyframe).beginTransform();
		}
		
		// Initiates an operation for transition
		private function _initOperation():void
		{
			_oldKeys = new Vector.<KKeyFrame>();
			_currentOperation = new KCompositeOperation();
		}
		
		// Performs operation updating when the transition ends
		private function _endOperation():IModelOperation
		{	
			if(true)
				_key.resampleMotion();
			
			_currentOperation.addOperation(_key.getTransformOperation());
			_overWrittenKeys = null;
			return _currentOperation;
		}
		
		private function _futureMode(lastOverWrittenKey:ISpatialKeyframe):void
		{
			if(_transitionType == KAppState.TRANSITION_REALTIME && KAppState.erase_real_time_future)
				return;
			
			var snapToActivity:Boolean = true;
			
			if(snapToActivity)
				_snapToActivityKey();
			
			if(lastOverWrittenKey.startTime() < _key.endTime && _key.endTime <= lastOverWrittenKey.startTime())
			{
				lastOverWrittenKey.splitKey(_key.endTime, _currentOperation,lastOverWrittenKey.center);	
			}
			
			var ref:KReferenceFrame = _referenceFrameList.getReferenceFrameAt(
				_currentTransformType) as KReferenceFrame;
			ref.append(lastOverWrittenKey);
			
			var addedFutureKey:IKeyFrame = lastOverWrittenKey;
			var addedFutureKeys:Vector.<IKeyFrame> = new Vector.<IKeyFrame>();
			while(addedFutureKey)
			{
				addedFutureKeys.push(addedFutureKey);
				addedFutureKey = addedFutureKey.next;
			}

			var appendFutureOp:KReplaceKeyframeOperation = new KReplaceKeyframeOperation(_object, ref,null, addedFutureKeys);
			_currentOperation.addOperation(appendFutureOp);
			
			var compensation:Matrix = new Matrix();
			var currentFullTransform:Matrix = _object.getFullPathMatrix(_prevLatestTime);
			var interpreter:Shape = new Shape();
			currentFullTransform.invert();
			currentFullTransform.concat(_prevFullTransform);
			interpreter.transform.matrix = currentFullTransform;
			var compensateRotate:Number = interpreter.rotation;
			var compensateScale:Number = interpreter.scaleX;
			var addedKeys:Vector.<IKeyFrame> = new Vector.<IKeyFrame>();
			var myKey:IKeyFrame = lastOverWrittenKey as IKeyFrame;
			
			var startInterpolateTime:Number = lastOverWrittenKey.startTime();
			var endInterpolateTime:Number = lastOverWrittenKey.endTime;
			var epsilon:Number = 0;
			
			//Compensate is in degrees
			if(Math.abs(compensateRotate) > epsilon)
			{
				var rotateRef:IReferenceFrame = _referenceFrameList.getReferenceFrameAt(ROTATION_REF);
				forceKeyAtTime(startInterpolateTime, rotateRef,_currentOperation);
				forceKeyAtTime(endInterpolateTime, rotateRef,_currentOperation);
				_interpolateRotateOverTime(compensateRotate, startInterpolateTime, endInterpolateTime, rotateRef);
			}

			if((Math.abs(compensateScale)-1) > epsilon)
			{
				var scaleRef:IReferenceFrame = _referenceFrameList.getReferenceFrameAt(SCALE_REF);
				forceKeyAtTime(startInterpolateTime, scaleRef,_currentOperation);
				forceKeyAtTime(endInterpolateTime, scaleRef,_currentOperation);
				_interpolateScaleOverTime(compensateScale, startInterpolateTime, endInterpolateTime, scaleRef);
			}
			
			currentFullTransform = _object.getFullPathMatrix(_prevLatestTime);
			var oldPosition:Point = _prevFullTransform.transformPoint(_object.defaultCenter);
			var newPosition:Point = currentFullTransform.transformPoint(_object.defaultCenter);
			var positionCompensation:Point = oldPosition.subtract(newPosition);
			var compensateX:Number = positionCompensation.x;
			var compensateY:Number = positionCompensation.y;
			
			if(Math.abs(compensateX) > epsilon || Math.abs(compensateY) > epsilon)
			{
				var transRef:IReferenceFrame = _referenceFrameList.getReferenceFrameAt(TRANSLATION_REF);
				forceKeyAtTime(startInterpolateTime, transRef,_currentOperation);
				forceKeyAtTime(endInterpolateTime, transRef,_currentOperation);
				_interpolateTranslateOverTime(compensateX, compensateY, startInterpolateTime, endInterpolateTime, transRef);
			}
			
			_prevFullTransform = new Matrix();			
		}

		private function _snapToActivityKey():void
		{
			var activityKeyBefore:IKeyFrame = _object.getActivityKeyBeforeAt(_key.endTime);
			var keySnapThreshold:Number = 250;
			
			if(activityKeyBefore)
			{
				if(activityKeyBefore.endTime != _object.createdTime)
				{
					var timeDifference:Number = _key.endTime - activityKeyBefore.endTime;
					
					if(0 < timeDifference)
						if(timeDifference < keySnapThreshold)
							_key.endTime = activityKeyBefore.endTime;
				}
			}
		}
		
		public function updateCenter(targetKey:ISpatialKeyframe, newCenter:Point, time:Number, op:KCompositeOperation):ISpatialKeyframe
		{
			//target key is key. so the center to be updated is actually 
			
			var oldCenter:Point = targetKey.center;

			if(Math.abs(newCenter.x-oldCenter.x) > 0.05 || Math.abs(newCenter.y - oldCenter.y) > 0.05)
			{
				//Instantiate vectors for operation object
				var prevCenter:Point = oldCenter;
				var prevMatrix:Matrix = _object.getFullMatrix(time);
				targetKey.center = newCenter.clone();
				var currentMatrix:Matrix = _object.getFullMatrix(time);
				prevMatrix.invert();
				prevMatrix.concat(currentMatrix);
				
				//Add an interpolated translation over the key's time range
				var transRef:IReferenceFrame = _referenceFrameList.getReferenceFrameAt(TRANSLATION_REF);
				var transKey:ISpatialKeyframe = transRef.getAtOrAfter(time) as ISpatialKeyframe;
				if(!transKey)
					transKey = transRef.getAtOrBeforeTime(time) as ISpatialKeyframe;
				
				if(transKey.endTime != time)
				{
					if(time < transKey.endTime)
						transKey = transKey.splitKey(time,op)[0] as ISpatialKeyframe;
					else
					{
						transKey = new KSpatialKeyFrame(time,_object.defaultCenter) as ISpatialKeyframe;
						transRef.append(transKey);
						
						var newKeys:Vector.<IKeyFrame> = new Vector.<IKeyFrame>();
						newKeys.push(transKey);
						
						var insertOp:IModelOperation = new KReplaceKeyframeOperation(_object,transRef,null,newKeys);
						(insertOp as KReplaceKeyframeOperation).actionType = "update center";
						op.addOperation(insertOp);
					}
				}
				
				//Current Interpolation only interpolates the last key frame in the range,
				//Not all translation keys in the time range.
				transKey.interpolateTranslate(-prevMatrix.tx, -prevMatrix.ty, op);
			}
			
			return targetKey;
		}
		
		public function forceKeyAtTime(time:Number, refFrame:IReferenceFrame, operation:KCompositeOperation):void
		{
			var prepareOp:KCompositeOperation = new KCompositeOperation();
			var targetKey:ISpatialKeyframe = refFrame.getAtOrAfter(time) as ISpatialKeyframe;
			var newKey:ISpatialKeyframe;
			var keyBefore:ISpatialKeyframe;
			var insertOp:IModelOperation;
			
			if(targetKey)
			{
				if(time < refFrame.earliestKey().endTime)
				{
					var objectCenter:Point = _object.defaultCenter;
					var newHeader:ISpatialKeyframe = refFrame.createSpatialKey(time, objectCenter.x, objectCenter.y);
					refFrame.insertKey(newHeader);
					
					var newHeaderKey:Vector.<IKeyFrame> = new Vector.<IKeyFrame>();
					newHeaderKey.push(targetKey);
					targetKey.dirtyKey();
					insertOp = new KReplaceKeyframeOperation(_object,refFrame,null,newHeaderKey);
				}
				else if(time < targetKey.endTime)
				{
					var preSplit:Vector.<IKeyFrame> = new Vector.<IKeyFrame>();
					preSplit.push(targetKey.clone());
					var postSplit:Vector.<IKeyFrame> = targetKey.splitKey(time, prepareOp);
					insertOp = new KReplaceKeyframeOperation(_object,refFrame,preSplit,postSplit);
				}
				//else case there is an active key at time, no need to do anything
			}
			else
			{
				//case there are no keys after at or after the start time.
				keyBefore = refFrame.getAtOrBeforeTime(time) as ISpatialKeyframe;
				targetKey = refFrame.createSpatialKey(time,keyBefore.center.x, keyBefore.center.y);
				refFrame.insertKey(targetKey);
				var addedKeys:Vector.<IKeyFrame> = new Vector.<IKeyFrame>();
				addedKeys.push(targetKey);
				targetKey.dirtyKey();
				insertOp = new KReplaceKeyframeOperation(_object,refFrame,null,addedKeys);
			}
			
			if(insertOp)
				operation.addOperation(insertOp);
		}
		
		private function _interpolateTranslateOverTime(dx:Number, dy:Number, startTime:Number, endTime:Number, refFrame:IReferenceFrame):void
		{
			var targetKey:ISpatialKeyframe = refFrame.getAtTime(startTime) as ISpatialKeyframe;
			targetKey = targetKey.next as ISpatialKeyframe;
			
			var currentProportion:Number;
			var keyX:Number;
			var keyY:Number;
			var clearedX:Number = 0;
			var clearedY:Number = 0;

			while(targetKey)
			{
				if(endTime < targetKey.endTime)
					break;
				
				currentProportion = (targetKey.endTime-startTime)/(endTime-startTime);
				keyX = (currentProportion * dx) - clearedX;
				keyY = (currentProportion * dy) - clearedY;
				clearedX = (currentProportion * dx);
				clearedY = (currentProportion * dy);
				
				targetKey.interpolateTranslate(keyX,keyY,_currentOperation);
				
				targetKey = targetKey.next as ISpatialKeyframe;
			}
		}
		
		private function _interpolateRotateOverTime(dTheta:Number, startTime:Number, endTime:Number, refFrame:IReferenceFrame):void
		{
			var targetKey:ISpatialKeyframe = refFrame.getAtTime(startTime) as ISpatialKeyframe;
			targetKey = targetKey.next as ISpatialKeyframe;
			
			dTheta = dTheta/180*Math.PI;
		
			var currentProportion:Number;
			var keyTheta:Number;
			var clearedTheta:Number = 0;
			while(targetKey)
			{
				if(endTime < targetKey.endTime)
					break;
				
				currentProportion = (targetKey.endTime-startTime)/(endTime-startTime);
				keyTheta = (currentProportion * dTheta) - clearedTheta;
		
				clearedTheta = (currentProportion * dTheta);
				
				targetKey.interpolateRotate(keyTheta,_currentOperation);
				
				targetKey = targetKey.next as ISpatialKeyframe;
			}
		}
		
		private function _interpolateScaleOverTime(dScale:Number, startTime:Number, endTime:Number, refFrame:IReferenceFrame):void
		{
			var targetKey:ISpatialKeyframe = refFrame.getAtTime(startTime) as ISpatialKeyframe;
			targetKey = targetKey.next as ISpatialKeyframe;
			
			var currentProportion:Number;
			var keyScale:Number;
			var clearedScale:Number = 0;
			
			while(targetKey)
			{
				if(endTime < targetKey.endTime)
					break;
				
				currentProportion = (targetKey.endTime-startTime)/(endTime-startTime);
				keyScale = (currentProportion * dScale) - clearedScale;
				clearedScale = (currentProportion * dScale);
				
				targetKey.interpolateScale(keyScale,_currentOperation);
				
				targetKey = targetKey.next as ISpatialKeyframe;
			}
		}
		
		private function _findLastOverWrittenKey():ISpatialKeyframe
		{
			if(_overWrittenKeys)
			{
				var lastOverWrittenKey:ISpatialKeyframe = _overWrittenKeys.getAtOrAfter(_key.endTime) as ISpatialKeyframe;
				
				if(lastOverWrittenKey)
				{
					if(lastOverWrittenKey.endTime == _key.endTime)
						return lastOverWrittenKey.next as ISpatialKeyframe;
					else
						return lastOverWrittenKey;
				}
			}
			
			return null;
		}
		
		public function clearTransforms():IModelOperation
		{
			var returnOp:KCompositeOperation = new KCompositeOperation();
			var earliestTime:Number = Number.MAX_VALUE;
			var ref:IReferenceFrame = _referenceFrameList.getReferenceFrameAt(0);
			
			while(ref)
			{
				if(ref.earliestKey().endTime < earliestTime)
					earliestTime = ref.earliestKey().endTime;
				
				var clearedKeys:Vector.<IKeyFrame> = ref.removeAllAfter(ref.earliestKey().endTime-1);
				var clearKeyOp:KReplaceKeyframeOperation = new KReplaceKeyframeOperation(_object, ref, clearedKeys, null);
				returnOp.addOperation(clearKeyOp);
				
				ref = ref.next;
			}
			
			ref = _referenceFrameList.getReferenceFrameAt(0);
			
			while(ref)
			{
				var newHeadVector:Vector.<IKeyFrame> = new Vector.<IKeyFrame>();
				var newHeader:ISpatialKeyframe = ref.createSpatialKey(earliestTime, _object.defaultCenter.x, _object.defaultCenter.y);
				ref.insertKey(newHeader);
				newHeadVector.push(newHeader);
				var addHeaderOp:KReplaceKeyframeOperation = new KReplaceKeyframeOperation(_object, ref, null, newHeadVector);
				returnOp.addOperation(addHeaderOp);
				
				ref = ref.next;
			}
			
			if(returnOp.length > 0)
				return returnOp;
			else
				return null;
		}
	}
}