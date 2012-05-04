/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.operation
{
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
	
	//Prepare to turn this thing into an ioperableinterface class.
	/*
	IOperable class
		beginOperation();
		endOperation();
	
	The class should just have to think about what changes to make and when.
	The demoArbiter sould be able to think like the tranform mgr but does grouping predictions instead?
	*/
	public class KTransformMgr
	{
		public static const TRANSLATION_REF:int = 0;
		public static const ROTATION_REF:int = 2;
		public static const SCALE_REF:int = 1;
		
		public static const REALTIME:int = 0;
		public static const INTERPOLATED:int = 1;
		public static const INSTANT:int = 2;
		
		private var _object:KObject;
		private var _key:ISpatialKeyframe;
		private var _referenceFrameList:KReferenceFrameList;
		
		private var _currentOperation:KCompositeOperation;
		private var _transitionType:int;
		private var _currentTransformType:int;
		private var _oldKeys:Vector.<KKeyFrame>;
		private var _overWrittenKeys:KReferenceFrame;
		
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
		public function beginTranslation(time:Number, transitionType:String):void
		{
			//Initialise and prepare the variables required for translation
			var startMatrix:Matrix = _object.getFullPathMatrix(time);
			var startPoint:Point = startMatrix.transformPoint(_object.defaultCenter).clone();
			
			_initOperation();
			_initTransitionTypes(transitionType);
			
			//start point of a translate is the object's center
			_prepareKeyframe(TRANSLATION_REF, time, startPoint); 
			
			_key.center = startPoint;
		}
		
		/**
		 * Updates the current translation interaction
		 * Receives information required to update the translate transform in the working key.
		 */
		public function addToTranslation(translateX:Number, translateY:Number, time:Number, 
										 cursorPoint:Point = null):void//call it setTranslation
		{
			_updateChildrenPositionMatrix(_object, time);
			
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
			if(_overWrittenKeys)
				_futureMode();
	
			if(_object is KGroup)
				_updateFuturePositionMatrices(_object, time);
			
			_key.endTranslation(_transitionType);
			
			
			return _endOperation();
		}
		
		public function beginRotation(center:Point, time:Number, transitionType:String):void
		{
			//Initialise and prepare the variables required for translation
			var startMatrix:Matrix = _object.getFullPathMatrix(time);
			startMatrix.invert();
			
			//The center for a rotation should be in object coordinates
			var keyCenter:Point = startMatrix.transformPoint(center);
			
			_inputCenter = center.clone();
			_initOperation();
			_initTransitionTypes(transitionType);
			_prepareKeyframe(ROTATION_REF, time, keyCenter);
			_key.center = keyCenter.clone();
		}
		
		public function addToRotation(angle:Number, cursorPoint:Point, 
									  time:Number):void//call it setRotation
		{
			//Find the cursor point in object coordinates
			var currentPoint:Point = cursorPoint.subtract(_inputCenter);
			
			//Add the rotate to _key's rotation path
			//Path points should be in object coordinates 
			_updateChildrenPositionMatrix(_object, time);
			_key.addToRotation(currentPoint.x, currentPoint.y, angle, time);
			_key.endTime = time;
		}
		
		public function endRotation(time:Number):IModelOperation
		{
			if(_object is KGroup)
				_updateFuturePositionMatrices(_object, time);
			_key.endRotation(_transitionType);
			return _endOperation();
		}
		
		public function beginScale(center:Point, time:Number, transitionType:String):void
		{
			// Initialise and prepare the variables required for translation
			var startMatrix:Matrix = _object.getFullPathMatrix(time);
			var transformedCenter:Point = startMatrix.transformPoint(_object.defaultCenter);
			var myOffset:Point = center.subtract(transformedCenter);
			
			// Normalise the center offset because scale matrix 
			// computation are still reliant on previous scales
			var scaleRef:IReferenceFrame = _referenceFrameList.getReferenceFrameAt(SCALE_REF);
			var scaleMatrix:Matrix = scaleRef.getMatrix(time);
			scaleMatrix.translate(-scaleMatrix.tx, -scaleMatrix.ty)
			scaleMatrix.invert();
			myOffset = scaleMatrix.transformPoint(myOffset);
			
			// The center for a rotation should be in object coordinates
			var keyCenter:Point = _object.defaultCenter.add(myOffset);
			
			_inputCenter = center.clone();
			_initOperation();
			_initTransitionTypes(transitionType);
			_prepareKeyframe(SCALE_REF, time, keyCenter);
			_key.center = keyCenter.clone();	
		}
		
		public function addToScale(scale:Number, cursorPoint:Point, time:Number):void//setScale
		{
			//Find the cursor point in object coordinates
			var currentPoint:Point = cursorPoint.subtract(_inputCenter);
			
			//Add the rotate to _key's rotation path
			//Path points should be in object coordinates 
			_updateChildrenPositionMatrix(_object, time);
			_key.addToScale(currentPoint.x, currentPoint.y, scale, time);
			_key.endTime = time;
			
		}
		
		public function endScale(time:Number):IModelOperation
		{
			if(_object is KGroup)
				_updateFuturePositionMatrices(_object, time);
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
				
		// Transforms a point based on the inverse of the given matrix
		private function _invert(m:Matrix,p:Point):Point
		{
			var invert:Matrix = m.clone();
			invert.invert();
			return invert.transformPoint(p);
		}
		
		// Function invoked to prepare for a real time transition
		// Puts in place the _key variable that has the correct properties required for the transition
		// Prepares the reference frame
		private function _prepareKeyframe(transformType:int,time:Number, center:Point):void
		{			
			//Perform consistency check on the ref frame, make sure there is a key at created time
			var ref:IReferenceFrame = _referenceFrameList.getReferenceFrameAt(transformType);
			var keyHead:IKeyFrame = ref.getAtTime(_object.createdTime);
			_currentTransformType = transformType;
			
			if(!keyHead)
				_addKeyFrame(transformType, _object.createdTime, 
					_object.defaultCenter.x, _object.defaultCenter.y) as ISpatialKeyframe;
			
			//Look up at the keyframe at time first
			_key = getKeyFrame(transformType, time);
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
					_key = _addKeyFrame(transformType, time, center.x, center.y) as ISpatialKeyframe;
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
						
						//Visualise the timeline
						// if interpolation/instant, we are looking at modifying the front key
						// if real time, we are looking at preserving the front key
						if(_transitionType != REALTIME)
							_key.center = center;
	
						var splitOp:KReplaceKeyframeOperation = new KReplaceKeyframeOperation(
							_object, ref, oldKeys, splitKeys);
						_currentOperation.addOperation(splitOp);
					}
					
					//Remove the future for demonstrated transitions
					//Need an operation for removed frames here
					//Should keep the 
					var removedKeys:Vector.<IKeyFrame> =  ref.removeAllAfter(time);
					
					if(removedKeys.length > 0)
					{
						var replaceKeyOp:KReplaceKeyframeOperation = new KReplaceKeyframeOperation(
							_object, ref, removedKeys, null);
						_currentOperation.addOperation(replaceKeyOp);
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
				_key = _addKeyFrame(transformType,time,center.x,center.y) as ISpatialKeyframe;
				_key.endTime = time;			
			}
			
			if(_transitionType == REALTIME)
			{
				//Add a key after the given time, This will be the key frame that is used for
				//Storing the data of the upcoming transition for real time transitions
				var T1:Number = KAppState.nextKey(time);
				_key =  _addKeyFrame(transformType,T1,center.x,center.y) as ISpatialKeyframe;
			}
			
			(_key as ISpatialKeyframe).beginTransform();
		}
		
		// Initiates an operation for transition
		private function _initOperation():void
		{
			_oldKeys = new Vector.<KKeyFrame>();
			_currentOperation = new KCompositeOperation();
		}
		
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
					
					_correctObjectFuture(currentObject,nextParentKey.endTime,
						previousPositionMatrix, nextParentKey.positionMatrix);
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
					_correctObjectFuture(currentObject,nextParentKey.endTime,
						previousPositionMatrix, nextParentKey.positionMatrix);
					_updateFuturePositionMatrices(nextParentKey.parent, nextParentKey.endTime);
					
					if(currentObject is KGroup)
						(currentObject as KGroup).updateCenter();
				}
			}
		}
		
		//Only called when the position matrix of the object at positionMatrixTime is changed
		private function _correctObjectFuture(targetObject:KObject, positionMatrixTime:Number, 
											  prevPositionMatrix:Matrix, currentPositionMatrix:Matrix):void
		{
			/*prevPositionMatrix.invert();
			currentPositionMatrix.concat(prevPositionMatrix);
			var myShape:Shape = new Shape();
			myShape.transform.matrix = currentPositionMatrix;
			
			var dx:Number = myShape.x;
			var dy:Number = myShape.y;
			var theta:Number = myShape.rotation;
			var sigma:Number = myShape.scaleX;*/
		}
		
		// Performs operation updating when the transition ends
		private function _endOperation():IModelOperation
		{	
			_currentOperation.addOperation(_key.getTransformOperation());
			_overWrittenKeys = null;
			return _currentOperation;
		}
		
		private function _futureMode():void
		{
			var snapToActivity:Boolean = true;			
			
			if(snapToActivity)
				_snapToActivityKey();
				
			var lastOverWrittenKey:ISpatialKeyframe = _overWrittenKeys.getAtOrAfter(_key.endTime) as ISpatialKeyframe;
			if(!lastOverWrittenKey)
				return;
			if(lastOverWrittenKey.endTime == _key.endTime)
				return;
			
			var compensation:Matrix;
			
			//Find the compensation matrix to be used for the computation
			if(_transitionType == REALTIME)
			{
				var prevKey:ISpatialKeyframe = _key.previous as ISpatialKeyframe;

				if(prevKey)
					compensation = prevKey.getFullMatrix(_key.endTime,new Matrix());
				else
					compensation = new Matrix();
				
				var overWrittenTransform:Matrix = _overWrittenKeys.getMatrix(_key.endTime);
				var currentTransform:Matrix = _key.getFullMatrix(_key.endTime, new Matrix());
				compensation.concat(overWrittenTransform);
				compensation.invert();
				compensation.concat(currentTransform);
				
				if(_key.endTime != lastOverWrittenKey.startTime() || 
					_key.endTime != lastOverWrittenKey.endTime)
					lastOverWrittenKey.splitKey(_key.endTime, 
						new KCompositeOperation(),lastOverWrittenKey.center);	
			}
			else
			{
				compensation = new Matrix();
				var displacementChange:Point = _key.translate.currentTransform;
				compensation.translate(displacementChange.x, displacementChange.y);
				
				//Handle rotate and scale changes here also
			}
			
			compensation.invert();
			
			var tRef:IReferenceFrame = _referenceFrameList.getReferenceFrameAt(TRANSLATION_REF);
			
			switch(_currentTransformType)
			{
				case TRANSLATION_REF:
					(lastOverWrittenKey as KSpatialKeyFrame).interpolateTranslate(
						compensation.tx,compensation.ty);
					break;
				case ROTATION_REF:
					break;
				case SCALE_REF:
					break;
			}
			
			var ref:KReferenceFrame = _referenceFrameList.getReferenceFrameAt(
				_currentTransformType) as KReferenceFrame;
			ref.append(lastOverWrittenKey);
			
			var addedKeys:Vector.<IKeyFrame> = new Vector.<IKeyFrame>();
			
			var myKey:IKeyFrame = lastOverWrittenKey as IKeyFrame;
			
			while(myKey)
			{
				addedKeys.push(myKey);
				myKey = myKey.next;
			}
			
			_currentOperation.addOperation(
				new KReplaceKeyframeOperation(_object, ref,null,addedKeys));
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
		
		
		// Initialises the transition types and records the initial 
		// data required for interpolation and instant transitions.
		private function _initTransitionTypes(transitionType:String):void
		{
			switch(transitionType)
			{
				case "REALTIME":
					_transitionType = REALTIME;
					break;
				case "INTERPOLATED":
					_transitionType = INTERPOLATED;
					break;
				case "INSTANT":
					_transitionType = INSTANT;
					break;
				default:
					throw new Error("KTransformMgr - beginTranslation: " +
						"Transition type is not specified, Please specify either " +
						"REALTIME, INTERPOLATED OR INSTANT for the transition type");
			}
		}
	}
}