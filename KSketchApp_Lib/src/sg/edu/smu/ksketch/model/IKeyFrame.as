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
	import flash.geom.Point;

	public interface IKeyFrame
	{
		/**
		 * Returns the previous key frame
		 */
		function get previous():IKeyFrame;
		
		/**
		 * Returns the next key frame
		 */
		function get next():IKeyFrame;
		
		/**
		 * Defines the end time of this key frame
		 */
		function get endTime():Number;		
		
		/**
		 * Defines the end time of this keyframe
		 */
		function set endTime(value:Number):void;
		
		/**
		 * Returns the start time of this key
		 */
		function startTime():Number;
		
		/**
		 * Returns a clone of this keyframe
		 */
		function clone():IKeyFrame;
		
		/**
		 * Retimes the keyframe
		 */
		function retimeKeyframe(newTime:Number):void;		
	}
}