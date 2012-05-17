/**------------------------------------------------
 * Copyright 2012 Singapore Management University
 * All Rights Reserved
 *
 *-------------------------------------------------*/

package sg.edu.smu.ksketch.operation
{	
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch.event.KGroupUngroupEvent;
	import sg.edu.smu.ksketch.event.KModelEvent;
	import sg.edu.smu.ksketch.event.KObjectEvent;
	import sg.edu.smu.ksketch.model.IKeyFrame;
	import sg.edu.smu.ksketch.model.IParentKeyFrame;
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.model.KModel;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.model.KStroke;
	import sg.edu.smu.ksketch.operation.implementations.KCompositeOperation;
	import sg.edu.smu.ksketch.operation.implementations.KRemoveParentKeyFrameOperation;
	import sg.edu.smu.ksketch.operation.implementations.KUngroupOperation;
	import sg.edu.smu.ksketch.utilities.IIterator;
	import sg.edu.smu.ksketch.utilities.KAppState;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;
	
	/**
	 * A utility class to support ungroup operations.
	 */	
	public class KUngroupUtil
	{
		/**
		 * Ungroup a list of objects in static mode at kskTime, by placing under root.
		 */
		public static function ungroupStatic(model:KModel, root:KGroup, 
											 objs:KModelObjectList):IModelOperation
		{	
			return _ungroupObjects(model, root, objs);
		}
		
		/**
		 * Ungroup a list of objects in dynamic mode at kskTime, by placing under root.
		 */
		public static function ungroupDynamic(model:KModel, root:KGroup, objs:KModelObjectList, 
											  kskTime:Number):IModelOperation
		{	
			return _ungroupObjects(model, root, objs, kskTime);
		}
		
		/**
		 * Remove duplicate parent key frames for all objects in the model.
		 */
		public static function removeAllDuplicateParentKeys(model:KModel):IModelOperation
		{
			var ops:KCompositeOperation = new KCompositeOperation();
			var it:IIterator = model.iterator;
			while (it.hasNext())
			{
				var rmKeyOp:IModelOperation = _removeDuplicateParentKeys(it.next());
				if (rmKeyOp != null)
					ops.addOperation(rmKeyOp);
			}
			return ops.length > 0 ? ops : null;
		}
		
		/**
		 * Remove the parent key frames for all objects with endTime greater that time.
		 */
		public static function removeAllFutureParentKeys(objects:KModelObjectList,
														 time:Number):IModelOperation
		{
			var ops:KCompositeOperation = new KCompositeOperation();
			var it:IIterator = objects.iterator;
			while (it.hasNext())
			{
				var rmKeyOp:IModelOperation = _removeFutureParentKeys(it.next(),time);
				if (rmKeyOp != null)
					ops.addOperation(rmKeyOp);
			}
			return ops.length > 0 ? ops : null;
		}
		
		/**
		 * Remove singleton groups for all objects and all keyframes in the model.
		 */
		public static function removeAllSingletonGroups(model:KModel):IModelOperation
		{
			var ops:KCompositeOperation = new KCompositeOperation();
			var times:Vector.<Number> = _getKeyFrameTimes(_getParentKeyFrames(model));
			for (var i:int = 0; i < times.length; i++)
			{
				var rmOp:IModelOperation = _removeSingletonGroups(model,model.root,times[i]);
				if (rmOp != null)
					ops.addOperation(rmOp);
			}
			return ops.length > 0 ? ops : null;
		}
		
		/**
		 * Determine if the ungrouping can be performed at the current appState.
		 */
		public static function ungroupEnable(root:KGroup, appState:KAppState):Boolean
		{
			return appState.selection != null && selectedStrokes(root,
				appState.selection.objects,appState.time).length() > 0
		}		
		
		/**
		 * Select and return list of KStroke from objects that is not under notParent at time.
		 */
		public static function selectedStrokes(notParent:KGroup,objects:KModelObjectList,
											   time:Number):KModelObjectList
		{
			return _selectedStrokes(notParent,objects.iterator,time);
		}		
		
		/**
		 * Dispatch ungroup event and transform change event after ungrouping operation.
		 */
		public static function dispatchUngroupOperationEvent(model:KModel, parent:KGroup, 
															 object:KObject):void
		{
			model.dispatchEvent(new KGroupUngroupEvent(parent,KGroupUngroupEvent.EVENT_GROUP));
			model.dispatchEvent(new KGroupUngroupEvent(parent,KGroupUngroupEvent.EVENT_UNGROUP));
			parent.dispatchEvent(new KObjectEvent(parent,KObjectEvent.EVENT_TRANSFORM_CHANGED));
			object.dispatchEvent(new KObjectEvent(object,KObjectEvent.EVENT_TRANSFORM_CHANGED));
			object.dispatchEvent(new KObjectEvent(object,KObjectEvent.EVENT_PARENT_CHANGED));
			model.dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATED));
		}		
		
		// Ungroup a list of objects at kskTime, by placing under newParent.
		private static function _ungroupObjects(model:KModel, newParent:KGroup, 
												objs:KModelObjectList,
												kskTime:Number=-1):IModelOperation
		{	
			var ops:KCompositeOperation = new KCompositeOperation();
			var it:IIterator = objs.iterator;
			while (it.hasNext())
			{
				var obj:KObject = it.next();
				var groupTime:Number = kskTime >= 0 ? kskTime : obj.createdTime;
				var oldParent:KGroup = obj.getParent(groupTime);
				if (oldParent != null && oldParent != model.root)
				{
					var ungpOp:IModelOperation = _ungroupObject(
						model,oldParent,newParent,obj,groupTime);
					if (ungpOp != null)
						ops.addOperation(ungpOp);
				}
			}
			return ops.length > 0 ? ops : null;
		}
		
		// Ungroup given object at kskTime, by placing under newParent.
		private static function _ungroupObject(model:KModel, oldParent:KGroup, newParent:KGroup,
											   object:KObject, ungroupTime:Number):IModelOperation
		{			
			var ops:KCompositeOperation = new KCompositeOperation();
			
			KGroupUtil.setParentKey(ungroupTime,object,newParent);
			oldParent.updateCenter();
			if (!newParent.children.contains(object))
				newParent.add(object);
			
			if (!_hasChildren(oldParent, ungroupTime))
				oldParent.addActivityKey(ungroupTime,0);
			
			dispatchUngroupOperationEvent(model, oldParent, object);
			
			ops.addOperation(new KUngroupOperation(model,object,ungroupTime,oldParent,newParent));
			return ops;
		}
		
		// Select KStroke from it iterator and return a list of KStroke. 
		private static function _selectedStrokes(notParent:KGroup,it:IIterator,
												 time:Number):KModelObjectList
		{
			var strokes:KModelObjectList = new KModelObjectList();
			while (it.hasNext())
			{
				var object:KObject = it.next();
				if (object is KStroke && !strokes.contains(object) && 
					object.getParent(time) != notParent)
					strokes.add(object);
				else if (object is KGroup)
					strokes.merge(_selectedStrokes(notParent,
						(object as KGroup).directChildIterator(time),time));
			}
			return strokes;
		}
		
		private static function _getKeyFrameTimes(keys:Vector.<IKeyFrame>):Vector.<Number>
		{
			var times:Vector.<Number> = new Vector.<Number>();
			for (var i:int; i < keys.length; i++)
				if (times.indexOf(keys[i].endTime) < 0)
					times.push(keys[i].endTime);
			return times;
		}
		
		private static function _getParentKeyFrames(model:KModel):Vector.<IKeyFrame>
		{
			var keys:Vector.<IKeyFrame> = new Vector.<IKeyFrame>();
			var it:IIterator = model.iterator;
			while (it.hasNext())
				keys = keys.concat(it.next().getParentKeys());
			return keys;
		}
		
		// Remove consecutive duplicate parent keys from the object parent key list.
		private static function _removeDuplicateParentKeys(object:KObject):IModelOperation
		{
			var keys:Vector.<IKeyFrame> = object.getParentKeys();
			var rmKeys:Vector.<IKeyFrame> = new Vector.<IKeyFrame>;
			for (var i:int=1; i < keys.length; i++)
			{
				var key1:IParentKeyFrame = keys[i-1] as IParentKeyFrame; 
				var key2:IParentKeyFrame = keys[i] as IParentKeyFrame;
				if (key1.parent.id == key2.parent.id)
					rmKeys.push(object,object.removeParentKey(key2.endTime));
			}
			return rmKeys.length > 0 ? new KRemoveParentKeyFrameOperation(object,rmKeys):null;
		}
		
		// Remove the parent key frames of the object with endTime greater that time.
		private static function _removeFutureParentKeys(object:KObject,time:Number):IModelOperation
		{
			var removedKeys:Vector.<IKeyFrame> = new Vector.<IKeyFrame>();
			var allKeys:Vector.<IKeyFrame> = object.getParentKeys();
			for (var i:int=0; i < allKeys.length; i++)
				if (allKeys[i].endTime > time)
					removedKeys.push(object.removeParentKey(allKeys[i].endTime));
			return removedKeys.length > 0 ? 
				new KRemoveParentKeyFrameOperation(object,removedKeys) : null;
		}
		
		// Remove all KGroup object under group with only one child at time, 
		// and put the child to the parent of the removed KGroup object.
		private static function _removeSingletonGroups(model:KModel,group:KGroup,
													   time:Number):IModelOperation
		{
			var ops:KCompositeOperation = new KCompositeOperation();
			var it:IIterator = group.directChildIterator(time);
			while (it.hasNext())
			{
				var obj:KObject = it.next();
				var gp:KGroup = obj is KGroup ? obj as KGroup : null;
				if (gp && _singleChildren(gp,time))
				{	
					const _TRANSLATION_REF:int = KTransformMgr.TRANSLATION_REF;
					const _ROTATION_REF:int = KTransformMgr.ROTATION_REF;
					const _SCALE_REF:int = KTransformMgr.SCALE_REF;					
					var tMaxTime:Number = _getLastKeyTime(gp.getSpatialKeys(_TRANSLATION_REF));
					var rMaxTime:Number = _getLastKeyTime(gp.getSpatialKeys(_ROTATION_REF));
					var sMaxTime:Number = _getLastKeyTime(gp.getSpatialKeys(_SCALE_REF));
					var child:KObject = gp.directChildIterator(time).next();
					var ctMaxTime:Number = _getLastKeyTime(child.getSpatialKeys(_TRANSLATION_REF));
					var maxTime:Number = Math.max(tMaxTime,rMaxTime,sMaxTime,ctMaxTime);
					var matrix1:Matrix = child.getFullPathMatrix(maxTime);
					
					//				gp.addActivityKey(time,0);
					
					if (!group.children.contains(child))
						group.add(child);
					
					group.addActivityKey(time,1);
					KGroupUtil.setParentKey(time,child,group);
					
					dispatchUngroupOperationEvent(model, gp, child);
					dispatchUngroupOperationEvent(model, group, gp);					
					ops.addOperation(new KUngroupOperation(model,child,time,gp,group));		
					
					if (time < tMaxTime)
						KMergerUtil.mergeKeys(child,gp,time,ops,_TRANSLATION_REF);
					
					if (time < rMaxTime)
						KMergerUtil.mergeKeys(child,gp,time,ops,_ROTATION_REF);
					
					if (time < sMaxTime)
						KMergerUtil.mergeKeys(child,gp,time,ops,_SCALE_REF);
					
					group.updateCenter();
					
					var matrix2:Matrix = child.getFullPathMatrix(maxTime);
					var p1:Point = matrix1.transformPoint(child.defaultCenter);
					var p2:Point = matrix2.transformPoint(child.defaultCenter);
					if ((p1.x != p2.x || p1.y != p2.y) && time < maxTime)
					{
						var op:IModelOperation = KMergerUtil.addInterpolatedTranslation(
							child,p2,p1,time,maxTime);
						if (op != null)
							ops.addOperation(op);
					}
				}
				var rmOp:IModelOperation = gp ? _removeSingletonGroups(model,gp,time) : null;
				if (rmOp)
					ops.addOperation(rmOp);
			}
			return ops.length > 0 ? ops : null;
		}
		
		// Obtain the end time of the last key in keys list. 
		private static function _getLastKeyTime(keys:Vector.<IKeyFrame>):Number
		{
			return keys[keys.length-1].endTime;
		}
		
		// Determine if the group has any direct children at kskTime. 
		private static function _hasChildren(group:KGroup, kskTime:Number):Boolean
		{
			return group.directChildIterator(kskTime).hasNext();
		}		
		
		// Determine if the group has only one direct children at kskTime. 
		private static function _singleChildren(group:KGroup, kskTime:Number):Boolean
		{
			var it:IIterator = group.directChildIterator(kskTime);
			return it.hasNext() && it.next() && !it.hasNext();
		}
	}
}