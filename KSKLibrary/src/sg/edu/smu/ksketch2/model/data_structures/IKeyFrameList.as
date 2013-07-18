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
	/**
	 * The IKeyFrameList interface serves as the interface class for a key frame list in K-Sketch.
	 */
	public interface IKeyFrameList
	{
		/**
		 * Gets the first key frame in the key frame list.
		 * 
		 * @return The first key frame in the key frame list.
		 */
		function get head():IKeyFrame;
		
		/**
		 * Gets the last key frame in the key frame list.
		 * 
		 * @return The last key frame in the key frame list.
		 */
		function get lastKey():IKeyFrame;
		
		/**
		 * Gets the key frame at the given target time.
		 * 
		 * @param time The target time.
		 * @return The key frame at the given target time.
		 */
		function getKeyAtTime(time:int):IKeyFrame;
		
		/**
		 * Gets the last key frame that is at or before the given time,
		 * else null if a key frame does not exist at or before time.
		 * 
		 * @param time The target time.
		 * @return The last key frame that is at or before the given time, else null.
		 */
		function getKeyAtBeforeTime(time:int):IKeyFrame;
		
		/**
		 * Gets the first key frame that is after the given time if it exists,
		 * else null if a key frame does not exist after the given target time.
		 * [Note: Should refactor this method name to match capitalization of
		 * beforeKeyatBeforeTime(...) method.
		 * 
		 * @param time The target time.
		 * @return The first key frame after the given target time, else null.
		 */
		function getKeyAftertime(time:int):IKeyFrame;
		
		/**
		 * Inserts the given key into its correct position in the key frame list.
		 * 
		 * @param key The target key frame.
		 */
		function insertKey(key:IKeyFrame):void;
		
		/**
		 * Removes the given key frame from the key frame list. Links the next
		 * key frame to the prevous key frame, and vice versa.
		 *
		 * @param key The target key to remove.
		 */
		function removeKeyFrame(key:IKeyFrame):void
		
		/**
		 * Serializes the key frame list to an XML object.
		 * 
		 * @return The serialized XML object of the key frame list.
		 */
		function serialize():XML;
	}
}