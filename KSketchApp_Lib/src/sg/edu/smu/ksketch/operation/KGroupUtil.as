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
		public static function addObjectToParent(time:Number, object:KObject, newParent:KGroup):IModelOperation
		{
			var key:IParentKeyFrame = object.getParentKeyAtOrBefore(time) as IParentKeyFrame;
			var oldParent:KGroup;
			if(key != null)
			{
				oldParent = key.parent;
				object.removeParentKey(time) as IParentKeyFrame;
			}
			
			if(newParent)
				object.addParentKey(time,newParent);
			
			return new KChangeParentOperation(object, newParent, oldParent, time);
		}
		
		/**
		 * Create a group of objects at kskTime with center in static grouping mode. 
		 */			
		public static function groupStatic(model:KModel, objs:KModelObjectList, time:Number, staticGroupOperation:KCompositeOperation):KObject
		{
			//Assume that the object list given consists of the highest order
			//of object combinations possible ie. objects with common parents will
			//be given as one KGroup
			var it:IIterator = objs.iterator;
			var currentObject:KObject;
			var collapseOperation:IModelOperation;
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
				KMergerUtil.MergeHierarchyMotionsIntoObject(stopMergingAtParent,currentObject, time, staticGroupOperation);
			}
			
			//RIght, we need to deal with the case of breaking ONE bloody object out.
			if(objs.length() == 1)
			{
				var the_one_object:KObject = objs.getObjectAt(0);
				
				//Group that dude to the root if needed
				if(the_one_object.getParent(STATIC_GROUP_TIME).id != model.root.id)
					staticGroupOperation.addOperation(addObjectToParent(STATIC_GROUP_TIME, the_one_object, model.root));
				
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
			//Find the grandparent: parent which the new group will be grouped under
			var grandParent:KGroup = _lowestCommonParent(objs,groupTime,model.root);
			
			var groupOp:KCompositeOperation = new KCompositeOperation();

			//create the new parent and put it under the grandparent
			var newParent:KGroup = new KGroup(model.nextID, groupTime, objs, null);
			groupOp.addOperation(addObjectToParent(groupTime,newParent,grandParent));
			
			//Add the objects in the given list to the new parent 
			var it:IIterator = objs.iterator;
			while (it.hasNext())
				groupOp.addOperation(addObjectToParent(groupTime,it.next(),newParent));
			
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
			
			//Singleton group, 1 child, merge motion into child
			if(numChildren == 1)
			{	
				var child:KObject = currentGroup.children.getObjectAt(0);
				//Merge motion into child
				var grandParent:KGroup = currentGroup.getParent(KGroupUtil.STATIC_GROUP_TIME);
				
				KMergerUtil.MergeHierarchyMotionsIntoObject(grandParent, child, Number.MAX_VALUE, removeStaticSingletonOp);

				var oldParents:Vector.<KGroup> = new Vector.<KGroup>();
				oldParents.push(currentGroup);
				//Move child to parent
				removeStaticSingletonOp.addOperation(KGroupUtil.addObjectToParent(KGroupUtil.STATIC_GROUP_TIME, child, grandParent));
			}
			
			//Remove the current group from the model
			var oldParent:KGroup = currentGroup.getParent(KGroupUtil.STATIC_GROUP_TIME);
			if(oldParent)
				removeStaticSingletonOp.addOperation(KGroupUtil.addObjectToParent(KGroupUtil.STATIC_GROUP_TIME, currentGroup, null));
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
	}
}