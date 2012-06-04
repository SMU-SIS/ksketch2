/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

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