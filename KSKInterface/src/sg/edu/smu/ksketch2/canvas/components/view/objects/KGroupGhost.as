/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.canvas.components.view.objects
{
	import flash.display.Sprite;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch2.operators.KVisibilityControl;
	
	/**
	 * Ghost for KGroupView
	 */
	public class KGroupGhost extends Sprite
	{
		public function KGroupGhost(objectArr:Array)
		{
			//original implementation
			super();
			visible = false;
			
			if(objectArr)
			{
				trace("KGroupGhost : " + objectArr.length);
				for(var i:int=0; i<objectArr.length; i++)
				{
					var strokePoints:Vector.<Point> = objectArr[i][0];
					var color:uint = objectArr[i][1];
					var thickness:Number = objectArr[i][2];
					
					if(strokePoints)
					{
						if(strokePoints.length > 0)
						{
							graphics.lineStyle(thickness, color);
							graphics.moveTo(strokePoints[0].x, strokePoints[0].y);
							
							for(var j:int = 1; j< strokePoints.length; j++)
								graphics.lineTo(strokePoints[j].x, strokePoints[j].y);
						}
					}
					
					alpha = KVisibilityControl.GHOST_ALPHA;
				}
			}
			
		}
	}
}