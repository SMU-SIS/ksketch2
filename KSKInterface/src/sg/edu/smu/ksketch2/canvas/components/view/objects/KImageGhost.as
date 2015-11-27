/**
 * Copyright 2010-2015 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.canvas.components.view.objects
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	
	import sg.edu.smu.ksketch2.operators.KVisibilityControl;

	/**
	 * Ghost for KImageView
	 */
	public class KImageGhost extends Sprite
	{
		private var image:Bitmap;
		
		public function KImageGhost(bitmapData:BitmapData, x:Number, y:Number)
		{
			super();
			image = new Bitmap(bitmapData);
			image.x = x;
			image.y = y;
			addChild(image);
			alpha = KVisibilityControl.GHOST_ALPHA;
			visible = false;
		}
	}
}