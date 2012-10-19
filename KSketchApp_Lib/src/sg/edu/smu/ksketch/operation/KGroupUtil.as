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
	
	import sg.edu.smu.ksketch.event.KModelEvent;
	import sg.edu.smu.ksketch.event.KObjectEvent;
	import sg.edu.smu.ksketch.model.IParentKeyFrame;
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.model.KModel;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.model.KStroke;
	import sg.edu.smu.ksketch.operation.implementations.KChangeParentOperation;
	import sg.edu.smu.ksketch.operation.implementations.KCompositeOperation;
	import sg.edu.smu.ksketch.operation.implementations.KGroupOperation;
	import sg.edu.smu.ksketch.utilities.IIterator;
	import sg.edu.smu.ksketch.utilities.KAppState;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;
	
	/**
	 * A class to support grouping operation in KModelFacade.
	 */	
	public class KGroupUtil
	{	
		public static const STATIC_GROUP_TIME:Number = 0;
		
		/**
		 * At the given time, removes the object from its old parent and switches it to be under the new parent.
		 * newParent can be null, but it must be specified.
		 */
		public static function addObjectToParent(time:Number, object:KObject, newParent:KGroup, op:KCompositeOperation):void
		{
			time = STATIC_GROUP_TIME;
			
			var key:IParentKeyFrame = object.getParentKeyAtOrBefore(time) as IParentKeyFrame;
			var oldParent:KGroup;
			if(key != null)
			{
				oldParent = key.parent;
				object.removeParentKey(time) as IParentKeyFrame;
			}
			
			if(newParent)
				object.addParentKey(time,newParent);
			
			if(op)
				op.addOperation(new KChangeParentOperation(object, newParent, oldParent, time));
		}
		
		/**
		 * Create a group of objects at kskTime with center in static grouping mode. 
		 */			
		public static function groupStatic(model:KModel, objs:KModelObjectList, time:Number, staticGroupOperation:KCompositeOperation):KObject
		{
			if(objs.length() == 0)
				throw new Error("KGroupUtil.groupStatic: No objects in the objectlist given. Wth dood");
			
			//Assume that the object list given consists of the highest order
			//of object combinations possible ie. objects with common parents will
			//be given as one KGroup
			var it:IIterator = objs.iterator;
			var currentObject:KObject;
			var collapseOperation:IModelOperation;
			
			//Need a parent within the objects' common hierarchy to stop the merge
			//Merging does not include this parent
			var stopMergingAtParent:KGroup;
			
			//Find the lowest common parent if there are more than 1 object
			if(1 < objs.length())
				stopMergingAtParent= _lowestCommonParent(objs, STATIC_GROUP_TIME);
			else
				stopMergingAtParent = model.root; //one object, break it out! merge everything!!

			trace("Common Parent derived for grouping is group", stopMergingAtParent.id);
			
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
				KMergerUtil.MergeHierarchyMotionsIntoObject(stopMergingAtParent,currentObject, time, staticGroupOperation);
			}
			
			//RIght, we need to deal with the case of breaking ONE bloody object out.
			if(objs.length() == 1)
			{
				var the_one_object:KObject = objs.getObjectAt(0);
				
				//Group that dude to the root if needed
				if(the_one_object.getParent(STATIC_GROUP_TIME).id != model.root.id)
				{
					addObjectToParent(STATIC_GROUP_TIME, the_one_object, model.root, staticGroupOperation);
					
				}
				
				return the_one_object;
			}
			else
				return _group(objs, stopMergingAtParent,STATIC_GROUP_TIME, model, staticGroupOperation);
		}
		
		/**
		 * Groups the given list of objects together in a new group and adds the new group under grandParent at group time 
		 */
		private static function _group(objs:KModelObjectList, grandParent:KGroup, groupTime:Number, model:KModel,
									   operation:KCompositeOperation):KGroup
		{	
			if(objs.length() <= 1)
				throw new Error("one does not simply group one object, it'll feel lonely in a group you know.");
			
			var groupOp:KCompositeOperation = new KCompositeOperation();

			//create the new parent and put it under the grandparent
			var newParent:KGroup = new KGroup(model.nextID, groupTime, new KModelObjectList(), null);
			addObjectToParent(groupTime,newParent,grandParent, groupOp);
			
			//Add the objects in the given list to the new parent 
			var it:IIterator = objs.iterator;

			while (it.hasNext())
				addObjectToParent(groupTime,it.next(),newParent, groupOp);
			
			newParent.updateCenter();
			newParent.transformMgr.addInitialKeys(groupTime);
			
			if(groupOp.length > 0)
				operation.addOperation(groupOp);
			
			return newParent;
		}
		
		/**
		 * Optimised code path for removal of singleton group in static grouping mode.
		 * recursive, collapses group from leaves and branches upwards
		 */
		public static function removeStaticSingletonGroup(currentGroup:KGroup, model:KModel, removeStaticSingletonOp:KCompositeOperation):void
		{
			//Recursively traverse all the way down to the groups at the bottom first
			var groupIterator:IIterator = currentGroup.iterator;
			var children:Vector.<KObject> = new Vector.<KObject>();
			
			while(groupIterator.hasNext())
				children.push(groupIterator.next());
			
			var currentObject:KObject;
			var i:int;
			var length:int = children.length;
			var removeChildSingletonOp:IModelOperation;

			for(i = 0; i<length;i++)
			{
				currentObject = children[i];
				if(currentObject is KGroup)
					removeStaticSingletonGroup(currentObject as KGroup, model, removeStaticSingletonOp);
			}
			
			//Root, dont do anything
			if(currentGroup.id == 0)
				return;
	
			var numChildren:int = currentGroup.children.length();
			//Not singleton group, dont do anything
			if(numChildren > 1)
				return;
			
			
			trace("********************Trigger singleton purging at group",currentGroup.id,"**************************");
			
			//Singleton group, 1 child, merge motion into child
			if(numChildren == 1)
			{	
				var child:KObject = currentGroup.children.getObjectAt(0);
				//Merge motion into child
				var grandParent:KGroup = currentGroup.getParent(KGroupUtil.STATIC_GROUP_TIME);
				trace("Singleton merging", child.id,"with", currentGroup.id, "and parenting it under", grandParent.id);
				KMergerUtil.MergeHierarchyMotionsIntoObject(grandParent, child, Number.MAX_VALUE, removeStaticSingletonOp);

				var oldParents:Vector.<KGroup> = new Vector.<KGroup>();
				oldParents.push(currentGroup);
				//Move child to parent
				KGroupUtil.addObjectToParent(KGroupUtil.STATIC_GROUP_TIME, child, grandParent,removeStaticSingletonOp);
			}
			
			//Remove the current group from the model
			var oldParent:KGroup = currentGroup.getParent(KGroupUtil.STATIC_GROUP_TIME);
			if(oldParent)
				KGroupUtil.addObjectToParent(KGroupUtil.STATIC_GROUP_TIME, currentGroup, null,removeStaticSingletonOp);
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
		
		/**
		 * Returns the parent that are common among the list of given objects
		 * It will be the common parent that is lowest in the tree.
		 * If you give this function a list of one object, it will return its immediate parent.
		 */
		private static function _lowestCommonParent(objects:KModelObjectList,time:Number):KGroup
		{	
			var it:IIterator = objects.iterator;
			
			var hierarchy:KModelObjectList = _getHierarchy(it.next(), time, new KModelObjectList());
			while(it.hasNext())
			{
				var next:KObject = it.next();
				var toCompare:KModelObjectList = _getHierarchy(next, time, new KModelObjectList());
				hierarchy.intersect(toCompare);
			}
			return hierarchy.getObjectAt(0) as KGroup;
		}
		
		private static function _getHierarchy(object:KObject, time:Number, hierarchyList:KModelObjectList):KModelObjectList
		{
			var parent:KGroup = object.getParent(time);

			if(parent)
			{
				hierarchyList.add(parent);
				_getHierarchy(parent,time,hierarchyList);
			}
			return hierarchyList;
		}
	}
}