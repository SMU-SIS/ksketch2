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

	/**
	 * The KSelection class serves as the concrete class for handling
	 * selection in K-Sketch.
	 */
	public class KSelection
	{
		private var _visibleSelection:KModelObjectList;		// the visible selection
		private var _completeSelection:KModelObjectList;	// the complete selection
		
		/**
		 * The main constructor for the KSelection class.
		 * 
		 * @param selectedObjects The selected list of model objects.
		 */
		public function KSelection(selectedObjects:KModelObjectList)
		{
			_visibleSelection = selectedObjects;			// set the visible selection of model objects
			_completeSelection = selectedObjects.clone();	// set the complete selection of model objects
		}
		
		/**
		 * Gets the current set of visible objects at their highest order
		 * of composition. Groups that are partially visible will still be
		 * counted as fully visible, but then their their children objects
		 * should not be in the selection.
		 * 
		 * @return The current set of visible objects at their highest order of composition.
		 */
		public function get objects():KModelObjectList
		{
			return _visibleSelection;
		}
		
		/**
		 * Gets the complete selection of model objects.
		 * 
		 * @param The complete selection of model objects.
		 */
		public function get completeSelection():KModelObjectList
		{
			return _completeSelection;
		}
		
		/**
		 * Enables the selection boolean of all objects in the selection.
		 * The objects themselves will dispatch a selection changed event.
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
		 * Disables the selection boolean of all objects in the selection.
		 * The objects themselves will dispatch a selection changed event.
		 */
		public function triggerDeselected():void
		{
			var i:int = 0;
			var length:int = _completeSelection.length();

			for(i; i < length; i++)
				_completeSelection.getObjectAt(i).selected = false;
		}
		
		/**
		 * Gets the centroid for the selection at the given time.
		 * 
		 * @param time The target time.
		 * @return The centroid for the selection at the given time.
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
		
		/**
		 * Checks whether the selection is visible at the given time.
		 * 
		 * @param time The target time.
		 * @return Whether the selection is visible at the given time.
		 */
		public function isVisible(time:int):Boolean
		{
			return _visibleSelection.length() > 0;
		}
		
		/**
		 * Updates the selection composition.
		 * 
		 * @param time The target time.
		 */
		public function updateSelectionComposition(time:int):void
		{
			var i:int = 0;
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
		 * Checks whether the selection has an active selection
		 * transform time.
		 * 
		 * @param time The target time.
		 * @return Whether the selection has an active selection transform time.
		 */
		public function selectionTransformable(time:int):Boolean
		{
			if(objects.length() == 1)
				return _visibleSelection.getObjectAt(0).transformInterface.canInterpolate(time);
			else
				return false;
		}
		
		/**
		 * Checks whether the selection is different from another selection.
		 * 
		 * @param anotherSelection The other selection.
		 * @return Whether the two selections are different from each other.
		 */
		public function isDifferentFrom(anotherSelection:KSelection):Boolean
		{
			if(!anotherSelection)
				return true;
			
			return completeSelection.isDifferent(anotherSelection.completeSelection);
		}
		
		/**
		 * Outpus a debugging message to the console.
		 */
		public function debug():void
		{
			trace("visible selection:", objects);
			trace("Complete Selection:", completeSelection);
		}
	}
}