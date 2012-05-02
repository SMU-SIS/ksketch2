/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.gestures
{
	import flash.geom.Point;

	public class Template
	{
		private var _name:String;
		private var _points:Vector.<Point>;
		
		public function Template(name:String, points:Vector.<Point>)//, rotationInvariant:Boolean)
		{
			_name = name;
			_points = points;
		}
		
		public function get name():String
		{
			return _name;
		}

		public function get points():Vector.<Point>
		{
			return _points;
		}
	}
}