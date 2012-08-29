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
	
	public class KDragCenterLog extends KInteractiveLog
	{
		private var _tapDetected:Boolean;
		
		public function KDragCenterLog(cursorPath:Vector.<KPathPoint>)
		{
			super(cursorPath, KPlaySketchLogger.INTERACTION_DRAG_CENTER);
		}
		
		public function set isTap(value:Boolean):void
		{
			_tapDetected = value;
		}
		
		public override function toXML():XML
		{
			var node:XML = super.toXML();
			node.@[KPlaySketchLogger.IS_TAP] = _tapDetected;
			return node;
		}
	}
}