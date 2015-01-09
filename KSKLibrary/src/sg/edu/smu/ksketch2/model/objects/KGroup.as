/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.model.objects
{
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch2.events.KGroupEvent;
	import sg.edu.smu.ksketch2.model.data_structures.IModelObjectList;
	import sg.edu.smu.ksketch2.model.data_structures.KModelObjectList;
	import sg.edu.smu.ksketch2.operators.KSingleReferenceFrameOperator;
	import sg.edu.smu.ksketch2.utils.iterators.IKObjectIterator;

	/**
	 * The KGroup class serves as the concrete class for representing
	 * group objects in the model in K-Sketch.
	 */
	public class KGroup extends KObject implements IModelObjectList
	{
		private var _children:KModelObjectList;		// the group's list of children
		private var _moveCenter:Boolean;
		
		/**
		 * The main constructor of the KGroup class.
		 * 
		 * @param id The group's ID.
		 */
		public function KGroup(id:int)
		{
			super(id);
			_children = new KModelObjectList();
			_center = new Point();
			_moveCenter = true;
			transformInterface = new KSingleReferenceFrameOperator(this);
		}
		
		/**
		 * Gets the list of objects containing the group's children.
		 * Warning: Modifying this list modifies the children themselves!
		 * 
		 * @return The list of objects containing the group's children.
		 */
		public function get children():KModelObjectList
		{
			return _children;
		}
		
		override public function get maxTime():Number
		{
			if(!transformInterface)
				return 0;
			
			var thisMax:Number = transformInterface.lastKeyTime;
			var thisLength:int = length();
			var i:int = 0;
			var currentChild:KObject;
			var childMax:int;

			for(i = 0; i < thisLength; i++)
			{
				currentChild = _children.getObjectAt(i);
				
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
		 * Gets all the non-group objects by adding all of the group's
		 * non-group children (i.e., all the way down to the leaves) and
		 * putting them into the given parameter vector allChildren
		 * Note: The result is not sorted.
		 * 
		 * @param allChildren The target input list for holding all the non-group objects.
		 * @return An unsorted output list holding all the non-group objects.
		 */
		public function getAllNonGroupObjects(allChildren:KModelObjectList = null):KModelObjectList
		{
			if(!allChildren)
				allChildren = new KModelObjectList();
			
			var currentObject:KObject;
			
			for(var i:int = 0; i < _children.length(); i++)
			{
				currentObject = _children.getObjectAt(i);
				
				if(currentObject is KGroup)
					(currentObject as KGroup).getAllNonGroupObjects(allChildren);
				else if(!allChildren.contains(currentObject))
					allChildren.add(currentObject);
			}
			
			return allChildren;
		}
		
		/**
		 * Gets a list of all the children in the group.
		 * 
		 * @param allChildren The previous list of all the children in the group.
		 * @return The current list of all the children in the group.
		 */
		public function getAllChildren(allChildren:KModelObjectList = null):KModelObjectList
		{
			if(!allChildren)
				allChildren = new KModelObjectList();
			
			var currentObject:KObject;
			
			for(var i:int = 0; i < _children.length(); i++)
			{
				
				currentObject = _children.getObjectAt(i);
				
				if(currentObject.id != 0)
					allChildren.add(currentObject);
				
				if(currentObject is KGroup)
					(currentObject as KGroup).getAllChildren(allChildren);
			}
			
			return allChildren;
		}
		
		public function add(object:KObject, index:int = -1):void
		{
			_children.add(object, index);
			
			//TRACE GROUP CENTROID
			trace("original center: x = " + center.x + ", y = " + center.y);
			//END OF TRACE
			
			updateCenter();
			dispatchEvent(new KGroupEvent(KGroupEvent.OBJECT_ADDED,this, object));
		}
		
		/**
		 * Checks whether the group contains the given object.
		 * 
		 * @param obj The target object.
		 * @return Whether the group contains the given object.
		 */
		public function contains(obj:KObject):Boolean
		{
			return _children.contains(obj);
		}
		
		public function containsGroup():Boolean
		{
			var contains:Boolean = false;
			
			for(var i:int=0; i<_children.length(); i++)
			{
				if(_children.getObjectAt(i) is KGroup)
				{
					contains = true;
					break;
				}
			}
			
			return contains;
		}
		
		public function remove(object:KObject):void
		{
			_children.remove(object);
			dispatchEvent(new KGroupEvent(KGroupEvent.OBJECT_REMOVED,this, object));
		}
		
		public function getObjectAt(index:int):KObject
		{
			return _children.getObjectAt(index);			
		}
		
		public function length():int
		{
			return _children.length();
		}

		public function toIDs():Vector.<int>
		{
			return _children.toIDs();
		}

		/**
		 * Returns an interator that gives the KObjects in this list, in order from beginning to end. 
		 */
		public function iterator():IKObjectIterator
		{
			return _children.iterator();
		}

		/**
		 * Updates the group's geometric center.
		 */
		public function updateCenter():void
		{
			_moveCenter = true;
			var minX:Number = Number.MAX_VALUE;
			var minY:Number = Number.MAX_VALUE;
			
			var maxX:Number = Number.MIN_VALUE;
			var maxY:Number = Number.MIN_VALUE;
			
			var point:Point;
			var length:int = length();
			
			for(var i:int = 0; i<length; i++)
			{
				point = _children.getObjectAt(i).center;
				if(!isNaN(_creationTime))
					point = _children.getObjectAt(i).transformMatrix(_creationTime).transformPoint(point);
				
				if(point.x < minX)
					minX = point.x;
				
				if(maxX < point.x)
					maxX = point.x;
				
				if(point.y < minY)
					minY = point.y;
				
				if(maxY < point.y)
					maxY = point.y;
			}
			
			_center = new Point();
			
			_center.x = (minX+maxX)/2;
			_center.y = (minY+maxY)/2;
			
			//TRACE GROUP CENTROID
			trace("new center: x = " + _center.x + ", y = " + _center.y);
			//exponential values for center
			if(_center.x < 0 || _center.y < 0 || _center.x > 2000 || _center.y > 2000)
			{
				trace("EXPONENTIAL VALUES FOR CENTER: x = " + _center.x + ", y = " + _center.y);
			}
			trace("==============================================================");
			//END OF TRACE
		}
		
		/**
		 * Gets the group's geometric center.
		 * 
		 * @return The group's geometric center.
		 */
		override public function get center():Point
		{	
			return _center.clone();
		}
		
		override public function set selected(value:Boolean):void
		{
			for(var i:int = 0; i< _children.length(); i++)
				_children.getObjectAt(i).selected = value;
			
			super.selected = value;
		}
		
		override public function debug(debugSpacing:String=""):void
		{
			super.debug(debugSpacing);
			debugSpacing = debugSpacing+"	";
			trace(debugSpacing+"Debugging object:", id, "has nChildren = ", _children.length());
			for(var i:int = 0; i<_children.length(); i++)
			{
				_children.getObjectAt(i).debug(debugSpacing);
			}
		}
		
		override public function serialize():XML
		{
			var objectXML:XML = super.serialize();
			objectXML.@type = "group";			
			return objectXML;
		}
		
		/**
		 * Deserializes the XML object to a group.
		 * 
		 * @param The target XML object.
		 * @return The deserialized group.
		 */
		public static function groupFromXML(xml:XML):KGroup
		{
			return new KGroup(xml.@id);	
		}
	}
}