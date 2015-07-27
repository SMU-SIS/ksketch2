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

	public class KSketchStyles
	{
		//ANGLE VALUES
		public static const ANGLE_50:Number = 50;
		
		//SHADOW DISTANCE MEASUREMENTS
		public static const SHADOW_DIST_03:Number = 3;
		public static const SHADOW_DIST_12:Number = 12;
		
		//ALPHA VALUES
		public static const ALPHA_00:Number = 0;
		public static const ALPHA_02:Number = 0.2;
		public static const ALPHA_04:Number = 0.4;
		public static const ALPHA_05:Number = 0.5;
		public static const ALPHA_06:Number = 0.6;
		public static const ALPHA_1:Number = 1;
		
		//COLOR VALUES
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
		
		//FONT VALUES
		public static const FONT_FAMILY:String = "Arial, Helvetica";
		public static var FONT_SIZE_14:Number = 14;
		public static var FONT_SIZE_18:Number = 18;
		public static var FONT_SIZE_26:Number = 26;
		public static var FONT_SIZE_60:Number = 60;
		
		//SCALE FACTOR
		public static var SCALE:Number = 1;
		
		//MEASUREMENTS
		public static var NUMBER_01:Number = 1;
		public static var NUMBER_02:Number = 2;
		public static var NUMBER_03:Number = 3;
		public static var NUMBER_04:Number = 4;
		public static var NUMBER_05:Number = 5;
		public static var NUMBER_07:Number = 7;
		public static var NUMBER_075:Number = 7.5;
		public static var NUMBER_10:Number = 10;
		public static var NUMBER_0105:Number = 10.5;
		public static var NUMBER_12:Number = 12;
		public static var NUMBER_14:Number = 14;
		public static var NUMBER_15:Number = 15;
		public static var NUMBER_18:Number = 18;
		public static var NUMBER_20:Number = 20;
		public static var NUMBER_23:Number = 23;
		public static var NUMBER_25:Number = 25;
		public static var NUMBER_40:Number = 40;
		public static var NUMBER_50:Number = 50;
		public static var NUMBER_60:Number = 60;
		public static var NUMBER_74:Number = 74;
		public static var NUMBER_80:Number = 80;
		public static var NUMBER_90:Number = 90;
		public static var NUMBER_100:Number = 100;
		public static var NUMBER_120:Number = 120;
		public static var NUMBER_150:Number = 150;
		public static var NUMBER_160:Number = 160;
		public static var NUMBER_250:Number = 250;
		public static var NUMBER_300:Number = 300;
		public static var NUMBER_875:Number = 875;
		public static var NUMBER_960:Number = 960;
		public static var NUMBER_1000:Number = 1000;
		public static var NUMBER_1100:Number = 1100;
		public static var NUMBER_1200:Number = 1200;
		
		public static function scale(scale:int):void
		{ 
			trace("Scaling by " + scale);
			FONT_SIZE_14 = 14 * scale;
			FONT_SIZE_18 = 18 * scale;
			FONT_SIZE_26 = 26 * scale;
			FONT_SIZE_60 = 60 * scale;
			
			SCALE = 1 * scale;
			
			NUMBER_01 = 1 * scale;
			NUMBER_02 = 2 * scale;
			NUMBER_03 = 3 * scale;
			NUMBER_04 = 4 * scale;
			NUMBER_05 = 5 * scale;
			NUMBER_07 = 7 * scale;
			NUMBER_075 = 7.5 * scale;
			NUMBER_10 = 10 * scale;
			NUMBER_0105 = 10.5 * scale;
			NUMBER_12 = 12 * scale;
			NUMBER_14 = 14 * scale;
			NUMBER_15 = 15 * scale;
			NUMBER_18 = 18 * scale;
			NUMBER_20 = 20 * scale;
			NUMBER_23 = 23 * scale;
			NUMBER_25 = 25 * scale;
			NUMBER_40 = 40 * scale;
			NUMBER_50 = 50 * scale;
			NUMBER_60 = 60 * scale;
			NUMBER_74 = 74 * scale;
			NUMBER_80 = 80 * scale;
			NUMBER_90 = 90 * scale;
			NUMBER_100 = 100 * scale;
			NUMBER_120 = 120 * scale;
			NUMBER_150 = 150 * scale;
			NUMBER_160 = 160 * scale;
			NUMBER_250 = 250 * scale;
			NUMBER_300 = 300 * scale;
			NUMBER_875 = 875 * scale;
			NUMBER_960 = 960 * scale;
			NUMBER_1000 = 1000 * scale;
			NUMBER_1100 = 1100 * scale;
			NUMBER_1200 = 1200 * scale;
		}
	}
}