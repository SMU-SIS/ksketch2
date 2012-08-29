/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package sg.edu.smu.ksketch.gestures
{
	import flash.geom.Point;
	
	import mx.core.ByteArrayAsset;
	import mx.utils.ObjectUtil;

	public class Library
	{
		private var _design:GestureDesign;
		
		private var _templates:Vector.<Template>;
		
		public function Library(design:GestureDesign, preSelection:Boolean, postSelection:Boolean)
		{
			_design = design;
			_templates = new Vector.<Template>();
			var mapping:Object = _design.mapping;
			var claInfo:Object = ObjectUtil.getClassInfo(mapping);
			var props:Array = claInfo["properties"];
			var gName:String;
			var gTemplates:Vector.<Vector.<Point>>;
			var tCount:uint;
			for each(var q:QName in props)
			{
				if((preSelection && GestureDesign.isPreGesture(q.localName))
					|| (postSelection && GestureDesign.isPostGesture(q.localName)))
				{
					gName = mapping[q.localName] as String;
					gTemplates = Templates.getTemplates(gName);
					tCount = gTemplates.length;
					for(var i:uint = 0;i<tCount;i++)
						_templates.push(new Template(q.localName, gTemplates[i]));
				}
			}
		}
		
		public function get templates():Vector.<Template>
		{
			return _templates;
		}
	}
}