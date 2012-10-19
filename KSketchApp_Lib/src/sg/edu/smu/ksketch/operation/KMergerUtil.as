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
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch.model.IKeyFrame;
	import sg.edu.smu.ksketch.model.IParentKeyFrame;
	import sg.edu.smu.ksketch.model.IReferenceFrame;
	import sg.edu.smu.ksketch.model.ISpatialKeyframe;
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.model.geom.K3DPath;
	import sg.edu.smu.ksketch.model.geom.KPathPoint;
	import sg.edu.smu.ksketch.model.geom.KTranslation;
	import sg.edu.smu.ksketch.model.implementations.KSpatialKeyFrame;
	import sg.edu.smu.ksketch.operation.implementations.KCompositeOperation;
	import sg.edu.smu.ksketch.operation.implementations.KReplaceKeyframeOperation;
	import sg.edu.smu.ksketch.utilities.KAppState;
	import sg.edu.smu.ksketch.utilities.KClipBoard;

	public class KMergerUtil
	{
		/**
		 * Collapses the hierarchy of the given object
		 * Merges all of the object's hierachy's (all the way to the root) motions (up till given time) into the object
		 */
		public static function MergeHierarchyMotionsIntoObject(stopAtGroup:KGroup, object:KObject,
															   time:Number, currentOperation:KCompositeOperation):IModelOperation
		{
			var clipBoard:KClipBoard = new KClipBoard();
			var objectClone:KObject = clipBoard.cloneObject(object);
			
			var parent:KGroup = object.getParent(KGroupUtil.STATIC_GROUP_TIME);
			var directParent:KGroup = object.getParent(KGroupUtil.STATIC_GROUP_TIME);
			var currentMaxTime:Number;
			var maxTime:Number = 0;
			//Merge all available transformation data into the child object
			while(parent.id != stopAtGroup.id)
			{
				maxTime = _mergeMotionOfType(parent, object, time, currentOperation, KTransformMgr.ROTATION_REF);
				
				currentMaxTime = _mergeMotionOfType(parent, object, time, currentOperation, KTransformMgr.SCALE_REF);
				if(currentMaxTime > maxTime)
					maxTime = currentMaxTime;
				
				currentMaxTime = _mergeMotionOfType(parent, object, time, currentOperation, KTransformMgr.TRANSLATION_REF);
				if(currentMaxTime > maxTime)
					maxTime = currentMaxTime;
				
				parent = parent.getParent(KGroupUtil.STATIC_GROUP_TIME);
			}
			
			//Merging of transformation data does not compensate for any differences in rotation or scaling center.
			//Differences in centers cause positional changes but not orientation/size changes.
			//Perform checking of position, and compensate for any differences.
			var correctMatrix:Matrix;
			var currentMatrix:Matrix;
			
			var targetCenter:Point;
			var correctCenter:Point;
			var currentCenter:Point;
			var compensation:Point;
			
			var currentTime:Number = 0;
			var correctionPath:K3DPath = new K3DPath();
			
			if(object is KGroup)
				targetCenter = (object as KGroup).getCentroid(time);
			else
				targetCenter = object.defaultCenter;
			
			//The idea is to use a translation path and merge any differences in.
			//Not optimised, we need a faster algo. Its O(n) now, and merging everything, even dx = 0 and dy = 0
			var correctMaxTime:Number = maxTime;
			maxTime += KAppState.ANIMATION_INTERVAL;
			while(currentTime < maxTime)
			{
				if(correctMaxTime < currentTime)
					currentTime = correctMaxTime;
				correctMatrix = objectClone.getFullMatrix(currentTime);
				correctMatrix.concat(directParent.getFullPathMatrix(currentTime));
				correctCenter = correctMatrix.transformPoint(targetCenter);
				currentMatrix = object.getFullMatrix(currentTime);
				currentCenter = currentMatrix.transformPoint(targetCenter);
				compensation = correctCenter.subtract(currentCenter);
				correctionPath.push(compensation.x, compensation.y, currentTime);
				currentTime += KAppState.ANIMATION_INTERVAL;
			}

			//Merge the derived path into the object
			object.transformMgr.mergeTranslatePathOverTime(correctionPath, KGroupUtil.STATIC_GROUP_TIME, correctMaxTime, currentOperation);
			
			if(currentOperation.length > 0)
				return currentOperation;
			else
				return null;
		}
		
		/**
		 * Merge the keys from source to target of the type at the specific time.
		 */
		public static function mergeKeys(target:KObject,source:KObject,time:Number, 
										 ops:KCompositeOperation, type:int):void
		{
			var center:Point = target.defaultCenter;
			var targetKeys:Vector.<IKeyFrame> = target.getSpatialKeys(type);
			var sourceKeys:Vector.<IKeyFrame> = _cloneKeys(source.getSpatialKeys(type));
			_splitKeys(targetKeys,time,ops);
			_splitKeys(sourceKeys,time,new KCompositeOperation());
			for (var i:int=0; i < targetKeys.length; i++)
				_splitKeys(sourceKeys,targetKeys[i].endTime,new KCompositeOperation());
			for (var j:int=0; j < sourceKeys.length; j++)
			{
				var sourceKey:ISpatialKeyframe = sourceKeys[j] as ISpatialKeyframe;
				var sourceTime:Number = sourceKey.endTime;
				if (sourceTime < time) 
					continue;			
				_splitKeys(targetKeys,sourceTime,ops);
				if (target.getSpatialKeyAt(sourceTime,type) == null)
					target.transformMgr.addKeyFrame(type,sourceTime,center.x,center.y,ops);
				var targetKey:ISpatialKeyframe = target.getSpatialKeyAt(sourceTime,type);
				var op:IModelOperation = targetKey.mergeKey(sourceKey, type);
				if (op != null)
					ops.addOperation(op);
			}
		}

		// Split the key in keys, where key.startTime() < time < key.endTime. 
		private static function _splitKeys(keys:Vector.<IKeyFrame>,time:Number, 
										   ops:KCompositeOperation):void
		{
			for (var i:int=0; i < keys.length; i++)
			{
				if (keys[i].startTime() < time && time < keys[i].endTime)
				{
					var key:ISpatialKeyframe = keys[i] as ISpatialKeyframe; 
					var key01:Vector.<IKeyFrame> = key.splitKey(time,ops,key.center);
					keys.splice(i,1,key01[0],key01[1]);
					return;
				}
			}
		}
		
		// Clone all entries of keys and return the cloned keys as a new Vector.
		private static function _cloneKeys(keys:Vector.<IKeyFrame>):Vector.<IKeyFrame>
		{
			var clones:Vector.<IKeyFrame> = new Vector.<IKeyFrame>;
			for (var i:int=0; i < keys.length; i++)
				clones.push(keys[i].clone());
			return clones;
		}
		
		/**
		 * Merge the motions of a type from source object into the target
		 * Motions from the source's creation time, to given time will be merged into the target
		 * This function compensates for differences in centers between the source and target keys.
		 */
		private static function _mergeMotionOfType(source:KObject, target:KObject, time:Number, op:KCompositeOperation, type:int):Number
		{
			var sourceRef:IReferenceFrame = source.getReferenceFrameAt(type);
			var targetRef:IReferenceFrame = target.getReferenceFrameAt(type);
			
			//Normalise both reference frames
			var currentSourceKey:ISpatialKeyframe = sourceRef.earliestKey() as ISpatialKeyframe;
			var currentTargetKey:ISpatialKeyframe = null;
			
			//Set a key at the time to stop merging
			//source.transformMgr.forceKeyAtTime(time, sourceRef,op);
			
			//Iterate through both source and target reference frames, and make sure
			//that if a the source ref has a key at time Ti, target should also have a key at Ti too.
			while(currentSourceKey)
			{
				if(time < currentSourceKey.endTime)
					break;
				currentTargetKey = targetRef.getAtTime(currentSourceKey.endTime) as ISpatialKeyframe;
				if(!currentTargetKey)
					target.transformMgr.forceKeyAtTime(currentSourceKey.endTime, targetRef, op);
				currentSourceKey = currentSourceKey.next as ISpatialKeyframe;
			}
			
			//Same as the previous while loop
			//But we will be merging the motions together after each iteration.
			var lastKeyTime:Number = 0;
			currentTargetKey = targetRef.earliestKey() as ISpatialKeyframe;
			currentSourceKey = null;
			while(currentTargetKey)
			{
				if(time < currentTargetKey.endTime)
					break;
				currentSourceKey = sourceRef.getAtTime(currentTargetKey.endTime) as ISpatialKeyframe;
				if(!currentSourceKey)
					source.transformMgr.forceKeyAtTime(currentTargetKey.endTime, sourceRef, op);
				currentSourceKey = sourceRef.getAtTime(currentTargetKey.endTime) as ISpatialKeyframe;

				//Manage difference in centers. 
				//source.transformMgr.updateCenter(currentSourceKey, currentTargetKey.center, currentTargetKey.endTime, op);
				op.addOperation(currentTargetKey.mergeKey(currentSourceKey, type));
				currentTargetKey = currentTargetKey.next as ISpatialKeyframe;
				
				if(currentTargetKey)
					lastKeyTime = currentTargetKey.endTime;
			}

			return lastKeyTime;
		}
	}
}