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
	
	import sg.edu.smu.ksketch2.model.data_structures.KTimedPoint;

	/**
	 * This iterator returns (in order) the time of each point in a vector of KTimedPoints.
	 */
	public class KNumberIteratorVectorKTimedPoint implements INumberIterator
	{
		private var _index:uint = 0;
		private var _points:Vector.<KTimedPoint>;
		private var _scale:Number;
		private var _start:Number;
		private var _end:Number;

		/**
		 * Creates a new KNumberIteratorVectorKTimedPoint from a vector of KTimedPoints.
		 * 
		 * @param points The vector of points
		 */
		public function KNumberIteratorVectorKTimedPoint(points:Vector.<KTimedPoint> = null)
		{
			_index = 0;
			_points = points;
			_scale = 1;
			
			if (_points && 0 < _points.length)
			{
				_start = _points[0].time;
				_end = _points[_points.length-1].time;
			}
			else
			{
				_start = 0;
				_end = 0;
			}
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
		public function next():Number
		{
			if (_index < _points.length-1)
			{
				// Normal case
				return (_points[_index++].time - _points[0].time) * _scale + _start;
			}
			else if (_index == _points.length-1)
			{
				// Do this to avoid numeric precision problems
				_index++;
				return _end;
			} 
			else
			{
				throw new IllegalOperationError("Cannot call 'next' on an iterator that has no more elements.");
			}
		}
		
		/**
		 * Check if there are more elements to iterate over.
		 * 
		 * @return True iff there are more elements.
		 */
		public function hasNext():Boolean
		{
			return _points && _index < _points.length;
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
			return _start;
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
			return _end;
		}

		/**
		 * Returns true if there are no elements in this iterator.
		 * 
		 * @return True iff there are no elements
		 */
		public function get empty():Boolean
		{
			return _points == null || _points.length == 0;
		}
		
		/**
		 * Scales the numbers returned by this iterator so that the times start and and at specified moments.
		 * 
		 * @param start The start of the period 
		 * @param end The end of the period.
		 * @return this (for chaining)
		 */
		public function scale(start:Number, end:Number):KNumberIteratorVectorKTimedPoint
		{
			if (_points  &&  0 < _points.length)
			{
				_start = start;
				_end = end;
				_scale = (_end - _start) / (_points[_points.length-1].time - _points[0].time);
			}
			
			return this;
		}
	}
}

