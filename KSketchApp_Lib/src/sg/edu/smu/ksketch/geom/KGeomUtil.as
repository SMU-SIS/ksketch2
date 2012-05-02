/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.geom
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch.model.geom.KPathPoint;
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.utilities.IIterator;
	import sg.edu.smu.ksketch.utilities.KAppState;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;

	/**
	 * The KGeomUtil class contains methods that support geometry operations pertaining to K-Sketch.
	 * All the methods of the this class are static and must be called using the 
	 * syntax KGeomUtil.method(parameter) 	 
	 */	
	public class KGeomUtil
	{
		private static const ORIGIN:Point = new Point();
		private static const X_PREMITIVE:Point = new Point(100, 0);
		private static const Y_PREMITIVE:Point = new Point(0, 100);
		private static const START_POINT_POSITION:Point = new Point();
		private static const START_POINT_ROTATE:Point = new Point(0, -100);
		private static const START_POINT_SCALE:Point = X_PREMITIVE;

		/**
		 * Compute the intermediate KTimedPoint of the Translation within the start and end time 
		 * @param startTime The starting time
		 * @param endTime The ending time
		 * @param translation The vector representation of the translate transformation 
		 * @return Vector of intermediate KTimedPoint
		 */		
		public static function interpolateTranslation(startTime:Number, endTime:Number, 
													  translation:Point):Vector.<KTimedPoint>
		{
			var translations:Vector.<KTimedPoint> = new Vector.<KTimedPoint>();
			if(startTime == endTime)
				translations.push(new KTimedPoint(endTime, translation.x, translation.y));
			else
			{
				var t:int = startTime;
				var percent:Number;
				while(t <= endTime)
				{
					percent = (t - startTime)/(endTime - startTime);
					var point:Point = new Point(translation.x * percent, translation.y * percent);
					translations.push(new KTimedPoint(t, point.x, point.y));
					t = KAppState.nextKey(t);
				}
			}
			return translations;
		}
		
		/**
		 * Convert the path of KTimestampPoint to string representation 
		 * @param path The vector path of KTimestampPoint
		 * @return String representation of the path of KTimestampPoint
		 */		
		public static function cursorPathToString_KTimestampPoint(path:Vector.<KTimestampPoint>):String
		{
			var length:uint = path.length;
			if(length == 0)
				return "";
			var p:KTimestampPoint = path[0];
			var str:String = p.timeStamp+","+p.x+","+p.y;
			for(var i:uint = 1;i<length;i++)
			{
				p = path[i];
				str += " "+p.timeStamp+","+p.x+","+p.y;
			}
			return str;
		}
		
		/**
		 * Convert the path of KTimePoint to string representation 
		 * @param path The vector path of KTimePoint
		 * @return String representation of the path of KTimePoint
		 */		
		public static function cursorPathToString(path:Vector.<KPathPoint>):String
		{
			var length:uint = path.length;
			if(length == 0)
				return "";
			var p:KPathPoint = path[0];
			var str:String = p.time+","+p.x+","+p.y;
			for(var i:uint = 1;i<length;i++)
			{
				p = path[i];
				str += " "+p.time+","+p.x+","+p.y;
			}
			return str;
		}
		
		/**
		 * Convert the string representation to the path of KTimePoint 
		 * @param points The String representation of the KTimePoint
		 * @return path of the KTimePoint
		 */		
		public static function stringToCursorPath(points:String):Vector.<KTimedPoint>
		{
			var result:Vector.<KTimedPoint> = new Vector.<KTimedPoint>();
			var coordinates:Array = points.split(" ");
			
			var preTime:Number = 0;
			var time:Number = 0;
			for each(var point:String in coordinates)
			{
				var txy:Array = point.split(",");
				time = parseInt(txy[0]);
				if(txy.length==3) // new Triple(time, new Number(txy[1]), new Number(txy[2])));
					result.push(new KTimedPoint(time, txy[1], txy[2]));
				else
					throw new Error("The cursor path(t,x,y) cannot be "+points);
				if(time < preTime)
					throw new Error("Cusor path: Time order is wrong, cannot be"+points);
				preTime = time;
			}
			return result;
		}
		
		/**
		 * Get the coordinate of the center of a list of KModelObject at specify time.
		 * @param objects a list of KModelObject stored in KModelObjectList.
		 * @param kskTime the specify time.
		 * @return coordinate of the center.
		 */		
		public static function defaultCentroidOf(objects:KModelObjectList, kskTime:Number):Point
		{
			if(objects.length() == 0)
				return new Point(0, 0);
			
			var sum:Point = new Point();
			var m:Matrix;
			var object:KObject;
			var i:IIterator = objects.iterator;
			var total:int = 0;
			while(i.hasNext())
			{
				object = i.next();
				if(object is KGroup)
					total += _sumPoint(object as KGroup, kskTime, sum);
				else
				{
					total ++;
					m = object.getFullPathMatrix(kskTime);
					sum = sum.add(m.transformPoint(object.defaultCenter));
				}
			}
			return new Point(sum.x/total, sum.y/total);
		}
		
		// Used by defaultCenterOf()
		// Compute the sum of the x and y coordinates of the edge of a group of objects.
		private static function _sumPoint(group:KGroup, kskTime:Number, addToSum:Point):int
		{
			var m:Matrix;
			var object:KObject;
			var i:IIterator = group.allChildrenIterator(kskTime);
			var total:int = 0;
			var c:Point = new Point();
			while(i.hasNext())
			{
				object = i.next();
				total ++;
				m = object.getFullPathMatrix(kskTime);
				c = c.add(m.transformPoint(object.defaultCenter));
			}
			addToSum.x += c.x;
			addToSum.y += c.y;
			return total;
		}
	}
}