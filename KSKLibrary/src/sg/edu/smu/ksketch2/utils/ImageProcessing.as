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

	/**
	 * The ImageProcessing class serves as the concrete class for image
	 * processing in K-Sketch.
	 */
	public class ImageProcessing
	{
		/**
		 * Generate the edges of the target image.
		 * 
		 * @param targetBMD The target image.
		 * @return The generated edge of the target image.
		 */
		public static function sobelOperation(targetBMD:BitmapData):BitmapData
		{
			var edgeData:BitmapData = new BitmapData(targetBMD.width, targetBMD.height);
			var targetWidth:Number = targetBMD.width-1;
			var targetHeight:Number = targetBMD.height-1;
			
			// loop through original data and calculate edges
			for(var w:int = 1; w<targetWidth; w++)
			{
				for(var h:int = 1; h<targetHeight; h++)
				{
					var pixelValue270:uint = getGray(targetBMD.getPixel(w-1, h));
					var pixelValue90:uint = getGray(targetBMD.getPixel(w+1, h));
					
					var pixelValue0:uint = getGray(targetBMD.getPixel(w, h-1));
					var pixelValue180:uint = getGray(targetBMD.getPixel(w, h+1));
					
					var pixelValue315:uint = getGray(targetBMD.getPixel(w-1, h-1));
					var pixelValue45:uint = getGray(targetBMD.getPixel(w+1, h-1));
					var pixelValue135:uint = getGray(targetBMD.getPixel(w+1, h+1));
					var pixelValue225:uint = getGray(targetBMD.getPixel(w-1, h+1));
					
					// applying the following convolution mask matrix to the pixel
					//    GX        GY  
					// -1, 0, 1   1, 2, 1
					// -2, 0, 2   0, 0, 0
					// -1, 0, 1  -1,-2,-1
					
					var gx:int = (pixelValue45 + (pixelValue90 * 2) + pixelValue135)-(pixelValue315 + (pixelValue270 * 2) + pixelValue225);
					var gy:int = (pixelValue315 + (pixelValue0 * 2) + pixelValue45)-(pixelValue225 + (pixelValue180 * 2 ) + pixelValue135);
					
					var gray:uint = Math.abs(gx) + Math.abs(gy);
					
					// decrease the grays a little or else its all black and white
					// you can play with this value to get harder or softer edges
					gray *= .5;
					
					// check to see if values aren't out of bounds
					if(gray > 255)
						gray = 255;
					
					if(gray < 0)
						gray = 0;
					
					// build the new pixel value
					var newPixelValue:uint = (gray << 16) + (gray << 8) + (gray);
					
					// copy the new pixel into the edge data bitmap
					edgeData.setPixel(w,h,Math.round(Math.round(newPixelValue/0xAAAAAA)*0xFFFFFF));	
				}	
			}
			
			return edgeData;
		}
		
		/**
		 * Gets the gray pixel value of the given input color.
		 * 
		 * @param pixelValue The pixel value of the target input color.
		 * @return The gray pixel value of the target input color.
		 */
		private static function getGray(pixelValue:uint):uint
		{
			var red:uint = (pixelValue >> 16 & 0xFF) * 0.30;
			var green:uint = (pixelValue >> 8 & 0xFF) * 0.59;
			var blue:uint = (pixelValue & 0xFF) * 0.11;
			
			return (red + green + blue);
		}
	}
}