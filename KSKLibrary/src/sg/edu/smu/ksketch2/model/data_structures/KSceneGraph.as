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

	/**
	 * The KSceneGraph class serves as the concrete class that defines the core
	 * implementations of scene graphs in K-Sketch. Specifically, the class
	 * manages all objects that live in the model by providing functions that
	 * identifies or clones those objects.
	 */
	public class KSceneGraph
	{
		private var _highestID:int;		// the ID of the scene graph's highest object
		private var _root:KGroup;		// the scene graph's root node
		
		/**
		 * The main constructor of the KSceneGraph class.
		 */
		public function KSceneGraph()
		{
			// initialize the scene graph's root node
			_root = new KGroup(_highestID);
			
			// set the scene graph's root node to visible at the initial time 0
			_root.visibilityControl.setVisibility(true, 0, null);
			
			// initialize the ID of the scene graph's highest object to 1
			_highestID = 1;
		}
		
		/**
		 * Gets the scene graph's root node.
		 * 
		 * @return The scene graph's root node.
		 */
		public function get root():KGroup
		{
			return _root;
		}
		
		/**
		 * Get the maximum time that the scene graph will reach. This value is
		 * obtained from the maximum value of all the children's maximum times.
		 * 
		 * @return The maximum time that the scene graph will reach.
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
		 * Gets the ID of the highest object in the scene graph.
		 * 
		 * @return The ID of the highest object in the scene graph.
		 */
		public function get nextHighestID():int
		{
			return _highestID;
		}
		
		/**
		 * Registers an object to the scene graph by adding the object
		 * to the root of the scene graph.
		 * 
		 * @param newObject The target object.
		 * @param op The corresponding composite operation.
		 */
		public function registerObject(newObject:KObject, op:KCompositeOperation = null):void
		{
			_highestID++;
		
			var addOp:IModelOperation = KGroupingUtil.addObjectToParent(newObject, _root);
			
			if(op)
				op.addOperation(addOp);
		}
		
		/**
		 * Serializes the scene graph to an XML object.
		 * 
		 * @return The serialized XML object of the scene graph.
		 */
		public function serialize():XML
		{
			var sceneXML:XML = <scene/>;
			var objects:KModelObjectList = _root.getAllChildren();
			
			for(var i:int = 0; i<objects.length(); i++)
				sceneXML.appendChild(objects.getObjectAt(i).serialize());
			
			return sceneXML;
		}
		
		/**
		 * Deserializes the XML object to a scene graph.
		 * 
		 * @param xml The target XML object.
		 */
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
		
		/**
		 * Debugs the scene graph object by outputting a string
		 * representation of the scene graph's root node.
		 */
		public function debug():void
		{
			_root.debug();
		}
	}
}