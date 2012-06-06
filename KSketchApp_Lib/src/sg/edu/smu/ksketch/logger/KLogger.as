/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.logger
{
	import sg.edu.smu.ksketch.utilities.KAppState;
	/**
	 * A class which supports logging system. All methods in this class are static.
	 */	
	public class KLogger
	{
		public static const LOG_TIME:String = "logtime";

		// command names, same as xml node name
		public static const COMMANDS:String = "commands";

		public static const FILE_PATH:String = "file-path";
		public static const FILE_NAME:String = "filename";
		public static const FILE_APP_DIR:String = "playsketch";

		// toolbar operation
		public static const BTN_EXIT:String = "btn-exit";
		public static const BTN_NEW:String = "btn-new";
		public static const BTN_LOAD:String = "btn-load";
		public static const BTN_SAVE:String = "btn-save";

		public static const BTN_CUT:String = "btn-cut";
		public static const BTN_COPY:String = "btn-copy";
		public static const BTN_PASTE:String = "btn-paste";

		public static const BTN_UNDO:String = "btn-undo";
		public static const BTN_REDO:String = "btn-redo";
		
		public static const BTN_GROUP:String = "btn-group";
		public static const BTN_UNGROUP:String = "btn-ungroup";

		public static const BTN_ERASER:String = "btn-eraser";
		public static const BTN_RED_PEN:String = "btn-redpen";
		public static const BTN_BLUE_PEN:String = "btn-bluepen";
		public static const BTN_GREEN_PEN:String = "btn-greenpen";
		public static const BTN_BLACK_PEN:String = "btn-blackpen";
		public static const BTN_PEN_PREVIOUS_STATE:String = "btn-previous";
		
		public static const BTN_NEXT:String = "btn-next";
		public static const BTN_PREVIOUS:String = "btn-previous";
		public static const BTN_FIRST:String = "btn-first";
		public static const BTN_PLAY:String = "btn-play";

		public static const BTN_TOGGLE_VISIBILITY:String = "btn-toggle-visibility";
		
		public static const BTN_SETTING:String = "btn-setting";
		public static const BTN_DEBUG:String = "btn-debug";

		public static const BTN_TOGGLE_TIMEBAR_EXPAND:String = "btn-toggle-timebar-expand";

		public static const CHANGE_KEYFRAME:String = "changekeyframe";
		public static const CHANGE_TIME:String = "changetime";
		public static const CHANGE_TIME_ACTION:String = "changetime-action";
		public static const CHANGE_TIME_TAP:String = "changetime-tap";
		public static const CHANGE_TIME_DRAG:String = "changetime-drag";
		public static const CHANGE_TIME_FROM:String = "fromtime";
		public static const CHANGE_TIME_TO:String = "totime";
		
		public static const CHANGE_SELECTION_MODE:String = "change-selection-mode";		
		public static const CHANGE_SELECTION_MODE_FROM:String = "change-selection-mode-from";		
		public static const CHANGE_SELECTION_MODE_TO:String = "change-selection-mode-to";
		
		public static const CHANGE_GROUPING_MODE:String = "change-grouping-mode";		
		public static const CHANGE_GROUPING_MODE_FROM:String = "change-grouping-mode-from";		
		public static const CHANGE_GROUPING_MODE_TO:String = "change-grouping-mode-to";
		
		public static const CHANGE_GESTURE_DESIGN:String = "change-gesture-design";
		public static const CHANGE_GESTURE_DESIGN_FROM:String = "change-gesture-design-from";
		public static const CHANGE_GESTURE_DESIGN_TO:String = "change-gesture-design-to";
		
		public static const CHANGE_GESTURE_RECOGNITION_TIMEOUT:String = "change-gesture-recognition-timeout";
		public static const CHANGE_GESTURE_RECOGNITION_TIMEOUT_FROM:String = "change-gesture-recognition-timeout-from";
		public static const CHANGE_GESTURE_RECOGNITION_TIMEOUT_TO:String = "change-gesture-recognition-timeout-to";

		public static const CHANGE_GESTURE_ACCEPTANCE_SCORE:String = "change-gesture-acceptance-score";
		public static const CHANGE_GESTURE_ACCEPTANCE_SCORE_FROM:String = "change-gesture-acceptance-score-from";
		public static const CHANGE_GESTURE_ACCEPTANCE_SCORE_TO:String = "change-gesture-acceptance-score-to";
		
		public static const CHANGE_PATH_VISIBILITY:String = "change-path-visibility";
		public static const CHANGE_PATH_VISIBILITY_FROM:String = "change-path-visibility-from";
		public static const CHANGE_PATH_VISIBILITY_TO:String = "change-path-visibility-to";
		
		public static const CHANGE_CREATION_MODE:String = "change-creation-mode";
		public static const CHANGE_CREATION_MODE_FROM:String = "change-creation-mode-from";
		public static const CHANGE_CREATION_MODE_TO:String = "change-creation-mode-to";
		
		public static const CHANGE_DEMO_MERGE_MODE:String = "change-demo-merge-mode";
		public static const CHANGE_DEMO_MERGE_MODE_FROM:String = "change-demo-merge-mode-from";
		public static const CHANGE_DEMO_MERGE_MODE_TO:String = "change-demo-merge-mode-to";

		public static const CHANGE_ASPECT_RATIO:String = "change-aspect-ratio";
		public static const CHANGE_ASPECT_RATIO_FROM:String = "change-aspect-ratio-from";
		public static const CHANGE_ASPECT_RATIO_TO:String = "change-aspect-ratio-to";
		
		public static const CHANGE_RIGHT_MOUSE_ENABLED:String = "change-right-mouse-enabled";
		public static const CHANGE_RIGHT_MOUSE_ENABLED_FROM:String = "change-right-mouse-enabled-from";
		public static const CHANGE_RIGHT_MOUSE_ENABLED_TO:String = "change-right-mouse-enabled-to";
		
		public static const CHANGE_CONFIRM_DIALOG_ENABLED:String = "change-confirm-dialog-enabled";
		public static const CHANGE_CONFIRM_DIALOG_ENABLED_FROM:String = "change-confirm-dialog-enabled-from";
		public static const CHANGE_CONFIRM_DIALOG_ENABLED_TO:String = "change-confirm-dialog-enabled-to";
		
		public static const CHANGE_APPLICATION_LOG_ENABLED:String = "change-application-log-enabled";
		public static const CHANGE_APPLICATION_LOG_ENABLED_FROM:String = "change-application-log-enabled-from";
		public static const CHANGE_APPLICATION_LOG_ENABLED_TO:String = "change-application-log-enabled-to";
		
		// menu command
		public static const MENU_PEN_MENU:String = "pmenu";
		public static const MENU_CONTEXT_MENU:String = "cmenu";
		public static const MENU_CONTEXT_MENU_CUT:String = "cmenu-cut";
		public static const MENU_CONTEXT_MENU_COPY:String = "cmenu-copy";
		public static const MENU_CONTEXT_MENU_PASTE:String = "cmenu-paste";
		public static const MENU_CONTEXT_MENU_PASTE_WITH_MOTION:String = "cmenu-paste-with-motion";
		public static const MENU_SELECTED:String = "cmenu-select";
		
		// shortcut command
		public static const SHORTCUT_CUT:String = "shortcut-cut";
		public static const SHORTCUT_COPY:String = "shortcut-copy";
		public static const SHORTCUT_PASTE:String = "shortcut-paste";
		public static const SHORTCUT_PASTE_WITH_MOTION:String = "shortcut-paste-with-motion";
		public static const SHORTCUT_UNDO:String = "shortcut-undo";
		public static const SHORTCUT_REDO:String = "shortcut-redo";
		
		// interaction (widget)
		public static const INTERACTION_DRAW:String = "draw";
		public static const INTERACTION_ERASE:String = "erase";
		public static const INTERACTION_HIDE_POPUP:String = "hidepopup";
		public static const INTERACTION_DESELECT:String = "deselect";
		public static const INTERACTION_SELECT_LOOP:String = "loopselect";
		public static const INTERACTION_TRANSLATE:String = "translate";
		public static const INTERACTION_ROTATE:String = "rotate";
		public static const INTERACTION_SCALE:String = "scale";
		public static const INTERACTION_MOVE_CENTER:String = "movecenter";
		public static const INTERACTION_DRAG_CENTER:String = "dragcenter";
		public static const INTERACTION_GESTURE:String = "gesture";
		
		public static const CURSOR_PATH:String = "cursorpath";
		
		public static const TRANSITION_TYPE:String = "transitiontype";
		public static const TRANSITION_TYPE_INSTANT:String = "INSTANT";
		public static const TRANSITION_TYPE_INTERPOLATED:String = "INTERPOLATED";
		public static const TRANSITION_TYPE_REALTIME:String = "REALTIME";
		
		public static const IS_TAP:String = "isTap";
		
		public static const PREV_SELECTED_ITEMS:String = "previousSelectedItems";
		public static const SELECTED_ITEMS:String = "selectedItems";
		
		public static const MATCH:String = "match";
		public static const CONFIDENCE:String = "matchConfidence";
		
		public static const PIGTAIL:String = "pigtail";
		public static const CYCLE_NEXT:String = "cycleNext";
		public static const CYCLE_PREV:String = "cyclePrev";
		public static const UNDEFINED:String = "null";
		
		public static const CURSOR_PATH_PART:String = "pathPart";
		
		// test control commands
		public static const DELAY:String = "delay";
		public static const DELAY_TIME:String = "time";
		
		public static const BREAK:String = "break";
		public static const BREAK_VERIFY:String = "verify";
		
		public static const PAUSE:String = "pause";
		
		public static const PAUSEALL:String = "pauseall";
		
		public static const DELAYALL:String = "delayall";
		public static const DELAYALL_TIME:String = "time";
		
		// Assertion tag name
		public static const ASSERT_MATRIX:String = "assert-matrix";
		public static const ASSERT_KEYFRAME:String = "assert-keyframe";
		
		// Assertion attribute
		public static const ASSERTION_TIME:String = "time";
		public static const ASSERTION_OBJECT_NAME:String = "name";
		
		public static const MATRIX_A:String = "a";
		public static const MATRIX_B:String = "b";
		public static const MATRIX_C:String = "c";
		public static const MATRIX_D:String = "d";
		public static const MATRIX_TX:String = "tx";
		public static const MATRIX_TY:String = "ty";
		public static const MATRIX_TRANSLATE:String = "translate";
		public static const MATRIX_ROTATE:String = "rotate";
		public static const MATRIX_SCALE:String = "scale";
		public static const MATRIX_TOLERANCE_TRANSLATE:String = "ttol";
		public static const MATRIX_TOLERANCE_ROTATE:String = "rtol";
		public static const MATRIX_TOLERANCE_SCALE:String = "stol";
		
		public static const KEYFRAME_IS_NULL:String = "isnull";
		public static const KEYFRAME_TYPE:String = "type";
		public static const KEYFRAME_CENTER:String = "center";
		
		private static var _enabled:Boolean = true;
		private static var _logFile:XML = new XML("<"+COMMANDS+"/>");
		
		/**
		 * If logger is enabled, add an item into the log file. The log file is XML formatted, and an 
		 * item in log file contains tag name and attributes serials. The number of parameters should 
		 * be odd, one tag name and several pairs(can be 0) of attribute names and values. For example, 
		 * you can use log("addShape", "type", "circle", "x", 100, "y", 200, "r", 30) or log("newfile").
		 * @param tagName the tag name, cannot be null
		 * @param args the pairs of attribute names and values, if no attribute, args can be ignored
		 */
		public static function log(tagName:String, ...args):void
		{
			if(_enabled)
			{
				if(args.length%2 != 0)
					throw new Error("KLogger.log: Attributes' name and key should be in pair.");
				if (tagName.split(" ").length != 1)
					throw new Error("Tag Name: '"+tagName+"' is malformed");
				var node:XML = new XML("<"+tagName+"/>");
				node.@[LOG_TIME] = formartedTime(new Date());
				for(var i:int = 0; i<args.length/2; i++)
					node.@[args[2*i]] = args[2*i+1];
				_logFile.appendChild(node);
			}
		}
		
		public static function logObject(log:ILoggable):void
		{
			if(_enabled)
			{
				var node:XML = log.toXML();
				node.@[LOG_TIME] = formartedTime(new Date());
				_logFile.appendChild(node);
			}
		}
		
		/**
		 * If logger is enabled, remove all items in the log file, or do nothing. 
		 */
		public static function flush():void
		{
			_logFile = new XML("<"+COMMANDS+"/>");
		}
		
		public static function setLogFile(xml:XML):void
		{
			_logFile = xml;
		}
		
		/**
		 * Return the current log file which is XML formatted.
		 * @return
		 */
		public static function get logFile():XML
		{
			return _logFile;
		}
		
		/**
		 * Whether logging system will work. 
		 * If the value is true, logging system will run, 
		 * if the value is false, logging system will stop.
		 * @return the boolean value
		 */
		public static function get enabled():Boolean
		{
			return _enabled;
		}
		
		/**
		 * Whether logging system will work. 
		 * If the value is true, logging system will run, 
		 * if the value is false, logging system will stop.
		 * @param value the new boolean value
		 */
		public static function set enabled(value:Boolean):void
		{
			_enabled = value;
	//		if(!_enabled)
	//			flush();
		}
		
		public static function formartedTime(date:Date):String
		{
			var dateStr:String = date.toString();
			var lastColon:int = dateStr.lastIndexOf(":");
			var str:String = dateStr.substring(0, lastColon+3)+":"+
				date.getMilliseconds()+dateStr.substring(lastColon+3);
			return str;
		}

		public static function timeOf(formarted:String):Date
		{
			var lastColon:int = formarted.lastIndexOf(":");
			var nextSpace:int = formarted.indexOf(" ", lastColon);
			var dateStr:String = formarted.substring(0, lastColon) + formarted.substring(nextSpace);
			var seconds:Number = Date.parse(dateStr);
			var milliStr:String = formarted.substring(lastColon+1, nextSpace);
			var milli:Number = new Number(milliStr);
			var date:Date = new Date();
			date.setTime(seconds + milli);
			return date;
		}
	}
}