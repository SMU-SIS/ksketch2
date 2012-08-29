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
	import flash.errors.IllegalOperationError;
	import flash.utils.getQualifiedClassName;
	
	import sg.edu.smu.ksketch.event.KGroupUngroupEvent;
	import sg.edu.smu.ksketch.event.KModelEvent;
	import sg.edu.smu.ksketch.event.KObjectEvent;
	import sg.edu.smu.ksketch.model.IParentKeyFrame;
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.model.KModel;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.model.implementations.KReferenceFrame;
	import sg.edu.smu.ksketch.operation.KModelFacade;
	import sg.edu.smu.ksketch.utilities.ErrorMessage;
	import sg.edu.smu.ksketch.utilities.IIterator;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;
	
	public class KGroupingUtil implements IGroupingUtil
	{		
		/**
		 * ABSTRACT CLASS: DO NOT CALL THIS UTIL ON ITS OWN
		 * Provides the base functions that a grouping utility needs
		 */
		public function KGroupingUtil()
		{
			if (getQualifiedClassName(this) == "sg.edu.smu.ksketch.operation.grouping::KGroupingUtil")
				throw new IllegalOperationError(ErrorMessage.ABSTRACT_CLASS_INSTANTIATED);
		}
		
		/**
		 * Prepares the objects that are to be grouped for grouping
		 * Technically speaking, this function is just a ungroup then group for translation operations
		 * Should be deprecated soon.
		 */
		
		/**
		 * Creates a new group given the list of objects.
		 * Behaviour of this function is mode specific.
		 */
		public function group(objectList:KModelObjectList, groupUnder:KGroup, groupTime:Number, model:KModel):KGroup
		{
			if (getQualifiedClassName(this) == "sg.edu.smu.ksketch.operation.grouping::KDefaultGroupingUtil")
				throw new IllegalOperationError(ErrorMessage.ABSTRACT_METHODS_NOT_IMPLEMENTED);
			
			return null;
		}
		
		/**
		 * Parents the given node under the root
		 * Behaviour of this function is mode specific.
		 */
		public function ungroup(object:KObject, ungroupTime:Number, toParent:KGroup, model:KModel):void
		{
			if (getQualifiedClassName(this) == "sg.edu.smu.ksketch.operation.grouping::KDefaultGroupingUtil")
				throw new IllegalOperationError(ErrorMessage.ABSTRACT_METHODS_NOT_IMPLEMENTED);
		}
		
		/**
		 * Scans for and removes singleton groups from the
		 * entire model
		 * Behaviour of this function is mode specific.
		 * Singletons in static => Groups with 1 object throughout.
		 * Singletons in dynamic => Groups with 1 object from time onwards
		 */
		public function removeSingletons(model:KModel):void
		{
			if (getQualifiedClassName(this) == "sg.edu.smu.ksketch.operation.grouping::KDefaultGroupingUtil")
				throw new IllegalOperationError(ErrorMessage.ABSTRACT_METHODS_NOT_IMPLEMENTED);
		}
		
		/**
		 * Returns the parent that the new group will be grouped under.
		 */
		public function findToGroupUnder(objectList:KModelObjectList, type:int, groupTime:Number, root:KGroup):KGroup
		{
			if (getQualifiedClassName(this) == "sg.edu.smu.ksketch.operation.grouping::KDefaultGroupingUtil")
				throw new IllegalOperationError(ErrorMessage.ABSTRACT_METHODS_NOT_IMPLEMENTED);
			
			return null;
		}
		
		/**
		 * Adds given object to a given parent at given groupTime.
		 */
		protected function _addToParent(object:KObject, parent:KGroup, groupTime:Number):void
		{
			//Look for the active parent that the object has at given time.
			var key:IParentKeyFrame = object.getParentKeyAtOrBefore(groupTime) as IParentKeyFrame;
			
			//If there is a parent active at group time
			//Remove the object from the parent. The key doesn't have to be removed
			//Unless it is at the time of grouping.
			if(key != null)
			{
				key.parent.remove(object);
				
				if(key.endTime == groupTime)
					key = object.removeParentKey(key.endTime) as IParentKeyFrame;
			}
			
			var newParentKey:IParentKeyFrame = object.addParentKey(groupTime,parent);
			newParentKey.parent.add(object);
		}
		
		/**
		 * Given a node that has only one child
		 * Collapses that node so that the sole child takes its place in the tree.
		 * This function does not account for the motions lost during the collapse.
		 * Behaviour of this function is mode specific.
		 */
		protected function _collapseHierachy(parentNode:KGroup):void
		{
			if (getQualifiedClassName(this) == "sg.edu.smu.ksketch.operation.grouping::KDefaultGroupingUtil")
				throw new IllegalOperationError(ErrorMessage.ABSTRACT_METHODS_NOT_IMPLEMENTED);
		}
		
		/**
		 * Finds the lowest common parent of the given list of objects at given time.
		 */
		protected static function _lowestCommonParent(objects:KModelObjectList, time:Number, root:KGroup):KGroup
		{
			var parents:KModelObjectList = _getAncestry(objects.getObjectAt(0),time,root);
			for (var i:int = 1; i < objects.length(); i++)
				parents.intersect(_getAncestry(objects.getObjectAt(i),time,root));
			return parents.getObjectAt(0) as KGroup;
		}
		
		/**
		 * _getAncestry returns the ancestry of given object, with the immediate parent
		 * at level 0 of the KModelObjectList.
		 */
		protected static function _getAncestry(object:KObject, time:Number, root:KGroup):KModelObjectList
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
		
		/**
		 * Dispatch group event and transform change event after grouping operation.
		 */
		protected static function _dispatchGroupOperationEvent(model:KModel, group:KGroup, objs:KModelObjectList):void
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
		
		/**
		 * Dispatch ungroup event and transform change event after ungrouping operation.
		 */
		protected static function _dispatchUngroupOperationEvent(model:KModel, parent:KGroup, 
																 object:KObject):void
		{
			model.dispatchEvent(new KGroupUngroupEvent(parent,KGroupUngroupEvent.EVENT_GROUP));
			model.dispatchEvent(new KGroupUngroupEvent(parent,KGroupUngroupEvent.EVENT_UNGROUP));
			parent.dispatchEvent(new KObjectEvent(parent,KObjectEvent.EVENT_TRANSFORM_CHANGED));
			object.dispatchEvent(new KObjectEvent(object,KObjectEvent.EVENT_TRANSFORM_CHANGED));
			object.dispatchEvent(new KObjectEvent(object,KObjectEvent.EVENT_PARENT_CHANGED));
			model.dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATED));
		}
	}
	
}