/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.view.objects
{
	import flash.display.DisplayObject;
	import flash.filters.GlowFilter;
	
	import sg.edu.smu.ksketch2.events.KObjectEvent;
	import sg.edu.smu.ksketch2.model.objects.KObject;

	public class KGroupView extends KObjectView
	{
		private var _glowFilter:Array;
		
		public function KGroupView(object:KObject)
		{
			super(object);
		}
		
		override protected function _updateSelection(event:KObjectEvent):void
		{
			super._updateSelection(event);
			
			var filter:GlowFilter = new GlowFilter(0x9EF7A0,1,10,10,16,1);
			_glowFilter = [filter];
			
			for(var i:int = 0; i< this.numChildren; i++)
			{
				var child:DisplayObject = this.getChildAt(i);
				
				if(_object.selected)
				{
					if(child is KGroupView)
						(child as KGroupView)._updateSelection(event);
					else if(child is KStrokeView)
						(child as KStrokeView).filters = [new GlowFilter(0x9EF7A0,1,10,10,16,1)];
				}
				else
				{
					if(child is KGroupView)
						(child as KGroupView)._updateSelection(event);
					else if(child is KObjectView)
						(child as KObjectView).object.selected = (child as KObjectView).object.selected;
				}
			}
		}
	}
}