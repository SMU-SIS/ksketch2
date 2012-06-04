/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

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