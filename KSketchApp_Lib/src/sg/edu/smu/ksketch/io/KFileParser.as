/**------------------------------------------------
 * Copyright 2012 Singapore Management University
 * All Rights Reserved
 *
 *-------------------------------------------------*/

package sg.edu.smu.ksketch.io
{		
	import flash.display.BitmapData;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	import mx.graphics.codec.PNGEncoder;
	import mx.utils.Base64Decoder;
	import mx.utils.Base64Encoder;
	
	import sg.edu.smu.ksketch.logger.KLogger;
	import sg.edu.smu.ksketch.model.geom.K2DVector;
	import sg.edu.smu.ksketch.model.geom.K3DVector;
	import sg.edu.smu.ksketch.model.geom.KPathPoint;
	import sg.edu.smu.ksketch.utilities.KAppState;
	
	public class KFileParser
	{
		public static const ROOT:String = "kmv";
		public static const ID:String = "id";
		public static const PARENT_ID:String = "id";
		public static const GROUP:String = "g";
		public static const STROKE:String = "stroke";		
		public static const STROKE_POINTS:String = KLogger.STROKE_POINTS;
		public static const THICKNESS:String = KLogger.STROKE_THICKNESS;
		public static const COLOR:String = KLogger.STROKE_COLOR;
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
		public static const KEYFRAME_CENTER_X:String = KLogger.TRANSITION_CENTER_X;
		public static const KEYFRAME_CENTER_Y:String = KLogger.TRANSITION_CENTER_Y;
		public static const KEYFRAME_CURSOR_PATH:String = "cursorPath";
		public static const KEYFRAME_TRANSITION_TYPE:String = KLogger.TRANSITION_TYPE;
		public static const KEYFRAME_TRANSITION_TYPE_INSTANT:int = KLogger.TRANSITION_TYPE_INSTANT;
		public static const KEYFRAME_TRANSITION_TYPE_INTERPOLATED:int = KLogger.TRANSITION_TYPE_INTERPOLATED;
		public static const KEYFRAME_TRANSITION_TYPE_REALTIME:int= KLogger.TRANSITION_TYPE_REALTIME;
		
		public static const POSITION_KEYFAME_INSTANT_OFFSET:String = "instantOffset";
		public static const ROTATION_KEYFAME_INSTANT_ANGLE:String = "instantAngle";
		public static const SCALE_KEYFAME_INSTANT_FACTOR:String = "instantFactor";
		
		public static const ACTIVITY_ALPHA:String = "alpha";
		
		public static const IMAGE:String = "image";
		public static const IMAGE_X:String = KLogger.IMAGE_X;
		public static const IMAGE_Y:String = KLogger.IMAGE_Y;
		public static const IMAGE_WIDTH:String = KLogger.IMAGE_WIDTH;
		public static const IMAGE_HEIGHT:String = KLogger.IMAGE_HEIGHT;
		public static const IMAGE_DATA:String = KLogger.IMAGE_DATA;
		public static const IMAGE_FORMAT:String = KLogger.IMAGE_FORMAT;	
		public static const IMAGE_FORMAT_PNG:String = KLogger.IMAGE_FORMAT_PNG;
		
		public static function resolvePath(filename:String,location:String):File
		{
			switch(location)
			{
				case KLogger.FILE_USER_DIR:
					return File.userDirectory.resolvePath(filename);
				case KLogger.FILE_DESKTOP_DIR:
					return File.desktopDirectory.resolvePath(filename);
				case KLogger.FILE_DOCUMENT_DIR:
					return File.documentsDirectory.resolvePath(filename);
				case KLogger.FILE_STORAGE_DIR:
					return File.applicationStorageDirectory.resolvePath(filename);
			}
			return new File(null);
		}
				
		public static function pngToString(data:BitmapData):String
		{	
			var base64Enc:Base64Encoder = new Base64Encoder();  
			base64Enc.encodeBytes(_pngToByteArray(data),0,0);
			return base64Enc.toString();  				
		}
		
		public static function stringToByteArray(data:String):ByteArray
		{
			var base64Dec:Base64Decoder = new Base64Decoder();
			base64Dec.decode(data);
			return base64Dec.toByteArray();
		}
		
		public static function intsToString(ints:Vector.<int>):String
		{
			var intsString:String = "";
			if(ints.length > 0)
				intsString = String(ints[0]);
			for(var i:int = 1; i < ints.length; i++)
				intsString += " "+ints[i];
			return intsString;
		}
		
		public static function stringToInts(intsString:String):Vector.<int>
		{
			var ints:Vector.<int> = new Vector.<int>();
			var intArrays:Vector.<Array> = _stringToVectors(intsString);
			for (var i:int=0; i < intArrays.length; i++)
				ints.push(int(intArrays[i][0]));
			return ints;
		}
		
		public static function pointsToString(points:Vector.<Point>):String
		{
			var pntsString:String = "";
			if(points.length>0)
				pntsString = points[0].x+","+points[0].y;
			for(var i:int = 1;i<points.length;i++)
				pntsString += " "+points[i].x+","+points[i].y;
			return pntsString;
		}
		
		public static function stringToPoints(pntsString:String):Vector.<Point>
		{
			var points:Vector.<Point> = new Vector.<Point>();
			var pointArrays:Vector.<Array> = _stringToVectors(pntsString);
			for (var i:int=0; i < pointArrays.length; i++)
				points.push(new Point(Number(pointArrays[i][0]),Number(pointArrays[i][1])));
			return points;
		}
		
		public static function pathPointsToString(points:Vector.<KPathPoint>):String
		{
			var pntsString:String = "";
			if(points.length>0)
				pntsString = points[0].x+","+points[0].y+","+points[0].time;
			for(var i:int = 1;i<points.length;i++)
				pntsString += " "+points[i].x+","+points[i].y+","+points[i].time;
			return pntsString;
		}
		
		public static function stringToPathPoints(pntsString:String):Vector.<KPathPoint>
		{
			var points:Vector.<KPathPoint> = new Vector.<KPathPoint>();
			var pointArrays:Vector.<Array> = _stringToVectors(pntsString);
			for (var i:int=0; i < pointArrays.length; i++)
				points.push(new KPathPoint(Number(pointArrays[i][0]),
					Number(pointArrays[i][1]),Number(pointArrays[i][2])));
			return points;
		}
		
		public static function k2DVectorsToString(points:Vector.<K2DVector>):String
		{
			var pntsString:String = "";
			if(points.length > 0)
				pntsString = points[0].x+","+points[0].y;
			for(var i:int = 1;i<points.length;i++)
				pntsString += " "+points[i].x+","+points[i].y;
			return pntsString;
		}
		
		public static function stringToK2DVectors(pntsString:String):Vector.<K2DVector>
		{
			var points:Vector.<K2DVector> = new Vector.<K2DVector>();
			var pointArrays:Vector.<Array> = _stringToVectors(pntsString);
			for (var i:int=0; i < pointArrays.length; i++)
				points.push(new K2DVector(Number(pointArrays[i][0]),Number(pointArrays[i][1])));
			return points;
		}
		
		public static function k3DVectorsToString(points:Vector.<K3DVector>):String
		{
			var pntsString:String = "";
			if(points.length > 0)
				pntsString = points[0].x+","+points[0].y+","+points[0].z;
			for(var i:int = 1;i<points.length;i++)
				pntsString += " "+points[i].x+","+points[i].y+","+points[i].z;
			return pntsString;
		}
		
		public static function stringToK3DVectors(pntsString:String):Vector.<K3DVector>
		{
			var points:Vector.<K3DVector> = new Vector.<K3DVector>();
			var pointArrays:Vector.<Array> = _stringToVectors(pntsString);
			for (var i:int=0; i < pointArrays.length; i++)
				points.push(new K3DVector(Number(pointArrays[i][0]),
					Number(pointArrays[i][1]),Number(pointArrays[i][2])));
			return points;
		}
		
		private static function _pngToByteArray(data:BitmapData):ByteArray
		{
			return (new PNGEncoder()).encodeByteArray(
				_bitMapDataToBytes(data), data.width, data.height, true);		
		}
		
		private static function _bitMapDataToBytes(data:BitmapData):ByteArray
		{
			var bytes:ByteArray = new ByteArray();
			bytes.writeUnsignedInt(data.width);
			bytes.writeBytes(data.getPixels(data.rect));
			return bytes;
		}
		
		private static function _stringToVectors(pntsString:String):Vector.<Array>
		{
			if(pntsString == null)
				return null;
			var points:Vector.<Array> = new Vector.<Array>();
			var pntsArray:Array = pntsString.split(" ");
			for (var i:int=0; i < pntsArray.length; i++)
				if(pntsArray[i] != "")
					points.push(pntsArray[i].split(","));
			return points;
		}
	}
}