/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.components
{
	import flash.display.DisplayObjectContainer;
	import flash.utils.Dictionary;
	
	import mx.controls.Menu;
	
	public class KPenMenu extends Menu
	{
		public static const LABEL_WHITE:String = "Eraser";
		public static const LABEL_BLACK:String = "Black Pen";
		public static const LABEL_RED:String = "Red Pen";
		public static const LABEL_GREEN:String = "Green Pen";
		public static const LABEL_BLUE:String = "Blue Pen";

		public static const LABEL_THIN:String = "Thin Pen";		
		public static const LABEL_MEDIUM:String = "Medium Pen";
		public static const LABEL_THICK:String = "Thick Pen";
		
		public static const COLOR_WHITE:uint = 0xFFFFFF;
		public static const COLOR_BLACK:uint = 0x000000;
		public static const COLOR_RED:uint = 0xFF0000;
		public static const COLOR_GREEN:uint = 0x00FF00;
		public static const COLOR_BLUE:uint = 0x0000FF;		
		
		public static const THICKNESS_THIN:uint = 1;
		public static const THICKNESS_MEDIUM:uint = 5;
		public static const THICKNESS_THICK:uint = 10;
		
		private static var _colorMapping:Dictionary; 
		
		[Bindable]
		public static var PEN_OPTIONS:XML = 
			<root>
				<menuitem label={LABEL_BLACK} value={COLOR_BLACK}/>
				<menuitem label={LABEL_RED} value={COLOR_RED}/>
				<menuitem label={LABEL_GREEN} value={COLOR_GREEN}/>
				<menuitem label={LABEL_BLUE} value={COLOR_BLUE}/>
				<menuitem label={LABEL_WHITE} value={COLOR_WHITE}/>
				<menuitem label="------------ " enabled="false" />
				<menuitem label={LABEL_THIN} value={THICKNESS_THIN}/>
				<menuitem label={LABEL_MEDIUM} value={THICKNESS_MEDIUM}/>
				<menuitem label={LABEL_THICK} value={THICKNESS_THICK}/>
			</root>;
		
		public static function createMenu(parent:DisplayObjectContainer):KPenMenu
		{
			var menu:KPenMenu = new KPenMenu();
			menu.tabEnabled = false;    
			menu.owner = parent;
			menu.showRoot = false;
			menu.labelField = "@label";
			popUpMenu(menu, parent, PEN_OPTIONS);
			return menu;
		}
		
		public static function getColor(label:String):uint
		{
			if (_colorMapping == null)
			{
				_colorMapping = new Dictionary();
				_colorMapping[LABEL_WHITE] = COLOR_WHITE;
				_colorMapping[LABEL_BLACK] = COLOR_BLACK;
				_colorMapping[LABEL_RED] = COLOR_RED;
				_colorMapping[LABEL_GREEN] = COLOR_GREEN;
				_colorMapping[LABEL_BLUE] = COLOR_BLUE;
			}
			return _colorMapping[label];
		}
	}
}