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
	
	import sg.edu.smu.ksketch.event.KGroupUngroupEvent;
	import sg.edu.smu.ksketch.event.KModelEvent;
	import sg.edu.smu.ksketch.event.KObjectEvent;
	import sg.edu.smu.ksketch.model.IParentKeyFrame;
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.model.KModel;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.operation.implementations.KCompositeOperation;
	import sg.edu.smu.ksketch.operation.implementations.KGroupOperation;
	import sg.edu.smu.ksketch.utilities.IIterator;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;
	
	/**
	 * A class to support grouping operation in KModelFacade.
	 */	
	public class KGroupUtil
	{	
		public static const STATIC_GROUP_TIME:Number = 0;
		
		/**
		 * Create a group of objects at kskTime with center in static grouping mode. 
		 */			
		public static function groupStatic(model:KModel, objs:KModelObjectList, time:Number):Array
		{
			var staticGroupOperation:KCompositeOperation = new KCompositeOperation();
			
			//Assume that the object list given consists of the highest order
			//of object combinations possible ie. objects with common parents will
			//be given as one KGroup
			var it:IIterator = objs.iterator;
			var currentObject:KObject;
			var collapseOperation:IModelOperation;
			var groupToRootOperation:IModelOperation;
			var stopMergingAtParent:KGroup = _lowestCommonParent(objs, STATIC_GROUP_TIME, model.root);
			
			if(stopMergingAtParent.id != model.root.id)
				stopMergingAtParent = stopMergingAtParent.getParent(STATIC_GROUP_TIME);
			//Iterate through the list of objects
			while(it.hasNext())
			{
				currentObject = it.next();
				
				//If the object is a child of root, nothing to do with it
				//Fly away to the next one
				if(currentObject.getParent(KGroupUtil.STATIC_GROUP_TIME).id == model.root.id)
					continue;
				
				//Collapse the hierachy of this object
				//Merge all of the hierachy's motions into it
				collapseOperation = KMergerUtil.MergeHierarchyMotionsIntoObject(stopMergingAtParent,currentObject, time, "from group static");
				if(collapseOperation)
					staticGroupOperation.addOperation(collapseOperation);
				
				groupToRootOperation = KUngroupUtil.ungroupStatic(model, model.root,currentObject);
				
				if(groupToRootOperation)
					staticGroupOperation.addOperation(groupToRootOperation);
			}
			
			var groupOperation:KGroupOperation
			
			groupOperation = _group(model, objs, KGroupUtil.STATIC_GROUP_TIME) as KGroupOperation;
			staticGroupOperation.addOperation(groupOperation);
			
			if(staticGroupOperation.length == 0)
				return null;
			else
			{
				if(groupOperation)
				{
					var gp:KGroup = groupOperation.group;
					gp.updateCenter(KGroupUtil.STATIC_GROUP_TIME);
					gp.dispatchEvent(new KObjectEvent(gp,KObjectEvent.EVENT_OBJECT_CENTER_CHANGED));
					
					return [staticGroupOperation, gp];
				}
				else
					return [staticGroupOperation, null];
			}
		}
		
		/**
		 * Create a group of objects at kskTime with center in dynamic grouping mode. 
		 */			
		public static function groupDynamic(model:KModel, objs:KModelObjectList, 
											kskTime:Number):IModelOperation
		{
			return _group(model, objs, kskTime);
		}		
		
		public static function setParentKey(time:Number, object:KObject, newParent:KGroup):void
		{
			//var matrices:Vector.<Matrix> = getParentChangeMatrices(object, newParent, time);
			var key:IParentKeyFrame = object.getParentKeyAtOrBefore(time) as IParentKeyFrame;
			if(key != null)
			{
				key = object.removeParentKey(time) as IParentKeyFrame;
				if(key.parent.children.contains(object))
					key.parent.remove(object);
			}

			var newParentKey:IParentKeyFrame = object.addParentKey(time,newParent);
		
			
			//newParentKey.positionMatrix = computePositionMatrix(
				//matrices[0],matrices[1],matrices[2],matrices[3], object.id);
		}
		
		/**
		 * Obtain the lastest consistant time of the objects before given time.
		 * If there exist an inconsistant parent among the objects , return -1. 
		 */	
		public static function lastestConsistantParentKeyTime(objects:KModelObjectList,
															  time:Number):Number
		{
			var keys:Vector.<IParentKeyFrame> = new Vector.<IParentKeyFrame>();
			var firstKey:IParentKeyFrame = objects.getObjectAt(0).getParentKeyAtOrBefore(time);
			var maxTime:Number = firstKey.endTime;
			var it:IIterator = objects.iterator;
			while (it.hasNext())
			{
				var obj:KObject = it.next();
				var key:IParentKeyFrame = obj.getParentKeyAtOrBefore(time);
				if (key.parent != firstKey.parent)
					return -1;
				else
					maxTime = Math.max(maxTime,key.endTime);
			}
			return maxTime;
		}
		
		// Create a group of objects at groupTime with center. 
		private static function _group(model:KModel, objs:KModelObjectList, 
									   groupTime:Number):IModelOperation
		{			
			var parent:KGroup = _lowestCommonParent(objs,groupTime,model.root);
			var group:KGroup = new KGroup(model.nextID, groupTime, objs, null);
			parent.add(group);
			setParentKey(groupTime,group,parent);
			
			var oldParents:Vector.<KGroup> = new Vector.<KGroup>();
			var it:IIterator = objs.iterator;
			while (it.hasNext())
			{
				var obj:KObject = it.next();
				var key:IParentKeyFrame = obj.getParentKeyAtOrBefore(groupTime) as IParentKeyFrame;
				if (key != null && key.parent.children.contains(obj))
					key.parent.remove(obj);
				oldParents.push(key == null ? null : key.parent);
				setParentKey(groupTime,obj,group);
				key = obj.getParentKeyAtOrBefore(groupTime) as IParentKeyFrame;
			}
			
			group.updateCenter();
			group.transformMgr.addInitialKeys(groupTime);
			
			_dispatchGroupOperationEvent(model, group, objs);
			return new KGroupOperation(model, parent, group, oldParents);
		}
		
		// Loop through objs list and return the latest created time.
		private static function _getLatestCreatedTime(objs:KModelObjectList):Number
		{
			var time:Number = 0;
			for (var i:int; i < objs.length(); i++)
				time = Math.max(time,objs.getObjectAt(i).createdTime);
			return time;
		}
		
		private static function _lowestCommonParent(objects:KModelObjectList, 
													time:Number, root:KGroup):KGroup
		{
			if(objects.length() == 1)
				return root;
			
			var parents:KModelObjectList = _getParents(objects.getObjectAt(0),time,root);
			for (var i:int = 1; i < objects.length(); i++)
				parents.intersect(_getParents(objects.getObjectAt(i),time,root));
			return parents.getObjectAt(0) as KGroup;
		}
		
		private static function _getParents(object:KObject, time:Number,
											root:KGroup):KModelObjectList
		{
			var parents:KModelObjectList = new KModelObjectList();
			var gp:KGroup = object.getParent(time);
			while (gp != root)
			{
				parents.add(gp);
				gp = gp.getParent(time);
			}
			parents.add(root);
			return parents;
		}
		
		// Obtain the parent keyframe of the object strictly before given time. 
		private static function _getParentKeyBefore(object:KObject, time:Number, strictlyBefore:Boolean = false):IParentKeyFrame
		{	
			var prevKey:IParentKeyFrame = object.getParentKeyAtOrBefore(time) as IParentKeyFrame;
			
			if(strictlyBefore)
			{
				while (prevKey && prevKey.endTime == time)
					prevKey = prevKey.previous as IParentKeyFrame;
				
				return prevKey;
			}
			else
			{
				return prevKey;
			}
			
			
		}
		
		// Dispatch group event and transform change event after grouping operation.
		private static function _dispatchGroupOperationEvent(model:KModel ,group:KGroup, 
															 objs:KModelObjectList):void
		{
			model.dispatchEvent(new KObjectEvent(group, KObjectEvent.EVENT_OBJECT_ADDED));
			model.dispatchEvent(new KGroupUngroupEvent(group, KGroupUngroupEvent.EVENT_GROUP));
			group.dispatchEvent(new KObjectEvent(group,KObjectEvent.EVENT_TRANSFORM_CHANGED));
			var it:IIterator = objs.iterator;
			while(it.hasNext())
			{
				var obj:KObject = it.next();
				obj.dispatchEvent(new KObjectEvent(obj,KObjectEvent.EVENT_TRANSFORM_CHANGED));
			}
		}
		
		// Obtain the index of the object in the parent. 
		// Return -1 if object is not a child of parent.
		private static function _getObjectIndex(parent:KGroup,object:KObject):int
		{
			var index:int = -1;
			var i:IIterator = parent.iterator;
			while(i.hasNext())
			{
				index ++;
				if(i.next() == object)
					return index;
			}
			return index;
		}		
	}
}