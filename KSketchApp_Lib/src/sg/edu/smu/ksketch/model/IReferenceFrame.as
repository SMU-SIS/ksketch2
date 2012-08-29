/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package sg.edu.smu.ksketch.model
{
	import flash.geom.Matrix;

	public interface IReferenceFrame extends IKeyFrameList
	{
		//Each reference frame has its own coordinate system
		//Spatial key frames' centers are defined in their reference frame's coordinate system.
		//The coordinate system of the last reference frame (the one with the largest index) is the same as the object coordinate system
		
		/**
		 *The previous reference frame
		 */
		function get previous():IReferenceFrame;
		
		/**
		 *The next reference frame
		 */
		function get next():IReferenceFrame;
		
		/**
		 *Creates and returns a new spatial key.
		 *This key will not be inserted automatically
		 * Center is defined in reference frame coordinates
		 */
		function createSpatialKey(time:Number, centerX:Number = NaN, centerY:Number = NaN):ISpatialKeyframe
		
		/**
		 *Creates and returns a new visibility key.
		 *This key will not be inserted automatically
		 */
		function createActivityKey(time:Number, alpha:Number):IActivityKeyFrame
			
		/**
		 *Returns the matrix of this reference frame at kskTime
		 */
		function getMatrix(kskTime:Number):Matrix;
	}
}

