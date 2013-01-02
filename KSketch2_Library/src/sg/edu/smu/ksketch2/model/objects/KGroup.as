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
	import sg.edu.smu.ksketch2.events.KObjectEvent;
	import sg.edu.smu.ksketch2.model.data_structures.IModelObjectList;
	import sg.edu.smu.ksketch2.model.data_structures.KModelObjectList;
	import sg.edu.smu.ksketch2.operators.KSingleReferenceFrameOperator;

	public class KGroup extends KObject implements IModelObjectList
	{
		private var _children:KModelObjectList;
		
		public function KGroup(id:int)
		{
			super(id);
			_children = new KModelObjectList();
			_center = new Point();
			transformInterface = new KSingleReferenceFrameOperator(this);
		}
		
		/**
		 * Returns the KModelObjectList containing this KGroup's Children
		 * Warning: Modifying this list modifies the children themselves!
		 */
		public function get children():KModelObjectList
		{
			return _children;
		}
		
		/**
		 * Adds all of the group's children (all the way down to the leaves) into the given vector allChildren
		 * the result is not sorted
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
			updateCenter();
			dispatchEvent(new KGroupEvent(KGroupEvent.OBJECT_ADDED,this, object));
		}
		
		/**
		 * Checks if this IModelObjectList contains the given object
		 */
		public function contains(obj:KObject):Boolean
		{
			return _children.contains(obj);
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
		
		public function updateCenter():void
		{
			var minX:Number = Number.MAX_VALUE;
			var minY:Number = Number.MAX_VALUE;
			
			var maxX:Number = Number.MIN_VALUE;
			var maxY:Number = Number.MIN_VALUE;
			
			var point:Point;
			var length:int = length();
			
			for(var i:int = 0; i<length; i++)
			{
				point = _children.getObjectAt(i).centroid;
				point = _children.getObjectAt(i).fullPathMatrix(_creationTime).transformPoint(point);
				
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
		}
		
		override public function get centroid():Point
		{			
			if(!_center)
				updateCenter();

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
		
		public static function groupFromXML(xml:XML):KGroup
		{
			return new KGroup(xml.@id);	
		}
	}
}