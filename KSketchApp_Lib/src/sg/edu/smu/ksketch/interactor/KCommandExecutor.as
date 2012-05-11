/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.interactor
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.ui.Mouse;
	
	import mx.controls.Menu;
	import mx.events.CloseEvent;
	import mx.events.MenuEvent;
	
	import sg.edu.smu.ksketch.components.KCanvas;
	import sg.edu.smu.ksketch.components.KContextMenu;
	import sg.edu.smu.ksketch.components.KPenMenu;
	import sg.edu.smu.ksketch.event.KFileLoadedEvent;
	import sg.edu.smu.ksketch.event.KFileSavedEvent;
	import sg.edu.smu.ksketch.gestures.GestureDesign;
	import sg.edu.smu.ksketch.io.KFileLoader;
	import sg.edu.smu.ksketch.io.KFileSaver;
	import sg.edu.smu.ksketch.logger.KLogger;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	import sg.edu.smu.ksketch.operation.KModelFacade;
	import sg.edu.smu.ksketch.operation.implementations.KInteractionOperation;
	import sg.edu.smu.ksketch.utilities.KAppState;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;
	
	public class KCommandExecutor extends EventDispatcher
	{
		public static const EVENT_COMMAND_COMPLETE:String = "EVENT_COMMAND_COMPLETE";
		public static const PIGTAIL_CONTEXT_MENU:String = "pigtail";
		public static const HIGHLITED_CURSOR_PATH_CLICKED:String = "HIGHLITED_CURSOR_PATH_CLICKED";		
		protected var _contextMenu:KContextMenu;
		protected var _hasPopup:Boolean;		
		protected var _appState:KAppState;
		protected var _facade:KModelFacade;
		protected var _canvas:KCanvas;
		protected var _penSelectionMenu:KPenMenu;
		
		public function KCommandExecutor(appState:KAppState, canvas:KCanvas, facade:KModelFacade)
		{
			_appState = appState;
			_canvas = canvas;
			_facade = facade
			_hasPopup = false;
		}

		public function doButtonCommand(command:String):void
		{
			switch (command)
			{
				case KLogger.BTN_NEW:
					KLogger.log(command);
					KLogger.flush();
					newFile();
					break;
				case KLogger.BTN_LOAD:
					KLogger.log(command);
					KLogger.flush();
					_load();
					break;
				case KLogger.BTN_SAVE:
					KLogger.log(command);
					_save(null);
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
					_paste();
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
					_paste();
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
				case GestureDesign.NAME_PRE_TOGGLE:
					_appState.isPen = !_appState.isPen;					
					if (_canvas.interactorManager is KInteractorManager)
						(_canvas.interactorManager as KInteractorManager).setEraseMode(_appState.isPen);
					break;
				case GestureDesign.NAME_PRE_SELECT_PEN:
					if(_penSelectionMenu == null)
					{
						_penSelectionMenu = KPenMenu.createMenu(_canvas);
						_penSelectionMenu.addEventListener(MenuEvent.ITEM_CLICK, _penMenuListener);
					}
					popupMenu(_penSelectionMenu, canvasPoint);
					_hasPopup = true;
					break;
				case GestureDesign.NAME_PRE_SHOW_CONTEXT_MENU:
					if(_contextMenu == null)
					{
						_contextMenu = KContextMenu.createMenu(_canvas, _appState, _facade);
						_contextMenu.addEventListener(MenuEvent.ITEM_CLICK, 
							function(event:MenuEvent):void
							{
								_hasPopup = false;
							});
					}
					_contextMenu.withSelection = _appState.selection != null && 
					_appState.selection.objects.length() != 0;
					popupMenu(_contextMenu, canvasPoint);
					_contextMenu.hideWhenRelease = false;
					_hasPopup = true;
					break;
				case PIGTAIL_CONTEXT_MENU:
					if(_contextMenu == null)
						_contextMenu = KContextMenu.createMenu(_canvas, _appState, _facade);
					_contextMenu.withSelection = _appState.selection != null && 
					_appState.selection.objects.length() != 0;
					popupMenu(_contextMenu, canvasPoint);
					_contextMenu.hideWhenRelease = true;
					break;				
			}
		}
				
		public function get hasPopup():Boolean
		{
			return _hasPopup;
		}
		
		public function set hasPopup(value:Boolean):void
		{
			_hasPopup = value;
		}
		
		public function popupMenu(menu:Menu, canvasPoint:Point):void
		{
			//		var rootPoint:Point = _canvas.localToGlobal(canvasPoint);
			//		menu.show(rootPoint.x+220, rootPoint.y+50);
			menu.show(_canvas.mouseX+40,_canvas.mouseY+20);
		}
		
		public function save(path:String=null):void
		{
			_save(path);
		}
		
		public function newFile():void
		{
			KLogger.flush();
			_canvas.newFile();
			_facade.clearClipBoard();
			_appState.fireEditEnabledChangedEvent();
			_appState.fireGroupingEnabledChangedEvent();
		}
				
		protected function _load():void
		{
			var loader:KFileLoader = new KFileLoader();
			loader.addEventListener(KFileLoadedEvent.EVENT_FILE_LOADED, _kmvLoaded);
			loader.loadKMV();		
		}		
		
		protected function _save(path:String):void
		{			
			var content:XML = _facade.saveFile().appendChild(KLogger.logFile);
			var saver:KFileSaver = new KFileSaver();
			if (path)
				saver.saveToDir(content,path);
			else
			{
				saver.addEventListener(KFileSavedEvent.EVENT_FILE_SAVED, _fileSaved);
				saver.save(content);
			}
		}		
		
		protected function _redo():void
		{
			_appState.redo();
		}		
		
		protected function _undo():void
		{
			_appState.undo();
		}		
		
		protected function _cut():void
		{
			var time:Number = _appState.time;
			var oldSel:KSelection = _appState.selection;
			var op:IModelOperation = _facade.cut();
			if (op != null)
				_appState.addOperation(new KInteractionOperation(
					_appState,time,time,oldSel,_appState.selection,op));
		}
		
		protected function _copy():void
		{
			_facade.copy();
		}
		
		protected function _paste():void
		{
			var time:Number = _appState.time;
			var oldSel:KSelection = _appState.selection;
			var op:IModelOperation = _facade.paste();
			if (op != null)
				_appState.addOperation(new KInteractionOperation(
					_appState,time,time,oldSel,_appState.selection,op));
		}
		
		protected function _group():void
		{
			var time:Number = _appState.time;
			var oldSel:KSelection = _appState.selection;
			var op:IModelOperation = _facade.group(oldSel.objects);
			if (op != null)
				_appState.addOperation(new KInteractionOperation(
					_appState,time,time,oldSel,_appState.selection,op));
		}
		
		protected function _ungroup():void
		{
			var time:Number = _appState.time;
			var oldSel:KSelection = _appState.selection;
			var op:IModelOperation = _facade.ungroup(oldSel.objects);
			if (op != null)
				_appState.addOperation(new KInteractionOperation(
					_appState,time,time,oldSel,_appState.selection,op));
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
		
		protected function _moveFrame(time:Number):void
		{
			if(_appState.isAnimating)
				_appState.timerReset(time);
			else
				_appState.time = time;
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
		
		protected function _configurePen(cursor_name:String):void
		{
			var eraserMode:Boolean = cursor_name == KPenMenu.LABEL_WHITE;
			(_canvas.interactorManager as KInteractorManager).setEraseMode(eraserMode);
			Mouse.cursor = cursor_name;
			_appState.penColor = KPenMenu.getColor(cursor_name);
			_appState.selection = eraserMode ? null : _appState.selection;
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
			if(e.filePath == null)
				KLogger.log(KLogger.BTN_LOAD);
			else
			{
				KLogger.log(KLogger.BTN_LOAD, KLogger.FILE_PATH, e.filePath);
				_canvas.loadFile(new XML(e.content));
			}
		}
		
		private function _fileSaved(e:KFileSavedEvent):void
		{
			if(e.filePath == null)
				KLogger.log(KLogger.BTN_SAVE);
			else
				KLogger.log(KLogger.BTN_SAVE, KLogger.FILE_PATH, e.filePath);
		}		
	}
}