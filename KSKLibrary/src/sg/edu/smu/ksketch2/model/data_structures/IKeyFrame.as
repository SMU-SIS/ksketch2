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
	 * The IKeyFrame interface serves as the interface class for a key frame in K-Sketch.
	 */
	public interface IKeyFrame
	{
		/**
		 * Gets the key frame's owner ID.
		 * 
		 * @return The key frame's owner ID.
		 */
		function get ownerID():int;
		
		/**
		 * Sets the key frame's owner ID.
		 * 
		 * @param value The key frame's owner ID.
		 */
		function set ownerID(value:int):void;
		
		/**
		 * Gets the previous key frame.
		 * 
		 * @return The previous key frame.
		 */
		function get previous():IKeyFrame;
		
		/**
		 * Gets the next key frame.
		 * 
		 * @return The next key frame.
		 */
		function get next():IKeyFrame;
		
		/**
		 * Gets the time at which the key frame is defined.
		 * 
		 * @return The key frame's current time.
		 */
		function get time():int;
		
		/**
		 * Gets whether the key frame is active at this given time.
		 * 
		 * @return Whether the key frame is active at this given time.
		 */
		function hasActivityAtTime():Boolean;
		
		/**
		 * Gets a clone of the key frame.
		 * 
		 * @return A clone of the key frame.
		 */
		function clone():IKeyFrame;
		
		/**
		 * Splits this key into two parts: a front key frame and a back key frame.
		 * Then it returns the front key frame.
		 * 
		 * @param time The time of the target key frame.
		 * @param op The composite operation.
		 * @return The front key.
		 */
		function splitKey(time:int, op:KCompositeOperation):IKeyFrame;
		
		/**
		 * Checks the usefulness of the key frame.
		 * 
		 * @return Whether the key frame is useful.
		 */
		function isUseful():Boolean;

		/**
		 * Serializes the key frame to an XML object.
		 * 
		 * @return The serialized XML object of the key frame.
		 */
		function serialize():XML;
		
		/**
		 * Deserializes the XML object to a key frame.
		 * 
		 * @param xml The target XML object.
		 */
		function deserialize(xml:XML):void;
	}
}