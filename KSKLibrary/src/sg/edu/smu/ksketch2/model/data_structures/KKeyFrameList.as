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
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;

	/**
	 * The KKeyFrameList class serves as the abstract class for a key frame list in K-Sketch.
	 * The core implementation of the list is a linked list data structure of key frames.
	 */
	public class KKeyFrameList implements IKeyFrameList
	{
		protected var _head:KKeyFrame;		// head key frame of the list
		
		/**
		 * The default constructor of the key frame list.
		 */
		public function KKeyFrameList()
		{
			
		}
		
		/**
		 * Gets the first key frame in the key frame list.
		 * 
		 * @return The first key frame in the key frame list.
		 */
		public function get head():IKeyFrame
		{
			return _head;
		}
		
		/**
		 * Gets the last key frame in the key frame list for a non-empty list;
		 * else null otherwese.
		 * 
		 * @return The last key frame in the key frame list.
		 */
		public function get lastKey():IKeyFrame
		{
			var currentKey:KKeyFrame = _head;
			
			if(!currentKey)
				return null;
			
			while(currentKey.next)
			{
				currentKey = currentKey.next as KKeyFrame;
			}
			
			return currentKey;
		}
		
		/**
		 * Gets the key frame at the given target time for a non-empty list; else null otherwise.
		 * 
		 * @param time The target time.
		 * @return The key frame at the given target time.
		 */
		public function getKeyAtTime(time:int):IKeyFrame
		{
			var currentKey:KKeyFrame = _head;
			
			while(currentKey)
			{
				if(currentKey.time == time)
					return currentKey;
				else
					currentKey = currentKey.next as KKeyFrame;
 			}
			
			return null;
		}
		
		/**
		 * Gets the last key frame that is at or before the given time,
		 * else null if a key frame does not exist at or before time.
		 * 
		 * @param time The target time.
		 * @return The last key frame that is at or before the given time, else null.
		 */
		public function getKeyAtBeforeTime(time:int):IKeyFrame
		{
			var resultKey:IKeyFrame;
			var currentKey:KKeyFrame = _head;
			
			while(currentKey)
			{
				if(currentKey.time <= time)
					resultKey = currentKey;
				else
					break;
				
				currentKey = currentKey.next as KKeyFrame;
			}
			
			return resultKey;
		}
		
		/**
		 * Gets the first key frame that is after the given time if it exists,
		 * else null if a key frame does not exist after the given target time.
		 * [Note: Should refactor this method name to match capitalization of
		 * beforeKeyatBeforeTime(...) method].
		 * 
		 * @param time The target time.
		 * @return The first key frame after the given target time, else null.
		 */
		public function getKeyAftertime(time:int):IKeyFrame
		{
			var resultKey:IKeyFrame;
			var currentKey:KKeyFrame = _head;
			
			while(currentKey)
			{
				if(time < currentKey.time)
				{
					resultKey = currentKey;
					break;
				}
				
				currentKey = currentKey.next as KKeyFrame;
			}
			
			return resultKey;
		}
		
		/**
		 * Inserts the given key into its correct position in the key frame list.
		 * The key's previous linkages will be removed as a result.
		 * 
		 * @param key The target key frame.
		 */
		public function insertKey(key:IKeyFrame):void
		{
			if(!key)
				throw new Error("KKeyFrameList.insertKey: Come on. You have to insert a key.");
			
			var before:KKeyFrame = getKeyAtBeforeTime(key.time) as KKeyFrame;
			if(before)
			{
				if(before.time == key.time)
					throw new Error("KKeyFrameList.insertKey: KeyFrameLists cannot have 2 keys that are at the same time!");
	
				before.next = key;
				(key as KKeyFrame).previous = before;
			}	
				
			var after:KKeyFrame = getKeyAftertime(key.time) as KKeyFrame;
			
			if(after)
			{
				if(after.time == key.time)
					throw new Error("KKeyFrameList.insertKey: KeyFrameLists cannot have 2 keys that are at the same time!");
			
				after.previous = key;
				(key as KKeyFrame).next = after;
			}
			
			if(!_head)
				_head = key as KKeyFrame;
			else if(key.time < _head.time)
				_head = key as KKeyFrame;				
		}
		
		/**
		 * Appends the key frame to the end of the key frame list. An error will be thrown
		 * if the given key frame's time occurs before the existing last key's time.
		 * 
		 * @param key The key frame to append.
		 */
		public function appendKey(key:IKeyFrame):void
		{
			var last:KKeyFrame = lastKey as KKeyFrame;
			
			if(key.time < last.time)
				throw new Error("KeyFrameList.appendKey: The to be appended is earlier than the last key!");
			
			if(!last)
			{
				_head = key as KKeyFrame;
				return;
			}
			
			last.next = key;
			(key as KKeyFrame).previous = last;
		}
		
		/**
		 * Removes all keys after and including the given key frame, then returns
		 * all the removed key frames intact as a linked list.
		 * 
		 * @param key The target key frame.
		 */
		public function removeKeyFrom(key:IKeyFrame):IKeyFrame
		{
			var currentKey:IKeyFrame = _head;
			var belongs:Boolean = false;
			while(currentKey)
			{
				if(currentKey == key)
					belongs = true;
				
				currentKey = currentKey.next;
			}
			
			if(!belongs)
				throw new Error("Given key does not belong to this key frame list, check where this key belongs to before removing it");
			
			if(key.previous)
				(key.previous as KKeyFrame).next = null;
			(key as KKeyFrame).previous = null;
			
			return key;
		}
		
		/**
		 * Serializes the key frame list to an XML object.
		 * 
		 * @return The serialized XML object of the key frame list.
		 */
		public function serialize():XML
		{
			var keyListXML:XML = <keylist type="default"></keylist>;
			
			return keyListXML;
		}
		
		/**
		 * Gets a clone of the key frame list.
		 * 
		 * @return A clone of the key frame list.
		 */
		public function clone():KKeyFrameList
		{
			return null;
		}
		
		/**
		 * Debugs the key frame list object by outputting a string representation
		 * of the key frame list.
		 */
		public function debug():void
		{
			var debugString:String = "";
			var currentKey:IKeyFrame = _head;
			while(currentKey)
			{
				debugString += currentKey.time.toString() + " ";
				currentKey = currentKey.next;
			}
			
			if(debugString.length > 0)
				trace(debugString);
			else
				trace("There are no keys in this list");
		}
		
		/**
		 * Removes the given key frame from the key frame list. Links the
		 * next key frame to the prevous key frame, and vice versa.
		 * 
		 * @param key The target key to remove.
		 */
		public function removeKeyFrame(key:IKeyFrame):void
		{
			if(key == _head)
				throw new Error("You cannot remove the head of a key list");
			
			var prevKey:IKeyFrame = key.previous;
			var nextKey:IKeyFrame = key.next;
			
			if(prevKey)
				(prevKey as KKeyFrame).next = nextKey;
			
			if(nextKey)
				(nextKey as KKeyFrame).previous = prevKey;
		}
		
		/**
		 * Splits the given key frame at the time, and returns the front portion.
		 * Throws an error if the given key frame does not exist in the list.
		 * 
		 * @param key The target key frame.
		 * @param time The target time.
		 * @param op The corresponding composite operation.
		 */
		public function split(key:IKeyFrame, time:int, op:KCompositeOperation):IKeyFrame
		{
			var frontKey:IKeyFrame = key.splitKey(time, op);
			
			if(key == _head)
				_head = frontKey as KKeyFrame;
			
			return frontKey
		}
	}
}