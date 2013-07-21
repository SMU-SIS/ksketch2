/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.operators
{
	import sg.edu.smu.ksketch2.model.data_structures.IKeyFrame;
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;

	/**
	 * The IVisibilityControl class serves as the interface class for visibility
	 * control in K-Sketch. Specifically, the transform operator for visibility
	 * key frames. Note from original developer: This class is not really needed,
	 * but should have something here. Here for deadling with visibility
	 * interpolation instead of changing the data object for visibility keys.
	 */
	public interface IVisibilityControl
	{
		/**
		 * Gets the earliest visibility time.
		 * 
		 * @return The earliest visible time.
		 */
		function get earliestVisibleTime():int;
		
		/**
		 * Sets the visibility at the given time.
		 * 
		 * @param visibile The target state of the key frame's visibility.
		 * @param time The target time.
		 * @param op The corresponding composite operation.
		 */
		function setVisibility(visible:Boolean, time:int, op:KCompositeOperation):void;
		
		/**
		 * Gets the head key frame of the visibility key frame list.
		 * 
		 * @return The head key frame of the visibility key frame list.
		 */
		function get visibilityKeyHeader():IKeyFrame;
		
		/**
		 * Serializes the visibility control into an XML object.
		 * 
		 * @return The serialized XML object of the visibility control.
		 */
		function serializeVisibility():XML;
		
		/**
		 * Deserializes the XML object into a visibility control.
		 * 
		 * @param The target XML object of a visibility control.
		 */
		function deserializeVisibility(xml:XML):void;
		
		/**
		 * Gets the alpha value of the visibility key frame. If the
		 * visibility state is enabled, then a visibile alpha value is
		 * returned. Else, if the given time matches the visibility key
		 * frame's time, then a ghost alpha value is returned. Else, an
		 * invisible alpha value is returned.
		 * 
		 * @param time The target time.
		 * @return The corresponding alpha value for the visibility key.
		 */
		function alpha(time:int):Number;
	}
}