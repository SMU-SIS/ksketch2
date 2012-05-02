/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.interactor
{
	import flash.utils.Dictionary;
	
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.model.KImage;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.model.KStroke;
	import sg.edu.smu.ksketch.utilities.IIterator;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;
	
	public class KIntelligentArbiter extends KSimpleArbiter
	{
		private var _leafPortion:Dictionary;
		
		private var _groupPortion:Dictionary;
		
		private var _rawSelection:KModelObjectList;
		private var _s:Vector.<KGroup>;
		
		private var _candidates:Vector.<KModelObjectList>;
		private var _index:int;
		
		public function KIntelligentArbiter(root:KGroup)
		{
			super(root);
		}
		
		public override function bestGuess(rawData:Dictionary, time:Number):KModelObjectList
		{
			prepareOn(rawData, time);
			if(_rawSelection.length() == 0)
				return null;
			// skip if same as _g or _rawSelection
			_index = 0;
			return _candidates[_index];
		}
		
		public function cycleNext(rawData:Dictionary, time:Number):KModelObjectList
		{
			if(_leafPortion == null)
				prepareOn(rawData, time);
			if(_rawSelection.length() == 0)
				return null;
			// skip if same as _g or _rawSelection
			_index ++;
			_index %= _candidates.length;
			
			return _candidates[_index];
		}
		
		public function cyclePrevious(rawData:Dictionary, time:Number):KModelObjectList
		{
			if(_leafPortion == null)
				prepareOn(rawData, time);
			if(_rawSelection.length() == 0)
				return null;
			// skip if same as _g or _rawSelection
			_index --;
			if(_index < 0)
				_index = _candidates.length - 1;
			
			return _candidates[_index];
		}
		
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
			var gIt:IIterator = g.allChildrenIterator(time);
			var portion:KPortion;
			
			var currentChildren:Vector.<KObject> = g.getChildren(time);
			
			if(currentChildren.length <=1)
			{
				return false;
			}
			
			while(gIt.hasNext())
			{
				portion = rawData[gIt.next()];
				if(portion == null || portion.portion <= THRESHOLD)
				{
					allSelected = false;
					break;
				}
			}
			return allSelected;
		}
		
		private function prepareOn(rawData:Dictionary, time:Number):void
		{
			_rawSelection = rawSelection(rawData, time);
			if(_rawSelection.length() == 0)
				return;
			
			_leafPortion = rawData;
			_s = new Vector.<KGroup>();
			_groupPortion = new Dictionary();
			findSelectedNodes(_root, _s, time, _leafPortion, _groupPortion);
			
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
			var it:IIterator = list.iterator;
			while(it.hasNext())
				if(!(it.next() is KGroup))
					return false;
			return true;
		}
		
		private function findSelectedNodes(p:KGroup, s:Vector.<KGroup>, time:Number, rawData:Dictionary, groupPortion:Dictionary):void
		{
			var i:IIterator = p.directChildIterator(time);
			var obj:KObject;
			var portion:KPortion;
			while(i.hasNext())
			{
				obj = i.next();
				if(obj is KGroup)
				{
					portion = percentOfGroup(obj as KGroup, time, rawData);
					var percent:Number = portion.portion;
					if(percent > THRESHOLD)
					{
						var currentChildren:Vector.<KObject> = (obj as KGroup).getChildren(time);
						
						if(currentChildren.length <=1)
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
			var i:IIterator = group.allChildrenIterator(time);
			var selected:uint = 0;
			var total:uint = 0;
			var obj:KObject;
			while(i.hasNext())
			{
				obj = i.next();
				portion = rawData[obj];
				if(portion != null)
				{
					total += portion.total;
					selected += portion.selected;
				}
				else if(obj is KStroke)
					total += (obj as KStroke).points.length;
				else if(obj is KImage)
					total += KImage.NUM_BOUNDING_POINTS;
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
			if(selection1.length() == selection2.length())
			{
				var it1:IIterator = selection1.iterator;
				var it2:IIterator;
				var obj:KObject;
				var contain:Boolean;
				while(it1.hasNext())
				{
					obj = it1.next();
					it2 = selection2.iterator;
					contain = false;
					while(it2.hasNext())
					{
						if(obj == it2.next())
						{
							contain = true;
							break;
						}
					}
					if(!contain)
						return false;
				}
				return true;
			}
			return false;
		}
		
		private function canAdd(group:KGroup, time:Number, groupSelected:Dictionary):Boolean
		{
			var parent:KGroup = group.getParent(time);
			while(parent != null)
			{
				if(groupSelected[parent] == true)
					return false;
				parent = parent.getParent(time);
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
			var i:IIterator = list.iterator;
			var selected:uint = 0;
			var total:uint = 0;
			var obj:KObject;
			var portion:KPortion;
			while(i.hasNext())
			{
				obj = i.next();
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