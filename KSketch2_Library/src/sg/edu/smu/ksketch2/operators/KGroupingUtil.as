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
	import sg.edu.smu.ksketch2.model.objects.KGroup;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.operators.operations.IModelOperation;
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;
	import sg.edu.smu.ksketch2.operators.operations.KParentChangeOperation;

	public class KGroupingUtil
	{
		public function KGroupingUtil()
		{
		}
		
		/**
		 * Operation call to add an object to a parent
		 * Should return an operation
		 */
		public static function addObjectToParent(object:KObject, parent:KGroup):IModelOperation
		{
			var oldParent:KGroup = object.parent;
			object.parent = parent;

			return new KParentChangeOperation(object, parent, oldParent);
		}
		
		/**
		 * Generic grouping function. Should be overwritten with a grouping mode's specific grouping methods.
		 * This thing might not return a KGroup. If a single object is given, it will process the object according to the
		 * grouping util's capabilities and return it
		 */
		public function group(objects:KModelObjectList, commonParent:KGroup, groupTime:int, scene:KSceneGraph, op:KCompositeOperation):KObject
		{
			return _groupObjects(objects, commonParent, groupTime, scene, op);
		}
		
		/**
		 * Ungroup the given group and parents all its direct children into its parent.
		 * Effects are dependent on the active grouping mode.
		 * Returns a list of objects that were ungrouped.
		 * Objects that were not ungrouped will not be returned.
		 * Returned result will not be ordered according to their ids.
		 */
		public function ungroup(toUngroup:KGroup, ungroupTime:int, scene:KSceneGraph, op:KCompositeOperation):KModelObjectList
		{
			return _ungroupObjects(toUngroup, op)
		}
		
		/**
		 * Housekeeping method to remove singleton groups/ empty groups from the scene graph.
		 * How it modifies the model depends on what type of grouping util it is being called with.
		 */
		public function removeSingletonGroups(currentGroup:KGroup, model:KSceneGraph, op:KCompositeOperation):void
		{
			
		}
		
		/**
		 * Function to find the lowest common parent of the given list of object
		 * Returns null if there are no common parents;
		 */
		public function lowestCommonParent(objects:KModelObjectList):KGroup
		{
			if(objects.length() < 2)
				throw new Error("We shouldn't try and find the common parent for less than 2 objects");
			
			var hierarchy:KModelObjectList = objects.getObjectAt(0).getHierarchy();

			for(var i:int = 1; i<objects.length(); i++)
			{
				hierarchy.intersect(objects.getObjectAt(i).getHierarchy());
			}
			
			if(hierarchy.length() == 0)
				return null;
			else
				return hierarchy.getObjectAt(0) as KGroup;
		}
		
		/**
		 * The actual grouping function. Literally bunches the objects into a new group until grandparent.
		 * This thing returns a KGroup for sure.
		 */
		protected function _groupObjects(objects:KModelObjectList, commonParent:KGroup, groupTime:int, scene:KSceneGraph, op:KCompositeOperation):KGroup
		{	
			if(objects.length() <= 1)
				throw new Error("one does not simply group one object, it'll feel lonely in a group you know.");
			
			//create the new parent and put it under the grandparent
			var newParent:KGroup = new KGroup(scene.nextHighestID);
			scene.registerObject(newParent, op);
			newParent.init(groupTime, new KCompositeOperation());

			//Add the objects in the given list to the new parent 
			for(var i:int = 0; i< objects.length(); i++)
				op.addOperation(addObjectToParent(objects.getObjectAt(i), newParent));
			
			return newParent;
		}
		
		/***
		 * Actual ungrouping function. Dumps the children of the given group into the grand parent.
		 * Objects ungrouped in this manner loses all of its parent's transform
		 */
		protected function _ungroupObjects(toUngroup:KGroup, op:KCompositeOperation):KModelObjectList
		{
			if(toUngroup.id == 0)
				throw new Error("You Don't Ungroup the root bro");
			
			var grandParent:KGroup = toUngroup.parent;
			var numChildren:int = toUngroup.length();
			var result:KModelObjectList = new KModelObjectList();
			for(var i:int = 0; i < numChildren ; i++)
			{
				var currentChild:KObject = toUngroup.getObjectAt(i);
				result.add(currentChild);
				op.addOperation(addObjectToParent(currentChild, grandParent));
			}
			
			return result;
		}
	}
}