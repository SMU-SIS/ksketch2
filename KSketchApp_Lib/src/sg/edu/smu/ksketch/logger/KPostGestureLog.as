/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.logger
{
	import sg.edu.smu.ksketch.geom.KTimestampPoint;
	import sg.edu.smu.ksketch.gestures.GestureDesign;
	import sg.edu.smu.ksketch.gestures.RecognizeResult;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;

	public class KPostGestureLog extends KGestureSubLog
	{
		private var _selectionChangedTo:KModelObjectList;
		private var _confidence:Number;
		
		public function KPostGestureLog(gestureResult:RecognizeResult, recognizedAt:Date, 
										cursorPath:Vector.<KTimestampPoint>, 
										selectionChangedTo:KModelObjectList)
		{
			super(cursorPath, tagOf(gestureResult), recognizedAt);
			_confidence = gestureResult.score;
			_selectionChangedTo = selectionChangedTo;
		}
		
		public override function toXML():XML
		{
			var node:XML = super.toXML();
			if(tagName != KLogger.UNDEFINED)
			{
				node.@[KLogger.CONFIDENCE] = _confidence;
				node.@[KLogger.SELECTED_ITEMS] = _selectionChangedTo.toString();
			}
			return node;
		}
		
		private function tagOf(result:RecognizeResult):String
		{
			switch(result.type)
			{
				case GestureDesign.NAME_POST_CYCLE_NEXT:
					return KLogger.CYCLE_NEXT;
				case GestureDesign.NAME_POST_CYCLE_PREV:
					return KLogger.CYCLE_PREV;
				default:
					throw new Error("Unsupported result: "+result.type);
			}
		}
	}
}