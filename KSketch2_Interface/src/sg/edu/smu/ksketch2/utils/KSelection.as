/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.utils
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch2.model.data_structures.KModelObjectList;

	public class KSelection
	{
		private var _objects:KModelObjectList;
		
		public function KSelection(selectedObjects:KModelObjectList)
		{
			_objects = selectedObjects;
		}
		
		/**
		 * Returns the KModelObjectList of objcets for this selection
		 */
		public function get objects():KModelObjectList
		{
			return _objects;
		}
		
		/**
		 * Sets the selection boolean of all objects in this selection
		 * to be true. The objects themselves will dispatch a selection changed event
		 */
		public function triggerSelected():void
		{
			var i:int = 0;
			var length:int = objects.length();
			
			for(i; i < length; i++)
			{
				_objects.getObjectAt(i).selected = true;
			}
		}
		
		/**
		 * Sets the selection boolean of all objects in this selection
		 * to be false. The objects themselves will dispatch a selection changed event
		 */
		public function triggerDeselected():void
		{
			var i:int = 0;
			var length:int = objects.length();
			
			for(i; i < length; i++)
			{
				_objects.getObjectAt(i).selected = false;
			}
		}
		
		/**
		 * Returns the centroid for this selection at time
		 */
		public function centerAt(time:int):Point
		{
			var nVisible:int = numVisibleObjects(time);
			
			if(nVisible == 0)
				return new Point();
			
			var i:int = 0;
			var length:int = objects.length();
			var centroid:Point = new Point();
			var objectCentroid:Point;
			var matrix:Matrix;
			var objectsComputed:int = 0;

			for(i; i<length; i++)
			{
				if(0 < objects.getObjectAt(i).visibilityControl.alpha(time))
				{
					matrix = objects.getObjectAt(i).fullPathMatrix(time);
					objectCentroid = matrix.transformPoint(objects.getObjectAt(i).centroid);
					
					centroid.x += objectCentroid.x;
					centroid.y += objectCentroid.y;
					objectsComputed ++;
				}
			}
			
			if(objectsComputed != 0)
			{
				centroid.x = centroid.x/objectsComputed;
				centroid.y = centroid.y/objectsComputed;
			}
			
			return centroid;
		}
		
		public function isVisible(time:int):Boolean
		{
			return numVisibleObjects(time) > 0;
		}
		
		public function numVisibleObjects(time:int):int
		{
			var nVisible:int = 0;
			
			for(var i:int = 0; i<length; i++)
			{
				if(0 < objects.getObjectAt(i).visibilityControl.alpha(time))
					nVisible++;
			}
			
			return nVisible;
		}
		
		/**
		 * Determines whether the selection has an active transform time
		 */
		public function selectionTransformable(time:int):Boolean
		{
			if(objects.length() == 1)
				return objects.getObjectAt(0).transformInterface.canInterpolate(time);
			else
				return false;
		}
		
		public function isDifferentFrom(anotherSelection:KSelection):Boolean
		{
			if(!anotherSelection)
				return true;
			
			return _objects.isDifferent(anotherSelection.objects);
		}
		
		public function debug():void
		{
			trace(_objects);
		}
	}
}