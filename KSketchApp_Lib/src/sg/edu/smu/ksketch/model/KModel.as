/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.model
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import mx.utils.Base64Decoder;
	
	import sg.edu.smu.ksketch.event.KObjectEvent;
	import sg.edu.smu.ksketch.io.KFileReader;
	import sg.edu.smu.ksketch.io.KFileWriter;
	import sg.edu.smu.ksketch.utilities.IIterator;
	import sg.edu.smu.ksketch.utilities.IModelObjectList;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;
		
	/**
	 * KModel class models the hierarchical relationship (parent and child) using KGroup. 
	 */		
	public class KModel extends EventDispatcher implements IModelObjectList
	{
		private var _root:KGroup;
		private var _highestID:int;
		
		/**
		 * Constructor. Create a KGroup at the root, with empty object list, and center at Point(0,0).
		 */		
		public function KModel()
		{
			_root = new KGroup(0, 0, new KModelObjectList(), new Point(0, 0));
			_root.updateCenter();
			_highestID = 0;
		}

		/**
		 * Add the object (KObject) to the KGroup of the model at position specify by index. 
		 * Event of type KObjectEvent.EVENT_OBJECT_ADDED is dispatched after adding.
		 * @param object The KObject to be added to the KGroup.
		 * @param index The Index on the KGroup to be inserted.
		 */		
		public function add(object:KObject, index:int = -1):void
		{
			_root.add(object, index);
			_highestID = Math.max(_highestID,object.id);
			this.dispatchEvent(new KObjectEvent(object, KObjectEvent.EVENT_OBJECT_ADDED));
		}
		
		/**
		 * Remove the specify object (KObject) from the KGroup of the model. 
		 * Event of type KObjectEvent.EVENT_OBJECT_REMOVED is dispatched after removal.
		 * @param object The KObject to be removed from the KGroup.
		 */		
		public function remove(object:KObject):void
		{
			_root.remove(object);
			this.dispatchEvent(new KObjectEvent(object, KObjectEvent.EVENT_OBJECT_REMOVED));
		}
		
		/**
		 * Obtain the number of objects stored in the KGroup of the model. 
		 * @return The number of objects stored in the KGroup of the model.
		 */		
		public function length():int
		{
			return _root.length();
		}
		
		/**
		 * Obtain the object (KObject) stored in the KGroup of the model at the specify index. 
		 * @param index The specify index of the object in the KGroup.
		 * @return The KObject in the KGroup with the specify index.
		 */		
		public function getObjectAt(index:int):KObject
		{
			return _root.getObjectAt(index);
		}
		
		/**
		 * The iterator that can be used to access individual objects in the KGroup of the KModel.
		 */		
		public function get iterator():IIterator
		{
			return _root.iterator;
		}

		/**
		 * The root (KGroup) of the KModel.
		 */		
		public function get root():KGroup
		{
			return _root;
		}

		/**
		 * The next id that will be assigned to the KObject added to the group.
		 */		
		public function get nextID():int
		{
			return ++_highestID;
		}
		
		/**
		 * Reset the Model back to original state where it is first instantiated, 
		 * i.e. nextID = 1, empty object list in the KGroup.
		 */		
		public function resetModel():void
		{
			while(length() > 0)
				remove(this.getObjectAt(0));
			_highestID = 0;
		}

		/**
		 * Extract the object list (KModelObjectList) from the provided xml and add the extracted 
		 * object list to the KGroup of the model. Event of type KObjectEvent.EVENT_OBJECT_ADDED 
		 * is dispatched whenever a new object is added to the KGroup of the model.
		 * @param xml The XML storing the data of the list of objects.
		 */	
		public function addToModel(xml:XML):void
		{
			KFileReader.fileToKObjects(xml, _root);
			_highestID = _dispatchAdded(_root,new Dictionary());
		}
		
		/**
		 * Saved the group data into a XML structure.
		 * @return The XML storing the data of the objects in the KGroup of the model.
		 */		
		public function saveModel():XML
		{
			return KFileWriter.kObjectsToFile(_root);
		}
		
		/**
		 * Search the KObject in the group of the model with the same id as the specified object, 
		 * and then set the name of the found object with the specified name. 
		 * An Error is thrown if the KObject cannot be found in the group. 
		 * @param object The specify object to be used in the search.
		 * @param name The name to be set for the found object.
		 */		
		public function setObjectName(object:KObject, name:String):void
		{
			var obj:KObject = _searchByID(_root, object.id);
			if(obj == null)
				throw new Error("KObject with name \""+name+"\" doesn't exist in this model!");
			object.name = name;
		}
		
		/**
		 * Obtain the object in the KGroup of the model with the matching name. 
		 * @param name The specify Name to be used in the search.
		 * @return The KObject in the KGroup with the matching name.
		 */		
		public function getObjectByName(name:String):KObject
		{
			return _searchByName(_root, name);
		}
		
		/**
		 * Obtain the object in the KGroup of the model with the matching id. 
		 * @param id The specify ID to be used in the search.
		 * @return The KObject in the KGroup with the matching id.
		 */		
		public function getObjectByID(id:int):KObject
		{
			return _searchByID(_root, id);
		}
		
		// Traverse through the group and dispatch KObjectEvent.EVENT_OBJECT_ADDED at each KObject
		// that has not entry in the existing dictionary. Return the highest ID of all objects.
		private function _dispatchAdded(group:KGroup, existing:Dictionary):int
		{
			var highestID:int = int.MIN_VALUE;
			var it:IIterator = group.iterator;
			while(it.hasNext())
			{
				var obj:KObject = it.next();
				if(existing[obj] == null || existing[obj] == false)
				{
					existing[obj] = true;
					highestID = Math.max(highestID,obj.id);
					if (obj is KImage && (obj as KImage).data64 != null)
						_reloadImageData(obj as KImage);
					else
						this.dispatchEvent(new KObjectEvent(obj, KObjectEvent.EVENT_OBJECT_ADDED));
				}
				if(obj is KGroup)
					highestID = Math.max(highestID,_dispatchAdded(obj as KGroup, existing));
			}
			return highestID;
		}

		private function _reloadImageData(image:KImage):void
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE, 
				function (event:Event):void
				{
					image.imageData = event.target.content.bitmapData;
					_dispatchImageLoadedEvent(image);
				});
			var base64Dec:Base64Decoder = new Base64Decoder();
			base64Dec.decode(image.data64);
			loader.loadBytes(base64Dec.toByteArray());
		}
		
		private function _dispatchImageLoadedEvent(image:KImage):void
		{
			this.dispatchEvent(new KObjectEvent(image, KObjectEvent.EVENT_OBJECT_ADDED));
		}

		// Search the object in the model tree with the matching object name
		private function _searchByName(group:KGroup, objectName:String):KObject
		{
			var object:KObject;
			var it:IIterator = group.iterator;
			var tmp:KObject;
			while(it.hasNext())
			{
				tmp = it.next();
				if(tmp.name == objectName)
				{
					object = tmp;
					break;
				}
				else if(tmp is KGroup)
				{
					tmp = _searchByName(tmp as KGroup, objectName);
					if(tmp != null)
					{
						object = tmp;
						break;
					}
				}
			}
			return object;
		}
		
		// Search the object in the model tree with the matching object ID
		private function _searchByID(group:KGroup, ID:int):KObject
		{
			var object:KObject;
			var it:IIterator = group.iterator;
			var tmp:KObject;
			while(it.hasNext())
			{
				tmp = it.next();
				if(tmp.id == ID)
				{
					object = tmp;
					break;
				}
				else if(tmp is KGroup)
				{
					tmp = _searchByID(tmp as KGroup, ID);
					if(tmp != null)
					{
						object = tmp;
						break;
					}
				}
			}
			return object;
		}
		
		public function allChildren():IModelObjectList
		{
			var objectList:KModelObjectList = new KModelObjectList();
			
			var currentNode:KObject;
			var currentIterator:IIterator = _root.children.iterator;
			var stackedIterator:Vector.<IIterator> = new Vector.<IIterator>();
			
			while(currentIterator.hasNext())
			{
				currentNode = currentIterator.next();
				
				if(!objectList.contains(currentNode))
					objectList.add(currentNode);
				
				if(currentNode is KGroup)
				{
					stackedIterator.push(currentIterator);
					currentIterator = (currentNode as KGroup).children.iterator;
				}
				
				if(!currentIterator.hasNext())
				{
					if( 0 < stackedIterator.length)
					{
						currentIterator = stackedIterator.pop();
					}
				}
			}
			return objectList;
		}
	}
}