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

	public class KTransitionLog extends KInteractiveLog
	{
		private var _transitionType:int;
		
		public function KTransitionLog(transition:String, transitionType:int, 
									   cursorPath:Vector.<KPathPoint>)
		{
			super(cursorPath, transition);
			_transitionType = transitionType;
		}
		
		public function get transitionType():int
		{
			return _transitionType;
		}

		public function set transitionType(value:int):void
		{
			_transitionType = value;
		}

		public override function toXML():XML
		{
			var node:XML = super.toXML();
			node.@[KLogger.TRANSITION_TYPE] = _transitionType;
			return node;
		}
	}
}