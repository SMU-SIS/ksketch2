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
	import sg.edu.smu.ksketch2.model.data_structures.KModelObjectList;
	import sg.edu.smu.ksketch2.model.data_structures.KPath;
	import sg.edu.smu.ksketch2.model.data_structures.KSceneGraph;
	import sg.edu.smu.ksketch2.model.objects.KGroup;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.operators.operations.IModelOperation;
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;

	/**
	 * The KStaticGroupingUtil class serves as the concrete class for
	 * utilizing static grouping in K-Sketch.
	 */
	public class KStaticGroupingUtil extends KGroupingUtil
	{
		public static var STATIC_GROUP_TIME:int = 0;	// static variable for handling static group time
		
		/**
		 * The main constructor of the KStaticGroupingUtil class.
		 */
		public function KStaticGroupingUtil()
		{
			super();
		}
		
		override public function group(objects:KModelObjectList, commonParent:KGroup, groupTime:int, scene:KSceneGraph, op:KCompositeOperation):KObject
		{
			if(objects.length() == 0)
				throw new Error("KGroupUtil.groupStatic: No objects in the objectlist given. Wth dood");
			
			_static_CollapseHierarchy(objects, commonParent, groupTime, scene, op);
			
			//RIght, we need to deal with the case of breaking ONE bloody object out.
			if(objects.length() == 1)
			{
				var the_one_object:KObject = objects.getObjectAt(0);
				
				//Group that dude to the root if needed
				if(the_one_object.parent != scene.root)
					op.addOperation(KGroupingUtil.addObjectToParent(the_one_object, scene.root));
				
				return the_one_object;
			}
			else
				return _groupObjects(objects, commonParent, groupTime, scene, op);
		}
		
		/**
		 * Ungroups the given list of objects. This method is hardcorded.
		 * Given a list of objects Puts all strokes in the set of objects
		 * (even the children/grandchildren/great grand children/the whole
		 * family) into the root! Returns a list of all ungrouped objects.
		 * 
		 * @param toUngroupList The list of objects to ungroup.
		 * @param ungroupTime The target time of the list of objects to ungroup.
		 * @param scene The corresponding target scene graph.
		 * @param op The corresponding composite operation.
		 * @return The ungrouped list of objects.
		 */
		override public function ungroup(toUngroupList:KModelObjectList, ungroupTime:int, scene:KSceneGraph,
										 op:KCompositeOperation):KModelObjectList
		{
			var result:KModelObjectList = new KModelObjectList();
			var object:KObject;
			var i:int = 0;
			
			//Need to assume that there are no repeats in the list of objects to ungroup
			for(i = 0; i < toUngroupList.length(); i++)
			{
				object = toUngroupList.getObjectAt(i);
				
				if(object is KGroup)
				{
					var children:KModelObjectList = new KModelObjectList();
					var j:int;

					for(j = 0; j < (object as KGroup).length(); j++)
						children.add((object as KGroup).getObjectAt(j));
					
					var sublist:KModelObjectList = ungroup(children, ungroupTime, scene, op);
					
					for(j = 0; j < sublist.length(); j++)
						result.add(sublist.getObjectAt(j));
				}
				else
				{
					if(object.parent != scene.root)
						_topDownCollapse(object, scene.root, ungroupTime, scene, op);
					result.add(object);
				}
			}
			
			return result;
		}
		
		/**
		 * Merges the objects' hierarchies's transforms into the objects themselves
		 * empowering the objects with their ancestors' powers
		 */
		private function _static_CollapseHierarchy(objects:KModelObjectList, stopParent:KGroup, stopCollapseTime:int,
												   scene:KSceneGraph, op:KCompositeOperation):void
		{
			//Assume that the object list given consists of the highest order
			//of object combinations possible ie. objects with common parents will
			//be given as one KGroup
			var currentObject:KObject;
			var parent:KGroup;
			
			var translatePath:KPath;
			//Iterate through the list of objects
			for(var i:int = 0; i<objects.length(); i++)
			{
				currentObject = objects.getObjectAt(i);
				_topDownCollapse(currentObject, stopParent, stopCollapseTime,scene, op)
			}
		}
		
		private function _topDownCollapse(object:KObject, stopParent:KGroup, stopCollapseTime:int,
										  scene:KSceneGraph, op:KCompositeOperation):void
		{
			if(object.parent != stopParent && object.parent != scene.root)
			{
				_topDownCollapse(object.parent, stopParent, stopCollapseTime,scene, op);
				object.transformInterface.mergeTransform(object.parent, stopCollapseTime, op);
				op.addOperation(KGroupingUtil.addObjectToParent(object, object.parent.parent));
			}
		}
		
		override public function removeSingletonGroups(currentGroup:KGroup, model:KSceneGraph, op:KCompositeOperation):void
		{
			// recursively traverse all the way down to the groups at the bottom first
			var children:KModelObjectList = currentGroup.children;
			var currentObject:KObject;
			var i:int;
			var removeChildSingletonOp:IModelOperation;
			
			for(i = 0; i< children.length();i++)
			{
				if(i < 0)
					continue;
				
				currentObject = children.getObjectAt(i);
				if(currentObject is KGroup)
				{
					removeSingletonGroups(currentObject as KGroup, model, op);
					
					if(currentObject.parent != currentGroup)
					{
						children = currentGroup.children;
						i = -1;
					}
				}
			}
			
			// case: is a Root
			// don't do anything
			if(currentGroup == model.root)
				return;
			
			var numChildren:int = currentGroup.children.length();

			// case: not a singleton group
			// don't do anything
			if(numChildren > 1)
				return;
			
			// singleton group, 1 child
			// merge motion into child
			if(numChildren == 1)
			{	
				var child:KObject = currentGroup.children.getObjectAt(0);
				// merge motion into child
				_static_CollapseHierarchy(currentGroup.children, currentGroup.parent, currentGroup.transformInterface.lastKeyTime, model, op);
			}
			
			// remove the current group from the model
			var oldParent:KGroup = currentGroup.parent;
			if(oldParent)
				op.addOperation(addObjectToParent(currentGroup, null));
		}
	}
}