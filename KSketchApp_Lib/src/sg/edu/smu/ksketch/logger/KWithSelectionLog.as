/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.logger
{
	import sg.edu.smu.ksketch.model.geom.KPathPoint;
	import sg.edu.smu.ksketch.utilities.IIterator;
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
		
		public override function toXML():XML
		{
			var node:XML = super.toXML();
			node.@[KLogger.PREV_SELECTED_ITEMS] = _prevSelected ? _prevSelected.toString():"";
			node.@[KLogger.SELECTED_ITEMS] = _selected ? _selected.toString():"";
			return node;
		}
	}
}