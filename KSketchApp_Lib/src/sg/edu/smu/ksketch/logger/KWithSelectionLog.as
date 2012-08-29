/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package sg.edu.smu.ksketch.logger
{
	import sg.edu.smu.ksketch.model.geom.KPathPoint;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;
	
	public class KWithSelectionLog extends KInteractiveLog
	{
		protected var _prevSelected:KModelObjectList;
		protected var _selected:KModelObjectList;
		
		public function KWithSelectionLog(cursorPath:Vector.<KPathPoint>, tagName:String,
										  prevSelected:KModelObjectList=null)
		{
			super(cursorPath, tagName);
			_prevSelected = prevSelected;
		}
		
		public function set selected(selection:KModelObjectList):void
		{
			_selected = selection;
		}
		
		public function get selectedItems():KModelObjectList
		{
			return _selected;
		}
		
		public function get prevSelectedItems():KModelObjectList
		{
			return _prevSelected;
		}
		
		public override function toXML():XML
		{
			var node:XML = super.toXML();
			node.@[KPlaySketchLogger.PREV_SELECTED_ITEMS] = _prevSelected ? _prevSelected.toString():"";
			node.@[KPlaySketchLogger.SELECTED_ITEMS] = _selected ? _selected.toString():"";
			return node;
		}
	}
}