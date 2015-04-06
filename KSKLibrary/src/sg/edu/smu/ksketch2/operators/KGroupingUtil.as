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
	import sg.edu.smu.ksketch2.model.data_structures.KSceneGraph;
	import sg.edu.smu.ksketch2.model.objects.KGroup;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.operators.operations.IModelOperation;
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;
	import sg.edu.smu.ksketch2.operators.operations.KParentChangeOperation;

	/**
	 * The KGroupingUtil class serves as the concrete class for utilizing
	 * grouping in K-Sketch.
	 */
	public class KGroupingUtil
	{
		/**
		 * The main constructor of the KGroupingUtil class.
		 */
		public function KGroupingUtil()
		{
		}
		
		/**
		 * Gets the operation utility for adding an object to its previous
		 * and current parent.
		 * 
		 * @param object The target object.
		 * @param parent The target parent.
		 * @return The utility operation for grouping the object with its
		 * previous and current parent.
		 */
		public static function addObjectToParent(object:KObject, parent:KGroup):IModelOperation
		{
			// get the older parent
			var oldParent:KGroup = object.parent;
			
			// set the given object's parent to the given parent
			object.parent = parent;

			// return the grouping utility of the object and its older and current parent
			return new KParentChangeOperation(object, parent, oldParent);
		}
		
		/**
		 * Generic grouping function. Should be overwritten with a grouping
		 * mode's specific grouping methods. This thing might not return a
		 * KGroup. If a single object is given, it will process the object
		 * according to the grouping util's capabilities and return it.
		 * 
		 * @param objects The list of objects to group.
		 * @param commonParent The parent commonly shared by the list of objects.
		 * @param groupTime The target time of the list of objects to group.
		 * @param scene The corresponding target scene graph.
		 * @param op The corresponding composite operation.
		 * @return The grouped list of objects.
		 */
		public function group(objects:KModelObjectList, commonParent:KGroup, groupTime:Number, scene:KSceneGraph, op:KCompositeOperation, breakToRoot:Boolean):KObject
		{
			return _groupObjects(objects, commonParent, groupTime, scene, op, breakToRoot);
		}
		
		/**
		 * Generic ungrouping function.  Ungroup the given group and parents
		 * all its direct children into its parent. Effects are dependent on
		 * the active grouping mode. Returns a list of objects that were
		 * ungrouped. Objects that were not ungrouped will not be returned.
		 * Returned result will not be ordered according to their IDs.
		 * 
		 * @param toUngroupList The list of objects to ungroup.
		 * @param ungroupTime The target time of the list of objects to ungroup.
		 * @param scene The corresponding target scene graph.
		 * @param op The corresponding composite operation.
		 * @return The ungrouped list of objects.
		 */
		public function ungroup(toUngroupList:KModelObjectList, ungroupTime:Number, scene:KSceneGraph, op:KCompositeOperation):KModelObjectList
		{
			return _ungroupObjects(toUngroupList, ungroupTime, scene, op)
		}
		
		/**
		 * Housekeeping method to remove singleton/empty groups from the
		 * scene graph. How it modifies the model depends on what type of
		 * grouping util it is being called with.
		 * 
		 * @param currentGroup The current group of objects.
		 * @param model The corresponding scene graph.
		 * @param op The corresponding composite operation.
		 */
		public function removeSingletonGroups(currentGroup:KGroup, model:KSceneGraph, op:KCompositeOperation):void
		{
			
		}
		
		/**
		 * Finds the lowest common parent of the given list of objects.
		 * Returns null if there are no common parents.
		 * 
		 * @param objects The list of objects.
		 * @return The lowest common parent of the given list of objects.
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
		 * The actual grouping function. It literally bunches the objects
		 * into a new group under the grandparent and definitely returns a KGroup object.
		 * 
		 * @param objects The list of objects to group.
		 * @param commonParent The parent commonly shared by the list of objects.
		 * @param groupTime The target time of the list of objects to group.
		 * @param scene The corresponding target scene graph.
		 * @param op The corresponding composite operation.
		 * @return The grouped list of objects.
		 */
		protected function _groupObjects(objects:KModelObjectList, commonParent:KGroup, groupTime:Number, scene:KSceneGraph, op:KCompositeOperation, breakToRoot:Boolean):KGroup
		{	
			// case: there is at most one oject in the group
			// throw an error
			if(objects.length() <= 1)
				throw new Error("Grouping requires more than 1 object. Only 1 object is selecetd.");
			
			// create the new group
			var newGroup:KGroup = new KGroup(scene.nextHighestID);
			var newParent:KGroup;
			
			if(!breakToRoot)
				newParent = commonParent;
			
			scene.registerObject(newGroup, newParent, false, op);
			newGroup.init(groupTime, op);
			
			//TRACE GROUP CENTROID
			trace("==============================================================");
			if(newParent)
				trace("KGroupingUtil > _groupObjects() > parent: " + newParent.id + ", kobject: " + newGroup.id);
			else
				trace("KGroupingUtil > _groupObjects() > parent: null, kobject: " + newGroup.id);
			trace("original center: x = " + newGroup.center.x + ", y = " + newGroup.center.y);
			//END OF TRACE
			
			
			// add the objects in the given list to the new parent 
			for(var i:int = 0; i< objects.length(); i++)
				op.addOperation(addObjectToParent(objects.getObjectAt(i), newGroup));
			//Fix for exponential centroids. Update center after children are added to the group
			newGroup.updateCenter();
			// return the newly-created grouped list of objects
			return newGroup;
		}
		
		/**
		 * The actual ungrouping function. It dumps the children of the
		 * given group into the grandparent. Objects ungrouped in this
		 * manner loses all of its parent's transform operations.
		 * 
		 * @param toUngroupList The list of objects to ungroup.
		 * @param ungroupTime The target time of the list of objects to ungroup.
		 * @param scene The corresponding target scene graph.
		 * @param op The corresponding composite operation.
		 * @return The ungrouped list of objects.
		 */
		protected function _ungroupObjects(toUngroupList:KModelObjectList, ungroupTime:Number, scene:KSceneGraph,
										   op:KCompositeOperation):KModelObjectList
		{
			// adds the objects in the given list to the new parent 
			for(var i:int = 0; i< toUngroupList.length(); i++)
				op.addOperation(addObjectToParent(toUngroupList.getObjectAt(i), scene.root));
			
			return toUngroupList;
		}
	}
}