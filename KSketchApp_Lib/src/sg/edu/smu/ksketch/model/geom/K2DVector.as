/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package sg.edu.smu.ksketch.model.geom
{
	public class K2DVector
	{
		public var x:Number;
		public var y:Number;
		
		public function K2DVector(givenX:Number=0, givenY:Number=0)
		{
			x = givenX;
			y = givenY;
		}
		
		public function clone():K2DVector
		{
			return new K2DVector(x,y);
		}
	}
}