/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package sg.edu.smu.ksketch2.components.ImportImage
{
	import flash.display.*;
	import flash.events.MouseEvent;

	public class Dott extends Sprite 
	{	
		public var shape:Shape = new Shape();
		
		public function Dott() 
		{			
			shape.graphics.beginFill( 0xFF0000 );
			shape.graphics.drawCircle( 0, 0, 5 );			
			shape.graphics.endFill();
			shape.graphics.beginFill( 0x00FF00 );
			shape.graphics.drawCircle( 0, 0, 3 );
			shape.graphics.endFill();
			shape.x = 0;
			shape.y = 0;			
	     	addChild(shape);										
			setChildIndex( shape, 0 );
			this.doubleClickEnabled=true;
		}
			
	}
		
}