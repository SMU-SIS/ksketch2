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
	import flash.geom.Matrix;
	
	/**
	 * The KReferenceFrame class serves as the concrete class that defines the core
	 * implementations of reference frames in K-Sketch. A reference frame is a key
	 * frame list for transformation key frames.
	 */
	public class KReferenceFrame extends KKeyFrameList implements IReferenceFrame
	{
		/**
		 * The default constructor for the reference frame.
		 */
		public function KReferenceFrame()
		{
			super();
		}
		
		/**
		 * Gets the concatenated matrix for the reference frame from time 0 to the given time.
		 * 
		 * @param time The target time.
		 * @return The concatenated matrix for the reference frame from time 0 to the given time.
		 */
		public function matrix(time:int):Matrix
		{
			var activeKey:KSpatialKeyFrame = getKeyAftertime(time) as KSpatialKeyFrame;
			
			if(!activeKey)
				activeKey = lastKey as KSpatialKeyFrame;

			if(!activeKey)
				return new Matrix();
			
			return activeKey.fullMatrix(time);
		}
		
		/**
		 * Serializes the reference frame to an XML object.
		 * 
		 * @return The serialized XML object of the reference frame.
		 */
		override public function serialize():XML
		{
			var keyListXML:XML = <keylist type="referenceframe"> </keylist>;
			var currentKey:KSpatialKeyFrame = _head as KSpatialKeyFrame;
			
			while(currentKey)
			{
				keyListXML.appendChild(currentKey.serialize());
				currentKey = currentKey.next as KSpatialKeyFrame;
			}
			
			return keyListXML;
		}
		
		/**
		 * Gets a clone of the reference frame.
		 * 
		 * @return A clone of the reference frame.
		 */
		override public function clone():KKeyFrameList
		{
			var newKeyList:KReferenceFrame = new KReferenceFrame();
			
			var currentKey:IKeyFrame = _head;
			
			while(currentKey)
			{
				newKeyList.insertKey(currentKey.clone());
				currentKey = currentKey.next;
			}
			
			return newKeyList;
		}
	}
}