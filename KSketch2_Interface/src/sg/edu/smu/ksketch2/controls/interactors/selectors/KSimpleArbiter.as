/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.controls.interactors.selectors
{
	import flash.utils.Dictionary;
	
	import sg.edu.smu.ksketch2.controls.interactors.selectors.KPortion;
	import sg.edu.smu.ksketch2.model.data_structures.KModelObjectList;
	import sg.edu.smu.ksketch2.model.objects.KGroup;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	
	public class KSimpleArbiter implements ISelectionArbiter
	{
		public static const THRESHOLD:Number = 0.6;
		
		protected var _root:KGroup;
		
		public function KSimpleArbiter(root:KGroup)
		{
			_root = root;
		}
		
		public function bestGuess(rawData:Dictionary, time:Number):KModelObjectList
		{
			return rawSelection(rawData, time);
		}
		
		public function rawSelection(rawData:Dictionary, time:Number):KModelObjectList
		{
			var selection:KModelObjectList = new KModelObjectList();
			
			rawSelection_recurse(rawData, _root, time, selection);
			
			
			return selection;
		}
		
		private function rawSelection_recurse(rawData:Dictionary, root:KGroup, time:Number, addTo:KModelObjectList):void
		{
			var objects:KModelObjectList = root.children;
			var obj:KObject;
			var portion:KPortion;
			
			for(var i:int = 0; i < objects.length(); i++)
			{
				obj = objects.getObjectAt(i);
				if(obj is KGroup)
				{
					if(allSelected(obj as KGroup, time, rawData))
					{
						addTo.add(obj);
					}
					else
						rawSelection_recurse(rawData, obj as KGroup, time, addTo);
				}
				else
				{
					portion = rawData[obj];
					if(portion != null && portion.portion > THRESHOLD)
						addTo.add(obj);
				}
			}
		}
		
		private function allSelected(g:KGroup, time:Number, rawData:Dictionary):Boolean
		{
			var allSelected:Boolean = true;
			var children:KModelObjectList = g.children;
			
			if(children.length() <=1)
				return false;
			
			var portion:KPortion;
			for(var i:int = 0; i < children.length(); i++)
			{
				portion = rawData[children.getObjectAt(i)];
				if(portion == null || portion.portion <= THRESHOLD)
				{
					allSelected = false;
					break;
				}
			}
			return allSelected;
		}
		
		//Function to select strokes only
		public function selectStrokes(rawData:Dictionary, time:Number, selection:KModelObjectList = null):KModelObjectList
		{
			
			if(!selection)
				selection = new KModelObjectList();
			
			var objects:KModelObjectList = _root.children;
			var obj:KObject;
			var portion:KPortion;

			//Iterate throught every child
			for(var i:int = 0; i < objects.length(); i++)
			{
				obj = objects.getObjectAt(i);
				
				if(obj is KGroup)
					rawSelection_recurse(rawData, obj as KGroup, time, selection);
				else
				{
					portion = rawData[obj];
					if(portion != null && portion.portion > THRESHOLD)
						selection.add(obj);
				}
			}
			
			return selection;
		}
		
		//Function to select top level nodes
		public function selectTopGroups(rawData:Dictionary, time:Number):KModelObjectList
		{
			var selection:KModelObjectList = new KModelObjectList();
			
			var objects:KModelObjectList = _root.children;
			var obj:KObject;
			var portion:KPortion;
			
			//Iterate throught every child
			for(var i:int = 0; i < objects.length(); i++)
			{
				obj = objects.getObjectAt(i);
				
				//Determine if the object's parent is the root
				if(obj.parent == _root)
				{	
					//if the object is a kgroup, make sure all of its child nodes have been selected before adding to selection
					if(obj is KGroup)
					{
						if(allSelected(obj as KGroup, time, rawData))
							selection.add(obj);
					}
					else
					{
						//if is single kobject, check if the loop encloses it enough before adding it to the selection	
						portion = rawData[obj];
						if(portion != null && portion.portion > THRESHOLD)
							selection.add(obj);
					}
				}
			}
			
			return selection;
		}
		
	}
}