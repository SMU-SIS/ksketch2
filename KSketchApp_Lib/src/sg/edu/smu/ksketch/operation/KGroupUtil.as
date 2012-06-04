/**------------------------------------------------
 * Copyright 2012 Singapore Management University
 * All Rights Reserved
 *
 *-------------------------------------------------*/

package sg.edu.smu.ksketch.operation
{
	import flash.geom.Matrix;
	
	import sg.edu.smu.ksketch.event.KGroupUngroupEvent;
	import sg.edu.smu.ksketch.event.KObjectEvent;
	import sg.edu.smu.ksketch.model.IParentKeyFrame;
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.model.KModel;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.operation.implementations.KGroupOperation;
	import sg.edu.smu.ksketch.utilities.IIterator;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;
	
	/**
	 * A class to support grouping operation in KModelFacade.
	 */	
	public class KGroupUtil
	{	
		/**
		 * Create a group of objects at kskTime with center in static grouping mode. 
		 */			
		public static function groupStatic(model:KModel, objs:KModelObjectList):IModelOperation
		{
			return _group(model, objs, _getLatestCreatedTime(objs));
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
			
			var matrices:Vector.<Matrix> = getParentChangeMatrices(object, newParent, time);
			var key:IParentKeyFrame = object.getParentKey(time) as IParentKeyFrame;
			if(key != null)
				key = object.removeParentKey(time) as IParentKeyFrame;
			var newParentKey:IParentKeyFrame = object.addParentKey(time,newParent);
			newParentKey.positionMatrix = computePositionMatrix(
				matrices[0],matrices[1],matrices[2],matrices[3], object.id);
		}
		
		/**
		 * Call this function before inserting
		 * Returns a vector of matrices that are used to compute a position matrix
		 * [0]:objFullMat:Matrix
		 * [1]:prevParentFPM:Matrix
		 * [2]:newParentFPM:Matrix
		 * [3]:prevPositionMat:Matrix
		 */
		public static function getParentChangeMatrices(object:KObject, newParent:KGroup, 
													   time:Number, strictlyBefore:Boolean = false):Vector.<Matrix>
		{
			var returnVector:Vector.<Matrix> = new Vector.<Matrix>(4);
			
			returnVector[0] = object.getFullMatrix(time);
			
			var prevParentKey:IParentKeyFrame = _getParentKeyBefore(object,time, strictlyBefore);
			
			if(prevParentKey)
			{
				var oldParent:KGroup = prevParentKey.parent;
				
				returnVector[1] = oldParent.getFullPathMatrix(time);
				returnVector[3] = prevParentKey.positionMatrix;
				
				if(newParent)
				{
					returnVector[2] = newParent.getFullPathMatrix(time);
				}
				else
				{
					returnVector[2] = new Matrix();
				}
				
				return returnVector;
			}
			else
			{
				returnVector[1] = new Matrix();
				returnVector[2] = new Matrix();
				returnVector[3] = new Matrix();
				return returnVector;
			}
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
		
		public static function computePositionMatrix(objFullMat:Matrix, prevParentFPM:Matrix, 
													 newParentFPM:Matrix, prevPositionMat:Matrix, 
													 debugID:int=-1):Matrix
		{
			//Clone, just in case things happen and matrices get unnecessarily shared in computation.
			var newPosMat:Matrix = new Matrix();
			newPosMat.concat(prevPositionMat);
			
			var inverseFullMat:Matrix = objFullMat.clone();
			inverseFullMat.invert();
			
			newPosMat.concat(objFullMat);
			newPosMat.concat(prevParentFPM);
			
			newParentFPM.invert();
			newPosMat.concat(newParentFPM);
			
			newPosMat.concat(inverseFullMat);
			return newPosMat;
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
				var key:IParentKeyFrame = obj.getParentKey(groupTime) as IParentKeyFrame;
				if (key != null && key.parent.children.contains(obj))
					key.parent.remove(obj);
				oldParents.push(key == null ? null : key.parent);
				setParentKey(groupTime,obj,group);
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