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
	import flash.errors.IllegalOperationError;
	
	import sg.edu.smu.ksketch2.model.data_structures.IKeyFrame;

	/**
	 * This iterator returns (in order) the times of all IKeyKrames.
	 */
	public class KNumberIteratorIKeyFrame implements INumberIterator
	{
		private var _head:IKeyFrame;
		private var _current:IKeyFrame;
		
		/**
		 * This iterator returns (in order) the times of all IKeyKrames from head onward.
		 * 
		 * @param The first key frame.
		 */
		public function KNumberIteratorIKeyFrame(head:IKeyFrame)
		{
			_head = head;
			reset();
		}
		
		/**
		 * Reset the iterator to point to the first element.
		 */
		public function reset():void
		{
			_current = _head;
		}
		
		/**
		 * Return the next element.
		 * 
		 * @return The next element.
		 */
		public function next():Number
		{
			var time:Number;
			
			if (_current != null)
			{
				time = _current.time;
				_current = _current.next;
				return time;
			}
			else
			{
				throw new IllegalOperationError("Cannot call next on KNumberIteratorIKeyFrame if there are no more elements."); 
			}
		}
		
		/**
		 * Check if there are more elements to iterate over.
		 * 
		 * @return True iff there are more elements.
		 */
		public function hasNext():Boolean
		{
			return _current !=  null;
		}
		
		/**
		 * Get the first element from this iterator, without changing the current index.
		 * If there are no elements, throws IllegalOperationError.
		 * 
		 * @return The first element
		 */
		public function get first():Number
		{
			if (empty)
			{
				throw new IllegalOperationError("An empty iterator cannot return the first element.");
			}
			
			return _head.time;
		}
		
		/**
		 * Get the last element from this iterator, without changing the current index.
		 * If there are no elements, throws IllegalOperationError.
		 * 
		 * @return The last element
		 */
		public function get last():Number
		{
			if (empty)
			{
				throw new IllegalOperationError("An empty iterator cannot return the last element.");			
			}

			var tmp:IKeyFrame = _head;
			while (tmp.next)
			{
				tmp = tmp.next;
			}
			return tmp.time;
		}

		/**
		 * Returns true if there are no elements in this iterator.
		 * 
		 * @return True iff there are no elements
		 */
		public function get empty():Boolean
		{
			return _head == null;
		}
		

	}
}
