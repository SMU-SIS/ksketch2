/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.model.data_structures
{
	import sg.edu.smu.ksketch2.model.objects.KObject;
	
	public class KModelObjectList implements IModelObjectList
	{
		private var _objectList:Vector.<KObject>;
		
		/**
		 * Data structure with functions to manipulate a sorted list of objects
		 * objects are sorted according to their ids
		 */
		public function KModelObjectList()
		{
			_objectList = new Vector.<KObject>();
		}
		
		/**
		 * Adds the given object to the sorted list. Its position in the list will
		 * be determined by its id.
		 */
		public function add(object:KObject, index:int = -1):void
		{
			if(_objectList.indexOf(object) < 0)
			{
				if(index < 0)
					_objectList.push(object);
				else
					_objectList.splice(index, 0, object);
			}
			else
				throw new Error("Object "+object.id+" exists in this list!");
		}
		
		/**
		 * Removes the given object from this KModelObjectList
		 */
		public function remove(object:KObject):void
		{
			var index:int = _objectList.indexOf(object);
			if(index >= 0)
				_objectList.splice(index,1);
			else
				throw new Error("Object does not exist in this list!");
		}
		
		/**
		 * Number of objects in this KModelObjectList
		 */
		public function length():int
		{
			return _objectList.length;
		}
		
		/**
		 * Checks if this KModelObjectList contains the given object
		 */
		public function contains(obj:KObject):Boolean
		{
			return _objectList.indexOf(obj) > -1;
		}
		
		
		public function getObjectAt(index:int):KObject
		{
			return _objectList[index];
		}
		
		public function toIDs():Vector.<int>
		{
			var ints:Vector.<int> = new Vector.<int>();
			for(var i:int = 0; i < _objectList.length; i++)
			{
				ints.push(_objectList[i].id);
			}
			return ints;
		}
		
		public function toString():String
		{
			var str:String = "";
			for(var i:int = 0; i < _objectList.length; i++)
				str += _objectList[i].id.toString();
			return str;
		}
		
		/**
		 * Given another IModelObjectList, intersect removes all objects
		 * that is not present in the other IModelObjectList from this list/
		 * This function modifies this KModelObjectList.
		 */
		public function intersect(toIntersect:IModelObjectList):void
		{
			var i:int;
			var currentObject:KObject;
			
			for(i = 0; i < _objectList.length; i++)
			{
				currentObject = _objectList[i];
				
				if(!toIntersect.contains(currentObject))
					remove(currentObject);
			}
		}
		
		/**
		 * Method for comparing whether both model object lists have identical composition
		 * Take not that only the objects directly recorded in the lists will be cmopared.
		 * We will be assuming that any composite objects will have the identical composition when
		 * using this method.
		 */
		public function isDifferent(comparedTo:IModelObjectList):Boolean
		{
			if(!comparedTo)
				return true;
			
			if(comparedTo.length() != length())
				return true;
			
			var i:int;
			var currentObject:KObject;
			
			for(i = 0; i < _objectList.length; i++)
			{
				currentObject = _objectList[i];
				
				if(!comparedTo.contains(currentObject))
					return true
			}
			
			return false;
		}
		
		public function getObjectByID(id:int):KObject
		{
			
			for(var i:int = 0; i<_objectList.length; i++)
			{
				if(_objectList[i].id == id)
					return _objectList[i];
			}
			throw new Error("Object does not exist in this list!");
			return null;
		}
	}
}