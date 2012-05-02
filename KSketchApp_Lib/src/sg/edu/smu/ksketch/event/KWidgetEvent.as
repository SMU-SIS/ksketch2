/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.event
{
	import flash.events.MouseEvent;
	
	public final class KWidgetEvent extends MouseEvent
	{
		public static const DOWN_TRANSLATE:String = "DOWN_TRANSLATE";
		public static const DOWN_ROTATE:String = "DOWN_ROTATE";
		public static const DOWN_SCALE:String = "DOWN_SCALE";
		public static const DOWN_CENTER:String = "DOWN_CENTER";
		
		public static const RIGHT_DOWN_TRANSLATE:String = "RIGHT_DOWN_TRANSLATE";
		public static const RIGHT_DOWN_ROTATE:String = "RIGHT_DOWN_ROTATE";
		public static const RIGHT_DOWN_SCALE:String = "RIGHT_DOWN_SCALE";
		public static const RIGHT_DOWN_CENTER:String = "RIGHT_DOWN_CENTER";
		
		public static const HOVER_TRANSLATE:String = "HOVER_TRANSLATE";
		public static const HOVER_ROTATE:String = "HOVER_ROTATE";
		public static const HOVER_SCALE:String = "HOVER_SCALE";
		public static const HOVER_CENTER:String = "HOVER_CENTER";
		
		public static const UP_TRANSLATE:String = "UP_TRANSLATE";
		public static const UP_ROTATE:String = "UP_ROTATE";
		public static const UP_SCALE:String = "UP_SCALE";
		public static const UP_CENTER:String = "UP_CENTER";
		
		public static const OUT:String = "OUT";
		
		private var _stageX:Number;
		private var _stageY:Number;
		
		public function KWidgetEvent(type:String, stageX:Number, stageY:Number)
		{
			super(type);
			_stageX = stageX;
			_stageY = stageY;
		}
		
		public override function get stageX():Number
		{
			return _stageX;
		}
		
		public override function get stageY():Number
		{
			return _stageY;
		}	
	}
}