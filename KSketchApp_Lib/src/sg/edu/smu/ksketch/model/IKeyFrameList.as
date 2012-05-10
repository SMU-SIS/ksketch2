/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.model
{
	import flash.geom.Matrix;

	public interface IKeyFrameList
	{
		//Current plan: access only by time
		/**
		 * Returns number of keys in this key frame list
		 */
		function get numKeys():int;

		/**
		 * Returns the key frame that should be used to access properties at the give time.
		 */
		function lookUp(kskTime:Number):IKeyFrame;
		// if last key frame time < ksktime, return last key frame, lese
		// return getAtOrAfter(kskTime)
		
		/**
		 * Returns a key frame given its position within the list of keys
		 */
		//function getAtIndex(index:int):IKeyFrame;
		
		/**
		 * Returns the key frame with endTime == kskTime.
		 * If not key frame exists at this time, returns null.
		 */
		function getAtTime(kskTime:Number):IKeyFrame;
		
		/**
		 * Returns the last key frame such that endTime <= kskTime
		 */
		function getAtOrBeforeTime(kskTime:Number):IKeyFrame;
		
		/**
		 * Returns the first key frame such that kskTime <= endTime
		 */
		function getAtOrAfter(kskTime:Number):IKeyFrame;
		
		
		/**
		 * Returns the index of the active key at kskTime
		 */
		//function indexOfActive(kskTime:Number):int;
		
		/**
		 * Takes in an IKeyFrame and finds its position in this list
		 */
		//function indexOf(key:IKeyFrame):int
		
		/**
		 * Inserts a new key frame at the given time if none exists
		 * Returns the key frame at that time
		 */
		function insert(time:Number):IKeyFrame
		 
		/**
		 * Inserts the given key into this list according to its time.
		 * THrows an error if there is an existing key at that time.
		 * Otherwise, returns the inserted key.
		 */
		function insertKey(keyframe:IKeyFrame):IKeyFrame
			
		/**
		 * Adds a key frame to the end of this list.
		 * Throws an error if the key frame has an earlier end time than the last key
		 */
		function append(keyFrame:IKeyFrame):void;
		
		/**
		 * Adds an ordered vector of key frames the end of this list
		 * Throws an error if the vector is not properly ordered in ascending time
		 * or if any one of the keys has end time <= the last key of this list
		 */
		function appendList(keyFrame:Vector.<IKeyFrame>):void;	

		/**
		 * Removes the given key frame from this list
		 * shiftTime will subtract t from the endTime of the key frames after the given key where
		 * t = keyFrame.endTime-keyFrame.previous.endTime;
		 */
		function remove(keyframe:IKeyFrame,shiftTime:Boolean = false):IKeyFrame;
		
		/**
		 * Removes all keys after the given key
		 */
		function removeSegmentAfter(keyframe:IKeyFrame):void;
		
		
		/**
		 * Removes all key frames with end time < kskTime
		 */
		function removeAllAfter(kskTime:Number):Vector.<IKeyFrame>;
		//could add rmoveAtIndex or removeAtTime if necessary
		
		/**
		 * Shifts all keys at and after kskTIme by the time by given delta
		 */
		function shiftKeys(kskTime:Number, delta:int):void;
		
		/**
		 * Function to merge the transformations of key frame from indices start to and including end
		 */
		//function mergeKeys(startIndex:int, endIndex:int):void;
		
		// consider ading functions to set a range of key frames to a set of values given in a vector
	}
}