/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.interactor
{
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.ui.Mouse;
	
	import mx.controls.Menu;
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
	import sg.edu.smu.ksketch.operation.IModelOperation;
	import sg.edu.smu.ksketch.operation.KModelFacade;
	import sg.edu.smu.ksketch.operation.implementations.KInteractionOperation;
	import sg.edu.smu.ksketch.utilities.IModelObjectList;
	import sg.edu.smu.ksketch.utilities.KAppState;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;
	
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
				case KLogger.BTN_EXIT:
					filename = _generateFileName(); 
					KLogger.log(command,KLogger.FILE_NAME,filename);
					_save(filename,KLogger.FILE_APP_DIR);
					break;
				case KLogger.BTN_NEW:
					filename = _generateFileName(); 
					KLogger.log(command,KLogger.FILE_NAME,filename);
					_save(filename,KLogger.FILE_APP_DIR);
					KLogger.flush();
					KLogger.log(KLogger.NEW_SESSION, KLogger.VERSION, _appState.appBuildNumber);
					_newFile();
					break;
				case KLogger.BTN_LOAD:
					filename = _generateFileName(); 
					KLogger.log(command,KLogger.FILE_NAME,filename);
					_save(filename,KLogger.FILE_APP_DIR);
					KLogger.flush();
					_load();
					break;
				case KLogger.BTN_SAVE:
					filename = _generateFileName(); 
					KLogger.log(command,KLogger.FILE_NAME,filename);
					_save(filename);
					break;
				case KLogger.BTN_CUT:
					KLogger.log(command);
					_cut();
					break;
				case KLogger.BTN_COPY:
					KLogger.log(command);
					_copy();
					break;
				case KLogger.BTN_PASTE:
					KLogger.log(command);
					_paste(false);
					break;				
				case KLogger.BTN_UNDO:
					KLogger.log(command);
					_undo();	
					break;
				case KLogger.BTN_REDO:
					KLogger.log(command);
					_redo();					
					break;
				case KLogger.BTN_GROUP:
					KLogger.log(command);
					_group();
					break;
				case KLogger.BTN_UNGROUP:
					KLogger.log(command);
					_ungroup();
					break;
				case KLogger.BTN_ERASER:
					KLogger.log(command,KLogger.BTN_PEN_PREVIOUS_STATE,Mouse.cursor);
					_configurePen(KPenMenu.LABEL_WHITE);
					break;
				case KLogger.BTN_BLACK_PEN:
					KLogger.log(command,KLogger.BTN_PEN_PREVIOUS_STATE,Mouse.cursor);
					_configurePen(KPenMenu.LABEL_BLACK);
					break;
				case KLogger.BTN_RED_PEN:					
					KLogger.log(command,KLogger.BTN_PEN_PREVIOUS_STATE,Mouse.cursor);
					_configurePen(KPenMenu.LABEL_RED);
					break;
				case KLogger.BTN_GREEN_PEN:					
					KLogger.log(command,KLogger.BTN_PEN_PREVIOUS_STATE,Mouse.cursor);
					_configurePen(KPenMenu.LABEL_GREEN);
					break;
				case KLogger.BTN_BLUE_PEN:					
					KLogger.log(command,KLogger.BTN_PEN_PREVIOUS_STATE,Mouse.cursor);
					_configurePen(KPenMenu.LABEL_BLUE);
					break;
				case KLogger.BTN_FIRST:
					KLogger.log(command,KLogger.CHANGE_TIME_FROM,_appState.time);
					_first();
					break;
				case KLogger.BTN_PREVIOUS:
					KLogger.log(command);
					_previous();
					break;
				case KLogger.BTN_NEXT:
					KLogger.log(command);
					_next();
					break;
				case KLogger.BTN_PLAY:
					KLogger.log(command,KLogger.CHANGE_TIME_FROM,_appState.time);
					_play();
					break;
				case KLogger.BTN_TOGGLE_VISIBILITY:
					KLogger.log(command);
					_toggleVisibility();
					break;
				default:
					break;
			}	
		}
		
		public function doGestureCommand(command:String, canvasPoint:Point):void
		{
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
				case KLogger.MENU_CONTEXT_MENU_COPY:
					_copy();									
					break;
				case KLogger.MENU_CONTEXT_MENU_CUT:
					_cut();
					break;
				case KLogger.MENU_CONTEXT_MENU_PASTE:
					_paste(false);
					break;
				case KLogger.MENU_CONTEXT_MENU_PASTE_WITH_MOTION:
					_paste(true);
					break;
				case KLogger.MENU_CONTEXT_MENU_INSERT_KEYS:
					_insertKeyFrames();
					break;
				case KLogger.MENU_CONTEXT_MENU_CLEAR_MOTIONS:
					_clearMotions();
					break;
			}
			KLogger.log(command);
		}
		
		public function doShortcutCommand(command:String):void
		{
			switch(command)
			{
				case KLogger.SHORTCUT_COPY:
					_copy();									
					break;
				case KLogger.SHORTCUT_CUT:
					_cut();
					break;
				case KLogger.SHORTCUT_PASTE:
					_paste(false);
					break;
				case KLogger.SHORTCUT_PASTE_WITH_MOTION:
					_paste(true);
					break;
				case KLogger.SHORTCUT_UNDO:
					_undo();
					break;
				case KLogger.SHORTCUT_REDO:
					_redo();
					break;
			}
			KLogger.log(command);
		}
		
		public function saveOnExit(listener:Function):void
		{
			var content:XML = _facade.saveFile().appendChild(KLogger.logFile);
			content.@version = _appState.appBuildNumber;
			trace(content.toXMLString());
			var saver:KFileSaver = new KFileSaver();
			saver.save(content,_generateFileName(),listener);
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
			_appState.redo();
		}		
		
		protected function _undo():void
		{
			_appState.undo();
		}		
				
		protected function _first():void
		{
			if(_appState.isAnimating)
				_appState.timerReset(0);
			else
				_appState.time = 0;
		}
		
		protected function _previous():void
		{
			if(_appState.time == 0)
				return;
			_moveFrame(KAppState.previousKey(_appState.time));
		}
		
		protected function _next():void
		{
			if(_appState.time == _appState.maxTime)
				return;
			_moveFrame(KAppState.nextKey(_appState.time));
		}		
		
		protected function _play():void
		{
			if(!_appState.isAnimating)
				_appState.startPlaying();
			else
				_appState.pause();
		}

		protected function _configurePen(cursor_name:String):void
		{
			var eraserMode:Boolean = cursor_name == KPenMenu.LABEL_WHITE;
			(_canvas.interactorManager as KInteractorManager).setEraseMode(eraserMode);
			Mouse.cursor = cursor_name;
			_appState.penColor = KPenMenu.getColor(cursor_name);
			_appState.selection = eraserMode ? null : _appState.selection;
		}
		
		protected function _toggleVisibility():void
		{
			var time:Number = _appState.time;
			var oldSel:KSelection = _appState.prevSelection;
			var selection:KSelection = oldSel == null ? _appState.selection : oldSel;
			var objs:KModelObjectList = selection != null ? selection.objects : null;
			var op:IModelOperation = objs != null ? _facade.toggleVisibility(objs,time) : null;
			if (op != null)
				_appState.addOperation(op);
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
			KLogger.flush();
			_canvas.newFile();
			_facade.clearClipBoard();
			_appState.fireEditEnabledChangedEvent();
			_appState.fireGroupingEnabledChangedEvent();
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
			var op:IModelOperation = _facade.cut();
			if (op != null)
				_appState.addOperation(new KInteractionOperation(
					_appState,time,time,oldSel,_appState.selection,op));
		}
		
		private function _copy():void
		{
			_facade.copy();
		}
		
		private function _paste(includeMotion:Boolean):void
		{
			var time:Number = _appState.time;
			var oldSel:KSelection = _appState.selection;
			var op:IModelOperation = _facade.paste(includeMotion);
			if (op != null)
				_appState.addOperation(new KInteractionOperation(
					_appState,time,time,oldSel,_appState.selection,op));
		}
		
		private function _group():void
		{
			var time:Number = _appState.time;
			var oldSel:KSelection = _appState.selection;
			var op:IModelOperation = _facade.group(oldSel.objects);
			if (op != null)
				_appState.addOperation(new KInteractionOperation(
					_appState,time,time,oldSel,_appState.selection,op));
		}
		
		private function _ungroup():void
		{
			var time:Number = _appState.time;
			var oldSel:KSelection = _appState.selection;
			var op:IModelOperation = _facade.ungroup(oldSel.objects);
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
			KLogger.log(KLogger.MENU_PEN_MENU, KLogger.MENU_SELECTED, label);
			_canvas.dispatchEvent(event);
		}
		
		private function _kmvLoaded(e:KFileLoadedEvent):void
		{
			if(e.filePath)
			{
				var xml:XML = new XML(e.content);
				_canvas.loadFile(xml);
				KLogger.setLogFile(new XML(xml.child(KLogger.COMMANDS).toXMLString()));
				KLogger.log(KLogger.NEW_SESSION, KLogger.VERSION, _appState.appBuildNumber);
			}
		}
		
		//Function to insert blank key frames into the selected object's timeline
		private function _insertKeyFrames():void
		{
			if(_appState.targetTrackBox < 0)
				return;
			
			var objects:IModelObjectList;
			
			if(_appState.selection)
			{
				objects = _appState.selection.objects;
				
				if(!objects || objects.length() <= 0)
					objects = null;
			}
			
			var insertKeyFrameOp:IModelOperation = _facade.insertKeyFrames(objects);
			
			if(insertKeyFrameOp)
				_appState.addOperation(insertKeyFrameOp);
		}
		
		private function _clearMotions():void
		{
			var objects:IModelObjectList;
			
			if(_appState.selection)
			{
				objects = _appState.selection.objects;
				
				if(!objects || objects.length() <= 0)
					objects = null;
			}
			
			if(objects)
				_facade.clearMotions(objects);
		}
		
		private function _save(filename:String,folder:String=null):void
		{
			var content:XML = _facade.saveFile().appendChild(KLogger.logFile);
			content.@version = _appState.appBuildNumber;
			var saver:KFileSaver = new KFileSaver();
			if (folder == null || folder.length < 2)
				saver.save(content,filename);
			else
				saver.saveToDir(content,folder,filename);
		}
		
		private function _generateFileName():String
		{
			var date:Date = new Date();
			
			return  date.fullYear+"-"+(date.month+1)+"-"+date.day+"-"+date.hours.toString()+date.minutes.toString()+"_K-Movie.kmv";
		}
		
		private function getTimeStamp():String
		{
			var date:Date = new Date();
			var returnString:String;
			if(date.hours < 10)
				returnString = "0"+date.hours.toString();
			else
				returnString = date.hours.toString();
			
			if(date.minutes < 10)
				return returnString +"0"+date.minutes.toString();
			else
				return returnString+date.minutes.toString();
		}
	}
}