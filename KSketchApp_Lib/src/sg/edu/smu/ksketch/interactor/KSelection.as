/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package sg.edu.smu.ksketch.interactor
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import sg.edu.smu.ksketch.geom.KGeomUtil;
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.utilities.IIterator;
	import sg.edu.smu.ksketch.utilities.IModelObjectList;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;

	public class KSelection
	{
		private var _objects:IModelObjectList;
		
		private var _selectedTime:Number;
		
//		private var _rawData:Dictionary;
		
		private var _interactionCenter:Point;
		private var _userSetHandleOffset:Point;
		private var _fullObjectSet:IModelObjectList;
		
		public function KSelection(selection:IModelObjectList, selectedTime:Number)
		{
			_fullObjectSet = selection;
			_objects = selection;
			_selectedTime = selectedTime;
			if(selection == null || selection.length() == 0)
				throw new Error("Selection cann't be null or empty!");
		}
		
		public function get selectedTime():int
		{
			return _selectedTime;
		}

		public function get objects():IModelObjectList
		{
			return _objects;
		}
		
		public function get fullObjectSet():IModelObjectList
		{
			return _fullObjectSet;	
		}
		
		public function set objects(value:IModelObjectList):void
		{
			_objects = value;
		}
		
		/**
		 * @return The center offset in object coordinate system.
		 */
		public function get userSetHandleOffset():Point
		{
			return _userSetHandleOffset;
		}
		
		/**
		 * @param value The new offset to be added to the existing center offset, 
		 * in object coordinate system.
		 */
		public function set userSetHandleOffset(value:Point):void
		{
			_userSetHandleOffset = value;
		}
		
		/**
		 * @param time KSK time
		 * @return The center of the selection. If no user set center exist, 
		 * this function will return the center of the keyframe at the given time.
		 */
		public function centerAt(time:Number):Point
		{
			if(_interactionCenter)
				return _interactionCenter;
			
			var c:Point;
			if(_objects.length() == 1)
			{
				var obj:KObject = _objects.getObjectAt(0);
				var rect:Rectangle = obj.getBoundingRect(time);
				var m:Matrix = obj.getFullPathMatrix(time);
				
				c = obj.handleCenter(time);
				c = m.transformPoint(c);					
				
				if(_userSetHandleOffset != null)
					c = c.add(_userSetHandleOffset);					
			}
			else
			{
				c = KGeomUtil.defaultCentroidOf(_objects, time);
				if(_userSetHandleOffset != null)
					c = c.add(_userSetHandleOffset);
			}
			return c;
		}

		public function get interactionCenter():Point
		{
			return _interactionCenter;
		}

		public function set interactionCenter(value:Point):void
		{
			_interactionCenter = value;
		}
		
		public function contains(obj:KObject):Boolean
		{
			var it:IIterator = _fullObjectSet.iterator;
			var currentObject:KObject;
			
			while(it.hasNext())
			{
				currentObject = it.next();
				if(currentObject.id == obj.id)
					return true;
				
				if(currentObject is KGroup)
					if((currentObject as KGroup).hasChild(obj, _selectedTime))
						return true;
			}
			
			return false;
		}
		
		public function tuneSelection(time:Number):void
		{
			var it:IIterator = _fullObjectSet.iterator;
			var currentObject:KObject;
			var visibleObjects:Vector.<KObject> = new Vector.<KObject>();
			
			while(it.hasNext())
			{
				currentObject = it.next();
				
				if(currentObject is KGroup)
				{
					var visibleChildParts:Vector.<KObject> = (currentObject as KGroup).partsVisible(time);
					if(visibleChildParts.length > 0)
						visibleObjects = visibleObjects.concat(visibleChildParts);
				}
				else
				{
					if(currentObject.getVisibility(time) > 0)
						visibleObjects.push(currentObject)
				}
			}
			
			var newList:KModelObjectList = new KModelObjectList();
			var fullList:Boolean = true;

			if(visibleObjects.length != _fullObjectSet.length())
				fullList = false;
			
			for(var i:int = 0; i<visibleObjects.length; i++)
			{
				currentObject = visibleObjects[i];
				if(!newList.contains(currentObject))
					newList.add(currentObject);	
			}

			if(fullList)
				_objects = _fullObjectSet;
			else
				_objects = newList;
		}
	}
}