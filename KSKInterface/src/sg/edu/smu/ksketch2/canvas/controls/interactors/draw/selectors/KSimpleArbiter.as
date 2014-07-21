/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.canvas.controls.interactors.draw.selectors
{
	import flash.utils.Dictionary;
	
	import sg.edu.smu.ksketch2.canvas.controls.interactors.draw.selectors.KPortion;
	import sg.edu.smu.ksketch2.model.data_structures.KModelObjectList;
	import sg.edu.smu.ksketch2.model.objects.KGroup;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	
	/**
	 * The KSimpleArbiter class serves as the concrete class for simple
	 * selection arbitration in K-Sketch.
	 */
	public class KSimpleArbiter implements ISelectionArbiter
	{
		/**
		 * The minimum portion percentage of points threshold value.
		 */
		public static const THRESHOLD:Number = 0.6;
		
		/**
		 * The main constructor of the KSimpleArbiter class.
		 */
		public function KSimpleArbiter()
		{

		}
		
		public function bestGuess(rawData:Dictionary, time:Number, searchRoot:KGroup):KModelObjectList
		{
			// get the raw selection set
			var selectionSet:KModelObjectList = rawSelection(rawData, time, searchRoot);
			
			// reduce the raw selection set to a minimum selection set
			_reduceSelectionSet(selectionSet, searchRoot);
			
			//filter selected objects based on visibility here
			if(selectionSet)
				selectionSet = filterByVisibility(selectionSet, time, 0.2);
			
			// return the best guess of the selection set
			return selectionSet;
		}
		
		/**
		 * Gets the selection list of objects whose percentage of raw
		 * selected portions exceed the set threshold value.
		 * 
		 * @param rawData The target raw data.
		 * @param time The target time.
		 * @param searchRoot The target search root node.
		 */
		public function rawSelection(rawData:Dictionary, time:Number, searchRoot:KGroup):KModelObjectList
		{
			// initialize a new selection list of model objects
			var selection:KModelObjectList = new KModelObjectList();
			
			// recurse through the raw data from the search node for objects
			// with large enough selected portions to add to the given
			// selection list
			rawSelection_recurse(rawData, searchRoot, time, selection);

			// return the selection list of raw selections
			return selection;
		}
		
		/**
		 * Recurses through the raw data from the search node for objects
		 * with large enough percentage of selected portions to add to
		 * the given selection list.
		 * 
		 * @param rawData The target raw data.
		 * @param searchRoot The target search root node.
		 * @param time The target time.
		 * @param addTo The target selection list.
		 */
		private function rawSelection_recurse(rawData:Dictionary, searchRoot:KGroup, time:Number, addTo:KModelObjectList):void
		{
			var objects:KModelObjectList = searchRoot.children;		// the search root node's children
			var obj:KObject;										// the target object
			var portion:KPortion;									// the target portion

			// iterate through the search root node's children
			for(var i:int = 0; i < objects.length(); i++)
			{
				// get the current object
				obj = objects.getObjectAt(i);
	
				// case: the current object is a group
				// recurse through the object group
				if(obj is KGroup)
				{
					rawSelection_recurse(rawData, obj as KGroup, time, addTo);
				}
				// case: the current object is not a group
				// add objects to the 
				else
				{
					// look up the corresponding portion from the current object in the raw data
					portion = rawData[obj];

					// case: the portion exists and the portion of points exceeds the threshold
					// add the current object to the selection list
					if(portion != null && portion.portion > THRESHOLD)
						addTo.add(obj);
				}
			}
		}
		
		/**
		 * Reduces the given list of objects to the minimum set of objects
		 * (i.e., if a group is selected, all of its children will be
		 * removed).
		 * 
		 * @param list The list of model objects.
		 * @param The root node of the group.
		 */
		private function _reduceSelectionSet(list:KModelObjectList, root:KGroup):void
		{
			// brute force this since minimal set theory is NP-hard
			// no point finding a reliable more efficient method
			var parent:KGroup;
			var sublist:KModelObjectList;
			var obj:KObject;
			var allSelected:Boolean;
			var i:int = 0;
			var j:int = 0;
			for(i = 0; i < list.length(); i++)
			{
				// assume that all objects are at its's lowest level node for this function
				obj = list.getObjectAt(i);
				
				// only perform reduction if parent is not root
				if(obj.parent != root)
				{
					parent = obj.parent;
					sublist = parent.children;
					allSelected = true;
					for(j = 0; j < sublist.length(); j++)
					{
						if(!list.contains(sublist.getObjectAt(j)))
							allSelected = false;
					}
					
					if(allSelected)
					{
						if(!list.contains(parent))
						{
							list.add(parent);
							
							for(j = 0; j < sublist.length(); j++)
								list.remove(sublist.getObjectAt(j));
							
							i = 0;
						}
					}
				}
			}
		}
		
		/**
		 * When selecting, it should be possible to select things erased on the current
		 * frame, but if any of the selection contains unerased things,
		 * then the erased things should be removed from the selection.
		 */
		public function filterByVisibility(list:KModelObjectList, time:Number, alphaValue:Number):KModelObjectList
		{
			var i:int = 0;
			var object:KObject;
			var newList:KModelObjectList = new KModelObjectList();
			
			for(i = 0; i < list.length(); i++)
			{
				object = list.getObjectAt(i);
				
				var isErased:Boolean = true;
				if(object is KGroup)
				{
					isErased = checkEraseInGroup((object as KGroup), time, alphaValue);
						if(!isErased)
							newList.add(object);
				}
				else
				{
					if(object.visibilityControl.alpha(time) > alphaValue)
						newList.add(object);	
				}
			}
			
			if(newList.length() > 0 || alphaValue == 0)
				return newList
			else
				return list;
		}
		
		private function checkEraseInGroup(group:KGroup, time:Number, alphaValue:Number):Boolean
		{
			var isErased:Boolean = true;
			
			var children:KModelObjectList = group.children;
			for(var i:int=0; i<children.length(); i++)
			{
				var object:KObject = children.getObjectAt(i);
				
				if(object is KGroup)
				{
					isErased = checkEraseInGroup((object as KGroup), time, alphaValue);
					if(!isErased)
						return isErased;
				}
				else
				{
					if(object.visibilityControl.alpha(time) > alphaValue)
					{
						isErased = false;
						return isErased;
					}
				}
			}
			
			return isErased;
		}
		
		/**
		 * Checks whether the selected portions for all the group's children
		 * exceeds the set threshold value.
		 * 
		 * @param g The target group.
		 * @param time The target time.
		 * @param rawData The target raw data.
		 * @return Whether the selected portions for all the group's children exceeds the set threshold value.
		 */
		private function allSelected(g:KGroup, time:Number, rawData:Dictionary):Boolean
		{
			var allSelected:Boolean = true;					// initialize the all selected boolean flag to true
			var children:KModelObjectList = g.children;		// get the children from the given group
			
			// case: there is at most one child
			// return false
			if(children.length() <=1)
				return false;
			
			// iterate through each children
			var portion:KPortion;
			for(var i:int = 0; i < children.length(); i++)
			{
				// get the portion value of the corresponding children
				portion = rawData[children.getObjectAt(i)];
				
				// case: the portion either doesn't exist or doesn't exceed the threshold
				// set the all selected boolean flag to false
				if(portion == null || portion.portion <= THRESHOLD)
				{
					allSelected = false;
					break;
				}
			}
			
			// return the all selected boolean flag
			return allSelected;
		}
	}
}