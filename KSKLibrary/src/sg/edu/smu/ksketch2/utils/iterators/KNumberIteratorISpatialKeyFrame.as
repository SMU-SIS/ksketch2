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
	import sg.edu.smu.ksketch2.model.data_structures.ISpatialKeyFrame;

	/**
	 * This iterator returns all translate, rotate, or scale events in a list of ISpatialKeyFrames,
	 * including all intermediate points on motion paths between key frames.
	 */
	public class KNumberIteratorISpatialKeyFrame implements INumberIterator
	{
		private var _type:uint;
		private var _head:ISpatialKeyFrame;
		
		// Strategy:
		// Use _moveTo to move to set the current key frame (_current) and iterator (_curIter).
		// The next time comes from that _curIter if it exists (and had 2 or more points when created).
		// Otherwise, the next time comes from  _current.time.
		private var _current:ISpatialKeyFrame;
		private var _curIter:INumberIterator;
		
		public static const TRANSLATE:uint = 0;
		public static const ROTATE:uint = 1;
		public static const SCALE:uint = 2;
		
		/**
		 * This iterator returns (in order) the times of all events of a particular type
		 * (translation, rotation, or scale) in a list of ISpatialKeyFrames.
		 * 
		 * @param head The first ISpatialKeyFrame in a list
		 * @parapm type A string that should be either "trans", "rot", or "scale"
		 */
		public function KNumberIteratorISpatialKeyFrame(head:ISpatialKeyFrame, type:uint)
		{
			_head = head;
			_type = type;
			
			if (_type != TRANSLATE && _type != ROTATE && _type != SCALE)
			{
				throw new RangeError("Type argument to KNumberIteratorISpatialKeyFrame constructor out of bounds.");			
			}
			
			reset();
		}
		
		/**
		 * Reset the iterator to point to the first element.
		 */
		public function reset():void
		{
			_moveTo(_head);
		}
		
		/**
		 * Return the next element.
		 * 
		 * @return The next element.
		 */
		public function next():Number
		{
			var num:Number;

			if (_current) 
			{
				if (_curIter)
				{
					num = _curIter.next();
					if (!_curIter.hasNext())
					{
						_moveTo(_current.next as ISpatialKeyFrame);
					}
				}
				else
				{
					num = _current.time;
					_moveTo(_current.next as ISpatialKeyFrame);
				}
			}
			else
			{
				throw new IllegalOperationError("Cannot call 'next' on an iterator that has no more elements.");
			}
			
			return num;
		}
		
		/**
		 * Check if there are more elements to iterate over.
		 * 
		 * @return True iff there are more elements.
		 */
		public function hasNext():Boolean
		{
			return _current != null;
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
		

		/**
		 * This helper function sets _current and _curIter when moving to a new key frame.
		 * 
		 * @param keyFrame The new Key frame, which can be null.
		 */
		private function _moveTo(keyFrame:ISpatialKeyFrame):void
		{
			_current = keyFrame;
			
			if (!_current || _current == _head)
			{
				_curIter = null;
			}
			else
			{
				switch (_type)
				{
					case TRANSLATE:
						_curIter = _current.translateTimeIterator();
						break;
					case ROTATE:
						_curIter = _current.rotateTimeIterator();
						break;
					case SCALE:
						_curIter = _current.scaleTimeIterator();
						break;
					default:
						throw new IllegalOperationError("KNumberIteratorISpatialKeyFrame _moveTo encountered unknown type: " + _type);
				}
				
				if (_curIter)
				{
					// Get rid of the first point, since it would have been returned by the previous key frame.
					if (_curIter.hasNext())
					{
						_curIter.next();
					}
					
					// If there is no second point, then set _curIter to null, because this path is undefined.
					if (!_curIter.hasNext())
					{
						_curIter = null;
					}
				}
			}
		}
		
	}
}