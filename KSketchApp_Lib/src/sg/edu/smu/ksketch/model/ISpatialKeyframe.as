/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.model
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch.model.geom.KPath;
	import sg.edu.smu.ksketch.model.geom.KPathPoint;
	import sg.edu.smu.ksketch.model.geom.KRotation;
	import sg.edu.smu.ksketch.model.geom.KScale;
	import sg.edu.smu.ksketch.model.geom.KTranslation;
	import sg.edu.smu.ksketch.model.implementations.KSpatialKeyFrame;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	import sg.edu.smu.ksketch.operation.implementations.KCompositeOperation;

	public interface ISpatialKeyframe extends IKeyFrame
	{
		//ALl the paths will be here
		
		/**
		 * Returns the complete matrix of this key frame,
		 * concatenated with the matrices of the preceding key frames
		 */
		function getFullMatrix(kskTime:Number, matrix:Matrix):Matrix;
		
		/**
		 * Returns the matrix of this key frame at kskTime
		 */
		function getPartialMatrix(kskTime:Number, matrix:Matrix):Matrix;
		
		/**
		 * Defines the center of this key frame
		 */	
		function get center():Point; //return point.clone()
		function set center(point:Point):void; 
		
		/**
		 * Defines the path on which this key frame's translation will be executed
		 */
		function get translate():KTranslation;
		function set translate(transform:KTranslation):void;
		
		/**
		 * Defines the path through which this key frame's rotation will be executed
		 */
		function get rotate():KRotation;
		function set rotate(path:KRotation):void;
		
		/**
		 * Defines the path through which this key frame's scale motion will be executed
		 */
		function get scale():KScale;
		function set scale(path:KScale):void;
		
		/**
		 * Returns a replace transform operation with the clones as the old keys and the current transforms
		 * as the new keys
		 */
		function getTransformOperation():IModelOperation;
		
		/**
		 * Returns the translation defined by this key frame's path at the given time.
		 */
		function getTranslation(time:Number):Point;
		
		/**
		 * Returns the rotation(in Radians) defined by this key frame's path at the given time.
		 */
		function getRotation(time:Number):Number;
		
		/**
		 * Returns the scale defined by this key frame's path at the given time.
		 */
		function getScale(time:Number):Number;
		
		/**
		 * Prepares the key frame for a transform
		 */
		function beginTransform():void;
		
		/**
		 * Appends a point to the end of the translation path
		 */
		function addToTranslation(x:Number, y:Number, time:Number):void;
		
		/**
		 * Call at the end of every translation operation
		 * Will invoke path processing functions to optimise the paths recorded during the operations
		 * and generate the appropriate transforms from the optimised paths
		 */
		function endTranslation(transitionType:int):void;
		
		/**
		 * Appends a point to the end of the rotation path
		 */
		function addToRotation(x:Number, y:Number, angle:Number, time:Number):void;
		function endRotation(transitionType:int):void;
		
		/**
		 * Appends a point to the end of the scale path
		 */
		function addToScale(x:Number, y:Number, scale:Number, time:Number):void;
		function endScale(transitionType:int):void;
		
		/**
		 * Takes in the elapsed time of the keyframe and splits the key into 2
		 * Returning the front portion
		 */
		function splitKey(time:Number, operation:KCompositeOperation, currentCenter:Point, startTimeOffset:Number = 0):Vector.<IKeyFrame>;

		/**
		 * Merges the transition path with that of the given key, 
		 * and returns the resultant offset path. 
		 */
		function mergeKey(key:ISpatialKeyframe, type:int):IModelOperation;
		
		/**
		 * Returns true if there are non-trivial transforms in this keyframe
		 */
		function hasTransform():Boolean;
	}
}