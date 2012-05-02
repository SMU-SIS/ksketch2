/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

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