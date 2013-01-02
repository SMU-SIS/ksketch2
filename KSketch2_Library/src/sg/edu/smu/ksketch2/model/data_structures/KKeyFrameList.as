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
	public class KKeyFrameList implements IKeyFrameList
	{
		protected var _head:KKeyFrame;
		
		/**
		 * KKeyFrameList is an abstract class defining the core implementations of a linked list of key frames
		 */
		public function KKeyFrameList()
		{
			
		}
		
		/**
		 * Returns the first key of the key frame list
		 */
		public function get head():IKeyFrame
		{
			return _head;
		}
		
		/**
		 * Returns the last key of the key frame list
		 * Returns null if there are no keys in this list
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
		 * Returns the key at the given time
		 * If a key does not exist at time, returns null
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
		 * Returns the last key frame that is at or before the given time
		 * returns null if a key does not exist at or before time
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
		 * Returns the first key that is after the given time
		 * Returns null if a key does not exist after time.
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
		 * Inserts key at its time into this key frame list
		 * Note: key's previous linkages will be removed.
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
		
		/**Attaches this key to the end of the key list
		 * If key.time < last key.time
		 * This function will complain
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
		 * removes all keys after and including key
		 * returns the removed keys intact as a linked list
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
		
		public function serialize():XML
		{
			var keyListXML:XML = <keylist type="default"></keylist>;
			
			return keyListXML;
		}
		
		public function clone():KKeyFrameList
		{
			return null;
		}
		
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
	}
}