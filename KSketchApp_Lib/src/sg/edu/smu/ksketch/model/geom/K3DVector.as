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
	public class K3DVector
	{
		public var x:Number;
		public var y:Number;
		public var z:Number;
		
		public function K3DVector(givenX:Number=0, givenY:Number=0, givenZ:Number=0)
		{
			x = givenX;
			y = givenY;
			z = givenZ;
		}
		
		public function clone():K3DVector
		{
			return new K3DVector(x,y,z);
		}
	}
}