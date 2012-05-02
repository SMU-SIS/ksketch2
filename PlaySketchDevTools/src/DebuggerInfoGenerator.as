/**------------------------------------------------
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 
*-------------------------------------------------*/
import mx.collections.ArrayCollection;

import sg.edu.smu.ksketch.io.KFileWriter;
import sg.edu.smu.ksketch.model.KObject;
import sg.edu.smu.ksketch.model.implementations.KParentKeyframe;

private function _updateTabbedDisplay():void
{
	if(_activeTab)
		_activeTab.visible = false;
	
	idLabel.visible = false;
	
	if(!objectModelTree.selectedItem || objectModelTree.selectedItems.length > 1 || objectModelTree.selectedItem.name() == "root")
		return;
	else
	{
		idLabel.text = "Current Selected Object: "+objectModelTree.selectedItem.@id;
		_activeObject = _facade.getObjectByID(int(objectModelTree.selectedItem.@id));
	}
	
	if(!_activeObject)
		return;
	
	switch(viewSelectionTab.selectedItem)
	{
		case "Properties":
			propertiesTab.visible = true;
			_activeTab = propertiesTab;
			_generateTransformProperties(_activeObject);
			break;
		
		case "Geometry":
			geometryTab.visible = true;
			_activeTab = geometryTab;
			_generateGeometricProperties(_activeObject);
			break;
		
		case "Parent Keys":
			parentKeyTab.visible = true;
			_activeTab = parentKeyTab;
			_generateParentTimelineProperties(_activeObject);
			break;
		
		case "Transform Keys":
			transformKeysTab.visible = true;
			_activeTab = transformKeysTab;
			break;
		
		default:
			propertiesTab.visible = true;
			_activeTab = propertiesTab;
			viewSelectionTab.selectedItem = "Properties";
			_generateTransformProperties(_activeObject);
	}
	
	idLabel.visible = true;
}

private function _generateTransformProperties(object:KObject):void
{
	objectSlider.value = _appState.time;
	_setMatrixTexts(_appState.time);
}

private function _setMatrixTexts(time:Number):void
{
	fullMatrixText.text = _activeObject.getFullMatrix(time).toString();
	fullPathMatrixText.text = _activeObject.getFullPathMatrix(time).toString();
	if(_activeObject.getParentKey(time))
		positionMatrixText.text = (_activeObject.getParentKey(time) as KParentKeyframe).positionMatrix.toString();
	//positionMatrixText.text = _activeObject.toString();
	
	var parentID:int = _activeObject.getParent(time).id;
	currentParentIDText.text = parentID.toString();
}

private function _generateGeometricProperties(object:KObject):void
{
	
	if(object!=null)
	{ 
		var content:XML = KFileWriter.debugInfo(object);
		geometricProperties.text = content.toXMLString();
	}
	else
		geometricProperties.text = "";
}

private function _generateParentTimelineProperties(object:KObject):void
{
	var parentKeys:KParentKeyframe = object.getParentKey(object.createdTime) as KParentKeyframe;
	
	var parentData:ArrayCollection = new ArrayCollection();
	
	while(parentKeys)
	{
		var currentKey:Object = new Object();
		currentKey["Key Time"] = parentKeys.endTime;
		currentKey["Parent ID"] = parentKeys.parent.id;
		parentData.addItem(currentKey);
		parentKeys = parentKeys.next as KParentKeyframe;
	}
	
	parentKeyInfo.dataProvider = parentData;
}

private function _generateSpatialTimeLineProperties(object:KObject):void
{
	
}