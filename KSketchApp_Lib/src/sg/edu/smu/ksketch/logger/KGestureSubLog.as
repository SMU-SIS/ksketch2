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
	import sg.edu.smu.ksketch.geom.KGeomUtil;
	import sg.edu.smu.ksketch.geom.KTimestampPoint;

	public class KGestureSubLog implements ILoggable
	{
		private var _subPath:Vector.<KTimestampPoint>;
		private var _recognizedTime:Date;
		private var _tagName:String;
		
		public function KGestureSubLog(subPath:Vector.<KTimestampPoint>, tagName:String, recognizedAt:Date)
		{
			_tagName = tagName;
			_subPath = subPath;
			_recognizedTime = recognizedAt;
		}
		
		public function get tagName():String
		{
			return _tagName;
		}

		public function toXML():XML
		{
			var node:XML = new XML("<"+tagName+"/>");
			node.@[KLogger.LOG_TIME] = KLogger.formartedTime(_recognizedTime);
			node.@[KLogger.CURSOR_PATH] = KGeomUtil.cursorPathToString_KTimestampPoint(_subPath);
			return node;
		}
	}
}