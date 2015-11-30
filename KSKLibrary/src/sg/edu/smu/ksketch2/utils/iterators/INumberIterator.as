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
	public interface INumberIterator
	{
		/**
		 * Reset the iterator to point to the first element.
		 */
		function reset():void;

		/**
		 * Return the next element.
		 * 
		 * @return The next element.
		 */
		function next():Number;

		/**
		 * Check if there are more elements to iterate over.
		 * 
		 * @return True iff there are more elements.
		 */
		function hasNext():Boolean;
		
		/**
		 * Get the first element from this iterator, without changing the current index.
		 * If there are no elements, throws IllegalOperationError.
		 * 
		 * @return The first element
		 */
		function get first():Number;

		/**
		 * Get the last element from this iterator, without changing the current index.
		 * If there are no elements, throws IllegalOperationError.
		 * 
		 * @return The last element
		 */
		function get last():Number;

		/**
		 * Returns true if there are no elements in this iterator.
		 * 
		 * @return True iff there are no elements
		 */
		function get empty():Boolean;
	}
}