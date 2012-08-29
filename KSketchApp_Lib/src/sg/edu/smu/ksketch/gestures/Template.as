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