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
	
	import mx.collections.ArrayCollection;
	import mx.controls.Tree;
	import mx.core.ClassFactory;
	import mx.core.FlexGlobals;
	import mx.events.ListEvent;
	import mx.managers.PopUpManager;
	
	import sg.edu.smu.ksketch.event.KObjectEvent;
	import sg.edu.smu.ksketch.event.KSelectionChangedEvent;
	import sg.edu.smu.ksketch.event.KTimeChangedEvent;
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.model.KStroke;
	import sg.edu.smu.ksketch.io.KFileWriter;
	import sg.edu.smu.ksketch.operation.KModelFacade;
	import sg.edu.smu.ksketch.utilities.IIterator;
	import sg.edu.smu.ksketch.utilities.IModelObjectList;
	import sg.edu.smu.ksketch.utilities.KAppState;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;
	import sg.edu.smu.ksketch.interactor.KSelection;
	
	import spark.components.TabBar;
	import spark.components.TextArea;
	import spark.components.TitleWindow;
	import spark.events.IndexChangeEvent;
	
	public class DebugWindow extends TitleWindow
	{
		private var _facade:KModelFacade;
		private var _appState:KAppState;
		
		private var _tree:Tree;
		private var _tab:TabBar;
		private var _attributes:TextArea;
		
		[Bindable]
		private var _treeList:XML;
		
		[Bindable]
		private var _tabList:ArrayCollection;
		
		private var _shownObj:KObject;
		
		public function DebugWindow(facade:KModelFacade, appState:KAppState)
		{
			super();
			this.title = "Debug Info";
			_facade = facade;
			_appState = appState;
			
			_treeList = <root/>;
			
			_tree = new Tree();
			//			_tree.showRoot = false;
			_tree.allowMultipleSelection = true;
			_tree.dataProvider = _treeList;
			_tree.itemRenderer = new ClassFactory(sg.edu.smu.ksketch.components.DebugTreeRenderer);
			_tree.labelFunction = function(item:Object):String{
				if((item as XML).name() == "root")
					return "Graphics on Canvas";
				else
					return "id:"+(item as XML).@id+", type:"+(item as XML).name()+", name:"+(item as XML).@name;
			};
			_tree.addEventListener(ListEvent.CHANGE, treeChangedEventHandler);
			
			_tabList = new ArrayCollection();
			_tab = new TabBar();
			_tab.dataProvider = _tabList;
			_tab.labelFunction = function(item:Object):String{
				return "id="+(item as XML).@id;
			};
			_tab.addEventListener(IndexChangeEvent.CHANGE, tabChangedEventHandler);
			
			_attributes = new TextArea();
			
			this.addElement(_tree);
			this.addElement(_tab);
			this.addElement(_attributes);
			
			var i:IIterator = _facade.root.directChildIterator(_appState.time); // _model.iterator;
			while(i.hasNext())
				_treeList.appendChild(objectToXML(i.next()));
			highlightUserSelection(null, _appState.selection);
			_facade.addEventListener(KObjectEvent.EVENT_OBJECT_ADDED, refreshTree);
			_facade.addEventListener(KObjectEvent.EVENT_OBJECT_REMOVED, refreshTree);
			_appState.addEventListener(KTimeChangedEvent.TIME_CHANGED, refreshTree);
			
			_appState.addEventListener(KSelectionChangedEvent.EVENT_SELECTION_CHANGED, selectionChangedEventHandler, false, 1);
		}
		
		public function removeAllEventListeners():void
		{
			_appState.debugSelection = null;
			
			if(_shownObj != null)
				this.removeObjectEventListener(_shownObj);
			_facade.removeEventListener(KObjectEvent.EVENT_OBJECT_ADDED, refreshTree);
			_facade.removeEventListener(KObjectEvent.EVENT_OBJECT_REMOVED, refreshTree);
			_appState.removeEventListener(KTimeChangedEvent.TIME_CHANGED, refreshTree);
			
			_appState.removeEventListener(KSelectionChangedEvent.EVENT_SELECTION_CHANGED, selectionChangedEventHandler);
		}
		
		private function refreshTree(event:Event):void
		{
			_treeList = <root/>;
			_tree.dataProvider = _treeList;
			var it:IIterator = _facade.root.directChildIterator(_appState.time);
			while(it.hasNext())
				_treeList.appendChild(objectToXML(it.next()));
			highlightUserSelection(null, _appState.selection);
		}
		
		private function selectionChangedEventHandler(event:KSelectionChangedEvent):void
		{
			highlightUserSelection(event.oldSelection, event.newSelection);
		}
		
		private function objectUpdatedEventHandler(event:KObjectEvent):void
		{
			setAttributes(event.object);
		}
		
		private function tabChangedEventHandler(event:IndexChangeEvent):void
		{
			var item:XML = (event.target as TabBar).selectedItem as XML;
			var id:int = item.@id;
			var obj:KObject = _facade.getObjectByID(id);
			if(obj == null)
				throw new Error("object with id="+id+"doesn't exist in model!");
			setNewSelected(obj); // show the latest selection
		}
		
		private function treeChangedEventHandler(event:Event):void
		{
			var items:Array = (event.target as Tree).selectedItems;
			var objects:KModelObjectList = new KModelObjectList();
			
			var obj:KObject;
			var id:int;
			var item:XML;
			
			_tabList.removeAll();
			
			for(var i:int=items.length-1;i>=0;i--)
			{
				item = items[i] as XML;
				if(item.name() == "root")
					break;
				id = parseInt(item.@id);
				obj = _facade.getObjectByID(id);
				if(obj == null)
					throw new Error("object with id="+id+"doesn't exist in model!");
				objects.add(obj);
				
				_tabList.addItem(item);
			}
			
			// set ksketchapp selection
			_appState.debugSelection = objects;
			
			_tab.selectedIndex = _tabList.length-1;
			setNewSelected(obj); // show the latest selection
		}
		
		// helper methods
		
		private function highlightUserSelection(oldSelection:KSelection, newSelection:KSelection):void
		{
			var xml:XML;
			var object:KObject;
			
			var it:IIterator;
			if(oldSelection != null)
			{
				it = oldSelection.objects.iterator;
				while(it.hasNext())
				{
					object = it.next();
					xml = findObjectInXMLList(_treeList, object);
					if(xml != null) // may be null if selection changed is result of ungroup operation
						xml.@selected = "false";
				}
			}
			
			if(newSelection != null)
			{
				it = newSelection.objects.iterator;
				while(it.hasNext())
				{
					object = it.next();
					xml = findObjectInXMLList(_treeList, object);
					if(xml != null)
						xml.@selected = "true";
				}
			}
		}
		private function findObjectInXMLList(xml:XML, object:KObject):XML
		{
			var ID:int = object.id;
			var result:XML = null;
			if(object is KStroke)
				result = xml.stroke.(@id == ID)[0];
			else if(object is KGroup)
				result = xml.g.(@id == ID)[0];
			else
				throw new Error("unsupported kobject!");
			
			if(result == null)
			{
				var subList:XMLList = xml.g;
				for each(var g:XML in subList)
				{
					result = findObjectInXMLList(g, object);
					if(result != null)
						break;
				}
			}
			return result;
		}
		
		// Return the corresponding xml of a KObject. If the object is group, the return value sums up all 
		// xmls of group's children.
		private function objectToXML(object:KObject):XML
		{
			var node:XML;
			if(object is KStroke)
				node = <stroke/>;
			else if(object is KGroup)
			{
				var group:KGroup = object as KGroup;
				node = <g/>;
				var it:IIterator = group.directChildIterator(_appState.time);
				while(it.hasNext())
					node.appendChild(objectToXML(it.next()));
			}
			else
				throw new Error("unsupported kobject!");
			
			node.@["id"] = object.id;
			node.@["name"] = object.name;
			node.@["selected"] = "false";
			return node;
		}
		
		private function setNewSelected(newSelected:KObject):void
		{
			if(_shownObj != null)
				removeObjectEventListener(_shownObj);
			
			_shownObj = newSelected;
			
			if(_shownObj != null)
				addObjectEventListener(_shownObj);
			
			setAttributes(_shownObj);
		}
		
		private function setAttributes(object:KObject):void
		{
			if(object!=null)
			{
				var content:XML = KFileWriter.debugInfo(object);
				_attributes.text = content.toXMLString();
			}
			else
				_attributes.text = "";
		}
		
		// Add listeners to a KObject.
		private function addObjectEventListener(object:KObject):void
		{
			object.addEventListener(KObjectEvent.EVENT_TRANSFORM_CHANGED, objectUpdatedEventHandler);
			object.addEventListener(KObjectEvent.EVENT_OBJECT_CENTER_CHANGED, objectUpdatedEventHandler);
			object.addEventListener(KObjectEvent.EVENT_VISIBILITY_CHANGED, objectUpdatedEventHandler);
			object.addEventListener(KObjectEvent.EVENT_POINTS_CHANGED, objectUpdatedEventHandler);
		}
		
		// Remove listeners from a KObject.
		private function removeObjectEventListener(object:KObject):void
		{
			object.removeEventListener(KObjectEvent.EVENT_TRANSFORM_CHANGED, objectUpdatedEventHandler);
			object.removeEventListener(KObjectEvent.EVENT_OBJECT_CENTER_CHANGED, objectUpdatedEventHandler);
			object.removeEventListener(KObjectEvent.EVENT_VISIBILITY_CHANGED, objectUpdatedEventHandler);
			object.removeEventListener(KObjectEvent.EVENT_POINTS_CHANGED, objectUpdatedEventHandler);
		}
		
		public function setPosition(y:Number):void
		{ 
			this.x = FlexGlobals.topLevelApplication.width - 400;
			this.y = y;
			this.width = 400;
			this.height = FlexGlobals.topLevelApplication.height - y;
			
			_tree.width = 400;
			_tree.height = 300;
			_tree.y = 0;
			
			_tab.width = 400;
			_tab.height = 35;
			_tab.y = _tree.y + _tree.height;
			
			_attributes.width = 400;
			_attributes.height = this.height - _tab.y - _tab.height - 60//450;
			_attributes.y = _tab.y + _tab.height;//300;
		}
		
		public function get tree():Tree
		{
			return _tree;
		}
		
		public function get attributes():TextArea
		{
			return _attributes;
		}
		
		public function get tab():TabBar
		{
			return _tab;
		}
		
		public function get treeList():XML
		{
			return _treeList;
		}
	}
}