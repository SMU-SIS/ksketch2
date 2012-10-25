/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package sg.edu.smu.ksketch.components
{
	import flash.events.Event;
	
	import sg.edu.smu.ksketch.event.KObjectEvent;
	import sg.edu.smu.ksketch.event.KSelectionChangedEvent;
	import sg.edu.smu.ksketch.interactor.KSelection;
	import sg.edu.smu.ksketch.utilities.IIterator;
	import sg.edu.smu.ksketch.utilities.IModelObjectList;
	import sg.edu.smu.ksketch.utilities.KAppState;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;
	
	public class KCanvasInteractingState implements ICanvasClockState
	{
		private var _appState:KAppState;
		private var _widget:IWidget;
		
		public function KCanvasInteractingState(appState:KAppState, widget:IWidget)
		{
			_appState = appState;
			_widget = widget;
		}
		
		public function entry():void
		{
			_widget.visible = false;
			addEventListeners();
		}
		
		public function exit():void
		{
			_widget.visible = true;
			removeEventListeners();
		}
		
		private function addEventListeners():void
		{
			// selection changed, redraw cursor path
			_appState.addEventListener(KSelectionChangedEvent.EVENT_SELECTION_CHANGED, selectionChangedEventHandler);
			_appState.addEventListener(KAppState.EVENT_HANDLE_CENTER_CHANGED, updateWidget);
			// transform changed
			listenTo(_appState.selection, true);
		}
		
		private function removeEventListeners():void
		{
			// selection changed, redraw cursor path
			_appState.removeEventListener(KSelectionChangedEvent.EVENT_SELECTION_CHANGED, selectionChangedEventHandler);
			_appState.removeEventListener(KAppState.EVENT_HANDLE_CENTER_CHANGED, updateWidget);
			// transform changed
			listenTo(_appState.selection, false);
		}
		
		private function selectionChangedEventHandler(event:KSelectionChangedEvent):void
		{
			listenTo(event.oldSelection, false);
			listenTo(event.newSelection, true);
			updateWidget();
		}
		
		private function listenTo(selection:KSelection, listen:Boolean):void
		{
			if(selection == null)
				return;
			
			var list:IModelObjectList = selection.objects;
			if(list != null)
			{
				var it:IIterator = list.iterator;
				if(listen)
					while(it.hasNext())
						it.next().addEventListener(KObjectEvent.EVENT_TRANSFORM_CHANGED, updateWidget);
				else
					while(it.hasNext())
						it.next().removeEventListener(KObjectEvent.EVENT_TRANSFORM_CHANGED, updateWidget);
//				var length:int = list.length();
//				var i:int = 0;
//				if(listen)
//					for(;i<length;i++)
//						list.getObjectAt(i).addEventListener(KObjectEvent.EVENT_TRANSFORM_CHANGED, updateWidget);
//				else
//					for(;i<length;i++)
//						list.getObjectAt(i).removeEventListener(KObjectEvent.EVENT_TRANSFORM_CHANGED, updateWidget);
			}
		}
		
		private function updateWidget(event:Event = null):void
		{
			_widget.highlightSelection();
		}
		
	}
}