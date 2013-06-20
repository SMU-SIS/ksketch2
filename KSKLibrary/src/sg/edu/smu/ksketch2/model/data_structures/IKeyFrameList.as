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
	public interface IKeyFrameList
	{
		/**
		 * Returns the first key in the list
		 */
		function get head():IKeyFrame;
		
		/**
		 * Returns the last key in the list
		 */
		function get lastKey():IKeyFrame;
		
		/**
		 * Returns the key at the specific time.
		 */
		function getKeyAtTime(time:int):IKeyFrame;
		
		/**
		 * Returns the last key frame that is at or before the given time
		 * returns null if a key does not exist at or before time
		 */
		function getKeyAtBeforeTime(time:int):IKeyFrame;
		
		/**
		 * Returns the first key that is after the given time
		 * Returns null if a key does not exist after time.
		 */
		function getKeyAftertime(time:int):IKeyFrame;
		
		/**
		 * Inserts the given key into its correct position in the key frame list
		 */
		function insertKey(key:IKeyFrame):void;
		
		/**
		 * Removes the given key frame from the key list. Hooks the next key to prev key and vice versa
		 */
		function removeKeyFrame(key:IKeyFrame):void
		
		function serialize():XML;
	}
}