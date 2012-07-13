/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.logger
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch.io.KFileParser;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.model.geom.KPathPoint;
	import sg.edu.smu.ksketch.utilities.KAppState;

	/**
	 * A class which supports logging system. All methods in this class are static.
	 */	
	public class KLogger
	{
		public static const LOG_TIME:String = "logtime";
		public static const TIME:String = "time";

		public static const OBJECTS:String = "objects";
		public static const NAME:String = "name";
		
		// command names, same as xml node name
		public static const COMMANDS:String = "commands";
		public static const NEW_SESSION:String = "newsession";
		public static const VERSION:String = "version";

		public static const FILE_NAME:String = "filename";
		public static const FILE_PATH:String = "file-path";
		public static const FILE_APP_DIR:String = "playsketch";
		public static const FILE_LOCATION:String = "file-location";
		public static const FILE_USER_DIR:String = "user-dir";
		public static const FILE_DESKTOP_DIR:String = "desktop-dir";
		public static const FILE_STORAGE_DIR:String = "storage-dir";
		public static const FILE_DOCUMENT_DIR:String = "document-dir";

		public static const CHANGE_TIME:String = "changetime";
		public static const CHANGE_TIME_ACTION:String = "changetime-action";
		public static const CHANGE_TIME_TAP:String = "changetime-tap";
		public static const CHANGE_TIME_DRAG:String = "changetime-drag";
		public static const CHANGE_TIME_FROM:String = "fromtime";
		public static const CHANGE_TIME_TO:String = "totime";
		
		// System command
		public static const SYSTEM_UNDO:String = "sys-undo";
		public static const SYSTEM_REDO:String = "sys-redo";
		public static const SYSTEM_IMAGE:String = "sys-image";
		public static const SYSTEM_STROKE:String = "sys-stroke";
		public static const SYSTEM_ERASE:String = "sys-erase";
		public static const SYSTEM_COPY:String = "sys-copy";
		public static const SYSTEM_CUT:String = "sys-cut";
		public static const SYSTEM_PASTE:String = "sys-paste";
		public static const SYSTEM_CLEARCLIPBOARD:String = "sys-clearclipboard";
		public static const SYSTEM_TOGGLEVISIBILITY:String = "sys-togglevisibility";
		public static const SYSTEM_TRANSLATE:String = "sys-translate";
		public static const SYSTEM_ROTATE:String = "sys-rotate";
		public static const SYSTEM_SCALE:String = "sys-scale";
		public static const SYSTEM_GROUP:String = "sys-group";
		public static const SYSTEM_UNGROUP:String = "sys-ungroup";
		public static const SYSTEM_REGROUP:String = "sys-regroup";
		public static const SYSTEM_NEW:String = "sys-new";
		public static const SYSTEM_LOAD:String = "sys-load";
		public static const SYSTEM_SAVE:String = "sys-save";
		public static const SYSTEM_SETOBJECTNAME:String = "sys-setobjectname";
		public static const SYSTEM_RETIMEKEYS:String = "sys-retimekeys";

		public static const KEYFRAME_TIME:String = "time";
		public static const KEYFRAME_TIMES:String = "times";
		public static const KEYFRAME_TYPE:String = "type";
		public static const KEYFRAME_TYPES:String = "types";
		public static const KEYFRAME_TYPE_TRANSLATE:String = "translate";
		public static const KEYFRAME_TYPE_ROTATE:String = "rotate";
		public static const KEYFRAME_TYPE_SCALE:String = "scale";
		public static const KEYFRAME_TYPE_ACTIVITY:String = "activity";
		public static const KEYFRAME_TYPE_PARENT:String = "parent";
		public static const KEYFRAME_RETIMETOS:String = "retime-tos";
		
		public static const PASTEINCLUDEMOTION:String = "paste-include-motion";

		public static const GROUPING_MODE:String = "mode";
		public static const GROUPING_MODE_EXPLICIT_STATIC:String = KAppState.GROUPING_EXPLICIT_STATIC;
		public static const GROUPING_MODE_EXPLICIT_DYNAMIC:String = KAppState.GROUPING_EXPLICIT_DYNAMIC;
		public static const GROUPING_MODE_IMPLICIT_DYNAMIC:String = KAppState.GROUPING_IMPLICIT_DYNAMIC;
		public static const GROUPING_ISREALTIMETRANSLATION:String = "is-realtime-translation";
		
		public static const TRANSITION_START_TIME:String = "start-time";
		public static const TRANSITION_END_TIME:String = "end-time";
		public static const TRANSITION_TYPE:String = "transitionType";
		public static const TRANSITION_TYPE_INSTANT:int = KAppState.TRANSITION_INSTANT;
		public static const TRANSITION_TYPE_INTERPOLATED:int = KAppState.TRANSITION_INTERPOLATED;
		public static const TRANSITION_TYPE_REALTIME:int= KAppState.TRANSITION_REALTIME;
		public static const TRANSITION_CENTER_X:String = "cy";
		public static const TRANSITION_CENTER_Y:String = "cx";
		public static const TRANSITION_PATH:String = "transition-path";
		public static const MOTION_PATH:String = "motion-path";

		public static const IMAGE_DATA:String = "image-data";
		public static const IMAGE_X:String = "x";
		public static const IMAGE_Y:String = "y";
		public static const IMAGE_WIDTH:String = "width";
		public static const IMAGE_HEIGHT:String = "height";
		public static const IMAGE_FORMAT:String = "format";		
		public static const IMAGE_FORMAT_PNG:String = "PNG";		

		public static const STROKE_POINTS:String = "points";
		public static const STROKE_THICKNESS:String = "thickness";
		public static const STROKE_COLOR:String = "color";
		public static const CURSOR_PATH:String = "cursorpath";
		public static const CURSOR_PATH_PART:String = "pathPart";
		
		private static var _enabled:Boolean = true;
		private static var _logFile:XML = new XML("<"+COMMANDS+"/>");
		
		private static var _systemLog:KSystemLog = new KSystemLog();
		
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

		public static function logUndo():void
		{
			_logObject(_systemLog.undo());
		}		
		
		public static function logRedo():void
		{
			_logObject(_systemLog.redo());
		}		
		
		public static function logAddKImage(imageData:BitmapData, time:Number, xPos:Number, yPos:Number):void
		{
			_logObject(_systemLog.addImage(imageData, time, xPos, yPos));
		}		
		
		public static function logBeginKStrokePoint(color:uint, thickness:Number, time:Number):void
		{
			_systemLog.beginStroke(color,thickness,time);
		}
		
		public static function logAddKStrokePoint(point:Point):void
		{
			_systemLog.addToStroke(point.x,point.y);
		}
		
		public static function logEndKStrokePoint():void
		{
			_logObject(_systemLog.endStroke());
		}
		
		public static function logErase(objectID:int, kskTime:Number):void
		{
			_logObject(_systemLog.erase(objectID,kskTime));
		}
		
		public static function logCopy(objectIDs:Vector.<int>, kskTime:Number):void
		{
			_logObject(_systemLog.copy(objectIDs,kskTime));
		}
		
		public static function logCut(objectIDs:Vector.<int>, kskTime:Number):void
		{
			_logObject(_systemLog.cut(objectIDs,kskTime));
		}
		
		public static function logPaste(includeMotion:Boolean,time:Number):void
		{
			_logObject(_systemLog.paste(includeMotion,time));
		}

		public static function logClearClipBoard():void
		{
			_logObject(_systemLog.clearClipBoard());
		}

		public static function logToggleVisibility(objectIDs:Vector.<int>,time:Number):void
		{
			_logObject(_systemLog.toggleVisibility(objectIDs,time));
		}

		public static function logRegroup(objectIDs:Vector.<int>, mode:String, transitionType:int,
										  time:Number,isRealTimeTranslation:Boolean = false):void
		{
			_logObject(_systemLog.regroup(objectIDs, mode, transitionType, time, isRealTimeTranslation));
		}

		public static function logGroup(objectIDs:Vector.<int>, mode:String, transitionType:int,
										time:Number=-2,  isRealTimeTranslation:Boolean = false):void
		{	
			_logObject(_systemLog.group(objectIDs, mode, transitionType, time, isRealTimeTranslation));
		}
		
		public static function logUngroup(objectIDs:Vector.<int>, mode:String, time:Number):void
		{
			_logObject(_systemLog.ungroup(objectIDs, mode, time));
		}
		
		public static function logBeginTranslation(objectID:int, kskTime:int, transitionType:int):void
		{
			_systemLog.beginTranslation(objectID, kskTime, transitionType);
		}	
		
		public static function logAddToTranslation(translateX:Number, translateY:Number, 
											kskTime:Number,cursorPoint:Point = null):void
		{
			_systemLog.addToTranslation(translateX, translateY, kskTime, cursorPoint);
		}
		
		public static function logEndTranslation(kskTime:Number):void
		{	
			_logObject(_systemLog.endTranslation(kskTime));
		}
		
		public static function logBeginRotation(objectID:int, canvasCenter:Point, 
										 kskTime:Number, transitionType:int):void
		{
			_systemLog.beginRotation(objectID, canvasCenter, kskTime, transitionType);
		}
		
		public static function logAddToRotation(angle:Number, cursorPoint:Point, kskTime:Number):void
		{
			_systemLog.addToRotation(angle, cursorPoint, kskTime);
		}
		
		public static function logEndRotation(kskTime:Number):void
		{
			_logObject(_systemLog.endRotation(kskTime));
		}
		
		public static function logBeginScale(objectID:int, canvasCenter:Point, 
											 kskTime:Number, transitionType:int):void
		{
			_systemLog.beginScale(objectID, canvasCenter, kskTime, transitionType);
		}
		
		public static function logAddToScale(scale:Number, cursorPoint:Point, kskTime:Number):void
		{
			_systemLog.addToScale(scale, cursorPoint, kskTime);
		}
		
		public static function logEndScale(kskTime:Number):void
		{		
			_logObject(_systemLog.endScale(kskTime));
		}
		
		public static function logNewFile():void
		{
			_logObject(_systemLog.newFile());
		}
		
		public static function logLoadFile(filepath:String):void
		{
			_logObject(_systemLog.loadFile(filepath));
		}
		
		public static function logSaveFile(filepath:String):void
		{
			_logObject(_systemLog.saveFile(filepath));
		}
		
		public static function logSetObjectName(objectID:int, name:String):void
		{		
			_logObject(_systemLog.setObjectName(objectID,name));
		}
		
		public static function logRetimeKeys(objectIDs:Vector.<int>, 
											 keyTypes:Vector.<int>,keyTimes:Vector.<Number>, 
											 retimeTos:Vector.<Number>, appTime:Number):void
		{		
			_logObject(_systemLog.retimeKeys(objectIDs,keyTypes,keyTimes,retimeTos,appTime));
		}
		
		public static function logObject(log:ILoggable):void
		{
			if(_enabled)
				_logObject(log.toXML());
		}
		
		/**
		 * If logger is enabled, remove all items in the log file, or do nothing. 
		 */
		public static function flush():void
		{
			_logFile = new XML("<"+COMMANDS+"/>");
		}
		
		public static function setLogFile(xml:XML,keepPreviousLog:Boolean = false):void
		{
			if (keepPreviousLog)
				_logFile.appendChild(xml.children());
			else
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
		
		private static function _logObject(node:XML):void
		{
			if(_enabled)
			{
				node.@[LOG_TIME] = formartedTime(new Date());
				_logFile.appendChild(node);
			}
		}
				
	}
}