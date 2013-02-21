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
	import sg.edu.smu.ksketch2.model.data_structures.KPath;
	import sg.edu.smu.ksketch2.model.data_structures.KReferenceFrame;
	import sg.edu.smu.ksketch2.model.data_structures.KSpatialKeyFrame;
	import sg.edu.smu.ksketch2.model.data_structures.KTimedPoint;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;
	import sg.edu.smu.ksketch2.operators.operations.KInsertKeyOperation;
	import sg.edu.smu.ksketch2.operators.operations.KRemoveKeyOperation;
	import sg.edu.smu.ksketch2.operators.operations.KReplacePathOperation;
	
	public class KSingleReferenceFrameOperator implements ITransformInterface
	{
		public static const TRANSLATE_THRESHOLD:Number = 10;
		public static const ROTATE_THRESHOLD:Number = 0.2;
		public static const SCALE_THRESHOLD:Number = 0.2;
		
		protected var _object:KObject;
		protected var _refFrame:KReferenceFrame;
		
		protected var _TWorkingPath:KPath;
		protected var _RWorkingPath:KPath;
		protected var _SWorkingPath:KPath;
		
		protected var _startTime:int;
		protected var _inTransit:Boolean
		protected var _transitionType:int;
		protected var _transitionX:Number;
		protected var _transitionY:Number;
		protected var _transitionTheta:Number;
		protected var _transitionSigma:Number;
		
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
			
			_transitionX = 0;
			_transitionY = 0;
			_transitionTheta = 0;
			_transitionSigma = 0;

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
				return _transitionMatrix(time);
			
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
			
			return result;
		}
		
		private function _transitionMatrix(time:int):Matrix
		{
			//Extremely hardcoded matrix
			//Iterate through the key list and add up the rotation, scale, dx dy values
			//Pump these values into the matrix after wards
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
				if(currentKey.startTime <= _startTime)
				{
					var proportionKeyFrame:Number = currentKey.findProportion(_startTime);
					
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
		
		/**
		 * Returns a boolean denoting whether it is possible to insert a key
		 * into this operator's key list
		 */
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
		public function beginTransition(time:int, transitionType:int):void
		{
			_transitionType = transitionType;
			_startTime = time;

			//Initiate transition values and variables first
			_transitionX = 0;
			_transitionY = 0;
			_transitionTheta = 0;
			_transitionSigma = 0;
			
			if(_transitionType == KSketch2.TRANSITION_DEMONSTRATED)
			{
				_TWorkingPath = new KPath();
				_RWorkingPath = new KPath();
				_SWorkingPath = new KPath();
			}
			
			_inTransit = true;
		}
		
		public function updateTransition(time:int, dx:Number, dy:Number, dTheta:Number, dScale:Number):void
		{
			_transitionX = dx;
			_transitionY = dy;
			_transitionTheta = dTheta;
			_transitionSigma = dScale;
			
			if(_transitionType == KSketch2.TRANSITION_DEMONSTRATED)
			{
				var elapsedTime:int = time - _startTime;
				_TWorkingPath.push(dx, dy, elapsedTime);
				_RWorkingPath.push(dTheta, 0, elapsedTime);
				_SWorkingPath.push(dScale, 0, elapsedTime);			
			}
			else
				_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_CHANGED, _object, time)); 
		}
		
		public function endTransition(time:int, op:KCompositeOperation):void
		{
			//Only two kinds of transitions, demonstrated or interpolated
			if(_transitionType == KSketch2.TRANSITION_DEMONSTRATED)
			{
				//Process the paths here first
				//Do w/e you want to the paths here!
				if(KSketch2.discardTransitionTimings)
				{
					_discardTransitionTiming(_TWorkingPath);
					_discardTransitionTiming(_RWorkingPath);
					_discardTransitionTiming(_SWorkingPath);
				}
				//Path validity will be tested in _normaliseForOverwriting
				//If path is valid, the object's future for that transform type will be discarded
				_normaliseForOverwriting(_startTime, op);

				
				//Then I need to put the usable paths into the object
				if(!_TWorkingPath.isTrivial(TRANSLATE_THRESHOLD))
					_replacePathOverTime(_TWorkingPath, _startTime, time, KSketch2.TRANSFORM_TRANSLATION, op);
				
				if(!_RWorkingPath.isTrivial(ROTATE_THRESHOLD))
					_replacePathOverTime(_RWorkingPath, _startTime, time, KSketch2.TRANSFORM_ROTATION, op);
				
				if(!_SWorkingPath.isTrivial(SCALE_THRESHOLD))
					_replacePathOverTime(_SWorkingPath, _startTime, time, KSketch2.TRANSFORM_SCALE, op);
				
				matrix(time);
				_clearEmptyKeys(op);
			}
			else
			{
				//We need a key to add the interpolation values
				//So check if a key can be inserted
				//A key can be inserted if there is no key at time
				if(canInsertKey(time))
					insertBlankKeyFrame(time, op);
				
				//After inserting a key, will be pretty sure there is a key at time.
				//Just get the key at time
				var targetKey:KSpatialKeyFrame = _refFrame.getKeyAtTime(time) as KSpatialKeyFrame;

				if(!targetKey)
					throw new Error("Unable to get a key for interpolation. Please check");
				//Errorneous status, need to find out what happened to the object's timeline
				
				//Then we just dump the transition values into the key
				interpolateKey(_transitionX, _transitionY, targetKey, KSketch2.TRANSFORM_TRANSLATION, time, op);
				interpolateKey(_transitionTheta, 0, targetKey, KSketch2.TRANSFORM_ROTATION, time, op);
				interpolateKey(_transitionSigma, 0, targetKey, KSketch2.TRANSFORM_SCALE, time, op);
			}
			
			_inTransit = false;
			
			//Initiate transition values and variables first
			_transitionX = 0;
			_transitionY = 0;
			_transitionTheta = 0;
			_transitionSigma = 0;
			
			//Dispatch a transform finalised event
			//Application level components can listen to this event to do updates
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
				interpolateKey(positionDifference.x, positionDifference.y, currentKey, KSketch2.TRANSFORM_TRANSLATION, currentKey.time, op, true);
				currentKey = currentKey.next as KSpatialKeyFrame;
			}
			
			_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_CHANGED, _object, stopMergeTime));
			_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_TRANSFORM_FINALISED, _object, stopMergeTime));
		}
		
		/**
		 * Adds a dx, dy interpolation to targetKey
		 */
		public function interpolateKey(dx:Number, dy:Number, targetKey:KSpatialKeyFrame, transformType:int, time:int,
									   op:KCompositeOperation, followUp:Boolean = false):void
		{
			if(time != targetKey.time)
				throw new Error("Unable to interpolate a key if the interpolation time != targetKey's time");
			
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
		
		/**
		 * Makes the timing for the given path linear
		 */
		protected function _discardTransitionTiming(path:KPath):void
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
		
		/**
		 * Linearly adds dx and dy up to the proportion given
		 * Linearly removes dx and dy up from that proportion onwards
		 */
		protected function _interpolatePath(dx:Number, dy:Number, targetPath:KPath, upToProportion:Number):void
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
					//Adding dx and dy linearly up to proportion
					currentPoint.x += dx * currentProportion/upToProportion;
					currentPoint.y += dy * currentProportion/upToProportion;
				}
				else
				{
					//Removing dx and dy linearly for the rest of the path
					currentPoint.x += dx+(dx *(upToProportion - currentProportion)/(1-upToProportion));
					currentPoint.y += dy+(dy *(upToProportion - currentProportion)/(1-upToProportion));
				}

				refinedPoints.push(currentPoint);
				currentProportion = currentTime / pathDuration;
			}
			
			targetPath.points = refinedPoints;
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
			
			var validTranslate:Boolean = !_TWorkingPath.isTrivial(TRANSLATE_THRESHOLD);
			var validRotate:Boolean = !_RWorkingPath.isTrivial(ROTATE_THRESHOLD);
			var validScale:Boolean = !_SWorkingPath.isTrivial(SCALE_THRESHOLD);
			
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