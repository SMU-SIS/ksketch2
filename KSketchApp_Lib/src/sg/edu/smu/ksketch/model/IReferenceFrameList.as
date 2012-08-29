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

	
	public interface IReferenceFrameList
	{
		/**
		 * Returns the number of reference frames in this reference frame list
		 */
		function get numReferenceFrames():int;
		
		/**
		 * Creates and returns a new reference frame
		 * This reference frame will not be inserted into the list
		 */
		function newReferenceFrame():IReferenceFrame;
		
		/**
		 * Returns the matrix of this reference frame list at kskTime
		 */
		function getMatrix(kskTime:Number):Matrix;
		
		/**
		 * Returns the reference frame at index
		 */
		function getReferenceFrameAt(index:int):IReferenceFrame;
		
		/**
		 *Inserts a new reference frame at index and returns it.
		 *If the given index is greater than this list's length, it will append it to the end
		 *If the given index is smaller than 0, it will append it to the front
		 */
		function insert(index:int):IReferenceFrame;
		
		/**
		 * Moves the given IReferenceFrame to after the ReferenceFrame at destination index
		 * If the given index is greater than this list's length, it will move it to the end
		 * If the given index is smaller than 0, it will move it to the front
		 * Returns the reference frame moved
		 */
		function move(frame:IReferenceFrame, destinationIndex:int):IReferenceFrame;
		
		/**
		 * Moves the reference frame at "from" to after the reference frame at "to" 
		 * Returns the reference frame moved
		 */
		function moveFrame(from:int, to:int):IReferenceFrame;
		
		/**
		 * Takes in an IReferenceFrame and finds its position in this list
		 */
		function indexOf(key:IReferenceFrame):int
		
		/**
		 * Removes the given reference frame from this reference frame list
		 */
		function removeReferenceFrame(refFrame:IReferenceFrame):IReferenceFrame;
		
		/**
		 * Removes the reference frame at index
		 */
		function removeReferenceFrameAt(index:int):IReferenceFrame;
		
		/**
		 * Removes the reference frame after index
		 */
		function removeAllAfter(index:int):IReferenceFrame;
	}
}