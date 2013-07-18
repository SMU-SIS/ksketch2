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
	 * The IReferenceFrame interface serves as the interface class for a reference
	 * frame in K-Sketch. A reference frame is a key frame list for transformation key frames.
	 */
	public interface IReferenceFrame extends IKeyFrameList
	{
		/**
		 * Gets the concatenated matrix for the reference frame from time 0 to the given time.
		 * 
		 * @param time The target time.
		 * @return The concatenated matrix for the reference frame from time 0 to the given time.
		 */
		function matrix(time:int):Matrix;
	}
}