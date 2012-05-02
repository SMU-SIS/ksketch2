/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.model.implementations
{
	import sg.edu.smu.ksketch.model.IActivityKeyFrame;
	import sg.edu.smu.ksketch.model.IKeyFrame;
	import sg.edu.smu.ksketch.model.IKeyFrameList;
	import sg.edu.smu.ksketch.model.IParentKeyFrame;
	import sg.edu.smu.ksketch.model.KGroup;
	
	public class KKeyFrameList implements IKeyFrameList
	{
		private var _keys:KKeyFrame;
		
		public function KKeyFrameList()
		{
			
		}
		
		public function earliestTime():Number
		{
			if(_keys)
				return _keys.endTime;
			else
				return NaN;
		}
		
		/**
		 * Returns number of keys in this key frame list
		 */
		public function get numKeys():int
		{
			var nKeys:int = 0;
			var keys:KKeyFrame = _keys;
			
			if(keys)
				nKeys++;
			else
				return nKeys;
			
			while(keys.next)
			{
				keys = keys.next as KKeyFrame;
				nKeys++;
			}
			
			return nKeys;
		}
		
		/**
		 * Returns the key frame that should be used to access properties at the give time.
		 * if last key frame time < ksktime, return last key frame, lese
		 * return getAtOrAfter(kskTime)
		 */
		public function lookUp(kskTime:Number):IKeyFrame
		{
			var lastKey:IKeyFrame = getLastKey();

			if(lastKey && lastKey.endTime <= kskTime)
				return lastKey;
			else
				return getAtOrAfter(kskTime);
		}
		
		/**
		 * Returns the key frame with endTime == kskTime.
		 * If not key frame exists at this time, returns null.
		 */
		public function getAtTime(kskTime:Number):IKeyFrame
		{
			var key:KKeyFrame = _keys;
	
			while(key)
			{
				if(key.endTime == kskTime)
					return key;
				else
					key = key.next as KKeyFrame;
			}
			//If there's no keys with the same time, return null
			return null;
		}
		
		/**
		 * Returns the last key frame such that endTime <= kskTime
		 * if no such keys exist, will return null.
		 */
		public function getAtOrBeforeTime(kskTime:Number):IKeyFrame
		{
			if(!_keys)
				return null;
			
			var key:KKeyFrame = _keys;

			while(key.next)
			{
				if(key.endTime <= kskTime)
					key = key.next as KKeyFrame;
				else
					break;
			}
			
			if(key.endTime <= kskTime)
				return key;
			
			if(key.previous&& key.previous.endTime <= kskTime)
				return key.previous;
			else
				return null;
		}
		
		/**
		 * Returns the first key frame such that kskTime <= endTime
		 * Returns null if no such key exists
		 */
		public function getAtOrAfter(kskTime:Number):IKeyFrame
		{
			if(!_keys)
				return null;
			
			var key:KKeyFrame = _keys;
			
			//Iterate through and return the first key found.
			while(key.next)
			{
				if(kskTime <= key.endTime)
					return key;
				
				key = key.next as KKeyFrame;
			}
			
			if(kskTime <= key.endTime)
				return key;
			else
				return null;
		}
		
		/**
		 * Inserts a new key frame at the given time if none exists
		 * Returns the key frame at that time
		 * Throws an error if key exists at time
		 */
		public function insert(time:Number):IKeyFrame
		{
			var newKey:KKeyFrame = getAtTime(time) as KKeyFrame;
			
			if(newKey)
				return newKey;
			
			newKey = new KKeyFrame(time);
			var key:KKeyFrame = _keys;
			
			if(!key)
			{
				_keys = newKey;
				return _keys;
			}
		
			if(time < key.endTime)
			{
				//assume that it is a prepend operation
				key.previous = newKey;
				newKey.next = key;
				_keys = newKey;
				return _keys;
			}
			
			//Iterate through and return the first key with end time after given time
			while(key)
			{
				if(time <= key.endTime)
					break;
				else
					key = key.next as KKeyFrame;
			}
			
			//if there are no keys after given time
			if(key.endTime < time)
			{
				//safely assume that it is an append operation;
				newKey.previous = key;
				key.next = newKey;
			}
			
			if(key.endTime == time)
				throw(new Error("A key already exists at time "+time.toString()));
			
			var previous:KKeyFrame = key.previous as KKeyFrame;
			
			newKey.previous = previous;
			newKey.next = key;
			
			if(previous)
			{
				previous.next = newKey;
				key.previous = newKey;
			}
			
			return newKey;
		}
		
		/**
		 * Inserts the given key into this list according to its time.
		 * Throws an error if there is an existing key at that time.
		 * Otherwise, returns the inserted key.
		 */
		public function insertKey(keyframe:IKeyFrame):IKeyFrame
		{	
			//Make the given keyframe the header of the list if there are no keys
			if(!_keys)
			{
				_keys = keyframe as KKeyFrame;
				return keyframe;
			}
			
			var currentKey:KKeyFrame = keyframe as KKeyFrame;
			
			//Find the key that should be before the given key
			var existingKey:KKeyFrame = getAtOrBeforeTime(keyframe.endTime) as KKeyFrame; //Tested correct
			//If there is an existing key that should be before the given key
			if(existingKey)
			{
				if(existingKey.endTime == keyframe.endTime)
					throw new Error("KKeyFrameList.insertKey: There is an existing key at"+existingKey.endTime);
				else
				{
					var nextKey:KKeyFrame = existingKey.next as KKeyFrame;
					existingKey.next = currentKey;
					currentKey.previous = existingKey;
					
					if(nextKey)
					{
						currentKey.next = nextKey;
						nextKey.previous = currentKey;
					}

					return currentKey;
				}
			}
			else
			{
				currentKey.next = _keys;
				_keys.previous = currentKey;
				_keys = currentKey;
				return _keys;
			}			
		}
		
		/**
		 * Adds a key frame to the end of this list.
		 * Throws an error if the key frame has an earlier end time than the last key
		 */
		//remove append, just use insert.
		public function append(keyFrame:IKeyFrame):void
		{
			//CHECK IF
			//KEY FRAME'S END TIME > PREV END TIME
			//NULL CASES
			//ENDTIME - DURATION > PREV END TIME 
			var lastKey:KKeyFrame = getLastKey() as KKeyFrame;
			
			if(lastKey)
			{
				lastKey.next = keyFrame;
				(keyFrame as KKeyFrame).previous = lastKey;
			}
			else
				_keys = keyFrame as KKeyFrame;
		}
		
		/**
		 * Adds an ordered vector of key frames the end of this list
		 * Throws an error if the vector is not properly ordered in ascending time
		 * or if any one of the keys has end time <= the last key of this list
		 */
		public function appendList(keyFrames:Vector.<IKeyFrame>):void
		{
			var lastKey:KKeyFrame = getLastKey() as KKeyFrame;
			var i:int = 0;
			var length:int = keyFrames.length;
			var currentKey:KKeyFrame;
			
			for(i = 0; i<length;i++)
			{
				currentKey = keyFrames[i] as KKeyFrame;
				
				if(lastKey.endTime < currentKey.endTime)
				{
					lastKey.next = currentKey;
					currentKey.previous = lastKey;
					lastKey = currentKey;
				}
				else
				{
					throw new Error("KKeyFrameList.appendList: vector given is not ordered properly");
				}
			}
		}
		
		/**
		 * Removes the given key frame from this list
		 * shiftTime will subtract t from the endTime of the key frames after the given key where
		 * t = keyFrame.endTime-keyFrame.previous.endTime;
		 */
		public function remove(keyframe:IKeyFrame, shiftTime:Boolean=false):IKeyFrame
		{
			//If the given key does not exist in the list, throw an error
			var existingKey:KKeyFrame = getAtTime(keyframe.endTime) as KKeyFrame;
			
			if(!existingKey)
				throw new Error("KKeyFrameList.remove: The given key frame does not exist in this list");
			
			//Assign variables for the previous and next elements in the list
			var previous:KKeyFrame = existingKey.previous as KKeyFrame;
			var next:KKeyFrame = existingKey.next as KKeyFrame;
			
			if(previous)
				previous.next = next;
			
			if(next)
				next.previous = previous;
			
			if(_keys == existingKey)
				_keys = next;
			
			(existingKey as KKeyFrame).previous = null;
			(existingKey as KKeyFrame).next = null;
			
			return existingKey;
		}
		
		/**
		 * Removes all key frames with end time < kskTime
		 */
		public function removeAllAfter(kskTime:Number):Vector.<IKeyFrame>
		{
			var endKey:KKeyFrame = this.getAtOrBeforeTime(kskTime) as KKeyFrame;
			var returnVector:Vector.<IKeyFrame> = new Vector.<IKeyFrame>();
			var removedKey:KKeyFrame;
			
			if(!endKey)
			{
				//There are no keys before or at given time
				//remove all keys
				var keys:KKeyFrame = _keys as KKeyFrame;
				var nextKey:KKeyFrame;
				
				while(keys)
				{
					nextKey = keys.next as KKeyFrame;
					keys.previous = null;
					keys.next = null;
					
					returnVector.push(keys);
					keys = nextKey;
				}
				
				_keys = null;
				return returnVector;
			}
			
			var lastKey:KKeyFrame = this.getLastKey() as KKeyFrame;
			var prevKeyBeforeLast:KKeyFrame;
			
			while(lastKey != endKey)
			{
				prevKeyBeforeLast = lastKey.previous as KKeyFrame;
				
				removedKey = remove(lastKey) as KKeyFrame;
				returnVector.push(removedKey);
				lastKey = prevKeyBeforeLast;
			}
			
			returnVector.reverse();
			return returnVector;
		}
		
		/**
		 * Shifts all keys at and after kskTIme by the time by given delta
		 */
		public function shiftKeys(kskTime:Number, delta:int):void
		{
			var key:KKeyFrame = getAtOrAfter(kskTime) as KKeyFrame;
			
			if(key)
			{
				key.endTime += delta;
				
				while(key.next)
				{
					key = key.next as KKeyFrame;
					key.endTime += delta;
				}
			}
		}
		
		/**
		 * Checks if given key exists in this list
		 */
		public function keyExists(keyframe:IKeyFrame):Boolean
		{
			var key:IKeyFrame = _keys;
			
			if(key.endTime == keyframe.endTime)
				return true;
			
			while(key.next)
			{
				key = key.next;
				if(key.endTime == keyframe.endTime)
					return true;
			}
			
			return false;
		}
		
		public function createActivityKey(time:Number, alpha:Number):IActivityKeyFrame
		{
			return new KActivityKeyFrame(time, alpha);
		}
		
		/**
		 * Return the last key frame in this list
		 */
		private function getLastKey():IKeyFrame
		{	
			if(!_keys)
				return null;
			
			var currentKey:IKeyFrame = _keys;
			
			while(currentKey.next)
			{
				if(currentKey.next)
					currentKey = currentKey.next;
				else
					break;
			}
			
			return currentKey;
		}

		/**
		 * Protected function for sub classes to access the key list
		 */
		protected function get keys():KKeyFrame
		{
			return _keys;
		}
	}
}