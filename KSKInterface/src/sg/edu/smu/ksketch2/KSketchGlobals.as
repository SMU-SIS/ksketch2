/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2
{
	import flash.system.Capabilities;

	public class KSketchGlobals
	{
		//Color 
		public static const COLOR_WHITE:uint = 0xFFFFFF;
		public static const COLOR_BLACK:uint = 0x000000;
		public static const COLOR_RED_LIGHT:uint = 0xDD1F26;
		public static const COLOR_RED:uint = 0xFF0000;
		public static const COLOR_RED_DARK:uint = 0x6B0000;
		public static const COLOR_GREY_VERYLIGHT:uint = 0xD0D2D3;
		public static const COLOR_GREY_LIGHT:uint = 0xC8CCCE;
		public static const COLOR_GREY_MEDIUM:uint = 0xA6A8AB;
		public static const COLOR_GREY_DARK:uint = 0x505050;
		public static const COLOR_BLUE:uint = 0x0000FF;
		public static const COLOR_GREEN:uint = 0x00FF00;
		
		//Alpha 
		public static const ALPHA_00:Number = 0;
		public static const ALPHA_02:Number = 0.2;
		public static const ALPHA_04:Number = 0.4;
		public static const ALPHA_05:Number = 0.5;
		public static const ALPHA_06:Number = 0.6;
		public static const ALPHA_1:Number = 1;
		
		//Angle 
		public static const ANGLE_50:Number = 50;
		
		//Font sizes
		public static const FONT_FAMILY:String = "Arial, Helvetica";
		public static var FONT_SIZE_10:Number = 10;
		public static var FONT_SIZE_10_5:Number = 10.5;
		public static var FONT_SIZE_14:Number = 14;
		public static var FONT_SIZE_18:Number = 18;
		public static var FONT_SIZE_20:Number = 20;
		public static var FONT_SIZE_26:Number = 26;
		public static var FONT_SIZE_60:Number = 60;
		public static var FONT_SIZE_300:Number = 300;
		
		//Main rectangle
		public static const RECT_STRENGTH:Number = 1;
		public static const RECT_BLURX:Number = 12;
		public static const RECT_BLURY:Number = 12;
		public static var RECT_RADIUSX:Number = 5;
		public static var RECT_RADIUSY:Number = 5;
		
		//Scaling
		public static var SCALE:Number = 1;
		public static var WIDTH:int = 0;
		public static var HEIGHT:int = 0;
		public static var ASPECTRATIO:Number = 0;
		
		public static function setView():void
		{
			
			if(Capabilities.playerType != "PlugIn" && Capabilities.playerType != "Desktop")
			{
				if(Capabilities.screenResolutionX > Capabilities.screenResolutionY)
				{
					WIDTH = Capabilities.screenResolutionX;
					HEIGHT = Capabilities.screenResolutionY;
				}
				else
				{
					WIDTH = Capabilities.screenResolutionY;
					HEIGHT = Capabilities.screenResolutionX;
				}
				
				ASPECTRATIO = int((WIDTH/HEIGHT)*100)/100;
				
				if(WIDTH > 1280 && HEIGHT > 960)
					SCALE = 2;
				
				FONT_SIZE_10 = 10 * SCALE;
				FONT_SIZE_10_5 = 10.5 * SCALE;
				FONT_SIZE_14 = 14 * SCALE;
				FONT_SIZE_18 = 18 * SCALE;
				FONT_SIZE_20 = 20 * SCALE;
				FONT_SIZE_26 = 26 * SCALE;
				FONT_SIZE_60 = 60 * SCALE;
				FONT_SIZE_300 = 300 * SCALE;
				
				RECT_RADIUSX = 5 * SCALE;
				RECT_RADIUSY = 5 * SCALE;
			}
			
		}
	}
}