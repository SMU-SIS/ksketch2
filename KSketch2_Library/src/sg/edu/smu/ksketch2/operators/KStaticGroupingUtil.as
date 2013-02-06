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
	import flash.display.Scene;
	import flash.geom.Matrix;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.model.data_structures.KModelObjectList;
	import sg.edu.smu.ksketch2.model.data_structures.KPath;
	import sg.edu.smu.ksketch2.model.objects.KGroup;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.operators.operations.IModelOperation;
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;
	import sg.edu.smu.ksketch2.model.data_structures.KSceneGraph;

	public class KStaticGroupingUtil extends KGroupingUtil
	{
		public static var STATIC_GROUP_TIME:int = 0;
		
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
		 * Ungroups the given group. Transfers given group's transforms up till ungroup time to its children.
		 * The children will be parented under the given group's parent
		 */
		override public function ungroup(toUngroup:KGroup, ungroupTime:int, scene:KSceneGraph, op:KCompositeOperation):KModelObjectList
		{
			if(toUngroup.id == 0)
				throw new Error("You Don't Ungroup the root bro");
			
			var grandParent:KGroup = toUngroup.parent;
			var numChildren:int = toUngroup.length();
			var result:KModelObjectList = new KModelObjectList();
			for(var i:int = 0; i < numChildren; i++)
				result.add(toUngroup.getObjectAt(i));
			
			_static_CollapseHierarchy(toUngroup.children, grandParent, ungroupTime, scene, op);
			
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
			var matrixBefore:Matrix;
			var matrixAfter:Matrix;
			
			var translatePath:KPath;
			//Iterate through the list of objects
			for(var i:int = 0; i<objects.length(); i++)
			{
				currentObject = objects.getObjectAt(i);
				
				//Merge objects' ancestors powers into itself unutil stopParent or root is reached
				while(currentObject.parent != stopParent && currentObject.parent != scene.root)
				{
					parent = currentObject.parent;
					currentObject.transformInterface.mergeTransform(parent, stopCollapseTime, op);
					op.addOperation(KGroupingUtil.addObjectToParent(currentObject, parent.parent));
				}
			}
		}
		
		override public function removeSingletonGroups(currentGroup:KGroup, model:KSceneGraph, op:KCompositeOperation):void
		{
			//Recursively traverse all the way down to the groups at the bottom first
			var children:KModelObjectList = currentGroup.children;
			
			var currentObject:KObject;
			var i:int;
			var length:int = children.length();
			var removeChildSingletonOp:IModelOperation;
			
			for(i = 0; i<length;i++)
			{
				currentObject = children.getObjectAt(i);
				if(currentObject is KGroup)
					removeSingletonGroups(currentObject as KGroup, model, op);
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
				var grandParent:KGroup = currentGroup.parent;
				_static_CollapseHierarchy(currentGroup.children, grandParent, currentGroup.transformInterface.lastKeyTime, model, op);
			}
			
			//Remove the current group from the model
			var oldParent:KGroup = currentGroup.parent;
			if(oldParent)
				op.addOperation(addObjectToParent(currentGroup, null));
		}
	}
}