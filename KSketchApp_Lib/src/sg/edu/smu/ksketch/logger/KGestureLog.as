package sg.edu.smu.ksketch.logger
{
	import sg.edu.smu.ksketch.model.geom.KPathPoint;
	import sg.edu.smu.ksketch.gestures.RecognizeResult;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;
	
	public class KGestureLog extends KWithSelectionLog
	{
		private var _preGesture:RecognizeResult;
		private var _subLogs:Vector.<KGestureSubLog>;
		
		public function KGestureLog(cursorPath:Vector.<KPathPoint>,
									prevSelected:KModelObjectList=null)
		{
			super(cursorPath, KPlaySketchLogger.INTERACTION_GESTURE,prevSelected);
		}
		
		public function set preGestureRecognized(result:RecognizeResult):void
		{
			_preGesture = result;
		}
		
		public function addSubLog(subLog:KGestureSubLog):void
		{
			if(_subLogs == null)
				_subLogs = new Vector.<KGestureSubLog>();
			_subLogs.push(subLog);
		}
		
		public override function toXML():XML
		{
			var node:XML = super.toXML();
			if(_preGesture != null)
			{
				delete node.@[KPlaySketchLogger.SELECTED_ITEMS];
				if(_preGesture == RecognizeResult.UNDEFINED)
					node.@[KPlaySketchLogger.MATCH] = _preGesture.type;
				else
				{
					node.@[KPlaySketchLogger.MATCH] = _preGesture.type;
					node.@[KPlaySketchLogger.CONFIDENCE] = _preGesture.score;
				}
			}
			else if(_subLogs != null)
			{
				for each(var subNode:KGestureSubLog in _subLogs)
				node.appendChild(subNode.toXML());
			}
			return node;
		}
	}
}