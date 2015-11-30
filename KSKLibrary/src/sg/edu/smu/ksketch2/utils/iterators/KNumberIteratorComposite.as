/**
 * Copyright 2010-2015 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.utils.iterators
{
	import flash.errors.IllegalOperationError;
	
	/**
	 * This iterator combines two iterators into one. 
	 * It assumes that the numbers returned by both iterators are monotonically increasing, 
	 * and it interleaves the two so that all values are monotonically increasing.
	 * If a number is returned by both iterators, that number is returned only once by this itorator.
	 */
	public class KNumberIteratorComposite implements INumberIterator
	{
		private var _a:INumberIterator;
		private var _b:INumberIterator;
		private var _hasNextA:Boolean;
		private var _hasNextB:Boolean;
		private var _nextA:Number;
		private var _nextB:Number;
		
		/**
		 * Constructs a new KNumberIteratorComposite.
		 * 
		 * @param Iterator a (assumed to be monotonically incrasing).
		 * @param Iterator b (assumed to be monotonically incrasing).
		 */
		public function KNumberIteratorComposite(a:INumberIterator, b:INumberIterator)
		{
			_a = a;
			_b = b;
			
			reset();
		}
		
		/**
		 * Reset the iterator to point to the first element.
		 */
		public function reset():void
		{
			_a.reset();
			_b.reset();
			
			_hasNextA = _a.hasNext();
			_hasNextB = _b.hasNext();
			
			if (_hasNextA) 
			{
				_nextA = _a.next();
			}
			if (_hasNextB) 
			{
				_nextB = _b.next();
			}			
		}
		
		/**
		 * Return the next element.
		 * Call hasNext to verify that there in an element before calling this method.
		 * If there are no more elements, then this will throw an IllegalOperationError. 
		 * 
		 * @return The next element.
		 */
		public function next():Number
		{
			var num:Number;
			var advanceA:Boolean;
			var advanceB:Boolean;
			
			// Check to see which iterator has the next value, and which should be advanced.
			if (_hasNextA && _hasNextB)
			{
				if (_nextA <= _nextB)
				{
					num = _nextA;
					advanceA = true;
				} 
				else if (_nextB <= _nextA)
				{
					num = _nextB;
					advanceB = true;					
				}
			}
			else if (_hasNextA)
			{
				num = _nextA;
				advanceA = true;				
			}
			else if (_hasNextB)
			{
				num = _nextB;
				advanceB = true;					
			}
			else
			{
				throw new IllegalOperationError("Cannot call 'next' on an iterator that has no more elements.");
			}

			// Advance iterators that need to be advanced
			if (advanceA)
			{
				_hasNextA = _a.hasNext();
				if (_hasNextA) 
				{
					_nextA = _a.next();
				}
			}
			if (advanceB)
			{
				_hasNextB = _b.hasNext();
				if (_hasNextB) 
				{
					_nextB = _b.next();
				}
			}
			
			// Return the number
			return num;
		}
		
		
		/**
		 * Check if there are more elements to iterate over.
		 * 
		 * @return True iff there are more elements.
		 */
		public function hasNext():Boolean
		{
			return _hasNextA || _hasNextB;
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
			
			if (!_a.empty && !_b.empty)
			{
				return Math.min(_a.first, _b.first);
			}
			else if (!_a.empty)
			{
				return _a.first;
			}
			else
			{
				return _b.first;
			}
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

			if (!_a.empty && !_b.empty)
			{
				return Math.max(_a.last, _b.last);
			}
			else if (!_a.empty)
			{
				return _a.last;
			}
			else
			{
				return _b.last;
			}
		}

		/**
		 * Returns true if there are no elements in this iterator.
		 * 
		 * @return True iff there are no elements
		 */
		public function get empty():Boolean
		{
			return _a.empty && _b.empty;	
		}

	}
}