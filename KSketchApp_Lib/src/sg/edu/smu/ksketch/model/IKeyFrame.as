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