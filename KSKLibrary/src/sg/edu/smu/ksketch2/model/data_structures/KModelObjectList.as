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
	import sg.edu.smu.ksketch2.utils.iterators.IKObjectIterator;
	import sg.edu.smu.ksketch2.utils.iterators.KKObjectIteratorVector;
	
	/**
	 * The KModelObjectList class serves as the concrete class for a list of
	 * model objects.
	 */
	public class KModelObjectList implements IModelObjectList
	{
		private var _objectList:Vector.<KObject>;		// the model object list
		
		/**
		 * The default constructor for initializing the model object list.
		 */
		public function KModelObjectList()
		{
			_objectList = new Vector.<KObject>();
		}
		
		/**
		 * Adds a KObject to the model object list. Its position in the list will
		 * be determined by its ID.
		 * 
		 * @param object The target KObject.
		 * @param index The index in the model object list.
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
		 * Removes a KObject from the model object list.
		 * 
		 * @param object The target KObject.
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
		 * Gets the length of the model object list.
		 * 
		 * @return The length of the model object list.
		 */
		public function length():int
		{
			return _objectList.length;
		}
		
		/**
		 * Checks whether the model object list contains the target KObject.
		 * 
		 * @param object The target KObject.
		 * @return Whether the model object list contains the target KObject.
		 */
		public function contains(obj:KObject):Boolean
		{
			return _objectList.indexOf(obj) > -1;
		}
		
		/**
		 * Gets the KObject at the target index.
		 * 
		 * @param index The target index.
		 * @return The KObject from the target index in the model object list.
		 */
		public function getObjectAt(index:int):KObject
		{
			return _objectList[index];
		}
		
		public function getAllObjectsInArray():Array
		{
			var array:Array = new Array(_objectList.length);
			// iterate through the model object list
			for(var i:int = 0; i<_objectList.length; i++)
			{
				array[i] = _objectList[i];
			}
			
			return array;
		}
		
		/**
		 * Gets the list of IDs for each KObject in the model object list.
		 * 
		 * @return The list of IDs for each KObject in the model object list.
		 */
		public function toIDs():Vector.<int>
		{
			// initialize the list of IDs
			var ints:Vector.<int> = new Vector.<int>();
			
			// iterate through each KObject in the model object list
			for(var i:int = 0; i < _objectList.length; i++)
			{
				// add the KObject's ID to the list
				ints.push(_objectList[i].id);
			}
			
			// get the list of each KObject's IDs
			return ints;
		}
		
		/**
		 * Returns an interator that gives the KObjects in this list, in order from beginning to end. 
		 */
		public function iterator():IKObjectIterator
		{
			return new KKObjectIteratorVector(_objectList);
		}

		/**
		 * Gets the string representation of the model object list.
		 * 
		 * @return The string representation of the model object list.
		 */
		public function toString():String
		{
			// initialize the string
			var str:String = "";
			
			// iterate through each object in the model object list
			for(var i:int = 0; i < _objectList.length; i++)
			{
				// append the KObject's ID
				str += _objectList[i].id.toString() +" ";
			}
			
			// get the string representation
			return str;
		}
		
		/**
		 * Intersects the model object list with the other model object list by removing all objects
		 * in the model object list not present in the other model object list, given another model
		 * object list. This function modifies the model object list.
		 * 
		 * @param toIntersect The other model object list.
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
		 * Compares whether both model object lists have identical composition. Assume that
		 * any composite objects will have the identical composition when using this method.
		 * 
		 * @param comparedTo The other model object list.
		 * @return Whether both model object lists have idential composition.
		 */
		public function isDifferent(comparedTo:IModelObjectList):Boolean
		{
			// case: the other model object list doesn't exist
			if(!comparedTo)
				return true;
			
			// case: the two model object lists have different lengths
			if(comparedTo.length() != length())
				return true;
			
			var i:int;
			var currentObject:KObject;
			
			// do one-to-one comparisons between both model object lists
			for(i = 0; i < _objectList.length; i++)
			{
				currentObject = _objectList[i];
				
				if(!comparedTo.contains(currentObject))
					return true
			}
			
			return false;
		}
		
		/**
		 * Gets the KObject from its ID.
		 * 
		 * @param id The KObject's ID.
		 * @return The ID's corresponding KObject.
		 */
		public function getObjectByID(id:int):KObject
		{
			// iterate through the model object list
			for(var i:int = 0; i<_objectList.length; i++)
			{
				// case: IDs match
				if(_objectList[i].id == id)
					return _objectList[i];
			}
			
			// handle case when no KObject in the model object list has this ID
			throw new Error("Object "+id.toString()+" does not exist in this list!");
			return null;
		}
		
		/**
		 * Gets a clone of the model object list.
		 * 
		 * @return A clone of the model object list.
		 */
		public function clone():KModelObjectList
		{
			var newList:KModelObjectList = new KModelObjectList();
			
			for(var i:int = 0; i<_objectList.length; i++)
				newList.add(_objectList[i]);
			
			return newList;
		}
	}
}