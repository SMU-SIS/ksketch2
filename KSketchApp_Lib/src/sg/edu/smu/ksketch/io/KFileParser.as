/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.io
{		
	import sg.edu.smu.ksketch.logger.KLogger;
	import flash.geom.Point;
	import sg.edu.smu.ksketch.model.geom.KPathPoint;
	import sg.edu.smu.ksketch.utilities.KAppState;
	
	public class KFileParser
	{
		public static const ROOT:String = "kmv";
		public static const ID:String = "id";
		public static const PARENT_ID:String = "id";
		public static const GROUP:String = "g";
		public static const STROKE:String = "stroke";		
		public static const STROKE_POINTS:String = "points";
		public static const THICKNESS:String = "thickness";
		public static const COLOR:String = "color";
		public static const TIMELINE:String = "timeline";
		public static const COMMANDS:String = KLogger.COMMANDS;
		
		public static const KEYFRAME:String = "keyframe";
		public static const KEYFRAME_LIST:String = "keyframeList";		
		public static const KEYFRAME_TYPE:String = "type";
		public static const KEYFRAME_TYPE_TRANSLATE:String = "translate";
		public static const KEYFRAME_TYPE_ROTATE:String = "rotate";
		public static const KEYFRAME_TYPE_SCALE:String = "scale";
		public static const KEYFRAME_TYPE_ACTIVITY:String = "activity";
		public static const KEYFRAME_TYPE_PARENT:String = "parent";
		public static const KEYFRAME_TIME:String = "time";
		public static const KEYFRAME_CENTER_X:String = "cy";
		public static const KEYFRAME_CENTER_Y:String = "cx";
		public static const KEYFRAME_CURSOR_PATH:String = "cursorPath";
		public static const KEYFRAME_TRANSITION_TYPE:String = "transitionType";
		public static const KEYFRAME_TRANSITION_TYPE_INSTANT:int = KAppState.TRANSITION_INSTANT;
		public static const KEYFRAME_TRANSITION_TYPE_INTERPOLATED:int = KAppState.TRANSITION_INTERPOLATED;
		public static const KEYFRAME_TRANSITION_TYPE_REALTIME:int= KAppState.TRANSITION_REALTIME;
		
		public static const POSITION_KEYFAME_INSTANT_OFFSET:String = "instantOffset";
		public static const ROTATION_KEYFAME_INSTANT_ANGLE:String = "instantAngle";
		public static const SCALE_KEYFAME_INSTANT_FACTOR:String = "instantFactor";
				
		public static const ACTIVITY_ALPHA:String = "alpha";

		public static const IMAGE:String = "image";
		public static const IMAGE_X:String = "x";
		public static const IMAGE_Y:String = "y";
		public static const IMAGE_WIDTH:String = "width";
		public static const IMAGE_HEIGHT:String = "height";
		public static const IMAGE_DATA:String = "data";
		public static const IMAGE_FORMAT:String = "format";
		
		public static function generatePathPoints(pntsString:String):Vector.<KPathPoint>
		{
			if(pntsString == null)
				return null;
			var points:Vector.<KPathPoint> = new Vector.<KPathPoint>();
			var coordinates:Array = pntsString.split(" ");
			for each(var point:String in coordinates)
			{
				if(point != "")
				{
					var txy:Array = point.split(",");
					if(txy.length==3)
						points.push(new KPathPoint(txy[1], txy[2],txy[0]));
					else
						throw new Error("Stroke.points: expected 3 parameters " +
							"for each path point, but found \""+point+"\"");
				}
			}
			return points;
		}						
	}
}