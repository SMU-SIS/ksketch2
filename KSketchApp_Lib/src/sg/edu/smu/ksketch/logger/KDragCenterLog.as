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