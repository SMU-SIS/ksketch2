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
	import sg.edu.smu.ksketch.model.geom.KPathPoint;

	public class KInteractiveLog implements ILoggable
	{
		private var _cursorPath:Vector.<KPathPoint>;
		
		private var _tagName:String;
		
		public function KInteractiveLog(cursorPath:Vector.<KPathPoint>, tagName:String)
		{
			_cursorPath = cursorPath;
			_tagName = tagName;
		}
		
		public function get tagName():String
		{
			return _tagName;
		}
		
		public function get cursorPath():Vector.<KPathPoint>
		{
			return _cursorPath;
		}
		
		public function set cursorPath(value:Vector.<KPathPoint>):void
		{
			_cursorPath = value;
		}
		
		public function addPoint(point:KPathPoint):void
		{
			_cursorPath.push(point);
		}
		
		public function toXML():XML
		{
			var node:XML = new XML("<"+tagName+"/>");
			node.@[KLogger.CURSOR_PATH] = cursorPathString;
			return node;
		}
		
		public function get cursorPathString():String
		{
			return KGeomUtil.cursorPathToString(_cursorPath);
		}
	}
}