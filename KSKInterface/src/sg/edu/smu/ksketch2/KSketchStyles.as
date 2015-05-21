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
		//scale
		public static var SCALE:int = 1;
		
		//Application
		public static const APP_BACKGROUND_COLOR:uint = 0xD0D2D3;
		public static const APP_FONT_FAMILY:String = "Arial, Helvetica";

		public static const BLACK_PEN:uint = 0x000000;
		public static const BLUE_PEN:uint = 0x0000FF;
		public static const GREEN_PEN:uint = 0x00FF00;
		public static const RED_PEN:uint = 0xFF0000;
		public static const GREY_HIGHLIGHT:uint = 0xd3d3d3;
		public static const WHITE_HIDE:uint = 0xFFFFFF;
		
		//Login
		public static var LOGIN_CONNECTION_FONT_SIZE:Number = 23;
		//Canvas
		public static const CANVAS_BUTTON_NORMAL:uint = 0xC8CCCE;
		public static const CANVAS_BUTTON_ACTIVATED:uint = 0x505050;
		public static const CANVAS_BUTTON_PLAY_ACTIVATED:uint = 0xDD1F26;
		public static const CANVAS_BUTTON_SHADOW_COLOR:uint = 0x000000;
		public static const CANVAS_BUTTON_SHADOW_STRENGTH:Number = 0.5;
		public static const CANVAS_BUTTON_SHADOW_ALPHA:Number = 0.6;
		public static const CANVAS_BUTTON_SHADOW_DISTANCE:Number = 3;
		public static const CANVAS_BUTTON_SHADOW_ANGLE:Number = 50;
		public static var CANVAS_BUTTON_CORNER_RADIUS:Number = 5;
		
		//Timebar Stuff
		public static var TIMEBAR_LAYOUT_GAP:Number = 4;
		public static var TIMEBAR_LAYOUT_PADDING_HORIZONTAL:Number = 5;
		public static var TIMEBAR_LAYOUT_PADDING_VERTICAL:Number = 5;
		public static const TIMEBAR_BACKGROUND_COLOR:uint = 0xA6A8AB;
		public static var TIMEBAR_GAP_CONTEXTMENU_DOUBLE:int = 15;
		public static var TIMEBAR_GAP_CONTEXTMENU_SINGLE:int = 100;
		public static var TIMEBAR_X_LIMIT_DOUBLE:int = 875;
		public static var TIMEBAR_X_LIMIT_SINGLE:int = 960;
		public static var TIMEBAR_X_LIMIT_DOUBLE_ANDROID:int = 1100;
		public static var TIMEBAR_X_LIMIT_SINGLE_ANDROID:int = 1200;
		
		public static const TIMEBAR_SHADOW_COLOR:uint = 0x000000;
		public static const TIMEBAR_SHADOW_ALPHA:Number = 0.35;
		public static const TIMEBAR_SHADOW_DISTANCE:Number = 8;
		public static const TIMEBAR_SHADOW_ANGLE:Number = 90;
		public static const TIMEBAR_SHADOW_STRENGTH:Number = 2;
		
		public static var TIMEBAR_PLAY_BUTTON_WIDTH:Number = 60; 
		public static var TIMEBAR_PLAY_BUTTON_HEIGHT:Number = 60;
		public static var TIMEBAR_BUTTON_WIDTH:Number = 50;
		public static var TIMEBAR_BUTTON_HEIGHT:Number = 50;
		
		public static var TIME_CONTROL_HEIGHT:Number = 80;
		public static const TIME_CONTROL_BACKGROUND_COLOR:uint = 0xFFFFFF;
		public static const TIME_CONTROL_FILL_COLOR:uint = 0xDD1F26;
		public static const TIME_INDICATOR_COLOR:uint = 0x000000;
		
		public static var TIME_LABEL_FONT_SIZE:Number = 10;
		public static const TIME_LABEL_FONT_COLOR:Number = 0x404041;
		public static var TIME_PARTITION_FONT_SIZE:Number = 10.5;
		
		public static const TIME_TICK_KEYFRAME:uint = 0x6B0000;		//for keyframes (passthrough = false)
		public static const TIME_TICK_CONTROLPOINT:uint = 0x6B0000; //for controlpoints (passthroug = true)
		public static var TIME_TICK_THICKNESS:Number = 4;
		public static var TIME_TICK_THICKNESS_A:Number = 3;
		public static var TIME_TICK_THICKNESS_B:Number = 7;
		public static const TIME_TICK_SELECTED_ALPHA:Number = 1;
		public static const TIME_TICK_UNSELECTED_ALPHA:Number = 0.5;
		public static const ACTIVITY_COLOR:uint = 0xFF0000;
		public static const ACTIVITY_OTHER_COLOR:uint = 0xC2C2C2;
		public static const ACTIVITY_ALPHA:Number = 1.0;
		
		public static const MAGNIFIER_BACKGROUND_COLOR:uint = 0x000000;
		public static var MAGNIFIER_IMAGE_UNSCALED_WIDTH:Number = 50;
		public static var MAGNIFIER_SCALE:Number = 2;
		public static var MAGNIFIER_PADDING:Number = 7.5;
		public static var MAGNIFIER_FONT_SIZE:Number = 11;
		public static const MAGNIFIER_FONT_COLOR:uint = 0xFFFFFF;
		public static var MAGNIFIER_ARROW_PROPORTION:Number = 0.4;
		public static var MAGNIFIER_INDICATOR_THICKNESS:Number = 3;
		public static var MAGNIFIER_CIRCLE_1:int = 18;
		public static var MAGNIFIER_CIRCLE_2:int = 14;
		public static var MAGNIFIER_CIRCLE_POS:int = 23;
		public static var MAGNIFIER_CURRENTTIMELABEL_THICKNESS:Number = 1;
		public static const MAGNIFIER_CURRENTTIMELABEL_COLOR_MULTIPLIER:Number = 100;
		
		public static const TOGGLEBUTTON_ON_COLOR:uint = 0xFFFFFF;
		public static const TOGGLEBUTTON_OFF_COLOR:uint = 0x000000;
		public static var TOGGLEBUTTON_PADDING:Number = 2;
		public static var TOGGLEBUTTON_FONT_SIZE:Number = 9;
		public static var TOGGLEBUTTON_CORNERS:Number = 2;
		
		//Context menu
		public static var CONTEXTMENU_PADDING:Number = 7.5;
		public static var CONTEXTMENU_BUTTON_PADDING:Number = 5;
		public static var CONTEXTMENU_CORNERS:Number = 5;
		public static const CONTEXTMENU_BACKGROUND_COLOR:uint = 0x000000;
		
		//Canvas
		public static const CANVAS_BACKGROUND_COLOR:uint = 0xA6A8AB;
		public static const CANVAS_PAPER_COLOR:uint = 0xFFFFFF;
		public static const CANVAS_PAPER_REGION:uint = 0xC43F2D;
		public static const CANVAS_BORDER_COLOR:uint = 0x000000;
		public static var CANVAS_BORDER_WEIGHT:Number = 1;
		public static const CANVAS_SHADOW_COLOR:uint = 0x000000;
		public static const CANVAS_SHADOW_ALPHA:Number = 0.4;
		public static const CANVAS_SHADOW_X_DISTANCE:Number = 12;
		public static const CANVAS_SHADOW_Y_DISTANCE:Number = 12;
		public static const CANVAS_SHADOW_ANGLE:Number = 45;
		public static const CANVAS_SHADOW_STRENGTH:Number = 2;
		
		//Dialog button skins
		public static var DIALOGBUTTON_PADDING:Number = 10;
		public static var DIALOGBUTTON_FONT_SIZE:Number = 12;
		
		//Feedback Message
		public static var FEEDBACK_FONT_SIZE:Number = 60;
		public static var FEEDBACK_FADE_TIME:Number = 250;
		public static const FEEDBACK_BACKGROUND_ALPHA:Number = 0;
		
		//Menu
		public static var MENU_GAP:Number = 10;
		public static var MENU_CORNER_RADIUS:Number = 5;
		public static const MENU_BACKGROUND_COLOR:uint = 0xA6A8AB;
		public static var MENU_PADDING:Number = 5;
		public static var MENU_BUTTON_GAP:Number = 10;
		public static var MENU_BUTTON_WIDTH:Number = 35;
		public static var MENU_BUTTON_HEIGHT:Number = 35;
		
		//Widget
		public static const WIDGET_ENABLED_ALPHA:Number = 1;
		public static const WIDGET_DISABLED_ALPHA:Number = 0.2;
		public static const WIDGET_INTERPOLATE_COLOR:uint = 0x6E6F71;
		public static const WIDGET_PERFORM_COLOR:uint = 0x971C24;
		public static var WIDGET_CENTROID_SIZE:Number = 10; //PIVOT
		
		//Logo
		public static var LOGO_BUTTON_WIDTH:Number = 150;
		public static var LOGO_BUTTON_HEIGHT:Number = 150;
		public static var LOGO_PADDING_LEFT:Number = 80;
		public static var LOGO_PADDING_TOP:Number = 40;
		public static var LOGO_PADDING_BUTTON:Number = 10;
		
		//List of sketches
		public static const LIST_SKETCH_GAP:int = 0;
		public static var LIST_SKETCH_FONT:int = 20;
		public static var LIST_SKETCH_LINE:int = 1000;
		public static var LIST_SKETCH_WIDTH:Number = 74;
		public static var LIST_SKETCH_HEIGHT:Number = 120;
		public static var LIST_SKETCH_IMAGE_WIDTH:Number = 160;
		public static var LIST_SKETCH_IMAGE_HEIGHT:Number = 90;
		
		//Pop up menu separator
		public static var POPUP_SEPARATOR_LINE:int = 60;
		public static var POPUP_SEPARATOR_GAP:int = 5;
		
		//General Button
		public static var BUTTON_SIZE:int = 15;
		public static var DIALOG_BUTTON_SIZE:int = 14;
		public static var DIALOG_BUTTON_HEADER:int = 26;
		public static var DIALOG_BUTTON_NORMAL_FONT:int = 18;
		public static var DIALOG_BUTTON_SMALL_FONT:int = 10;
		public static var DIALOG_PADDING_20:int = 20;
		public static var DIALOG_PADDING_15:int = 15;
		public static var DIALOG_PADDING_10:int = 10;
		public static var DIALOG_PADDING_5:int = 5;
		public static var DIALOG_MEASUREMENT_25:int = 50;
		public static var DIALOG_MEASUREMENT_50:int = 50;
		public static var DIALOG_MEASUREMENT_100:int = 100;
		public static var DIALOG_MEASUREMENT_300:int = 300;
		
		//Help screen
		public static var X_POS_BUTTON:int = 600;
		public static var Y_POS_BUTTON:int = 450;
		public static var IMAGE_HELP_WIDTH:int = 750;
		public static var IMAGE_HELP_HEIGHT:int = 512;
	
		public static function scaleUp(scaleFactor:Number):void
		{
			SCALE = scaleFactor;
			LOGIN_CONNECTION_FONT_SIZE = LOGIN_CONNECTION_FONT_SIZE * scaleFactor;
			CANVAS_BUTTON_CORNER_RADIUS = CANVAS_BUTTON_CORNER_RADIUS * scaleFactor;
			TIMEBAR_LAYOUT_GAP = TIMEBAR_LAYOUT_GAP * scaleFactor;
			TIMEBAR_LAYOUT_PADDING_HORIZONTAL = TIMEBAR_LAYOUT_PADDING_HORIZONTAL * scaleFactor;
			TIMEBAR_LAYOUT_PADDING_VERTICAL = TIMEBAR_LAYOUT_PADDING_VERTICAL * scaleFactor;
			TIMEBAR_GAP_CONTEXTMENU_DOUBLE = TIMEBAR_GAP_CONTEXTMENU_DOUBLE * (scaleFactor * 2);
			TIMEBAR_GAP_CONTEXTMENU_SINGLE = TIMEBAR_GAP_CONTEXTMENU_SINGLE * scaleFactor;
			TIMEBAR_X_LIMIT_DOUBLE = TIMEBAR_X_LIMIT_DOUBLE * scaleFactor;
			TIMEBAR_X_LIMIT_SINGLE = TIMEBAR_X_LIMIT_SINGLE * scaleFactor;
			TIMEBAR_X_LIMIT_DOUBLE_ANDROID = TIMEBAR_X_LIMIT_DOUBLE_ANDROID * scaleFactor;
			TIMEBAR_X_LIMIT_SINGLE_ANDROID = TIMEBAR_X_LIMIT_SINGLE_ANDROID * scaleFactor;
			TIMEBAR_PLAY_BUTTON_WIDTH = TIMEBAR_PLAY_BUTTON_WIDTH * scaleFactor; 
			TIMEBAR_PLAY_BUTTON_HEIGHT = TIMEBAR_PLAY_BUTTON_HEIGHT * scaleFactor;
			TIMEBAR_BUTTON_WIDTH = TIMEBAR_BUTTON_WIDTH * scaleFactor;
			TIMEBAR_BUTTON_HEIGHT = TIMEBAR_BUTTON_HEIGHT * scaleFactor;
			TIME_CONTROL_HEIGHT = TIME_CONTROL_HEIGHT * scaleFactor;
			TIME_LABEL_FONT_SIZE = TIME_LABEL_FONT_SIZE * scaleFactor;
			TIME_PARTITION_FONT_SIZE = TIME_PARTITION_FONT_SIZE * scaleFactor;
			TIME_TICK_THICKNESS = TIME_TICK_THICKNESS * scaleFactor;
			TIME_TICK_THICKNESS_A = TIME_TICK_THICKNESS_A * scaleFactor;
			TIME_TICK_THICKNESS_B = TIME_TICK_THICKNESS_B * scaleFactor;
			MAGNIFIER_IMAGE_UNSCALED_WIDTH = MAGNIFIER_IMAGE_UNSCALED_WIDTH * (scaleFactor);
			MAGNIFIER_SCALE = MAGNIFIER_SCALE * (scaleFactor-0.8);
			MAGNIFIER_PADDING = MAGNIFIER_PADDING * scaleFactor;
			MAGNIFIER_FONT_SIZE = MAGNIFIER_FONT_SIZE * scaleFactor;
			MAGNIFIER_ARROW_PROPORTION = MAGNIFIER_ARROW_PROPORTION * (scaleFactor-0.5);
			MAGNIFIER_INDICATOR_THICKNESS = MAGNIFIER_INDICATOR_THICKNESS * scaleFactor;
			MAGNIFIER_CURRENTTIMELABEL_THICKNESS = MAGNIFIER_CURRENTTIMELABEL_THICKNESS * scaleFactor;
			MAGNIFIER_CIRCLE_1 = MAGNIFIER_CIRCLE_1 * (scaleFactor - 0.2);
			MAGNIFIER_CIRCLE_2 = MAGNIFIER_CIRCLE_2 * (scaleFactor - 0.2);
			MAGNIFIER_CIRCLE_POS = MAGNIFIER_CIRCLE_POS * (scaleFactor);
			TOGGLEBUTTON_PADDING = TOGGLEBUTTON_PADDING * scaleFactor;
			TOGGLEBUTTON_FONT_SIZE = TOGGLEBUTTON_FONT_SIZE * scaleFactor;
			TOGGLEBUTTON_CORNERS = TOGGLEBUTTON_CORNERS * scaleFactor;
			CONTEXTMENU_PADDING = CONTEXTMENU_PADDING * scaleFactor;
			CONTEXTMENU_BUTTON_PADDING = CONTEXTMENU_BUTTON_PADDING * scaleFactor;
			CONTEXTMENU_CORNERS = CONTEXTMENU_CORNERS * scaleFactor;
			CANVAS_BORDER_WEIGHT = CANVAS_BORDER_WEIGHT * scaleFactor;
			DIALOGBUTTON_PADDING = DIALOGBUTTON_PADDING * scaleFactor;
			DIALOGBUTTON_FONT_SIZE = DIALOGBUTTON_FONT_SIZE * scaleFactor;
			FEEDBACK_FONT_SIZE = FEEDBACK_FONT_SIZE * scaleFactor;
			FEEDBACK_FADE_TIME = FEEDBACK_FADE_TIME * scaleFactor;
			MENU_GAP = MENU_GAP * scaleFactor;
			MENU_CORNER_RADIUS = MENU_CORNER_RADIUS * scaleFactor;
			MENU_PADDING = MENU_PADDING * scaleFactor;
			MENU_BUTTON_GAP = MENU_BUTTON_GAP * scaleFactor;
			MENU_BUTTON_WIDTH = MENU_BUTTON_WIDTH * scaleFactor;
			MENU_BUTTON_HEIGHT = MENU_BUTTON_HEIGHT * scaleFactor;
			WIDGET_CENTROID_SIZE = WIDGET_CENTROID_SIZE * (scaleFactor - 0.7);
			LOGO_BUTTON_WIDTH = LOGO_BUTTON_WIDTH * scaleFactor;
			LOGO_BUTTON_HEIGHT = LOGO_BUTTON_HEIGHT * scaleFactor;
			LOGO_PADDING_LEFT = LOGO_PADDING_LEFT * scaleFactor;
			LOGO_PADDING_TOP = LOGO_PADDING_TOP * scaleFactor;
			LOGO_PADDING_BUTTON = LOGO_PADDING_BUTTON * scaleFactor;
			BUTTON_SIZE = BUTTON_SIZE * scaleFactor;
			LIST_SKETCH_FONT = LIST_SKETCH_FONT * (scaleFactor - 0.5);
			LIST_SKETCH_LINE = LIST_SKETCH_LINE * (scaleFactor - 0.5); 
			LIST_SKETCH_IMAGE_WIDTH = LIST_SKETCH_IMAGE_WIDTH * (scaleFactor - 0.5);
			LIST_SKETCH_IMAGE_HEIGHT = LIST_SKETCH_IMAGE_HEIGHT * (scaleFactor - 0.5);
			LIST_SKETCH_WIDTH = LIST_SKETCH_WIDTH * (scaleFactor - 0.5);
			LIST_SKETCH_HEIGHT = LIST_SKETCH_HEIGHT * (scaleFactor - 0.5);
			POPUP_SEPARATOR_LINE = POPUP_SEPARATOR_LINE * scaleFactor;
			POPUP_SEPARATOR_GAP = POPUP_SEPARATOR_GAP * scaleFactor;
			BUTTON_SIZE = BUTTON_SIZE * (scaleFactor - 0.5);
			DIALOG_BUTTON_SIZE = DIALOG_BUTTON_SIZE * scaleFactor;
			DIALOG_BUTTON_HEADER = DIALOG_BUTTON_HEADER * scaleFactor;
			DIALOG_BUTTON_NORMAL_FONT = DIALOG_BUTTON_NORMAL_FONT * scaleFactor;
			DIALOG_BUTTON_SMALL_FONT = DIALOG_BUTTON_SMALL_FONT * scaleFactor;
			DIALOG_PADDING_20 = DIALOG_PADDING_20 * scaleFactor;
			DIALOG_PADDING_15 = DIALOG_PADDING_15 * scaleFactor;
			DIALOG_PADDING_10 = DIALOG_PADDING_10 * scaleFactor;
			DIALOG_PADDING_5 = DIALOG_PADDING_5 * scaleFactor;
			DIALOG_MEASUREMENT_25 = DIALOG_MEASUREMENT_25 * (scaleFactor * 2);
			DIALOG_MEASUREMENT_50 = DIALOG_MEASUREMENT_50 * scaleFactor;
			DIALOG_MEASUREMENT_300 = DIALOG_MEASUREMENT_300 * scaleFactor;
			DIALOG_MEASUREMENT_100 = DIALOG_MEASUREMENT_100 * scaleFactor;
			X_POS_BUTTON = X_POS_BUTTON * scaleFactor;
			Y_POS_BUTTON = Y_POS_BUTTON * scaleFactor;
			IMAGE_HELP_WIDTH = IMAGE_HELP_WIDTH * scaleFactor;
			IMAGE_HELP_HEIGHT = IMAGE_HELP_HEIGHT * scaleFactor;
		}
	}
}