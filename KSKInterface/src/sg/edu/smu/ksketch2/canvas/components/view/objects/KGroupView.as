/**
 * Copyright 2010-2015 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.canvas.components.view.objects
{
import mx.collections.ArrayList;

import sg.edu.smu.ksketch2.canvas.components.view.KModelDisplay;
import sg.edu.smu.ksketch2.model.data_structures.KModelObjectList;
import sg.edu.smu.ksketch2.model.objects.KGroup;
import sg.edu.smu.ksketch2.model.objects.KObject;
import sg.edu.smu.ksketch2.model.objects.KStroke;

	public class KGroupView extends KObjectView
	{
		private var _displayRoot:KModelDisplay;
		private var ghostArray:ArrayList;
		
		private var _glowFilter:Array;
		
		public function KGroupView(object:KObject)
		{
			super(object);
			
			//_displayRoot = displayRoot;
			_ghost = new KGroupGhost(null);
			addChild(_ghost);
			
			if(_object.id == 0)
				_ghost.visible = true;
		}
		
		public function resetDrawObject():void
		{
			ghostArray = new ArrayList();
		}
		
		public function drawObject(objectList:KModelObjectList):void
		{
			var tempArr:Array;
			var currObject:KStroke;
			
			for(var i:int=0; i<objectList.length(); i++)
			{
				if(objectList.getObjectAt(i) is KGroup)
					drawObject((objectList.getObjectAt(i) as KGroup).children);
				else
				{
					currObject = (objectList.getObjectAt(i) as KStroke);
					
					tempArr = new Array(3);
					tempArr[0]= currObject.points;
					tempArr[1] = currObject.color;
					tempArr[2] = currObject.thickness;
					ghostArray.addItem(tempArr);
				}
				
			}
			
			_ghost = new KGroupGhost(ghostArray);
			cacheAsBitmap = true;
		}
		
	}
}