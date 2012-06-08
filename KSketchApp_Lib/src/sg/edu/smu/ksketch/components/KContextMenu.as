/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.components
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.Menu;
	import mx.events.MenuEvent;
	
	import sg.edu.smu.ksketch.event.KModelEvent;
	import sg.edu.smu.ksketch.interactor.KCommandExecutor;
	import sg.edu.smu.ksketch.interactor.KSelection;
	import sg.edu.smu.ksketch.logger.KLogger;
	import sg.edu.smu.ksketch.model.ISpatialKeyframe;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	import sg.edu.smu.ksketch.operation.KModelFacade;
	import sg.edu.smu.ksketch.operation.KTransformMgr;
	import sg.edu.smu.ksketch.operation.implementations.KCompositeOperation;
	import sg.edu.smu.ksketch.utilities.IIterator;
	import sg.edu.smu.ksketch.utilities.IModelObjectList;
	import sg.edu.smu.ksketch.utilities.KAppState;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;
		
	public class KContextMenu extends Menu
	{
		[Bindable]
		public static var MENU_ITEMS_WITH_SEL:XML = 
			<root>
				<menuitem id="1" label="Copy(Ctrl+C)"/>
                <menuitem id="2" label="Paste Object(Ctrl+V)"/>
                <menuitem id="3" label="Paste Object with Motion(Ctrl+M)"/>
				<menuitem id="4" label="Clear Motions"/>
			</root>;
		
		[Bindable]
		public static var MENU_ITEMS_WITH_SEL_AND_ON_TRACK:XML = 
			<root>
				<menuitem id="5" label="Insert KeyFrame"/>
				<menuitem id="4" label="Clear Motions"/>
			</root>;
		
		[Bindable]
		public static var MENU_ITEMS_NO_SEL_AND_ON_OVERVIEW_TRACK:XML = 
			<root>
				<menuitem id="5" label="Insert KeyFrame"/>
				<menuitem id="2" label="Paste Object(Ctrl+V)"/>
                <menuitem id="3" label="Paste Object with Motion(Ctrl+M)"/>
			</root>;
		
		[Bindable]
		public static var MENU_ITEMS_NO_SEL:XML = 
			<root>
				<menuitem id="2" label="Paste Object(Ctrl+V)"/>
                <menuitem id="3" label="Paste Object with Motion(Ctrl+M)"/>
			</root>;
		
		private static var _COMMANDS:Array = ["",KLogger.MENU_CONTEXT_MENU_COPY,
			KLogger.MENU_CONTEXT_MENU_PASTE,KLogger.MENU_CONTEXT_MENU_PASTE_WITH_MOTION,
			KLogger.MENU_CONTEXT_MENU_CLEAR_MOTIONS,KLogger.MENU_CONTEXT_MENU_INSERT_KEYS];
		
		private var _appState:KAppState;
		private var _executor:KCommandExecutor;
		private var _objectsTotal:KModelObjectList;
		private var _cursorKey:ISpatialKeyframe
		private var _cursorObject:KObject;
		private var _facade:KModelFacade
		
		public function KContextMenu(appState:KAppState,executor:KCommandExecutor, facade:KModelFacade)
		{
			super();
			
			_facade = facade;
			_appState = appState;
			_executor = executor;
			labelField = "@label";
			this.addEventListener(MenuEvent.ITEM_CLICK, execute);
		}
				
		private function execute(event:MenuEvent):void
		{			
			var selected:String = event.item.@label;
			
		//	_appState.selectedItem = selected;
			
			var itemNo:int = event.item.@id;
			if (itemNo > 0)
				_executor.doMenuCommand(_COMMANDS[itemNo]);
						   
		   _executor.dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATED));	
		   _appState._fireFacadeUndoRedoModelChangedEvent();
		   _appState._fireUndoEvent();
		   _appState._fireRedoEvent();
		   
		   var selectedItems:String = selectedObjects();
			if(selectedItems != null)
				KLogger.log(KLogger.MENU_CONTEXT_MENU, KLogger.MENU_SELECTED, selected, KLogger.SELECTED_ITEMS, selectedItems);
			else
				KLogger.log(KLogger.MENU_CONTEXT_MENU, KLogger.MENU_SELECTED, selected);
		}
			
		
		public function _setCursorPathValues(key:ISpatialKeyframe,event:MouseEvent, _object:KObject):void
		{		
			this._cursorKey=key;
			this._cursorObject=_object;
		}
		
		private function selectedObjects():String
		{
			if(_appState.selection == null)
				return null;
			var selected:String;
			var it:IIterator = _appState.selection.objects.iterator;
			if(it.hasNext())
				selected = it.next().id.toString();
			while(it.hasNext())
				selected += " " + it.next().id;
			return selected;
		}
		
		public function set hideWhenRelease(hide:Boolean):void
		{
			var sbRoot:DisplayObject = this.systemManager.getSandboxRoot();
			if(hide)
			{
				sbRoot.addEventListener(MouseEvent.MOUSE_UP, hideMe);
				if(KAppState.IS_AIR)
					sbRoot.addEventListener(MouseEvent.RIGHT_MOUSE_UP, hideMe);
			}
			else
			{
				sbRoot.removeEventListener(MouseEvent.MOUSE_UP, hideMe);
				if(KAppState.IS_AIR)
					sbRoot.removeEventListener(MouseEvent.RIGHT_MOUSE_UP, hideMe);
			}
		}
		
		private function hideMe(event:Event):void
		{
			hide();
		}
		
		public function set withSelection(value:Boolean):void
		{
			if(value)
			{
				if(_appState.targetTrackBox >= 0)
					dataProvider = MENU_ITEMS_WITH_SEL_AND_ON_TRACK;
				else
					dataProvider = MENU_ITEMS_WITH_SEL;
			}
			else
			{				
				if(_appState.targetTrackBox == KTransformMgr.ALL_REF)
					dataProvider = MENU_ITEMS_NO_SEL_AND_ON_OVERVIEW_TRACK;
				else
					dataProvider = MENU_ITEMS_NO_SEL;
			}
		}
			
		public static function createMenu(parent:DisplayObjectContainer, appState:KAppState, 
										 executor:KCommandExecutor, facade:KModelFacade):KContextMenu
		{
			var menu:KContextMenu = new KContextMenu(appState,executor, facade);
			menu.tabEnabled = false;    
			menu.owner = parent;
			menu.showRoot = false;
			popUpMenu(menu, parent, null);
			return menu;
		}
	}
}