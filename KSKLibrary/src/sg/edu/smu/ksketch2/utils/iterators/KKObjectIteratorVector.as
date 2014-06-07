/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.utils.iterators
{
	import sg.edu.smu.ksketch2.model.objects.KObject;
	
	/**
	 * This iterator returns (in order) each KObject in a vector of KObjects.
	 */
	public class KKObjectIteratorVector implements IKObjectIterator
	{
		private var _index:uint = 0;
		private var _objects:Vector.<KObject>;
		
		/**
		 * Creates a new KKObjectIteratorVector from a vector of KObjects.
		 */
		public function KKObjectIteratorVector(objects:Vector.<KObject>)
		{
			_objects = objects;
			reset();
		}
		
		/**
		 * Reset the iterator to point to the first element.
		 */
		public function reset():void
		{
			_index = 0;
		}
		
		/**
		 * Return the next element.
		 * Call hasNext to verify that there in an element before calling this method.
		 * If there are no more elements, then this will throw an error. 
		 * 
		 * @return The next element.
		 */
		public function next():KObject
		{
			return _objects[_index++];
		}
		
		/**
		 * Check if there are more elements to iterate over.
		 * 
		 * @return True iff there are more elements.
		 */
		public function hasNext():Boolean
		{
			return _objects && _index < _objects.length;
		}
	}
}