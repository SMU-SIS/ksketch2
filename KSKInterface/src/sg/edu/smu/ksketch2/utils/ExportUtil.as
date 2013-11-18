/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.utils
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.canvas.components.view.KModelDisplay;

	/**
 	 * The ExportUtil class serves as the concrete class for video
 	 * exporting in K-Sketch. Specifically, it uses the given model and
 	 * its related display to generate a set of images to be used in video
 	 * exporting.
 	 */
	public class ExportUtil
	{
		/**
 		 * The exported content.
 		 */
		public static var exportedContent:ByteArray;

		/**
 		 * The width for 480p display.
 		 */
		public static const WIDTH_480P:Number = 854;
		
		/**
 		 * The height for 480p display.
 		 */
		public static const HEIGHT_480P:Number = 480;
		
		/**
 		 * Converts the scene graph to FLV bytes.
 		 * 
 		 * @param display The target model display.
 		 * @param ksketch The target ksketch object.
		 */
		public static function convertSceneToFLVBytes(display:KModelDisplay, ksketch:KSketch2):Vector.<BitmapData>
		{
			//Size of the area to be captured to be determined here
			var captureArea:Rectangle = new Rectangle(0,0,WIDTH_480P,HEIGHT_480P);
			var drawnFrames:Vector.<BitmapData> = new Vector.<BitmapData>();
			
			var currentTime:Number = 0;
			var endTime:Number = ksketch.maxTime;
			var currentFrame:BitmapData;
			
			//Generate the matrix to scale
			var toScaleX:Number = KSketch2.CANONICAL_WIDTH/captureArea.width;
			var toScaleY:Number = KSketch2.CANONICAL_HEIGHT/captureArea.height;
			var matrix:Matrix = new Matrix();
			matrix.scale(1/toScaleX, 1/toScaleY);
			
			//Draw the frames for at every frame boundary
			while(currentTime <= endTime)
			{
				ksketch.time = currentTime;
				currentFrame = new BitmapData(captureArea.width, captureArea.height, false, 0xFFFFFF);	
				currentFrame.draw(display, matrix);				
				drawnFrames.push(currentFrame);
				currentTime += KSketch2.ANIMATION_INTERVAL;				
			}
			
			return drawnFrames;
		}
	}
}