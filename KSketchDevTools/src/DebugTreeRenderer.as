/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package
{
	import mx.controls.treeClasses.TreeItemRenderer;
	import mx.controls.treeClasses.TreeListData;
	
	public class DebugTreeRenderer extends TreeItemRenderer
	{
		public function DebugTreeRenderer()
		{
			super();
		}
		
		override public function set data(value:Object):void {
			super.data = value;
			var xml:XML = TreeListData(super.listData).item as XML;
			if(xml.@selected == "true")
			{
				setStyle("color", 0xff0000);
				setStyle("fontWeight", 'bold');
			}
			else
			{
				setStyle("color", 0x000000);
				setStyle("fontWeight", 'normal');
			}
		}
	}
}