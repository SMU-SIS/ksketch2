/**
 * Copyright 2010-2015 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.model.objects
{
	public class KResult
	{
		private var _activityType:String;
		private var _instructionNo:int;
		private var _objectID:int;
		private var _time_taken:int;
		private var _time_given:int;
		private var _quadrantAttempt:int;
		private var _recreateQuadrant:int;
		private var _averageDistance:Number;
		private var _maximumDistance:Number;
		private var _rotationCountDifference:int;
		private var _stars:int;
		
		public function KResult(activityType:String, instruction:int, id:int)
		{
			_activityType = activityType;
			_instructionNo = instruction;
			_objectID = id;
			_time_taken = 0;
			_time_given = 0;
			_quadrantAttempt = 0;
			_averageDistance = 0;
			_maximumDistance = 0;
			_rotationCountDifference = 0;
			_stars = 0;
		}
		
		/**
		 * Get/Set methods for all attributes
		 */
		public function get activityType():String
		{
			return _activityType;
		}
		
		public function set activityType(activity:String):void
		{
			_activityType = activity;
		}
		
		public function get timeTaken():int
		{
			return _time_taken;
		}
		
		public function set timeTaken(t:int):void
		{
			_time_taken = t;
		}
		
		public function get timeGiven():int
		{
			return _time_given;
		}
		
		public function set timeGiven(t:int):void
		{
			_time_given = t;
		}
		
		public function get quadrantAttempt():int
		{
			return _quadrantAttempt;
		}
		
		public function set quadrantAttempt(percentage:int):void
		{
			_quadrantAttempt = percentage;
		}
		
		public function get averageDistance():Number
		{
			return _averageDistance;
		}
		
		public function set averageDistance(distance:Number):void
		{
			_averageDistance = distance;
		}
		
		public function get maximumDistance():Number
		{
			return _maximumDistance;
		}
		
		public function set maximumDistance(distance:Number):void
		{
			_maximumDistance = distance;
		}
		
		public function get rotationCountDifference():int
		{
			return _rotationCountDifference;
		}
		
		public function set rotationCountDifference(count:int):void
		{
			_rotationCountDifference = count;
		}
		
		public function get stars():int
		{
			return _stars;
		}
		
		public function set stars(stars:int):void
		{
			_stars = stars;
		}
	}
}