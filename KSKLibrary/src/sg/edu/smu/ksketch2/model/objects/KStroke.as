/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.model.objects
{
	import flash.geom.Point;
	
	import mx.utils.StringUtil;
	
	import sg.edu.smu.ksketch2.operators.KSingleReferenceFrameOperator;

	public class KStroke extends KObject
	{
		protected var _color:uint;
		protected var _thickness:Number;
		protected var _points:Vector.<Point>;
		
		public function KStroke(id:int, points:Vector.<Point>, newColor:uint, newThickness:Number)
		{
			super(id);
			_points = points;
			_color = newColor;
			_thickness = newThickness;
			computeCenter();
			transformInterface = new KSingleReferenceFrameOperator(this);
		}
		
		/**
		 * Color for this object
		 */
		public function get color():uint
		{
			return _color;
		}
		
		/**
		 * This stroke's thickness
		 */
		public function get thickness():Number
		{
			return _thickness;
		}
		
		/**
		 * Returns the set of points that makes up this KStroke
		 */
		public function get points():Vector.<Point>
		{
			return _points;
		}
		
		/**
		 * Computes the geometric center for this object
		 */
		public function computeCenter():void
		{
			if(!_points || _points.length == 0)
				throw new Error("KStroke:ComputerCenter says it can't compute any thing without any points");
			
			var minX:Number = Number.MAX_VALUE;
			var minY:Number = Number.MAX_VALUE;
			
			var maxX:Number = Number.MIN_VALUE;
			var maxY:Number = Number.MIN_VALUE;
			
			var point:Point;
			
			for(var i:int = 0; i<_points.length; i++)
			{
				point = _points[i];
				
				if(point.x < minX)
					minX = point.x;
				
				if(maxX < point.x)
					maxX = point.x;
				
				if(point.y < minY)
					minY = point.y;
				
				if(maxY < point.y)
					maxY = point.y;
			}
			
			if(!_center)
				_center = new Point();
			
			_center.x = (minX+maxX)/2;
			_center.y = (minY+maxY)/2;
		}
		
		/**
		 * Returns the geometric center for this KStroke
		 */
		override public function get center():Point
		{
			if(!_center)
				computeCenter();
			
			return _center;
		}
		
		override public function serialize():XML
		{
			var objectXML:XML = super.serialize();
			objectXML.@type = "stroke";

			var strokeXML:XML = <strokeData color="" thickness="" points=""/>;
			var pointSerial:String = "";
			var currentPoint:Point;
			for(var i:int = 0; i<_points.length; i++)
			{
				currentPoint = _points[i];
				pointSerial+= currentPoint.x.toString()+","+currentPoint.y.toString()+" ";
			}
			
			StringUtil.trim(pointSerial);
			strokeXML.@points = pointSerial;
			strokeXML.@color = _color.toString();
			strokeXML.@thickness = _thickness.toString();
			objectXML.appendChild(strokeXML);
			
			return objectXML;
		}
		
		public static function strokeFromXML(xml:XML):KStroke
		{
			var pointSerial:String = StringUtil.trim(xml.strokeData.@points);
			var color:uint = uint(StringUtil.trim(xml.strokeData.@color));
			var thickness:uint = uint(StringUtil.trim(xml.strokeData.@thickness));
			
			var pointVector:Array = pointSerial.split(" ");
			var strokePoints:Vector.<Point> = new Vector.<Point>();
			
			var onePoint:Array;
			for(var i:int = 0; i<pointVector.length; i++)
			{
				onePoint = pointVector[i].split(",");
				strokePoints.push(new Point(onePoint[0], onePoint[1]));
			}
			
			var newStroke:KStroke = new KStroke(int(xml.@id), strokePoints, color, thickness);
			
			return newStroke;
		}
		
		override public function clone(newObjectID:int, withMotions:Boolean = false):KObject
		{
			var clonedPoints:Vector.<Point> = new Vector.<Point>();
			
			for(var i:int = 0; i<_points.length; i++)
				clonedPoints.push(_points[i].clone());
			
			var newStroke:KStroke = new KStroke(id, clonedPoints, _color, _thickness);
			
			if(withMotions)
				newStroke.transformInterface = transformInterface.clone();
			
			return newStroke;
		}
	}
}