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
			if(tagName != KPlaySketchLogger.UNDEFINED)
			{
				node.@[KPlaySketchLogger.CONFIDENCE] = _confidence;
				node.@[KPlaySketchLogger.SELECTED_ITEMS] = _selectionChangedTo.toString();
			}
			return node;
		}
		
		private function tagOf(result:RecognizeResult):String
		{
			switch(result.type)
			{
				case GestureDesign.NAME_POST_CYCLE_NEXT:
					return KPlaySketchLogger.CYCLE_NEXT;
				case GestureDesign.NAME_POST_CYCLE_PREV:
					return KPlaySketchLogger.CYCLE_PREV;
				default:
					throw new Error("Unsupported result: "+result.type);
			}
		}
	}
}