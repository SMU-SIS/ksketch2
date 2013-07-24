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
	import sg.edu.smu.ksketch2.model.objects.KStroke;
	
	/**
	 * The KIntelligentArbiter class serves as the concrete class for
	 * intelligent selection arbitration in K-Sketch.
	 */
	public class KIntelligentArbiter extends KSimpleArbiter
	{
		private var _leafPortion:Dictionary;					// the leaf portion
		
		private var _groupPortion:Dictionary;					// the group portion
		private var _rawSelection:KModelObjectList;				// the raw selection
		private var _s:Vector.<KGroup>;							// the selection list
		
		private var _candidates:Vector.<KModelObjectList>;		// the list of candidates
		private var _index:int;									// the list index
		
		/**
		 * The main constructor of the KIntelligentArbiter class.
		 */
		public function KIntelligentArbiter()
		{

		}
		
		public override function bestGuess(rawData:Dictionary, time:Number, searchRoot:KGroup):KModelObjectList
		{
			prepareOn(rawData, time, searchRoot);
			
			if(_rawSelection.length() == 0)
				return null;
			// skip if same as _g or _rawSelection
			_index = 0;
			return _candidates[_index];
		}
		
		/**
		 * Gets the next list of candidates in the cycle.
		 * 
		 * @param rawData The target raw data.
		 * @param time The target time.
		 * @param searchRoot The target search root node.
		 * @return The next list of candidates in the cycle.
		 */
		public function cycleNext(rawData:Dictionary, time:Number, searchRoot:KGroup):KModelObjectList
		{
			// case: there is no leaf portion
			// prepare a leaf portion
			if(_leafPortion == null)
				prepareOn(rawData, time, searchRoot);
			
			// case: the raw selection list is empty
			// return a null list
			if(_rawSelection.length() == 0)
				return null;
			
			// skip if same as _g or _rawSelection
			_index ++;
			_index %= _candidates.length;
			
			// return the next list of candidates
			return _candidates[_index];
		}
		
		/**
		 * Gets the previous list of candidates in the cycle.
		 * 
		 * @param rawData The target raw data.
		 * @param time The target time.
		 * @param searchRoot The target search root node.
		 * @return The previous list of candidates in the cycle.
		 */
		public function cyclePrevious(rawData:Dictionary, time:Number, searchRoot:KGroup):KModelObjectList
		{
			// case: there is no leaf portion
			// prepare a leaf portion
			if(_leafPortion == null)
				prepareOn(rawData, time,searchRoot);
			
			// case: the raw selection list is empty
			// return a null list
			if(_rawSelection.length() == 0)
				return null;
			
			// skip if same as _g or _rawSelection
			_index --;
			if(_index < 0)
				_index = _candidates.length - 1;
			
			return _candidates[_index];
		}
		
		/**
		 * Clears the settings of the intelligent arbiter.
		 */
		public function clear():void
		{
			_rawSelection = null;
			_leafPortion = null;
			_s = null;
			_candidates = null;
			_index = -1;
		}
		
		private function allSelected(g:KGroup, time:Number, rawData:Dictionary):Boolean
		{
			var allSelected:Boolean = true;
			var objects:KModelObjectList = g.children;
			var portion:KPortion;
			
			if(objects.length() <=1)
				return false;
			
			for(var i:int = 0; i < objects.length(); i++)
			{
				portion = rawData[objects.getObjectAt(i)];
				if(portion == null || portion.portion <= THRESHOLD)
				{
					allSelected = false;
					break;
				}
			}
			return allSelected;
		}
		
		private function prepareOn(rawData:Dictionary, time:Number, searchRoot:KGroup):void
		{
			_rawSelection = rawSelection(rawData, time, searchRoot);
			
			if(_rawSelection.length() == 0)
				return;
			
			_leafPortion = rawData;
			_s = new Vector.<KGroup>();
			_groupPortion = new Dictionary();
			findSelectedNodes(searchRoot, _s, time, _leafPortion, _groupPortion);
			
			_candidates = combination(_s, time);
			_candidates.sort(sort);
			if(_candidates.length == 0)
				_candidates.push(_rawSelection);
			else
			{
				if(allAreKGroup(_rawSelection, time) && rankOf(_rawSelection) > rankOf(_candidates[0]))
					_candidates.splice(0, 0, _rawSelection);
				else
					_candidates.splice(1, 0, _rawSelection);
			}
			_index = -1;
		}
		
		private function allAreKGroup(list:KModelObjectList, time:Number):Boolean
		{
			for(var i:int = 0; i < list.length(); i++)
				if(!(list.getObjectAt(i) is KGroup))
					return false;
			return true;
		}
		
		private function findSelectedNodes(p:KGroup, s:Vector.<KGroup>, time:Number, rawData:Dictionary, groupPortion:Dictionary):void
		{
			var objects:KModelObjectList = p.children;
			var obj:KObject;
			var portion:KPortion;
			for(var i:int = 0; i < objects.length(); i++)
			{
				obj = objects.getObjectAt(i);
				if(obj is KGroup)
				{
					portion = percentOfGroup(obj as KGroup, time, rawData);
					var percent:Number = portion.portion;
					if(percent > THRESHOLD)
					{
						if((obj as KGroup).children.length() <=1)
							return;
						
						s.push(obj as KGroup);
						groupPortion[obj] = portion;
					}

					if(percent > 0 && !allSelected(obj as KGroup, time, rawData))
						findSelectedNodes(obj as KGroup, s, time, rawData, groupPortion);
				}
			}
		}
		
		private function percentOfGroup(group:KGroup, time:Number, rawData:Dictionary):KPortion
		{
			var portion:KPortion;
			var objects:KModelObjectList = group.children;
			var selected:uint = 0;
			var total:uint = 0;
			var obj:KObject;
			for(var i:int = 0; i < objects.length(); i++)
			{
				obj = objects.getObjectAt(i);
				portion = rawData[obj];
				if(portion != null)
				{
					total += portion.total;
					selected += portion.selected;
				}
				else if(obj is KStroke)
					total += (obj as KStroke).points.length;
				else
					throw new Error("Case Unhandled: computing selected percentage on " + obj);
			}
			return new KPortion(total, selected);
		}
		
		private function combination(s:Vector.<KGroup>, time:Number):Vector.<KModelObjectList>
		{
			var candidates:Vector.<KModelObjectList> = new Vector.<KModelObjectList>();
			var combineID:uint = 1;
			var bits:uint = s.length;
			var total:uint = Math.pow(2, bits) - 1;
			var selection:KModelObjectList;
			var bitChecker:uint = 0;
			var count:int;
			var groupSelected:Dictionary;
			var group:KGroup;
			for(;combineID<=total;combineID++)
			{
				selection = new KModelObjectList();
				groupSelected = new Dictionary();
				count = 0;
				bitChecker = 1;
				for(;count < bits;count++)
				{
					if((combineID & bitChecker) != 0)
					{
						group = s[count];
						if(canAdd(group, time, groupSelected))
						{
							selection.add(group);
							groupSelected[group] = true;
						}
						else
						{
							selection = null;
							break;
						}
					}
					bitChecker = uint(bitChecker<<1);
				}
				if(selection != null && !duplicated(selection, _rawSelection) && rankOf(selection) > THRESHOLD)
					candidates.push(selection);
			}
			return candidates;
		}
		
		private function duplicated(selection1:KModelObjectList, selection2:KModelObjectList):Boolean
		{
			if(selection1.length() != selection2.length())
				return false;
			
			var duplicatedList:Boolean = true;
			
			for(var i:int = 0; i<selection1.length(); i++)
			{
				if(!selection2.contains(selection1.getObjectAt(i)))
					duplicatedList = false;
			}
			
			return duplicatedList;
		}
		
		private function canAdd(group:KGroup, time:Number, groupSelected:Dictionary):Boolean
		{
			var parent:KGroup = group.parent;
			while(parent != null)
			{
				if(groupSelected[parent] == true)
					return false;
				parent = parent.parent;
			}
			return true;
		}
		
		private function sort(a:KModelObjectList, b:KModelObjectList):Number
		{
//			Given the elements A and B, the result of compareFunction can have a negative, 0, or positive value: 
//				A negative return value specifies that A appears before B in the sorted sequence. 
//				A return value of 0 specifies that A and B have the same sort order. 
//				A positive return value specifies that A appears after B in the sorted sequence. 
			var scoreA:Number = rankOf(a);
			var scoreB:Number = rankOf(b);
			if(scoreA == scoreB)
				return 0;
			return scoreA>scoreB?-1:1;
		}
		
		private function rankOf(list:KModelObjectList):Number
		{
			var selected:uint = 0;
			var total:uint = 0;
			var obj:KObject;
			var portion:KPortion;
			for(var i:int = 0; i<list.length(); i++)
			{
				obj = list.getObjectAt(i);
				if(obj is KGroup)
					portion = _groupPortion[obj];
				else
					portion = _leafPortion[obj];
				selected += portion.selected;
				total += portion.total;
			}
			var percentSelected:Number = selected / total;
			
			total = 0;
			for each(var leafP:Object in _leafPortion)
				total += (leafP as KPortion).total;
			var percentInSelection:Number = selected / total;
			
			return (percentSelected + percentInSelection) / 2;
		}
		
	}
}