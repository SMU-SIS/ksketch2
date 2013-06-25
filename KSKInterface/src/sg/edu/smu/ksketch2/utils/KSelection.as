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
	import sg.edu.smu.ksketch2.model.objects.KObject;

	public class KSelection
	{
		private var _visibleSelection:KModelObjectList;
		private var _completeSelection:KModelObjectList;
		
		public function KSelection(selectedObjects:KModelObjectList)
		{
			_visibleSelection = selectedObjects;
			_completeSelection = selectedObjects.clone();
		}
		
		/**
		 * Returns the current set of visible objects at their highest order of composition
		 * Groups that are partially visible will still be counted as fully visible (their children objects should not be in the selection)
		 * 
		 */
		public function get objects():KModelObjectList
		{
			return _visibleSelection;
		}
		
		/**
		 * Returns the entire set of objects
		 */
		public function get completeSelection():KModelObjectList
		{
			return _completeSelection;
		}
		
		/**
		 * Sets the selection boolean of all objects in this selection
		 * to be true. The objects themselves will dispatch a selection changed event
		 */
		public function triggerSelected():void
		{
			var i:int = 0;
			var length:int = _completeSelection.length();
			
			for(i; i < length; i++)
			{
				_completeSelection.getObjectAt(i).selected = true;
			}
		}
		
		/**
		 * Sets the selection boolean of all objects in this selection
		 * to be false. The objects themselves will dispatch a selection changed event
		 */
		public function triggerDeselected():void
		{
			var i:int = 0;
			var length:int = _completeSelection.length();

			for(i; i < length; i++)
				_completeSelection.getObjectAt(i).selected = false;
		}
		
		/**
		 * Returns the centroid for this selection at time
		 */
		public function centerAt(time:int):Point
		{
			if(!_visibleSelection)
				return null;
			
			if(_visibleSelection.length() == 0)
				return null;
			
			var i:int = 0;
			var length:int = _visibleSelection.length();
			var centroid:Point = new Point();
			var objectCentroid:Point;
			var matrix:Matrix;
			var currentObject:KObject;
			
			for(i; i<length; i++)
			{
				currentObject = _visibleSelection.getObjectAt(i);
				matrix = currentObject.fullPathMatrix(time);
				objectCentroid = matrix.transformPoint(currentObject.center);
				
				centroid.x += objectCentroid.x;
				centroid.y += objectCentroid.y;
			}
			
			centroid.x = centroid.x/length;
			centroid.y = centroid.y/length;
			
			return centroid;
		}
		
		public function isVisible(time:int):Boolean
		{
			return _visibleSelection.length() > 0;
		}
		
		public function updateSelectionComposition(time:int):void
		{
			var i:int =0 ;
			var length:int = _completeSelection.length();
			var currentObject:KObject;
			var visibleList:KModelObjectList = new KModelObjectList;
			
			for(i; i < length; i++)
			{
				currentObject = _completeSelection.getObjectAt(i);
				
				if(0 < currentObject.visibilityControl.alpha(time))
					visibleList.add(currentObject);
			}
			
			_visibleSelection = visibleList;
		}
		
		/**
		 * Determines whether the selection has an active transform time
		 */
		public function selectionTransformable(time:int):Boolean
		{
			if(objects.length() == 1)
				return _visibleSelection.getObjectAt(0).transformInterface.canInterpolate(time);
			else
				return false;
		}
		
		public function isDifferentFrom(anotherSelection:KSelection):Boolean
		{
			if(!anotherSelection)
				return true;
			
			return completeSelection.isDifferent(anotherSelection.completeSelection);
		}
		
		public function debug():void
		{
			trace("visible selection:", objects);
			trace("Complete Selection:", completeSelection);
		}
	}
}