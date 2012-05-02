/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.gestures
{
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import mx.core.ByteArrayAsset;
		
	import sg.edu.smu.ksketch.utilities.KAppState;

	public class Templates
	{
		public static const ROOT:String = "gestures";
		public static const TAG_GESTURE:String = "gesture";
		public static const TAG_TEMPLATE:String = "template";
		public static const ATTR_GESTURE_NAME:String = "name";
		public static const ATTR_POINTS:String = "points";
		
		private static var _templates:Dictionary;
		
		[Embed(source="Templates.tpl", mimeType="application/octet-stream")]
	    private static const templateAsset:Class;
		
	/*	[Embed(source="Templates_Current.tpl", mimeType="application/octet-stream")]
		private static const templateAsset2:Class;
	*/	
		public static function getTemplates(gestureName:String):Vector.<Vector.<Point>>
		{
			if(_templates == null)
				initTemplates();
			return _templates[gestureName];
		}
		
		private static function initTemplates():void
		{
			var file:ByteArrayAsset ;
				file = ByteArrayAsset(new templateAsset());
		    // if(design2.selected==true)
			//	file = ByteArrayAsset(new templateAsset2());
			
			var xml:XML = new XML(file.readUTFBytes(file.length));
			var gestures:XMLList = xml.child(TAG_GESTURE);
			
			var gCount:uint = gestures.length();
			var g:XML;
			var templatesXML:XMLList;
			var tCount:uint;
			
			var gTemplates:Vector.<Vector.<Point>>;
			var gName:String;
			
			_templates = new Dictionary();
			for(var gIndex:uint = 0;gIndex<gCount;gIndex++)
			{
				g = gestures[gIndex];
				gName = g.@[ATTR_GESTURE_NAME];
				gTemplates = new Vector.<Vector.<Point>>();
				templatesXML = g.children();
				tCount = templatesXML.length();
				for(var tIndex:uint = 0;tIndex<tCount;tIndex++)
					gTemplates.push(generateTemplate(templatesXML[tIndex]));
				_templates[gName] = gTemplates;
			}
		}
		
		private static function generateTemplate(templateNode:XML):Vector.<Point>//, rotationInv:Boolean):Gesture
		{
			var type:String = templateNode.@[ATTR_GESTURE_NAME];
			var pntsStr:String = templateNode.@[ATTR_POINTS];
			var pnts:Vector.<Point> = generatePoints(pntsStr);
			return Recognizer.generateTemplate(type, pnts);//, rotationInv);
		}
		
		private static function generatePoints(pntsString:String):Vector.<Point>
		{
			var points:Vector.<Point> = new Vector.<Point>();
			var coordinates:Array = pntsString.split(" ");
			for each(var point:String in coordinates)
			{
				if(point != "")
				{
					var xy:Array = point.split(",");
					if(xy.length==2)
						points.push(new Point(xy[0], xy[1]));
					else
						throw new Error("Stroke.points: expected 2 parameters for each coordiantes, but found \""+point+"\"");
				}
			}
			return points;
		}
		
	}
}