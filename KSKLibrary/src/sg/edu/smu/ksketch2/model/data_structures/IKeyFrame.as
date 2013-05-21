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

	public interface IKeyFrame
	{
		function get ownerID():int;
		function set ownerID(value:int):void;
		
		/**
		 * Previous key frame
		 */
		function get previous():IKeyFrame;
		
		/**
		 * Next key frame
		 */
		function get next():IKeyFrame;
		
		/**
		 * The time at which this key is defined
		 */
		function get time():int;
		
		/**
		 * Whether this key is active at given time.
		 */
		function hasActivityAtTime():Boolean;
		
		/**
		 * Returns a clone of this key
		 */
		function clone():IKeyFrame;
		
		/**
		 * Splits this key into 2 parts, front and back
		 * Returns the front key
		 */
		function splitKey(time:int, op:KCompositeOperation):IKeyFrame;
		
		function isUseful():Boolean;
			
		function serialize():XML;
		function deserialize(xml:XML):void;
	}
}