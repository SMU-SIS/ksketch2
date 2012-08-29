/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package sg.edu.smu.ksketch.interactor
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.ui.Mouse;
	
	import mx.controls.Alert;
	import mx.controls.Menu;
	import mx.events.CloseEvent;
	import mx.events.MenuEvent;
	
	import sg.edu.smu.ksketch.components.KCanvas;
	import sg.edu.smu.ksketch.components.KContextMenu;
	import sg.edu.smu.ksketch.components.KPenMenu;
	import sg.edu.smu.ksketch.event.KCommandEvent;
	import sg.edu.smu.ksketch.event.KFileLoadedEvent;
	import sg.edu.smu.ksketch.gestures.GestureDesign;
	import sg.edu.smu.ksketch.io.KFileAccessor;
	import sg.edu.smu.ksketch.io.KFileLoader;
	import sg.edu.smu.ksketch.io.KFileSaver;
	import sg.edu.smu.ksketch.logger.KLogger;
	import sg.edu.smu.ksketch.logger.KPlaySketchLogger;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	import sg.edu.smu.ksketch.operation.KModelFacade;
	import sg.edu.smu.ksketch.operation.implementations.KInteractionOperation;
	import sg.edu.smu.ksketch.utilities.IModelObjectList;
	import sg.edu.smu.ksketch.utilities.KAppState;
	
	public class KCommandExecutor extends EventDispatcher
	{
		public static const EVENT_COMMAND_COMPLETE:String = "EVENT_COMMAND_COMPLETE";
		public static const PIGTAIL_CONTEXT_MENU:String = "pigtail";
		public static const HIGHLITED_CURSOR_PATH_CLICKED:String = "HIGHLITED_CURSOR_PATH_CLICKED";
		private static const _MENU_XPOSITION_OFFSET:Number = 150;
		private static const _MENU_YPOSITION_OFFSET:Number = 25;
		protected var _contextMenu:KContextMenu;
		protected var _hasPopup:Boolean;		
		protected var _appState:KAppState;
		protected var _facade:KModelFacade;
		protected var _canvas:KCanvas;
		protected var _penSelectionMenu:KPenMenu;
		protected var _prevPenColor:uint;		
		
		public function KCommandExecutor(appState:KAppState, canvas:KCanvas, facade:KModelFacade)
		{
			_appState = appState;
			_canvas = canvas;
			_facade = facade
			_hasPopup = false;
		}
		
		public function doButtonCommand(command:String):void
		{
			var filename:String;
			switch (command)
			{
				case KPlaySketchLogger.BTN_EXIT:
					filename = _generateFileName(); 
					_save(filename,KLogger.FILE_APP_DIR);
					KLogger.log(command,KLogger.FILE_NAME,filename);
					break;
				case KPlaySketchLogger.BTN_NEW:
					filename = _generateFileName(); 
					_save(filename,KLogger.FILE_APP_DIR);
					KLogger.flush();
					_newFile();
					KLogger.log(command);
					break;
				case KPlaySketchLogger.BTN_LOAD:
					filename = _generateFileName();
					_save(filename,KLogger.FILE_APP_DIR);
					KLogger.flush();
					_load();
					KLogger.log(command);
					break;
				case KPlaySketchLogger.BTN_SAVE:
					filename = _generateFileName(); 
					KLogger.log(command,KLogger.FILE_NAME,filename);
					_save(filename);
					break;
				case KPlaySketchLogger.BTN_CUT:
					_cut();
					KLogger.log(command);
					break;
				case KPlaySketchLogger.BTN_COPY:
					_copy();
					KLogger.log(command);
					break;
				case KPlaySketchLogger.BTN_PASTE:
					_paste(false);
					KLogger.log(command);
					break;				
				case KPlaySketchLogger.BTN_UNDO:
					_undo();	
					KLogger.log(command);
					break;
				case KPlaySketchLogger.BTN_REDO:
					_redo();					
					KLogger.log(command);
					break;
				case KPlaySketchLogger.BTN_GROUP:
					_group();
					KLogger.log(command);
					break;
				case KPlaySketchLogger.BTN_UNGROUP:
					_ungroup();
					KLogger.log(command);
					break;
				case KPlaySketchLogger.BTN_ERASER:
					_configurePen(KPenMenu.LABEL_WHITE);
					KLogger.log(command,KPlaySketchLogger.BTN_PEN_PREVIOUS_STATE,Mouse.cursor);
					break;
				case KPlaySketchLogger.BTN_BLACK_PEN:
					_configurePen(KPenMenu.LABEL_BLACK);
					KLogger.log(command,KPlaySketchLogger.BTN_PEN_PREVIOUS_STATE,Mouse.cursor);
					break;
				case KPlaySketchLogger.BTN_RED_PEN:					
					_configurePen(KPenMenu.LABEL_RED);
					KLogger.log(command,KPlaySketchLogger.BTN_PEN_PREVIOUS_STATE,Mouse.cursor);
					break;
				case KPlaySketchLogger.BTN_GREEN_PEN:					
					_configurePen(KPenMenu.LABEL_GREEN);
					KLogger.log(command,KPlaySketchLogger.BTN_PEN_PREVIOUS_STATE,Mouse.cursor);
					break;
				case KPlaySketchLogger.BTN_BLUE_PEN:					
					_configurePen(KPenMenu.LABEL_BLUE);
					KLogger.log(command,KPlaySketchLogger.BTN_PEN_PREVIOUS_STATE,Mouse.cursor);
					break;
				case KPlaySketchLogger.BTN_FIRST:
					KLogger.log(command,KLogger.TIME_FROM,_appState.time);
					_first();
					break;
				case KPlaySketchLogger.BTN_PREVIOUS:
					_previous();
					KLogger.log(command);
					break;
				case KPlaySketchLogger.BTN_NEXT:
					_next();
					KLogger.log(command);
					break;
				case KPlaySketchLogger.BTN_PLAY:
					_play();
					KLogger.log(command,KLogger.TIME_FROM,_appState.time);
					break;
				case KPlaySketchLogger.BTN_TOGGLE_VISIBILITY:
					_toggleVisibility();
					KLogger.log(command);
					break;
				default:
					break;
			}	
		}
		
		public function doGestureCommand(command:String, canvasPoint:Point):void
		{
			// 
			switch(command)
			{
				case GestureDesign.NAME_PRE_COPY:	
					_copy();									
					break;
				case GestureDesign.NAME_PRE_CUT:
					_cut();					
					break;
				case GestureDesign.NAME_PRE_PASTE:
					_paste(false);
					break;
				case GestureDesign.NAME_PRE_CYCLE_NEXT:
					break;
				case GestureDesign.NAME_PRE_CYCLE_PREV:
					break;
				case GestureDesign.NAME_PRE_REDO:					
					_redo()
					break;
				case GestureDesign.NAME_PRE_UNDO:
					_undo();
					break;
				case GestureDesign.NAME_PRE_PASTE_WITH_MOTIONS:
					_paste(true);
					break;
				case GestureDesign.NAME_PRE_TOGGLE:
					_appState.isPen = !_appState.isPen;					
					if (_canvas.interactorManager is KInteractorManager)
						(_canvas.interactorManager as KInteractorManager).setEraseMode(!_appState.isPen);
					if (!_appState.isPen)
					{
						_prevPenColor = _appState.penColor;
						_configurePen(KPenMenu.LABEL_WHITE);
					}
					else
						_configurePen(KPenMenu.getLabel(_prevPenColor));
					_canvas.dispatchEvent(new KCommandEvent(
						KCommandEvent.EVENT_PEN_CHANGE,KPenMenu.getLabel(_appState.penColor)));
					break;
				case GestureDesign.NAME_PRE_SELECT_PEN:
					if(_penSelectionMenu == null)
					{
						_penSelectionMenu = KPenMenu.createMenu(_canvas);
						_penSelectionMenu.addEventListener(MenuEvent.ITEM_CLICK, _penMenuListener);
					}
					_popupMenu(_penSelectionMenu);
					_hasPopup = true;
					break;
				case GestureDesign.NAME_PRE_SHOW_CONTEXT_MENU:
					if(_contextMenu == null)
					{
						_contextMenu = KContextMenu.createMenu(_canvas, _appState, this, _facade);
						_contextMenu.addEventListener(MenuEvent.ITEM_CLICK, 
							function(event:MenuEvent):void
							{
								_hasPopup = false;
							});
					}
					_contextMenu.withSelection = _appState.selection != null && 
					_appState.selection.objects.length() != 0;
					_popupMenu(_contextMenu);
					_contextMenu.hideWhenRelease = false;
					_hasPopup = true;
					break;
				case PIGTAIL_CONTEXT_MENU:
					if(_contextMenu == null)
						_contextMenu = KContextMenu.createMenu(_canvas, _appState, this, _facade);
					_contextMenu.withSelection = _appState.selection != null && 
					_appState.selection.objects.length() != 0;
					_popupMenu(_contextMenu);
					_contextMenu.hideWhenRelease = true;
					break;				
			}
		}
		
		public function doMenuCommand(command:String):void
		{
			switch(command)
			{
				case KPlaySketchLogger.MENU_CONTEXT_MENU_COPY:
					_copy();									
					break;
				case KPlaySketchLogger.MENU_CONTEXT_MENU_CUT:
					_cut();
					break;
				case KPlaySketchLogger.MENU_CONTEXT_MENU_PASTE:
					_paste(false);
					break;
				case KPlaySketchLogger.MENU_CONTEXT_MENU_PASTE_WITH_MOTION:
					_paste(true);
					break;
				case KPlaySketchLogger.MENU_CONTEXT_MENU_INSERT_KEYS:
					_insertKeyFrames();
					break;
				case KPlaySketchLogger.MENU_CONTEXT_MENU_CLEAR_MOTIONS:
					_clearMotions();
					break;
			}
			KLogger.log(command);
		}
		
		public function doShortcutCommand(command:String):void
		{
			switch(command)
			{
				case KPlaySketchLogger.SHORTCUT_COPY:
					_copy();									
					break;
				case KPlaySketchLogger.SHORTCUT_CUT:
					_cut();
					break;
				case KPlaySketchLogger.SHORTCUT_PASTE:
					_paste(false);
					break;
				case KPlaySketchLogger.SHORTCUT_PASTE_WITH_MOTION:
					_paste(true);
					break;
				case KPlaySketchLogger.SHORTCUT_UNDO:
					_undo();
					break;
				case KPlaySketchLogger.SHORTCUT_REDO:
					_redo();
					break;
			}
			KLogger.log(command);
		}

		public function load(filename:String,location:String):void
		{
			var file:File = KFileAccessor.resolvePath(filename,
				location ? location : KLogger.FILE_DESKTOP_DIR) as File;
			var xml:XML = new KFileLoader().loadKMVFromFile(file);
			_canvas.loadFile(xml);
			KLogger.setLogFile(new XML(xml.child(KLogger.COMMANDS)));
		}
		
		public function saveWithListener(listener:Function):void
		{
			var filename:String = _generateFileName(); 
			KLogger.log(KPlaySketchLogger.BTN_SAVE,KLogger.FILE_NAME,filename);
			var content:XML = _facade.saveFile().appendChild(KLogger.logFile);
			content.@version = _appState.appBuildNumber;
			var saver:KFileSaver = new KFileSaver();
			saver.save(content,filename,listener);
		}
		
		public function get hasPopup():Boolean
		{
			return _hasPopup;
		}
		
		public function set hasPopup(value:Boolean):void
		{
			_hasPopup = value;
		}
		
		protected function _redo():void
		{
			if (_appState.redoEnabled)
			{
				KLogger.logRedo();
				_appState.redo();
			}
		}		
		
		protected function _undo():void
		{
			if (_appState.undoEnabled)
			{
				KLogger.logUndo();
				_appState.undo();
			}
		}		
		
		protected function _first():void
		{
			KLogger.logRewind(_appState.time);
			if(_appState.isAnimating)
				_appState.timerReset(0);
			else
				_appState.time = 0;
		}
		
		protected function _previous():void
		{
			KLogger.logPrevFrame(_appState.time);
			if(_appState.time == 0)
				return;
			_moveFrame(KAppState.previousKey(_appState.time));
		}
		
		protected function _next():void
		{
			KLogger.logNextFrame(_appState.time);
			if(_appState.time == _appState.maxTime)
				return;
			_moveFrame(KAppState.nextKey(_appState.time));
		}		
		
		protected function _play():void
		{
			if(!_appState.isAnimating)
			{
				KLogger.logPlay(_appState.time);
				_appState.startPlaying();
			}
			else
			{
				KLogger.logPause(_appState.time);
				_appState.pause();
			}
		}
		
		protected function _configurePen(cursor_name:String):void
		{
			var eraserMode:Boolean = cursor_name == KPenMenu.LABEL_WHITE;
			(_canvas.interactorManager as KInteractorManager).setEraseMode(eraserMode);
			Mouse.cursor = cursor_name;
			_appState.penColor = KPenMenu.getColor(cursor_name);
			_appState.selection = eraserMode ? null : _appState.selection;
		}
		
		private function _toggleVisibility():void
		{
			var time:Number = _appState.time;
			var oldSel:KSelection = _appState.prevSelection;
			var selection:KSelection = oldSel == null ? _appState.selection : oldSel;
			if (selection != null)
			{
				var op:IModelOperation = _facade.toggleVisibility(selection.objects, time);
				if (op != null)
					_appState.addOperation(op);
			}
		}
		
		private function _popupMenu(menu:Menu):void
		{
			var mouseXVariable:Number = 0;
			var mouseYVariable:Number = 0;
			
			if(_canvas.width - _canvas.mouseX < menu.width)
				mouseXVariable = menu.width;
			
			if(_canvas.height - _canvas.mouseY < menu.height)
				mouseYVariable = menu.height;
			
			if(menu.width == 0)
				mouseXVariable = 225;
			if(menu.height == 0)
				mouseYVariable = 50;
			
			var menuXPos:Number = _canvas.mouseX - mouseXVariable;
			var menuYPos:Number = _canvas.mouseY - mouseYVariable;
			
			if(menuXPos < 0)
				menuXPos = 0;
			if(menuYPos < -0)
				menuYPos = 0;
			
			menu.show(menuXPos, menuYPos);
		}
		
		private function _newFile():void
		{
			_canvas.resetCanvas();
			_facade.clearClipBoard();
			_appState.fireEditEnabledChangedEvent();
			_appState.fireGroupingEnabledChangedEvent();
			KLogger.logNewFile(_appState.appBuildNumber);
		}
		
		private function _load():void
		{
			var loader:KFileLoader = new KFileLoader();
			loader.addEventListener(KFileLoadedEvent.EVENT_FILE_LOADED, _kmvLoaded);
			loader.loadKMV();		
		}
		
		private function _cut():void
		{
			var time:Number = _appState.time;
			var oldSel:KSelection = _appState.selection;
			if (oldSel != null)
			{
				var op:IModelOperation = _facade.cut(oldSel.objects,time);
				_appState.addOperation(new KInteractionOperation(
					_appState,time,time,oldSel,_appState.selection,op));
			}
		}
		
		private function _copy():void
		{
			if(_appState.selection)
				_facade.copy(_appState.selection.objects,_appState.time);
		}
		
		private function _paste(includeMotion:Boolean):void
		{
			var time:Number = _appState.time;
			var oldSel:KSelection = _appState.selection;
			var op:IModelOperation = _facade.paste(includeMotion,time);
			if (op != null)
				_appState.addOperation(new KInteractionOperation(
					_appState,time,time,oldSel,_appState.selection,op));
		}
		
		private function _group():void
		{
			var mode:String = _appState.groupingMode;
			var type:int = _appState.transitionType;
			var time:Number = _appState.time;
			var oldSel:KSelection = _appState.selection;
			var op:IModelOperation = _facade.group(oldSel.objects, mode, type, time);
			if (op != null)
			{
				_appState.addOperation(new KInteractionOperation(
					_appState,time,time,oldSel,_appState.selection,op));
			}
		}
		
		private function _ungroup():void
		{
			var mode:String = _appState.groupingMode;
			var type:int = _appState.transitionType;
			var time:Number = _appState.time;
			var oldSel:KSelection = _appState.selection;
			var op:IModelOperation = _facade.ungroup(oldSel.objects, mode, time);
			if (op != null)
				_appState.addOperation(new KInteractionOperation(
					_appState,time,time,oldSel,_appState.selection,op));
		}		
		
		private function _moveFrame(time:Number):void
		{
			if(_appState.isAnimating)
				_appState.timerReset(time);
			else
				_appState.time = time;
		}
		
		private function _penMenuListener(event:MenuEvent):void
		{
			_hasPopup = false;			
			_appState.isPen = true;
			var label:String = event.item.@label;
			if (label==KPenMenu.LABEL_THIN || label==KPenMenu.LABEL_MEDIUM || 
				label==KPenMenu.LABEL_THICK)
				_appState.penThickness = event.item.@value;
			else 
				_configurePen(label);			
			KLogger.log(KPlaySketchLogger.MENU_PEN_MENU, KPlaySketchLogger.MENU_SELECTED, label);
			_canvas.dispatchEvent(event);
		}
		
		private function _kmvLoaded(e:KFileLoadedEvent):void
		{
			var kmv:XML = new XML(e.content);
			var commands:XML = new XML(kmv.child(KLogger.COMMANDS));
			var array:Array = _xmlListToArray(commands.children());				
			var newXML:XML = array.length > 0 ? XML(array[0]) : null;
			var filename:String = newXML ? newXML.attribute(KLogger.FILE_NAME) : null;
			var location:String = newXML ? newXML.attribute(KLogger.FILE_LOCATION) : null;
			if ( KAppState.IS_AIR && filename && _isLoadingNode(newXML))
				_loadFileAndAppendLog(filename,location,array);
			else
			{
				_canvas.loadFile(kmv);
				KLogger.setLogFile(commands);
				KLogger.logLoadFile(_appState.appBuildNumber,e.fileName,null);
			}
		}
		
		private function _insertKeyFrames():void
		{
			var sel:KSelection = _appState.selection;
			if(sel && sel.objects && sel.objects.length() > 0 && _appState.targetTrackBox >= 0)
			{
				var op:IModelOperation = _facade.insertKeyFrames(sel.objects);
				if (op != null)
					_appState.addOperation(op);
			}
		}
		
		private function _clearMotions():void
		{
			var sel:KSelection = _appState.selection;
			if(sel && sel.objects && sel.objects.length() > 0)
			{
				var op:IModelOperation = _facade.clearMotions(sel.objects);
				if (op != null)
					_appState.addOperation(op);
			}
		}
		
		private function _save(filename:String,folder:String=null):void
		{
			var content:XML = _facade.saveFile().appendChild(KLogger.logFile);
			content.@version = _appState.appBuildNumber;
			var saver:KFileSaver = new KFileSaver();
			if (folder == null || folder.length < 2)
				saver.save(content,filename);
			else if (KAppState.IS_AIR)
				saver.saveToDir(content,folder,filename);
		}

		private function _loadFileAndAppendLog(filename:String,location:String,array:Array):void
		{
			var fileExist:Boolean = _fileExist(filename,location);
			var fileInDesktop:Boolean = _fileInDesktop(filename);
			if (fileExist || fileInDesktop)
			{
				if (fileExist)
					load(filename,location);
				else
				{
					var file:File = KFileAccessor.resolvePath(filename,KLogger.FILE_DESKTOP_DIR) as File;
					load(file.nativePath,null);
				}
				var logXML:XML = KLogger.logFile;
				for (var i:int=1; i < array.length; i++)
					logXML.appendChild(XML(array[i]));
				KLogger.setLogFile(logXML);
			}			
			else
			{
				Alert.show("Unable to find the new session file " + filename + 
					" in location " + location + "\n\nReload manually?",
					"File Not Found",Alert.YES|Alert.NO,null,function (e:CloseEvent):void
					{
						if (e.detail == Alert.YES)
						{
							var file:File = new File(); 
							file.addEventListener(Event.SELECT,function (e:Event):void
							{
								_loadFileAndAppendLog(file.nativePath,null,array);					
							});
							file.browseForOpen("Select a file");
						}
					});
			}
		}

		private function _fileInDesktop(filename:String):Boolean
		{
			return (KFileAccessor.resolvePath(filename,KLogger.FILE_DESKTOP_DIR) as File).exists;
		}
				
		private function _xmlListToArray(list:XMLList):Array
		{
			var array:Array = new Array();
			for each(var xml:XML in list)
			{
				array.push(xml);
			}
			return array;
		}
		
		private function _isLoadingNode(xml:XML):Boolean
		{
			return xml && xml.attribute(KLogger.FILE_NAME).length() > 0 && 
				xml.name().toString() == KLogger.SYSTEM_NEWSESSION;
		}
				
		private function _fileExist(filename:String,location:String):Boolean
		{
			return (KFileAccessor.resolvePath(filename,
				location ? location : KLogger.FILE_DESKTOP_DIR) as File).exists;
		}
		
		private function _generateFileName():String
		{
			var d:Date = new Date();
			return  d.fullYear + "-" + (d.month+1) + "-" + d.date + "-" +
				_getTimeStamp(d.hours,d.minutes,d.seconds) + "_K-Movie.kmv";
		}
		
		private function _getTimeStamp(hr:Number,min:Number,sec:Number):String
		{
			var hrStr:String  =  hr < 10 ? "0" + hr.toString()  : hr.toString();
			var minStr:String = min < 10 ? "0" + min.toString() : min.toString();
			var secStr:String = sec < 10 ? "0" + sec.toString() : sec.toString();;
			return hrStr +"."+ minStr+"."+ secStr;
		}
	}
}