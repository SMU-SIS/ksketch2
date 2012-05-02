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
	import sg.edu.smu.ksketch.interactor.KSelection;
	import sg.edu.smu.ksketch.interactor.KCommandExecutor;
	import sg.edu.smu.ksketch.logger.KLogger;
	import sg.edu.smu.ksketch.model.ISpatialKeyframe;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	import sg.edu.smu.ksketch.operation.KModelFacade;
	import sg.edu.smu.ksketch.operation.implementations.KCompositeOperation;
	import sg.edu.smu.ksketch.operation.implementations.KInteractionOperation;
	import sg.edu.smu.ksketch.utilities.IIterator;
	import sg.edu.smu.ksketch.utilities.KAppState;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;
		
	public class KContextMenu extends Menu
	{
		[Bindable]
		public static var MENU_ITEMS_WITH_SEL:XML = 
			<root>
				<menuitem label="Copy(Ctr+C)"/>
                <menuitem label="Paste Object(Ctrl+V)"/>
			<!--
                <menuitem label="Insert KeyFrame"/>
			-->
			</root>;
		
		[Bindable]
		public static var MENU_ITEMS_NO_SEL:XML = 
			<root>
				<menuitem label="Paste Object(Ctrl+V)"/>
			</root>;
		
		private var _appState:KAppState;
		private var _facade:KModelFacade;
		private var _objectsTotal:KModelObjectList;
		private var _cursorKey:ISpatialKeyframe
		private var _cursorObject:KObject
		
		public function KContextMenu(appState:KAppState,facade:KModelFacade)
		{
			super();
			_appState = appState;
			_facade = facade;
			labelField = "@label";
			this.addEventListener(MenuEvent.ITEM_CLICK, execute);
		}
				
		private function execute(event:MenuEvent):void
		{			
			var selected:String = event.item.@label;
			_appState.selectedItem = selected;			
			
			switch(selected)
			{
				case "Copy(Ctr+C)":
					_facade.copy();
					break;
				case "Paste Object(Ctrl+V)":
			//		KCommandExecutor.paste(_appState,_facade);
					break;
				case "Insert KeyFrame":
					_insertKeyFrames();
					break;
			}
						   
		   _facade.dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATED));	
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
				
		//Function to insert blank key frames into the selected object's timeline
		private function _insertKeyFrames():void
		{
			if(_appState.selection)
			{			
				var KMObjectList:KModelObjectList=new KModelObjectList();
				var snapShotOperationComposite:KCompositeOperation = new KCompositeOperation;
				_objectsTotal= _appState.selection.objects;
				
				var op:IModelOperation;
/*				
				//For each selected object
				//Add a blank keyframe at appstate time.
				for(var k:int=0; k<_objectsTotal.length(); k++)
			  	{
					//Perform the add blank keyframe operation.
					//If a keyframe exists at the time, the function will return a null operation.
					op = _kOperationMgr.addSnapShotKeyframe(_appState.selection.objects.getObjectAt(k),_appState.time, "POSITION");
					
					//Only add the operation to the operation list if it is not null
					if(op)
						snapShotOperationComposite.addOperation(op);
					
					op = _kOperationMgr.addSnapShotKeyframe(_appState.selection.objects.getObjectAt(k),_appState.time, "ROTATION");
					
					if(op)
						snapShotOperationComposite.addOperation(op);
					
					op = _kOperationMgr.addSnapShotKeyframe(_appState.selection.objects.getObjectAt(k),_appState.time, "SCALE");
					
					if(op)
						snapShotOperationComposite.addOperation(op);
			  	}	 				  
*/				
				//If at least a frame is added, create an operation and add the operation to the undo stack.
				if(snapShotOperationComposite.length > 0)
				{
			    	var myInteractiveOp:KInteractionOperation= new KInteractionOperation(_appState, _appState.time,
					_appState.time, new KSelection(_objectsTotal, _appState.time), new KSelection(_objectsTotal, _appState.time), snapShotOperationComposite);
				    _appState.addOperation(myInteractiveOp);			  			  	
				}
			}
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
			dataProvider = value ? MENU_ITEMS_WITH_SEL : MENU_ITEMS_NO_SEL;
		}
			
		public static function createMenu(parent:DisplayObjectContainer, appState:KAppState, 
										  facade:KModelFacade):KContextMenu
		{
			var menu:KContextMenu = new KContextMenu(appState,facade);
			menu.tabEnabled = false;    
			menu.owner = parent;
			menu.showRoot = false;
			popUpMenu(menu, parent, null);
			return menu;
		}
	}
}