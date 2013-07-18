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
	 * The KVisibilityKeyList class serves as the concrete class for a visibility key frame list
	 * in K-Sketch.
	 */
	public class KVisibilityKeyList extends KKeyFrameList
	{
		/**
		 * Checks the visibility of a visibility key frame at the given time.
		 * 
		 * @param time The target time.
		 * @return The visibility of a visibility key frame at the given time.
		 */
		public function KVisibilityKeyList()
		{
			super();
		}
		
		/**
		 * Gets the key that determines the key frame's visibility at the given time; can return null.
		 * 
		 * @param time The target time.
		 * @return The visibility key frame at the given time.
		 */
		public function visible(time:int):Boolean
		{
			var key:IVisibilityKey = getActiveKey(time);
			
			if(key)
				return key.visible;
			else
				return false;
		}
		
		/**
		 * Gets the key that determines the key frame's visibility at the given time; can return null.
		 * 
		 * @param time The target time.
		 * @return The visibility key frame at the given time.
		 */
		public function getActiveKey(time:int):IVisibilityKey
		{
			return getKeyAtBeforeTime(time) as IVisibilityKey;
		}
		
		/**
		 * Serializes the visibility key frame list to an XML object.
		 * 
		 * @return The serialized XML object of the visibility key frame list.
		 */
		override public function serialize():XML
		{
			var keyListXML:XML = <keylist type="visibility"> </keylist>;
			var currentKey:KVisibilityKey = _head as KVisibilityKey;
			
			while(currentKey)
			{
				keyListXML.appendChild(currentKey.serialize());
				currentKey = currentKey.next as KVisibilityKey;
			}
			
			return keyListXML;
		}
		
		/**
		 * Gets a clone of the visibility key frame list.
		 * 
		 * @return A clone of the visibility key frame list.
		 */
		override public function clone():KKeyFrameList
		{
			var newKeyList:KVisibilityKeyList = new KVisibilityKeyList();
			
			var currentKey:IKeyFrame = _head.clone();
			
			while(currentKey)
			{
				newKeyList.insertKey(currentKey);
				
				if(currentKey.next)
				{
					currentKey = currentKey.next.clone();
				}
			}
			
			return newKeyList;
		}
	}
}