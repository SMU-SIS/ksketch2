/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.components
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import sg.edu.smu.ksketch.event.KObjectEvent;
	import sg.edu.smu.ksketch.event.KSelectionChangedEvent;
	import sg.edu.smu.ksketch.event.KTimeChangedEvent;
	import sg.edu.smu.ksketch.interactor.KSelection;
	import sg.edu.smu.ksketch.interactor.UserOption;
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.operation.KModelFacade;
	import sg.edu.smu.ksketch.utilities.IIterator;
	import sg.edu.smu.ksketch.utilities.IModelObjectList;
	import sg.edu.smu.ksketch.utilities.KAppState;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;

	public class KCanvasStoppedState implements ICanvasClockState
	{
		private var _facade:KModelFacade;
		private var _viewsTable:Dictionary;
		private var _appState:KAppState;
		private var _widget:IWidget;
		private var _lastSelection:KSelection;
		
		private var _showPathState:String;
		
		public function KCanvasStoppedState(appState:KAppState, viewsTable:Dictionary, facade:KModelFacade, widget:IWidget)
		{
			_facade = facade;
			_appState = appState;
			_viewsTable = viewsTable;
			_widget = widget;
		}
		
		public function init():void
		{
			_lastSelection = null;
		}
		
		public function entry():void
		{
			// load selection
			if(_appState.selection == null && _lastSelection != null && canSelect(_lastSelection.objects))
			{
				_appState.selection = _lastSelection;
				_lastSelection = null;
			}
			else if(_appState.selection != null)
				_lastSelection = null;
			
			if(_showPathState != _appState.userOption.showPath)
				showPathState = _appState.userOption.showPath;
			else
				updatePath();
			
			updateSelection();
			
			addEventListeners();
		}
		
		public function exit():void
		{
			removeEventListeners();
			
			clearPath();
		}
		
		// ----------
		
		private function addEventListeners():void
		{
			_appState.addEventListener(KSelectionChangedEvent.EVENT_SELECTION_CHANGED, selectionChangedEventHandler);
			_appState.addEventListener(KTimeChangedEvent.TIME_CHANGED, timeChangedEventHandler);
			_appState.addEventListener(KAppState.EVENT_OBJECT_PATH, showPathChangedEventHandler);
			listenTo(_appState.selection, true);
		}
		private function removeEventListeners():void
		{
			listenTo(_appState.selection, false);
			_appState.removeEventListener(KAppState.EVENT_OBJECT_PATH, showPathChangedEventHandler);
			_appState.removeEventListener(KTimeChangedEvent.TIME_CHANGED, timeChangedEventHandler);
			_appState.removeEventListener(KSelectionChangedEvent.EVENT_SELECTION_CHANGED, selectionChangedEventHandler);
		}
		
		private function showPathChangedEventHandler(event:Event):void
		{
			showPathState = _appState.userOption.showPath;
		}
		
		private function selectionChangedEventHandler(event:KSelectionChangedEvent):void
		{
			updatePath(event);
			listenTo(event.oldSelection, false);
			listenTo(event.newSelection, true);
			updateSelection();
		}
		
		private function listenTo(selection:KSelection, listen:Boolean):void
		{
			if(selection == null)
				return;
			var list:KModelObjectList = selection.objects;
			if(list != null)
			{
				var it:IIterator = list.iterator;
				var i:int = 0;
				if(listen)
					while(it.hasNext())
						it.next().addEventListener(KObjectEvent.EVENT_TRANSFORM_CHANGED, updateSelection);
				else
					while(it.hasNext())
						it.next().removeEventListener(KObjectEvent.EVENT_TRANSFORM_CHANGED, updateSelection);
			}
		}
		
		private function updateSelection(event:KObjectEvent = null):void
		{
			if(_appState.selection)
				_appState.selection.tuneSelection(_appState.time);

			_widget.highlightSelection();
		}
		
		private function timeChangedEventHandler(event:KTimeChangedEvent):void
		{
			if(_appState.selection != null)
			{	
				updateSelection();
			}
			else
			{
				if(_lastSelection != null && canSelect(_lastSelection.objects))
				{
					_appState.selection = _lastSelection;
					_lastSelection = null;
				}
			}
		}
		
		private function canSelect(objects:KModelObjectList):Boolean
		{
			if(objects.length() == 0)
				return false;
			
			var kskTime:Number = _appState.time;
			var length:int = objects.length();
			var object:KObject;
			var it:IIterator = objects.iterator;
			while(it.hasNext())
			{
				object = it.next();
				if(_facade.getObjectByID(object.id) == null || object.getVisibility(kskTime) <= 0)
					return false;
			}

			return true;
		}
		
		private function set showPathState(value:String):void
		{
			if(_showPathState == value)
				return;
			
			if(_showPathState == UserOption.SHOW_PATH_ALL || value == UserOption.SHOW_PATH_NONE)
				clearPath();
			
			_showPathState = value;
			updatePath();
		}
		
		private function clearPath():void
		{
			var it:IIterator = _facade.root.directChildIterator(_appState.time);
			while(it.hasNext())
				showPath_Object(it.next(), false);
		}
		
		private function updatePath(event:KSelectionChangedEvent = null):void
		{
			switch(_showPathState)
			{
				case UserOption.SHOW_PATH_ALL:
					var it:IIterator = _facade.root.directChildIterator(_appState.time);
					while(it.hasNext())
						showPath_Object(it.next(), true);
					break;
				case UserOption.SHOW_PATH_SELECTED:
					if(event != null)
					{
						showPath_List(event.oldSelection, false);
						showPath_List(event.newSelection, true);
					}
					else
						showPath_List(_appState.selection, true);
					break;
				case UserOption.SHOW_PATH_NONE:
					break;
			}
		}
		
		private function showPath_List(selection:KSelection, show:Boolean):void
		{
			if(selection == null)
				return;
			
			var list:KModelObjectList = selection.objects;
			var it:IIterator = list.iterator;
			while(it.hasNext())
				showPath_Object(it.next(), show);
		}
		private function showPath_Object(object:KObject, show:Boolean):void
		{
			if (_viewsTable[object] != null)
			{
				(_viewsTable[object] as IObjectView).showCursorPath = show;
				if(!show && object is KGroup)
				{
					var group:KGroup = object as KGroup;
					var it:IIterator = group.directChildIterator(_appState.time);
					while(it.hasNext())
						showPath_Object(it.next(), show);
				}
			}
		}
	}
}