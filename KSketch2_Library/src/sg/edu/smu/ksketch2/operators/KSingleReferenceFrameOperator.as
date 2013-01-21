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
	import sg.edu.smu.ksketch2.model.data_structures.KKeyFrame;
	import sg.edu.smu.ksketch2.model.data_structures.KKeyFrameList;
	import sg.edu.smu.ksketch2.model.data_structures.KPath;
	import sg.edu.smu.ksketch2.model.data_structures.KReferenceFrame;
	import sg.edu.smu.ksketch2.model.data_structures.KSpatialKeyFrame;
	import sg.edu.smu.ksketch2.model.data_structures.KTimedPoint;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;
	import sg.edu.smu.ksketch2.operators.operations.KInsertKeyOperation;
	import sg.edu.smu.ksketch2.operators.operations.KKeyOperation;
	import sg.edu.smu.ksketch2.operators.operations.KRemoveKeyOperation;
	import sg.edu.smu.ksketch2.operators.operations.KReplacePathOperation;
	
	import spark.primitives.Path;
	
	public class KSingleReferenceFrameOperator implements ITransformInterface
	{
		private var _object:KObject;
		private var _refFrame:KReferenceFrame;
		
		private var _workingPath:KPath;
		
		private var _startTime:int;
		private var _transitionType:int;
		private var _transitionX:Number;
		private var _transitionY:Number;
		private var _transitionTheta:Number;
		private var _transitionSigma:Number;
		
		/**
		 * KSingleReferenceFrame is the transform interface dealing with the single reference frame model
		 */
		public function KSingleReferenceFrameOperator(object:KObject)
		{
			if(!object)
				throw new Error("Transform interface says: Dude, no object given!");
			_refFrame = new KReferenceFrame();
			_object = object;
			//Oh yeah, since we are doing static grouping, lets create the keys at zero to make our lives easier!
//			var headerKey:KSpatialKeyFrame = new KSpatialKeyFrame(0, object.centroid);
//			_refFrame.insertKey(headerKey);
			
			_transitionX = 0;
			_transitionY = 0;
			_transitionTheta = 0;
			_transitionSigma = 0;

		}
		
		public function get firstKeyTime():int
		{
			return _refFrame.head.time;
		}
		
		public function get lastKeyTime():int
		{
			return _refFrame.lastKey.time;
		}
		
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
			var currentKey:KSpatialKeyFrame = _refFrame.head as KSpatialKeyFrame;
			
			if(!currentKey)
				return new Matrix();
			
			var x:Number = _transitionX;
			var y:Number = _transitionY;
			var theta:Number = _transitionTheta;
			var sigma:Number = 1 + _transitionSigma;
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

			return result;	
		}
		
		/**
		 * Identifies if the object has active transforms at given time
		 * Returns true if there is a transform
		 */
		public function canTransform(time:int):Boolean
		{
			var activeKey:KSpatialKeyFrame = _refFrame.getKeyAftertime(time-1) as KSpatialKeyFrame;
			
			if(!activeKey)
				return false;
			
			if(activeKey.time == time)
				return true;
			
			return activeKey.hasActivityAtTime();
		}
		
		public function canInsertKey(time:int):Boolean
		{
			var activeKey:KSpatialKeyFrame = _refFrame.getKeyAtTime(time) as KSpatialKeyFrame;
			
			if(activeKey)
				return false;
			
			activeKey = _refFrame.getKeyAftertime(time-1) as KSpatialKeyFrame;
			
			if(!activeKey)
				return false;
			
			return activeKey.hasActivityAtTime();
		}
		
		/**
		 * Preps the object for transition
		 * Checks for errors and inconsistencies and complains if the object is not in a magical state
		 * --- THe previous operation did not clean up the object
		 */
		public function beginTransition(time:int, transitionType:int, transformType:int,op:KCompositeOperation):void
		{
			if(_workingPath)
				throw new Error("TransformInterface BeginTransition: Someone forgot to clean up the previous transition");
			
			_transitionType = transitionType;
			
			//We need to put the model into its magical state first.
			_normaliseModel(time, transformType, op);

			//Then we can find the keys we need for transition
			_workingPath = new KPath();
			_startTime = time;
		}
		
		public function endTransition(time:int, op:KCompositeOperation):void
		{
			_workingPath = null;
		}
		
		/**
		 * This method currently checks for inconsistencies only.
		 */
		public function beginTranslation(time:int):void
		{
			if(_transitionX != 0 || _transitionY != 0)
				throw new Error("Transition variables are not clean, can't proceed");
			_workingPath.push(0, 0, 0);
		}
		
		public function updateTranslation(dx:Number, dy:Number, time:int):void
		{
			_transitionX = dx;
			_transitionY = dy;
			
			if(_transitionType == KSketch2.TRANSITION_DEMONSTRATED)
				_workingPath.push(dx, dy, time-_startTime);
			else
				_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_CHANGED, _object, time));
		}
		
		public function endTranslation(time:int, op:KCompositeOperation):void
		{
			if(_transitionType == KSketch2.TRANSITION_DEMONSTRATED)
			{
				if(KSketch2.discardTransitionTimings)
					_discardTransitionTiming(_workingPath);
				_replacePathOverTime(_workingPath, _startTime, time, KSketch2.TRANSFORM_TRANSLATION, op);
				_clearEmptyKeys(op);
			}
			else
			{
				var targetKey:KSpatialKeyFrame = _refFrame.getKeyAftertime(time-1) as KSpatialKeyFrame;
				interpolateKey(_transitionX, _transitionY, targetKey, KSketch2.TRANSFORM_TRANSLATION, time, op);
			}
			
			//Reset the transition values
			_transitionX = 0;
			_transitionY = 0;
			_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_FINALISED, _object, time));
		}
		
		public function beginRotation(time:int):void
		{
			if(_transitionTheta != 0)
				throw new Error("Transition variables are not clean, can't proceed");
			_workingPath.push(0, 0, 0);
		}
		
		public function updateRotation(dTheta:Number, time:int):void
		{
			_transitionTheta = dTheta;
			if(_transitionType == KSketch2.TRANSITION_DEMONSTRATED)
					_workingPath.push(dTheta, 0, time-_startTime);
			else
				_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_CHANGED, _object, time));
		}
		
		public function endRotation(time:int, op:KCompositeOperation):void
		{
			if(_transitionType == KSketch2.TRANSITION_DEMONSTRATED)
			{
				if(KSketch2.discardTransitionTimings)
					_discardTransitionTiming(_workingPath);
				_replacePathOverTime(_workingPath, _startTime, time, KSketch2.TRANSFORM_ROTATION, op);
				_clearEmptyKeys(op);
			}
			else
			{
				var targetKey:KSpatialKeyFrame = _refFrame.getKeyAftertime(time-1) as KSpatialKeyFrame;
				interpolateKey(_transitionTheta, 0, targetKey, KSketch2.TRANSFORM_ROTATION, time, op);
			}
			_transitionTheta = 0;
			_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_FINALISED, _object, time));
		}
		
		public function beginScale(time:int):void
		{
			if(_transitionSigma != 0)
				throw new Error("Transition variables are not clean, can't proceed");
			_workingPath.push(0, 0, 0);
		}
		
		public function updateScale(dSigma:Number, time:int):void
		{
			_transitionSigma = dSigma;
			if(_transitionType == KSketch2.TRANSITION_DEMONSTRATED)
				_workingPath.push(dSigma, 0, time-_startTime);
			else
				_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_CHANGED, _object, time));
		}
		
		public function endScale(time:int, op:KCompositeOperation):void
		{
			if(_transitionType == KSketch2.TRANSITION_DEMONSTRATED)
			{
				if(KSketch2.discardTransitionTimings)
					_discardTransitionTiming(_workingPath);
				_replacePathOverTime(_workingPath, _startTime, time, KSketch2.TRANSFORM_SCALE, op);
				_clearEmptyKeys(op);
			}
			else
			{
				var targetKey:KSpatialKeyFrame = _refFrame.getKeyAftertime(time-1) as KSpatialKeyFrame;
				interpolateKey(_transitionSigma, 0, targetKey, KSketch2.TRANSFORM_SCALE, time, op);
			}
			_transitionSigma = 0;
			_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_FINALISED, _object, time));
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
		
		public function mergeTransform(sourceObject:KObject, stopMergeTime:int, op:KCompositeOperation):void
		{
			var sourceInterface:KSingleReferenceFrameOperator = sourceObject.transformInterface.clone() as KSingleReferenceFrameOperator;
			var oldInterface:KSingleReferenceFrameOperator = this.clone() as KSingleReferenceFrameOperator;
			var toMergeRefFrame:KReferenceFrame = new KReferenceFrame();
			var toModifyKey:KSpatialKeyFrame;
			var currentKey:KSpatialKeyFrame = sourceInterface.getActiveKey(-1) as KSpatialKeyFrame;

			//Clone the source object's reference frame and modify the this operator's reference frame 
			//Such that it is the same as the source reference frame
			while(currentKey && currentKey.time <= stopMergeTime)
			{
				toMergeRefFrame.insertKey(currentKey.clone());
				toModifyKey = _refFrame.getKeyAtTime(currentKey.time) as KSpatialKeyFrame;
				if(!toModifyKey)
				{
					toModifyKey = _refFrame.getKeyAftertime(currentKey.time) as KSpatialKeyFrame;
					
					if(toModifyKey)
						toModifyKey.splitKey(currentKey.time, dummyOp);
					else
					{
						toModifyKey = new KSpatialKeyFrame(currentKey.time, _object.centroid);
						op.addOperation(new KInsertKeyOperation(_refFrame.getKeyAtBeforeTime(currentKey.time), null, toModifyKey));
						_refFrame.insertKey(toModifyKey);
					}
				}
				
				currentKey = currentKey.next as KSpatialKeyFrame;
			}
			
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
				interpolateKey(positionDifference.x, positionDifference.y, currentKey, KSketch2.TRANSFORM_TRANSLATION, currentKey.time, op, true);
				currentKey = currentKey.next as KSpatialKeyFrame;
			}
			
			_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_CHANGED, _object, stopMergeTime));
			_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_FINALISED, _object, stopMergeTime));
		}
		
		/**
		 * Adds an dx, dy interpolation to targetKey
		 */
		public function interpolateKey(dx:Number, dy:Number, targetKey:KSpatialKeyFrame, transformType:int, time:int,
									   op:KCompositeOperation, followUp:Boolean = false):void
		{
			if(KSketch2.addInterpolationKeys && time < targetKey.time)
				targetKey = targetKey.splitKey(time, op) as KSpatialKeyFrame;
			
			var proportionElapsed:Number;
			
			if(targetKey.duration == 0)
				proportionElapsed = 1;
			else
				proportionElapsed = (time-targetKey.startTime)/targetKey.duration;
			
			var targetPath:KPath;
			var unInterpolate:Boolean = false;
			
			//Case 1: No path
			switch(transformType)
			{
				case KSketch2.TRANSFORM_TRANSLATION:
					targetPath = targetKey.translatePath;
					unInterpolate = KSketch2.returnTranslationInterpolationToZero;
					break;
				case KSketch2.TRANSFORM_ROTATION:
					targetPath = targetKey.rotatePath;
					unInterpolate = KSketch2.returnRotationInterpolationToZero;
					break;
				case KSketch2.TRANSFORM_SCALE:
					targetPath = targetKey.scalePath;
					unInterpolate = KSketch2.returnScaleInterpolationToZero;
					break;
				default:
					throw new Error("Unable to replace path because an unknown transform type is given");
			}
			
			var oldPath:KPath = targetPath.clone();
			//Only case, adjusting an object's transform when that transform does not exist
			if(targetPath.length < 2)
			{
				if(targetPath.length != 0)
					throw new Error("Someone created a path with 1 point somehow! Better check out the path functions");
				
				targetPath.push(0,0,0);
				targetPath.push(dx,dy,targetKey.duration * proportionElapsed);
				
				if(targetKey.duration != 0)
				{
					if(unInterpolate && time != targetKey.time)
						targetPath.push(0,0,targetKey.duration);

					var pathDuration:int = targetPath.pathDuration;
					var currentTime:int = 0;
					var currentProportion:Number = 0;
					var currentPoint:KTimedPoint;
					var newPoints:Vector.<KTimedPoint> = new Vector.<KTimedPoint>();
					
					while(currentProportion <= 1)
					{
						currentPoint = targetPath.find_Point(currentProportion);
						currentPoint.time = currentTime;
						newPoints.push(currentPoint);
						currentTime += KSketch2.ANIMATION_INTERVAL;
						currentProportion = currentTime / pathDuration;
					}
					
					targetPath.points = newPoints;
				}
				
				op.addOperation(new KReplacePathOperation(targetKey, targetPath, oldPath, transformType));
				if(unInterpolate&&!followUp && targetKey.next)
					interpolateKey(-dx, -dy, targetKey.next as KSpatialKeyFrame, transformType, targetKey.next.time, op, true);
				return;
			}

			if(targetKey.time == time) //Case 2:interpolate at key time
			{
				_interpolatePath(dx,dy,targetPath,proportionElapsed);
				op.addOperation(new KReplacePathOperation(targetKey, targetPath, oldPath, transformType));

				if(unInterpolate&&!followUp && targetKey.next)
					interpolateKey(-dx, -dy, targetKey.next as KSpatialKeyFrame, transformType, targetKey.next.time, op, true);
			}
			else
			{
				//case 3:interpolate between two keys
				_interpolatePath(dx,dy,targetPath, proportionElapsed);
				op.addOperation(new KReplacePathOperation(targetKey, targetPath, oldPath, transformType));
			}
		}
		
		private function _discardTransitionTiming(path:KPath):void
		{
			var currentTime:int = 0;
			var currentProportion:Number = 0;
			var currentPoint:KTimedPoint;
			var pathDuration:int = path.pathDuration;
			var newPoints:Vector.<KTimedPoint> = new Vector.<KTimedPoint>();

			while(currentProportion <= 1)
			{
				currentPoint = path.find_Point_By_Magnitude(currentProportion);
				currentPoint.time = currentTime;
				newPoints.push(currentPoint);
				currentTime += KSketch2.ANIMATION_INTERVAL;
				currentProportion = currentTime / pathDuration;
			}
			path.points = newPoints;
		}
		
		private function _interpolatePath(dx:Number, dy:Number, targetPath:KPath, upToProportion:Number):void
		{
			var pathDuration:int = targetPath.pathDuration;
			var currentTime:int = 0;
			var currentProportion:Number = 0;
			var refinedPoints:Vector.<KTimedPoint> = new Vector.<KTimedPoint>;
			var currentPoint:KTimedPoint;
			var pathPoints:Vector.<KTimedPoint> = targetPath.points;;
			
			for(var i:int = 0; i < pathPoints.length; i++)
			{
				currentPoint = pathPoints[i].clone();
				
				if(pathDuration == 0)
					currentProportion = 1;
				else
					currentProportion = currentPoint.time/pathDuration;
				
				if(currentProportion <= upToProportion)
				{
					currentPoint.x += dx * currentProportion/upToProportion;
					currentPoint.y += dy * currentProportion/upToProportion;
				}
				else
				{
					currentPoint.x += dx+(dx *(upToProportion - currentProportion)/(1-upToProportion));
					currentPoint.y += dy+(dy *(upToProportion - currentProportion)/(1-upToProportion));
				}

				refinedPoints.push(currentPoint);
				currentProportion = currentTime / pathDuration;
			}
			
			targetPath.points = refinedPoints;
		}
		
		/**
		 * Adds the path to the reference frame across frames (if needed) over time
		 * Assume that the current keys are empty!
		 */
		private function _replacePathOverTime(sourcePath:KPath, startTime:int, endTime:int, transformType:int, op:KCompositeOperation):void
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
		 * Makes sure the object/model is in THE MAGICAL STATE for transition
		 * For this mode, we will need to make sure there is nothing else in the future
		 */
		private function _normaliseModel(time:int, transformType:int, op:KCompositeOperation):void
		{
			if(_transitionType != KSketch2.TRANSITION_DEMONSTRATED)
				return;
			
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
				throw new Error("_normaliseModel's magic is failing!");
			
			var currentKey:KSpatialKeyFrame = key;
			var oldPath:KPath;
			var newPath:KPath;
			while(currentKey.next)
			{
				currentKey = currentKey.next as KSpatialKeyFrame;
				
				switch(transformType)
				{
					case KSketch2.TRANSFORM_TRANSLATION:
						oldPath = currentKey.translatePath;
						currentKey.translatePath = new KPath();
						newPath = currentKey.translatePath;
						break;
					case KSketch2.TRANSFORM_ROTATION:
						oldPath = currentKey.rotatePath;
						currentKey.rotatePath = new KPath();
						newPath = currentKey.rotatePath;
						break;
					case KSketch2.TRANSFORM_SCALE:
						oldPath = currentKey.scalePath;
						currentKey.scalePath = new KPath();
						newPath = currentKey.scalePath;
						break;
					default:
						throw new Error("NormaliseModel can't work its magic if you give it the wrong transform type!");
				}

				//Create a new path replacement operation;
				op.addOperation(new KReplacePathOperation(currentKey, newPath, oldPath, transformType));
			}
		}
		
		//Cleans up the model after a transition.
		//Splits key frames up if a key frame has a path that does not fill its time span fully.
		//Removes empty key frames
		private function _clearEmptyKeys(op:KCompositeOperation):void
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