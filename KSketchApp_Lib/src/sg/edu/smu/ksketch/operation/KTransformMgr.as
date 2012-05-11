/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.operation
{
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch.model.IKeyFrame;
	import sg.edu.smu.ksketch.model.IParentKeyFrame;
	import sg.edu.smu.ksketch.model.IReferenceFrame;
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
			addKeyFrame(TRANSLATION_REF, time, center.x,center.y);
			addKeyFrame(ROTATION_REF, time, center.x,center.y);
			addKeyFrame(SCALE_REF, time, center.x,center.y);
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
			_initOperation(_object.defaultCenter, _transitionType);
			_prepareKeyframe(TRANSLATION_REF, time, _object.defaultCenter); 
			_key.center = _object.defaultCenter;
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
			_initOperation(center,transitionType);
			_prepareKeyframe(ROTATION_REF, time, keyCenter);
			_updateCenter(_key, keyCenter,time);
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
			_initOperation(center, transitionType);
			_prepareKeyframe(SCALE_REF, time, keyCenter);
			
			_updateCenter(_key,keyCenter,time);
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
		
		/**
		 * Adds a spatial key frame to a specified reference frame at kskTime
		 */
		//Adds a spatial key frame to a specified reference frame at kskTime
		public function addKeyFrame(refFrameNumber:int,kskTime:Number,centerX:Number,
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
			_currentTransformType = transformType;
			_prevLatestTime = _referenceFrameList.latestTime()
			_prevFullTransform = _object.getFullPathMatrix(_prevLatestTime);
			
			//Check if there is a key present at created time
			var keyHead:IKeyFrame = ref.getAtTime(_object.createdTime);
			if(!keyHead)
				addKeyFrame(transformType, _object.createdTime, 
					_object.defaultCenter.x, _object.defaultCenter.y) as ISpatialKeyframe;
			
			//Look up at the keyframe at time first
			_key = ref.lookUp(time) as ISpatialKeyframe;
			if(_key)
			{
				//If a key is found, we need to prepare it for the upcoming transition
				//First we determine if _key is before or after given time
				if(_key.endTime < time)
				{
					//This case only happens if the last key in the reference frame is
					//before the given time. We can safely perform an append operation from now onwards.
					//First, we need a key at the given time first.
					//This key will represent the start time of _key, required for the transition.
					_key = addKeyFrame(transformType, time, center.x, center.y) as ISpatialKeyframe;
				}
				else
				{
					//A few things to do here
					if(time < _key.endTime)
					{
						// Split the existing key into 2 pieces. The first piece must end at the 
						// given time while the second piece ends at the original keys' end time.
						// Need an operation for split keys step.
						var oldKeys:Vector.<IKeyFrame> = new Vector.<IKeyFrame>();
						oldKeys.push(_key);
						
						var splitKeys:Vector.<IKeyFrame> = _key.splitKey(time,_currentOperation,center);
						
						_key = splitKeys[0] as ISpatialKeyframe;
						
						var splitOp:KReplaceKeyframeOperation = new KReplaceKeyframeOperation(
							_object, ref, oldKeys, splitKeys);
						_currentOperation.addOperation(splitOp);
					}
					
					//Remove the future of the reference frame in use.
					var removedKeys:Vector.<IKeyFrame> =  ref.removeAllAfter(time);
					
					if(removedKeys.length > 0)
					{
						var replaceKeyOp:KReplaceKeyframeOperation = new KReplaceKeyframeOperation(
							_object, ref, removedKeys, null);
						_currentOperation.addOperation(replaceKeyOp);
						
						//Create a new reference frame.
						//This new reference frames will be used during future correction at the end of the transform
						_overWrittenKeys = new KReferenceFrame();
						var computeTime:Number = time-KAppState.ANIMATION_INTERVAL;
	
						if(computeTime >= 0)
							_overWrittenKeys.append(_overWrittenKeys.createSpatialKey(
								computeTime, _key.center.x, _key.center.y));
						
						var currentRemovedKey:IKeyFrame;
						
						for(var i:int = 0; i< removedKeys.length; i++)
						{
							currentRemovedKey = removedKeys[i].clone();
							_overWrittenKeys.append(currentRemovedKey);
						}
					}				
				}
			}
			else
			{
				//There are no keys in the reference frame, create one and put it in.
				_key = addKeyFrame(transformType,time,center.x,center.y) as ISpatialKeyframe;
				_key.endTime = time;			
			}

			if(_transitionType == KAppState.TRANSITION_REALTIME)
			{
				//Add a key after the given time, This will be the key frame that is used for
				//Storing the data of the upcoming transition for real time transitions
				var T1:Number = KAppState.nextKey(time);
				_key =  addKeyFrame(transformType,T1,center.x,center.y) as ISpatialKeyframe;
			}
			
			(_key as ISpatialKeyframe).beginTransform();
		}
		
		// Initiates an operation for transition
		private function _initOperation(center:Point, transitionType:int):void
		{
			_oldKeys = new Vector.<KKeyFrame>();
			_currentOperation = new KCompositeOperation();
			_inputCenter = center.clone();
			_transitionType = transitionType;
		}
		
		// Performs operation updating when the transition ends
		private function _endOperation():IModelOperation
		{	
			_currentOperation.addOperation(_key.getTransformOperation());
			_overWrittenKeys = null;
			return _currentOperation;
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
		
		private function _futureMode(lastOverWrittenKey:ISpatialKeyframe):void
		{
			//Snap the active transform key to the closest activity key
			//held by the object
			_snapToActivityKey();
			
			//Find portion of the overwritten keys to be corrected
			if(_key.endTime != lastOverWrittenKey.startTime() || _key.endTime != lastOverWrittenKey.endTime)
				lastOverWrittenKey.splitKey(_key.endTime, new KCompositeOperation(),lastOverWrittenKey.center);	
			
			var ref:KReferenceFrame = _referenceFrameList.getReferenceFrameAt(_currentTransformType) as KReferenceFrame;
			ref.append(lastOverWrittenKey);
			var interpreter:Shape = _computeCompensation();
			
			//Set up the undo for the keys there have been appended to the reference frame
			var addedKeys:Vector.<IKeyFrame> = new Vector.<IKeyFrame>();
			var myKey:IKeyFrame = lastOverWrittenKey as IKeyFrame;
			
			while(myKey)
			{
				addedKeys.push(myKey);
				myKey = myKey.next;
			}
			
			_currentOperation.addOperation(new KReplaceKeyframeOperation(_object, ref,null,addedKeys));
			
			var startInterpolateTime:Number = lastOverWrittenKey.startTime();
			var endInterpolateTime:Number = lastOverWrittenKey.endTime;
			var epsilon:Number = 0.5;
			
			//Correct the object if the changes exceed a small number
			if(Math.abs(interpreter.x) > epsilon || Math.abs(interpreter.y) > epsilon)
			{
				var transRef:IReferenceFrame = _referenceFrameList.getReferenceFrameAt(TRANSLATION_REF);
				_forceKeyAtTime(startInterpolateTime, transRef);
				_forceKeyAtTime(endInterpolateTime, transRef);
				_interpolateTranslateOverTime(interpreter.x, interpreter.y, startInterpolateTime, endInterpolateTime, transRef);
			}
			
			//Rotation compensation is in degrees. Will get converted to radians inside the processing methods
			if(Math.abs(interpreter.rotation) > epsilon)
			{
				var rotateRef:IReferenceFrame = _referenceFrameList.getReferenceFrameAt(ROTATION_REF);
				_forceKeyAtTime(startInterpolateTime, rotateRef);
				_forceKeyAtTime(endInterpolateTime, rotateRef);
				_interpolateRotateOverTime(interpreter.rotation, startInterpolateTime, endInterpolateTime, rotateRef);
			}
			
			if(Math.abs(interpreter.scaleX) > (epsilon/50))
			{
				var scaleRef:IReferenceFrame = _referenceFrameList.getReferenceFrameAt(SCALE_REF);
				_forceKeyAtTime(startInterpolateTime, scaleRef);
				_forceKeyAtTime(endInterpolateTime, scaleRef);
				_interpolateScaleOverTime(interpreter.scaleX, startInterpolateTime, endInterpolateTime, scaleRef);
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
		
		private function _computeCompensation():Shape
		{
			var currentFullTransform:Matrix = _object.getFullPathMatrix(_prevLatestTime);
			var oldPosition:Point = _prevFullTransform.transformPoint(_object.defaultCenter);
			var newPosition:Point = currentFullTransform.transformPoint(_object.defaultCenter);
			var positionCompensation:Point = oldPosition.subtract(newPosition);
			
			currentFullTransform.invert();
			currentFullTransform.concat(_prevFullTransform);
			
			var interpreter:Shape = new Shape();
			interpreter.transform.matrix = currentFullTransform;
			
			interpreter.x = positionCompensation.x;
			interpreter.y = positionCompensation.y;
			
			return interpreter;
		}
		
		private function _updateCenter(targetKey:ISpatialKeyframe, newCenter:Point, time:Number):void
		{
			var oldCenter:Point = targetKey.center;
	
			if(Math.abs(newCenter.x-oldCenter.x) > 0.05 || Math.abs(newCenter.y - oldCenter.y) > 0.05)
			{
				var prevMatrix:Matrix = _object.getFullMatrix(time);
				targetKey.center = newCenter.clone();
				var currentMatrix:Matrix = _object.getFullMatrix(time);
				currentMatrix.invert();
				currentMatrix.concat(prevMatrix);
				
				var transRef:IReferenceFrame = _referenceFrameList.getReferenceFrameAt(TRANSLATION_REF);
				_forceKeyAtTime(targetKey.startTime(), transRef);
				_forceKeyAtTime(targetKey.endTime, transRef);
				_interpolateTranslateOverTime(-prevMatrix.tx, -prevMatrix.ty, targetKey.startTime(), targetKey.endTime, transRef);
			}
		}
		
		private function _forceKeyAtTime(time:Number, refFrame:IReferenceFrame):void
		{
			var prepareOp:KCompositeOperation = new KCompositeOperation();
			var targetKey:ISpatialKeyframe = refFrame.getAtOrAfter(time) as ISpatialKeyframe;
			var newKey:ISpatialKeyframe;
			var keyBefore:ISpatialKeyframe;
			var addedKeys:Vector.<IKeyFrame> = new Vector.<IKeyFrame>();
			var insertOp:IModelOperation;
			
			if(targetKey)
			{
				//Case there is an active key with end time later than start time
				if(time < targetKey.endTime)
				{
					var postSplit:Vector.<IKeyFrame> = targetKey.splitKey(time, prepareOp);
					targetKey = postSplit[0] as ISpatialKeyframe;
					addedKeys.push(targetKey);
					insertOp = new KReplaceKeyframeOperation(_object,refFrame,null,addedKeys);
				}
				//else case there is an active key at time, no need to do anything
			}
			else
			{
				//case there are no keys after at or after the start time.
				keyBefore = refFrame.getAtOrBeforeTime(time) as ISpatialKeyframe;
				targetKey = refFrame.createSpatialKey(time,keyBefore.center.x, keyBefore.center.y);
				refFrame.insertKey(targetKey);
				addedKeys.push(targetKey);
				insertOp = new KReplaceKeyframeOperation(_object,refFrame,null,addedKeys);
			}
			
			if(insertOp)
				_currentOperation.addOperation(insertOp);
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
		
		/*
		private function _updateChildrenPositionMatrix(targetObject:KObject, time:Number):void
		{
			if(!(targetObject is KGroup))
				return;
			
			var it:IIterator = (targetObject as KGroup).directChildIterator(time);
			
			while(it.hasNext())
			{
				var currentObject:KObject = it.next();
				var currentParentKey:IParentKeyFrame = currentObject.getParentKeyAtOrBefore(time);
				var nextParentKey:IParentKeyFrame = currentObject.getParentKeyAtOrBefore(
					time+KAppState.ANIMATION_INTERVAL);
				
				if(currentParentKey.parent.id != nextParentKey.parent.id)
				{
					var previousPositionMatrix:Matrix = nextParentKey.positionMatrix;
					nextParentKey.positionMatrix = new Matrix();
					var matrices:Vector.<Matrix> = KGroupUtil.getParentChangeMatrices(
						currentObject, nextParentKey.parent, time, true);
					nextParentKey.positionMatrix = KGroupUtil.computePositionMatrix(
						matrices[0],matrices[1],matrices[2],matrices[3], currentObject.id);
					
					//_correctObjectFuture(currentObject,nextParentKey.endTime,
					//previousPositionMatrix, nextParentKey.positionMatrix);
					_updateFuturePositionMatrices(nextParentKey.parent, nextParentKey.endTime);
					
					if(currentObject is KGroup)
						(currentObject as KGroup).updateCenter();
				}
			}
		}
		
		private function _updateFuturePositionMatrices(targetObject:KObject, time:Number):void
		{
			if(!(targetObject is KGroup))
				return;
			
			var it:IIterator = (targetObject as KGroup).directChildIterator(time);
			
			while(it.hasNext())
			{
				var currentObject:KObject = it.next();
				
				var nextParentKey:IParentKeyFrame = currentObject.getParentKeyAtOrAfter(
					time+KAppState.ANIMATION_INTERVAL);
				
				if(nextParentKey)
				{
					var previousPositionMatrix:Matrix = nextParentKey.positionMatrix;
					nextParentKey.positionMatrix = new Matrix();
					var matrices:Vector.<Matrix> = KGroupUtil.getParentChangeMatrices(
						currentObject, nextParentKey.parent, nextParentKey.endTime, true);
					nextParentKey.positionMatrix = KGroupUtil.computePositionMatrix(
						matrices[0],matrices[1],matrices[2],matrices[3], currentObject.id);
					//_correctObjectFuture(currentObject,nextParentKey.endTime,
					//previousPositionMatrix, nextParentKey.positionMatrix);
					_updateFuturePositionMatrices(nextParentKey.parent, nextParentKey.endTime);
					
					if(currentObject is KGroup)
						(currentObject as KGroup).updateCenter();
				}
			}
		}*/
	}
}