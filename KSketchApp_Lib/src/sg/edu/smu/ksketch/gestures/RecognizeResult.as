/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package sg.edu.smu.ksketch.gestures
{
	import flash.geom.Point;

	public class RecognizeResult
	{
		public static const UNDEFINED:RecognizeResult = new RecognizeResult("Undefined", Number.MIN_VALUE);
		
		private var _type:String;
		
		private var _score:Number;
		
		public function RecognizeResult(name:String, score:Number)//rotationInvariant:Boolean, score:Number)
		{
			_type = name;
			_score = score;
		}

		public function get score():Number
		{
			return _score;
		}

		public function get type():String
		{
			return _type;
		}

	}
}