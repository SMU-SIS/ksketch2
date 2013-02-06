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
	import sg.edu.smu.ksketch2.model.data_structures.KSceneGraph;
	
	public class KSimpleArbiter implements ISelectionArbiter
	{
		public static const THRESHOLD:Number = 0.6;
		
		public function KSimpleArbiter()
		{

		}
		
		public function bestGuess(rawData:Dictionary, time:Number, searchRoot:KGroup):KModelObjectList
		{
			return rawSelection(rawData, time, searchRoot);
		}
		
		public function rawSelection(rawData:Dictionary, time:Number, searchRoot:KGroup):KModelObjectList
		{
			var selection:KModelObjectList = new KModelObjectList();
			
			rawSelection_recurse(rawData, searchRoot, time, selection);
			
			return selection;
		}
		
		private function rawSelection_recurse(rawData:Dictionary, searchRoot:KGroup, time:Number, addTo:KModelObjectList):void
		{
			var objects:KModelObjectList = searchRoot.children;
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
	}
}