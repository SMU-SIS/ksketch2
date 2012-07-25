/**------------------------------------------------
 * Copyright 2012 Singapore Management University
 * All Rights Reserved
 *
 *-------------------------------------------------*/

package sg.edu.smu.ksketch.logger
{
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch.io.KFileParser;
	import sg.edu.smu.ksketch.model.KImage;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.model.KStroke;
	import sg.edu.smu.ksketch.model.geom.K2DVector;
	import sg.edu.smu.ksketch.model.geom.K3DVector;
	import sg.edu.smu.ksketch.model.geom.KPathPoint;
	
	/** 
	 * A Logger to handle logging for facade functions
	 */
	public class KSystemLog
	{
		private var _node:XML;
		private var _ids:Vector.<int>;
		private var _points:Vector.<Point>;
		private var _pathPoints:Vector.<KPathPoint>;
		private var _2DPoints:Vector.<K2DVector>;
		private var _3DPoints:Vector.<K3DVector>;
		
		// ------------------ Select / Deselect ---------------- //
		public function select(currentSelections:Vector.<int>,previousSelections:Vector.<int>):XML
		{
			_node = new XML("<"+KLogger.SYSTEM_SELECT+"/>");
			_node.@[KLogger.SELECTED_ITEMS] = KFileParser.intsToString(currentSelections);
			_node.@[KLogger.PREV_SELECTED_ITEMS] = KFileParser.intsToString(previousSelections);
			return _node;
		}		
		public function deselect(previousSelections:Vector.<int>):XML
		{
			_node = new XML("<"+KLogger.SYSTEM_DESELECT+"/>");
			_node.@[KLogger.PREV_SELECTED_ITEMS] = KFileParser.intsToString(previousSelections);
			return _node;
		}
		
		// ---------------- Undo/Redo Operation ---------------- //
		public function undo():XML
		{
			return new XML("<"+KLogger.SYSTEM_UNDO+"/>");
		}		
		public function redo():XML
		{
			return new XML("<"+KLogger.SYSTEM_REDO+"/>");
		}
		
		// ------------------ Edit Operation ------------------- //		
		public function switchContent(objectIDs:Vector.<int>):XML
		{
			return _getEditNode(KLogger.SYSTEM_SWITCHCONTENT, objectIDs);
		}
		public function addImage(imageData:BitmapData, time:Number, x:Number, y:Number):XML
		{
			_node = new XML("<"+KLogger.SYSTEM_ADDIMAGE+"/>");
			_node.@[KLogger.TIME] = time;
			_node.@[KLogger.IMAGE_X] = x;
			_node.@[KLogger.IMAGE_Y] = y;
			_node.@[KLogger.IMAGE_DATA] = KFileParser.pngToString(imageData);
			return _node;
		}
		public function addMovieClip(movieClip:MovieClip, time:Number, x:Number, y:Number):XML
		{
			_node = new XML("<"+KLogger.SYSTEM_ADDMOVIECLIP+"/>");
			_node.@[KLogger.TIME] = time;
			_node.@[KLogger.MOVIE_X] = x;
			_node.@[KLogger.MOVIE_Y] = y;
			_node.@[KLogger.MOVIE_DATA] = " ----- ";
			return _node;
		}
		public function beginStroke(color:uint, thickness:uint, time:Number):void
		{
			_points = new Vector.<Point>();
			_node = new XML("<"+KLogger.SYSTEM_ADDSTROKE+"/>");
			_node.@[KLogger.STROKE_COLOR] = color;
			_node.@[KLogger.STROKE_THICKNESS] = thickness;
			_node.@[KLogger.TIME] = time;
		}
		public function addToStroke(x:Number,y:Number):void
		{
			_points.push(new Point(x,y));
		}
		public function endStroke():XML
		{
			_node.@[KLogger.STROKE_POINTS] = KFileParser.pointsToString(_points);
			return _node;			
		}		
		public function erase(objectID:int, time:Number):XML
		{
			_node = new XML("<"+KLogger.SYSTEM_ERASE+"/>");
			_node.@[KLogger.OBJECTS] = objectID;
			_node.@[KLogger.TIME] = time;
			return _node;
		}
		public function copy(objectIDs:Vector.<int>, time:Number):XML
		{
			return _getEditNode(KLogger.SYSTEM_COPY, objectIDs,time);		
		}
		public function cut(objectIDs:Vector.<int>, time:Number):XML
		{
			return _getEditNode(KLogger.SYSTEM_CUT, objectIDs,time);		
		}
		public function paste(includeMotion:Boolean, time:Number):XML
		{
			_node = new XML("<"+KLogger.SYSTEM_PASTE+"/>");
			_node.@[KLogger.PASTEINCLUDEMOTION] = includeMotion;
			_node.@[KLogger.TIME] = time;
			return _node;
		}		
		public function clearClipBoard():XML
		{
			return new XML("<"+KLogger.SYSTEM_CLEARCLIPBOARD+"/>");
		}
		public function toggleVisibility(objectIDs:Vector.<int>,time:Number):XML
		{
			return _getEditNode(KLogger.SYSTEM_TOGGLEVISIBILITY, objectIDs,time);		
		}

		// ------------------ Grouping Operation ------------------- //
		public function regroup(objectIDs:Vector.<int>, mode:String, transitionType:int, 
								time:Number,isRealTimeTranslation:Boolean = false):XML
		{
			return _getGroupingNode(KLogger.SYSTEM_REGROUP, objectIDs,
				mode, transitionType, time, isRealTimeTranslation);		
		}
		public function group(objectIDs:Vector.<int>, mode:String, transitionType:int, 
							  time:Number=-2,  isRealTimeTranslation:Boolean = false):XML
		{	
			return _getGroupingNode(KLogger.SYSTEM_GROUP,objectIDs, 
				mode, transitionType, time, isRealTimeTranslation);		
		}
		public function ungroup(objectIDs:Vector.<int>, mode:String, time:Number):XML
		{
			return _getGroupingNode(KLogger.SYSTEM_UNGROUP,objectIDs, mode, -1, time);		
		}

		// ------------------ Transform Operation ------------------- //		
		public function beginTranslation(id:int, kskTime:Number, transitionType:int):void
		{
			_3DPoints = new Vector.<K3DVector>();
			_pathPoints = new Vector.<KPathPoint>();
			_node = _getTransitionNode(KLogger.SYSTEM_TRANSLATE,id,null,kskTime,transitionType);
		}
		public function addToTranslation(translateX:Number, translateY:Number, 
										 kskTime:Number,cursorPoint:Point = null):void
		{
			_3DPoints.push(new K3DVector(translateX,translateY,kskTime));
			if (cursorPoint)
				_pathPoints.push(new KPathPoint(cursorPoint.x,cursorPoint.y,kskTime));
		}
		public function endTranslation(kskTime:Number):XML
		{
			return _endTransitionNode(kskTime,KFileParser.k3DVectorsToString(_3DPoints));
		}		
		public function beginRotation(id:int, center:Point, kskTime:Number, transitionType:int):void
		{
			_beginK2DTransition(KLogger.SYSTEM_ROTATE, id, center, kskTime, transitionType);
		}
		public function addToRotation(angle:Number, cursorPoint:Point, kskTime:Number):void
		{
			_addToK2DTransition(angle, cursorPoint, kskTime);		
		}		
		public function endRotation(kskTime:Number):XML
		{
			return _endTransitionNode(kskTime,KFileParser.k2DVectorsToString(_2DPoints));
		}
		public function beginScale(id:int, center:Point, kskTime:Number, transitionType:int):void
		{
			_beginK2DTransition(KLogger.SYSTEM_SCALE, id, center, kskTime, transitionType);
		}
		public function addToScale(scale:Number, cursorPoint:Point, kskTime:Number):void
		{
			_addToK2DTransition(scale, cursorPoint, kskTime);		
		}
		public function endScale(kskTime:Number):XML
		{
			return _endTransitionNode(kskTime,KFileParser.k2DVectorsToString(_2DPoints));
		}
		public function insertKeyFrames(objectIDs:Vector.<int>):XML
		{
			return _getEditNode(KLogger.SYSTEM_INSERTKEYFRAMES, objectIDs);
		}
		public function clearMotions(objectIDs:Vector.<int>):XML
		{
			return _getEditNode(KLogger.SYSTEM_CLEARMOTIONS, objectIDs);
		}

		// ------------------ File Functions ------------------- //						
		public function newFile():XML
		{
			return new XML("<"+KLogger.SYSTEM_NEW+"/>");
		}
		public function loadFile(filename:String):XML
		{
			_node = new XML("<"+KLogger.SYSTEM_LOAD+"/>");
			_node.@[KLogger.FILE_NAME] = filename;
			return _node;
		}
		public function saveFile(filename:String):XML
		{
			_node = new XML("<"+KLogger.SYSTEM_SAVE+"/>");
			_node.@[KLogger.FILE_NAME] = filename;
			return _node;
		}
		
		// -------------- Model Access Functions --------------- //						
		public function setObjectName(objectID:int, name:String):XML
		{
			_node = new XML("<"+KLogger.SYSTEM_SETOBJECTNAME+"/>");
			_node.@[KLogger.OBJECTS] = objectID;
			_node.@[KLogger.NAME] = name;
			return _node;
		}

		// -------------- Time Widget Functions --------------- //						
		public function retimeKeys(objectIDs:Vector.<int>, 
								   keyTypes:Vector.<int>,keyTimes:Vector.<Number>, 
								   retimeTos:Vector.<Number>, appTime:Number):XML
		{
			_node = new XML("<"+KLogger.SYSTEM_RETIMEKEYS+"/>");
			_node.@[KLogger.OBJECTS] = KFileParser.intsToString(objectIDs);
			_node.@[KLogger.KEYFRAME_TYPES] = KFileParser.intsToString(keyTypes);
			_node.@[KLogger.KEYFRAME_TIMES] = KFileParser.numbersToString(keyTimes);
			_node.@[KLogger.KEYFRAME_RETIMETOS] = KFileParser.numbersToString(retimeTos);
			_node.@[KLogger.TIME] = appTime;
			return _node;
		}

		// -------------- Player Functions --------------- //						
		public function play(startTime:Number):XML
		{
			_node = new XML("<"+KLogger.SYSTEM_PLAY+"/>");
			_node.@[KLogger.TIME_FROM] = startTime;
			return _node;
		}
		public function pause(pauseTime:Number):XML
		{
			_node = new XML("<"+KLogger.SYSTEM_PAUSE+"/>");
			_node.@[KLogger.TIME_FROM] = pauseTime;
			return _node;
		}
		public function rewind(fromTime:Number):XML
		{
			_node = new XML("<"+KLogger.SYSTEM_REWIND+"/>");
			_node.@[KLogger.TIME_FROM] = fromTime;
			return _node;
		}
		public function prevFrame(fromTime:Number):XML
		{
			_node = new XML("<"+KLogger.SYSTEM_PREVFRAME+"/>");
			_node.@[KLogger.TIME_FROM] = fromTime;
			return _node;
		}
		public function nextFrame(fromTime:Number):XML
		{
			_node = new XML("<"+KLogger.SYSTEM_NEXTFRAME+"/>");
			_node.@[KLogger.TIME_FROM] = fromTime;
			return _node;
		}
		public function gutterTab(fromTime:Number,toTime:Number):XML
		{
			_node = new XML("<"+KLogger.SYSTEM_GUTTERTAP+"/>");
			_node.@[KLogger.TIME_FROM] = fromTime;
			_node.@[KLogger.TIME_TO] = toTime;
			return _node;
		}
		public function sliderDrag(fromTime:Number,toTime:Number):XML
		{
			_node = new XML("<"+KLogger.SYSTEM_SLIDERDRAG+"/>");
			_node.@[KLogger.TIME_FROM] = fromTime;
			_node.@[KLogger.TIME_TO] = toTime;
			return _node;
		}
		
		// ------------------ Private Function ------------------- //
		private function _getEditNode(editType:String, objectIDs:Vector.<int>,time:Number=-1):XML
		{
			_node = new XML("<"+editType+"/>");
			_node.@[KLogger.OBJECTS] = KFileParser.intsToString(objectIDs);
			if (time >=0)
				_node.@[KLogger.TIME] = time;
			return _node;
		}
		private function _getGroupingNode(groupingType:String, objectIDs:Vector.<int>, 
										  mode:String, transitionType:int, time:Number, 
										  isRealTimeTranslation:Boolean = false):XML
		{
			_node = new XML("<"+groupingType+"/>");
			_node.@[KLogger.OBJECTS] = KFileParser.intsToString(objectIDs);
			_node.@[KLogger.GROUPING_MODE] = mode;
			_node.@[KLogger.TIME] = time;
			_node.@[KLogger.GROUPING_ISREALTIMETRANSLATION] = isRealTimeTranslation;
			if (transitionType >= 0)
				_node.@[KLogger.TRANSITION_TYPE] = transitionType;
			return _node;
		}
		private function _beginK2DTransition(trasformType:String, id:int, center:Point, 
											 kskTime:Number, transitionType:int):void
		{
			_2DPoints = new Vector.<K2DVector>();
			_pathPoints = new Vector.<KPathPoint>();
			_node = _getTransitionNode(trasformType,id,center,kskTime,transitionType);
		}
		private function _addToK2DTransition(parameter:Number, cursorPoint:Point, kskTime:Number):void
		{
			_2DPoints.push(new K2DVector(parameter,kskTime));
			_pathPoints.push(new KPathPoint(cursorPoint.x,cursorPoint.y,kskTime));
		}
		private function _endTransitionNode(kskTime:Number,pathString:String):XML
		{
			_node.@[KLogger.TRANSITION_END_TIME] = kskTime;
			_node.@[KLogger.MOTION_PATH] = KFileParser.pathPointsToString(_pathPoints);
			_node.@[KLogger.TRANSITION_PATH] = pathString;
			return _node;
		}		
		private function _getTransitionNode(trasformType:String, objectID:int, center:Point, 
											kskTime:Number, transitionType:int):XML
		{
			var node:XML = new XML("<"+trasformType+"/>");
			node.@[KLogger.OBJECTS] = objectID;
			node.@[KLogger.TRANSITION_START_TIME] = kskTime;
			node.@[KLogger.TRANSITION_TYPE] = transitionType;
			if (center != null)
			{
				node.@[KLogger.TRANSITION_CENTER_X] = center.x;
				node.@[KLogger.TRANSITION_CENTER_Y] = center.y;
			}
			return node;
		}
		
	}
}