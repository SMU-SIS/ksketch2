/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.interactor
{
	import flash.utils.Dictionary;
	
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.model.KModel;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.utilities.IIterator;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;
	
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
			var i:IIterator = root.directChildIterator(time);
			var obj:KObject;
			var portion:KPortion;
			while(i.hasNext())
			{
				obj = i.next();
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
			var gIt:IIterator = g.allChildrenIterator(time);
			var currentChildren:Vector.<KObject> = g.getChildren(time);
			
			if(currentChildren.length <=1)
				return false;
			
			var portion:KPortion;
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
		
		//Function to select strokes only
		public function selectStrokes(rawData:Dictionary, time:Number, selection:KModelObjectList = null):KModelObjectList
		{
			
			if(!selection)
				selection = new KModelObjectList();
			
			var i:IIterator = _root.directChildIterator(time);
			var obj:KObject;
			var portion:KPortion;
			
			//Iterate throught every child
			while(i.hasNext())
			{
				obj = i.next();
				
				if(obj is KGroup)
				{
					rawSelection_recurse(rawData, obj as KGroup, time, selection);
				}
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
			
			var i:IIterator = _root.directChildIterator(time);
			var obj:KObject;
			var portion:KPortion;
			
			//Iterate throught every child
			while(i.hasNext())
			{
				obj = i.next();
				
				//Determine if the object's parent is the root
				if(obj.getParent(time) == _root)
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