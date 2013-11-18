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
	 * The IVisibilityKey interface serves as the interface class
	 * for a visibility key frame in K-Sketch.
	 */
	public interface IVisibilityKey extends IKeyFrame
	{
		/**
		 * Gets the visibility key frame's visibility status.
		 * 
		 * @return The visibility key frame's visibility status.
		 */
		function get visible():Boolean;
		
		/**
		 * Sets the visibility key frame's visibility status.
		 * 
		 * @param value The visibility key frame's target visibility status.
		 */
		function set visible(value:Boolean):void;
	}
}