/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.model.data_structures
{
	import mx.utils.StringUtil;
	
	import sg.edu.smu.ksketch2.model.objects.KGroup;
	import sg.edu.smu.ksketch2.model.objects.KImage;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.model.objects.KStroke;
	import sg.edu.smu.ksketch2.operators.KGroupingUtil;
	import sg.edu.smu.ksketch2.operators.operations.IModelOperation;
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;

	public class KSceneGraph
	{
		private var _highestID:int;
		
		private var _root:KGroup;
		
		
		/**
		 * The KSceneGraphClass manages all KObjects that lives in the model.
		 * Provides functions that identifies or clones KObjects.
		 */
		public function KSceneGraph()
		{
			_root = new KGroup(_highestID);
			_root.visibilityControl.setVisibility(true, 0, null);
			_highestID = 1;
		}
		
		/**
		 * Returns the root node of the scene graph
		 */
		public function get root():KGroup
		{
			return _root;
		}
		
		/**
		 * Maximum time that this scenegraph will reach
		 */
		public function get maxTime():int
		{
			var children:KModelObjectList = _root.children;
			var thisMax:int = 0;
			var thisLength:int = children.length();
			var i:int = 0;
			var currentChild:KObject;
			var childMax:int;
			
			for(i = 0; i < thisLength; i++)
			{
				currentChild = children.getObjectAt(i);
				
				if(currentChild)
				{
					childMax = currentChild.maxTime
					
					if(thisMax < childMax)
						thisMax = childMax;
				}
			}
			
			return thisMax;
		}
		
		/**
		 * Returns the ID of the highest object in the scene graph
		 */
		public function get nextHighestID():int
		{
			return _highestID;
		}
		
		/**
		 * Adds the object to the root of the scene graph
		 */
		public function registerObject(newObject:KObject, op:KCompositeOperation = null):void
		{
			_highestID++;
		
			var addOp:IModelOperation = KGroupingUtil.addObjectToParent(newObject, _root);
			
			if(op)
				op.addOperation(addOp);
		}
		
		public function serialize():XML
		{
			var sceneXML:XML = <scene/>;
			var objects:KModelObjectList = _root.getAllChildren();
			
			for(var i:int = 0; i<objects.length(); i++)
				sceneXML.appendChild(objects.getObjectAt(i).serialize());
			
			return sceneXML;
		}
		
		public function deserialize(xml:XML):void
		{
			var serializedObjects:XMLList = xml.children();
			var objects:Vector.<Object> = new Vector.<Object>();
			
			var currentSerial:XML;
			var objectInfo:Object;
			var deserializedObject:KObject;
			var i:int;
			for(i = 0; i<serializedObjects.length(); i++)
			{
				currentSerial = new XML(serializedObjects[i]);
				objectInfo = new Object();

				switch(StringUtil.trim(currentSerial.@type))
				{
					case "stroke":
						deserializedObject = KStroke.strokeFromXML(currentSerial);
						break;
					case "group":
						deserializedObject = KGroup.groupFromXML(currentSerial);
						break;
					case "image":
						deserializedObject = KImage.imageFromXML(currentSerial);
				}
				deserializedObject.deserialize(currentSerial);
				objectInfo.object = deserializedObject;
				objectInfo.parentID = int(currentSerial.parent.@id);
				registerObject(objectInfo.object);
				objects.push(objectInfo);
			}
			
			var j:int;
			var currentOtherObjectInfo:Object;

			for(i = 0; i<objects.length; i++)
			{
				objectInfo = objects[i];
				
				for(j = 0; j<objects.length; j++)
				{
					currentOtherObjectInfo = objects[j];

					if(objectInfo.parentID == currentOtherObjectInfo.object.id)
					{	
						(objectInfo.object as KObject).parent = currentOtherObjectInfo.object as KGroup;
					}
				}
			}
		}
		
		public function debug():void
		{
			_root.debug();
		}
	}
}