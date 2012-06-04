/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

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