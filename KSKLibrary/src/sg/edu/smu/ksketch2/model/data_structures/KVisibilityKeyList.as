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
	public class KVisibilityKeyList extends KKeyFrameList
	{
		public function KVisibilityKeyList()
		{
			super();
		}
		
		/**
		 * Returns the boolean denoting the visibility value of this timeline at time
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
		 * Returns the key that determines the visibility at given time.
		 * Can return null.
		 */
		public function getActiveKey(time:int):IVisibilityKey
		{
			return getKeyAtBeforeTime(time) as IVisibilityKey;
		}
		
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