/**
 * Copyright 2010-2015 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.model.data_structures
{
	import flash.geom.Matrix;
	
	import sg.edu.smu.ksketch2.utils.iterators.INumberIterator;

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
		function matrix(time:Number):Matrix;
		
		/**
		 * Returns an interator that gives the times of all translate events, in order from beginning to end. 
		 */
		function translateTimeIterator():INumberIterator;
		
		/**
		 * Returns an interator that gives the times of all rotate events, in order from beginning to end. 
		 */
		function rotateTimeIterator():INumberIterator;
		
		/**
		 * Returns an interator that gives the times of all scale events, in order from beginning to end. 
		 */
		function scaleTimeIterator():INumberIterator;		

	}
}