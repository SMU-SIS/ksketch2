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

	/**
	 * The KStroke class serves as the concrete class for representing
	 * stroke objects in the model in K-Sketch.
	 */
	public class KStroke extends KObject
	{
		protected var _color:uint;				// the stroke's color
		protected var _thickness:Number;		// the stroke's thickness
		protected var _points:Vector.<Point>;	// the stroke's list of points
		
		/**
		 * The main constructor for the KStroke class.
		 * 
		 * @param id The stroke's ID.
		 * @param points The stroke's list of points.
		 * @param newColor The stroke's color.
		 * @param newThickness The stroke's thickness.
		 */
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
		 * Gets the stroke's color.
		 * 
		 * @return The stroke's color.
		 */
		public function get color():uint
		{
			return _color;
		}
		
		/**
		 * Gets the stroke's thickness.
		 * 
		 * @return The stroke's thickness.
		 */
		public function get thickness():Number
		{
			return _thickness;
		}
		
		/**
		 * Gets the stroke's set of points.
		 * 
		 * @return The stroke's set of points.
		 */
		public function get points():Vector.<Point>
		{
			return _points;
		}
		
		/**
		 * Computes the geometric center for this object.
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
		 * Gets the stroke's geometric center.
		 * 
		 * @return The stroke's geometric center.
		 */
		override public function get center():Point
		{
			// case: the stroke's geometric center doesn't exist
			// compute the center
			if(!_center)
				computeCenter();
			
			// return the computed geometric center
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