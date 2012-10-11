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
		 * Clone and Collapses the hierarchy of the given object
		 * Merges all of the hierachy's motions (up till given time) into the object
		 */
		public static function MergeHierarchyMotionsIntoObject(root:KGroup, object:KObject, time:Number):IModelOperation
		{
			var clipBoard:KClipBoard = new KClipBoard();
			var mergeHierarchyOp:KCompositeOperation = new KCompositeOperation();
			var parent:KGroup = object.getParent(KGroupUtil.STATIC_GROUP_TIME);
			while(parent.id != root.id)
			{
				var parentClone:KObject = clipBoard.cloneObject(parent);
				var objectClone:KObject = clipBoard.cloneObject(object);
				_mergeMotionOfType(parentClone, object, time, mergeHierarchyOp, KTransformMgr.ROTATION_REF);
				_mergeMotionOfType(parentClone, object, time, mergeHierarchyOp, KTransformMgr.SCALE_REF);
				_mergeMotionOfType(parentClone, object, time, mergeHierarchyOp, KTransformMgr.TRANSLATION_REF);
				
				var currentTime:Number = 0;
				var correctMatrix:Matrix;
				var currentMatrix:Matrix;
				var currentCenter:Point;
				var correctCenter:Point;
				var compensation:Point;
				var correctionPath:K3DPath = new K3DPath();
				
				while(currentTime <= time)
				{
					correctMatrix = objectClone.getFullMatrix(currentTime);
					correctCenter = correctMatrix.transformPoint(object.defaultCenter);
					correctCenter = parent.getFullMatrix(currentTime).transformPoint(correctCenter);
					
					currentMatrix = object.getFullMatrix(currentTime);
					currentCenter = currentMatrix.transformPoint(object.defaultCenter);//handleCenter(currentTime));
					compensation = correctCenter.subtract(currentCenter);
					correctionPath.push(compensation.x, compensation.y, currentTime);
					currentTime += KAppState.ANIMATION_INTERVAL;
				}
				object.transformMgr.mergeTranslatePathOverTime(correctionPath, KGroupUtil.STATIC_GROUP_TIME, time, mergeHierarchyOp);
				
				parent = parent.getParent(KGroupUtil.STATIC_GROUP_TIME);
			}
			
			if(mergeHierarchyOp.length > 0)
				return mergeHierarchyOp;
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

		/**
		 * Add interpolated translation to the object fromPoint toPoint, fromTime toTime.
		 */
		public static function addInterpolatedTranslation(object:KObject,fromPoint:Point,
														  toPoint:Point,fromTime:Number,
														  toTime:Number):IModelOperation
		{
			const translateRef:int = KTransformMgr.TRANSLATION_REF;			
			var ops:KCompositeOperation = new KCompositeOperation();
			var center:Point = object.defaultCenter;
			var toKeys:Vector.<IKeyFrame> = object.getSpatialKeys(translateRef);			
			var fmKeys:Vector.<IKeyFrame> = new Vector.<IKeyFrame>();
			var key:ISpatialKeyframe = new KSpatialKeyFrame(toTime,center);
			key.translate = _getInterpolatedTranslation(fromPoint,toPoint,toTime-fromTime);
			fmKeys.push(key);
			for (var i:int = 0; i < toKeys.length; i++)
				_splitKeys(fmKeys,toKeys[i].endTime,new KCompositeOperation());
			for (var j:int = 0; j < fmKeys.length; j++)
			{
				var endTime:Number = fmKeys[j].endTime;
				key = object.getSpatialKey(endTime,translateRef);
				if (endTime < key.endTime)
					key.splitKey(endTime,ops,center);
				else if (endTime > key.endTime)
					object.transformMgr.addKeyFrame(
						translateRef,endTime,center.x,center.y,ops);
				key = object.getSpatialKeyAt(endTime,translateRef);
				var op:IModelOperation = key.mergeKey(fmKeys[j] as ISpatialKeyframe,translateRef);
				if (op != null)
					ops.addOperation(op);
			}
			return ops.length > 0 ? ops : null;
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
		
		// Obtain the translation from fromPoint to toPoint, interpolated across duration.
		private static function _getInterpolatedTranslation(fromPoint:Point,toPoint:Point,
															duration:Number):KTranslation
		{
			const translateRef:int = KTransformMgr.TRANSLATION_REF;			
			var offset:Point = toPoint.subtract(fromPoint);
			var result:KTranslation = new KTranslation();
			for (var i:int=0; i <= duration; i++)
			{
				var xi:Number = i*offset.x/duration;
				var yi:Number = i*offset.y/duration;
				var point:Point = new Point(fromPoint.x+xi,fromPoint.y+yi);
				result.motionPath.addPoint(xi,yi,i);
				result.transitionPath.push(xi,yi,i);
			}
			return result;
		}
		
		
		/**
		 * Merge the motions of a type from source object into the target
		 * Motions from the source's creation time, to given time will be merged into the target
		 * This function compensates for differences in centers between the source and target keys.
		 */
		private static function _mergeMotionOfType(source:KObject, target:KObject, time:Number, op:KCompositeOperation, type:int):void
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
			}
		}
	}
}