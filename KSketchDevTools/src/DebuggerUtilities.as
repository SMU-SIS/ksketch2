/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

import sg.edu.smu.ksketch.event.KGroupUngroupEvent;
import sg.edu.smu.ksketch.event.KObjectEvent;
import sg.edu.smu.ksketch.event.KSelectionChangedEvent;
import sg.edu.smu.ksketch.event.KTimeChangedEvent;
import sg.edu.smu.ksketch.interactor.KSelection;
import sg.edu.smu.ksketch.model.KGroup;
import sg.edu.smu.ksketch.model.KImage;
import sg.edu.smu.ksketch.model.KObject;
import sg.edu.smu.ksketch.model.KStroke;
import sg.edu.smu.ksketch.utilities.IIterator;

private function _treeLabelFunction(item:Object):String
{
	if((item as XML).name() == "root")
		return "Graphics on Canvas";
	else
		return "id:"+(item as XML).@id+", type:"+(item as XML).name()+", name:"+(item as XML).@name;
}

private function findObjectInXMLList(xml:XML, object:KObject):XML
{	
	var ID:int = object.id;
	var result:XML = null;
	if(object is KStroke)
		result = xml.stroke.(@id == ID)[0];
	else if(object is KImage)
		result = xml.image.(@id == ID)[0];
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

public function removeAllEventListeners():void
{
	_appState.debugSelection = null;
	
	_facade.removeEventListener(KObjectEvent.EVENT_OBJECT_ADDED, _refreshDebugger);
	_facade.removeEventListener(KObjectEvent.EVENT_OBJECT_REMOVED, _refreshDebugger);
	_facade.removeEventListener(KGroupUngroupEvent.EVENT_GROUP, _refreshDebugger);
	_facade.removeEventListener(KGroupUngroupEvent.EVENT_UNGROUP, _refreshDebugger);
	_appState.removeEventListener(KTimeChangedEvent.TIME_CHANGED, _refreshDebugger);
	
	_appState.removeEventListener(KSelectionChangedEvent.EVENT_SELECTION_CHANGED, selectionChangedEventHandler);
}

// Return the corresponding xml of a KObject. If the object is group, the return value sums up all 
// xmls of group's children.
private function objectToXML(object:KObject):XML
{
	var node:XML;
	if(object is KStroke)
		node = <stroke/>;
	else if(object is KImage)
		node = <image/>;
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
