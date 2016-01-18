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
		private var _sketchID:String;
		private var _version:int;
		private var _userName:String;
		private var _activityType:String; //all
		private var _instructionNo:int; //all
		private var _objectID:int; //the sketched object, only for trace, track and recreate
		private var _objectTemplateID:int //all
		private var _time_taken:int; //all
		private var _time_given:int; //all
		private var _quadrantAttempt:int; //recall number of times 
		private var _quadrantPercentage:int //recall percentage
		private var _quadrantTracedRegion:Boolean //trace and recreate for drawing object
		private var _averageDistance:Number; //trace, track
		private var _maximumDistance:Number; //trace, track
		private var _rotationCountDifference:int; //track
		private var _stars:int; //all
		private var _retry:Boolean; //all
		
		public function KResult(activityType:String, instruction:int, id:int)
		{
			_version = 0;
			_activityType = activityType;
			_instructionNo = instruction;
			_objectTemplateID = id;
			_time_taken = 0;
			_time_given = 0;
			_quadrantAttempt = 0;
			_quadrantPercentage = 0;
			_quadrantTracedRegion = false;
			_averageDistance = 0;
			_maximumDistance = 0;
			_rotationCountDifference = 0;
			_stars = 0;
			_retry = false;
		}
		
		/**
		 * Get/Set methods for all attributes
		 */
		public function get sketchID():String
		{
			return _sketchID;
		}
		
		public function set sketchID(id:String):void
		{
			_sketchID = id;
		}
		
		public function get version():int
		{
			return _version;
		}
		
		public function set version(v:int):void
		{
			_version = v;
		}
		
		public function get userName():String
		{
			return _userName;
		}
		
		public function set userName(name:String):void
		{
			_userName = name;
		}
		
		public function get activityType():String
		{
			return _activityType;
		}
		
		public function set activityType(activity:String):void
		{
			_activityType = activity;
		}
		
		public function get objectID():int
		{
			return _objectID;
		}
		
		public function set objectID(id:int):void
		{
			_objectID = id;
		}
		
		public function get objectTemplateID():int
		{
			return _objectTemplateID;
		}
		
		public function set objectTemplateID(id:int):void
		{
			_objectTemplateID = id;
		}
		
		public function get instructionNo():int
		{
			return _instructionNo;
		}
		
		public function set instructionNo(value:int):void
		{
			_instructionNo = value;
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
		
		public function set quadrantAttempt(attempt:int):void
		{
			_quadrantAttempt = attempt;
		}
		
		public function get quadrantPercentage():int
		{
			return _quadrantPercentage;
		}
		
		public function set quadrantPercentage(percentage:int):void
		{
			_quadrantPercentage = percentage;
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
		
		public function get retry():Boolean
		{
			return _retry;
		}
		
		public function set retry(value:Boolean):void
		{
			_retry = value;
		}
	}
}