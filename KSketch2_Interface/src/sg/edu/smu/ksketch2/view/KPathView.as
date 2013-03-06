/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.view
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch2.model.data_structures.KTimedPoint;
	import sg.edu.smu.ksketch2.model.objects.KObject;

	public class KPathView
	{
		private const PATH_THICKNESS:Number = 1.5
		private const PATH_TRANSLATE_COLOR:uint = 0x0000FF;
		private const PATH_ROTATE_COLOR:uint = 0x00FF00;
		private const PATH_SCALE_COLOR:uint = 0xFF0000;
			
		protected var _object:KObject;
		protected var _currentCentroid:Point;
		protected var _translatePoints:Vector.<KTimedPoint>;
		protected var _nextTranslatePoints:Vector.<KTimedPoint>;
		protected var _rotatePoints:Vector.<KTimedPoint>;
		protected var _scalePoints:Vector.<KTimedPoint>;
		
		protected var _translatePath:Shape;
		protected var _nextTranslatePath:Shape;
		protected var _rotatePath:Shape;
		protected var _scalePath:Shape;
		protected var _visibility:Boolean;
		
		public function KPathView(object:KObject)
		{
			_object = object;	
			_translatePath = new Shape();
			_nextTranslatePath = new Shape();
			_rotatePath = new Shape();
			_scalePath = new Shape();
			visible = false;
		}
		
		public function setDrawingArea(translateHost:DisplayObjectContainer, rotateHost:DisplayObjectContainer, scaleHost:DisplayObjectContainer):void
		{
			translateHost.addChild(_translatePath);
			translateHost.addChild(_nextTranslatePath);
			rotateHost.addChild(_rotatePath);
			scaleHost.addChild(_scalePath);
		}
		
		public function clearPoints():void
		{
			_translatePoints = null;
			_rotatePoints = null;
			_scalePoints = null;
			_nextTranslatePoints = null;
			
			_translatePath.graphics.clear();
			_nextTranslatePath.graphics.clear();
			_rotatePath.graphics.clear();
			_scalePath.graphics.clear();
		}
		
		public function recomputePathPoints(time:int):void
		{
			
		}
		
		public function renderPathView(time:int):void
		{
			_currentCentroid = _object.transformMatrix(time).transformPoint(_object.centroid);
			renderTranslationPath(time, _translatePoints, _translatePath);
			renderTranslationPath(time, _nextTranslatePoints, _nextTranslatePath);
			renderRotationPath(time, _rotatePoints, _rotatePath);
			renderScalePath(time, _scalePoints, _scalePath);
		}
		
		protected function renderTranslationPath(time:int, path:Vector.<KTimedPoint>, display:Shape):void
		{
			display.graphics.clear();
			
			if(!path || path.length == 0)
				return;

			display.graphics.lineStyle(PATH_THICKNESS, PATH_TRANSLATE_COLOR);
			display.graphics.moveTo(path[0].x, path[0].y);
			
			for(var i:int = 1; i<path.length; i++)
				display.graphics.lineTo(path[i].x, path[i].y);
			
			_drawArrowHead(display, PATH_TRANSLATE_COLOR, path);
		}
		
		protected function renderRotationPath(time:int, path:Vector.<KTimedPoint>, display:Shape):void
		{
			display.graphics.clear();
			
			if(!path || path.length == 0)
				return;
			
			display.graphics.lineStyle(PATH_THICKNESS, PATH_ROTATE_COLOR);
			display.graphics.moveTo(path[0].x+_currentCentroid.x, path[0].y+_currentCentroid.y);
			
			for(var i:int = 1; i<path.length; i++)
				display.graphics.lineTo(path[i].x+_currentCentroid.x, path[i].y+_currentCentroid.y);
			
			_drawArrowHead(display, PATH_ROTATE_COLOR, path);
		}
		
		protected function renderScalePath(time:int, path:Vector.<KTimedPoint>, display:Shape):void
		{
			display.graphics.clear();
			
			if(!path || path.length == 0)
				return;
			
			display.graphics.lineStyle(PATH_THICKNESS, PATH_SCALE_COLOR);
			display.graphics.moveTo(path[0].x+_currentCentroid.x, path[0].y+_currentCentroid.y);
			
			for(var i:int = 1; i<path.length; i++)
				display.graphics.lineTo(path[i].x+_currentCentroid.x, path[i].y+_currentCentroid.y);
			
			_drawArrowHead(display, PATH_SCALE_COLOR, path);
		}
		
		public function set visible(visibility:Boolean):void
		{
			_visibility = visibility;
			_translatePath.visible = visibility;
			_nextTranslatePath.visible = visibility;
			_rotatePath.visible = visibility;
			_scalePath.visible = visibility;
		}
		
		public function get visible():Boolean
		{
			return _visibility;
		}
		
		protected function _drawArrowHead(display:Shape, color:uint, points:Vector.<KTimedPoint>):void
		{
			var length:int = points.length;
			var directionStart:int;
			
			if(length > 5)
				directionStart = 5;
			else if(length ==2)
				directionStart = 2;
			else
				return;
			
			var direction:KTimedPoint = points[length-1].clone();
			var drawPoint:KTimedPoint = direction.clone();
			direction.subtract(points[length-directionStart]);
			if(display == _rotatePath || display == _scalePath)
			{
				drawPoint.x += _currentCentroid.x;
				drawPoint.y += _currentCentroid.y;
			}
			
			var triangleVertices:Vector.<Number> = _getTriangleVertices(direction, drawPoint);
			
			display.graphics.beginFill(color);
			display.graphics.drawTriangles(triangleVertices);
			display.graphics.endFill();
		}
		
		//Construct a triangular arrow head.
		protected function _getTriangleVertices(vector:KTimedPoint,start:KTimedPoint):Vector.<Number>
		{
			//Find the vector's unit vector
			var magnitude:Number = Math.sqrt(vector.x*vector.x + vector.y*vector.y);
			var unitVector:Point = new Point(vector.x/magnitude*7,vector.y/magnitude*7);
			
			//Find the ortogonal vector for the arrow's direction.
			//This vector will form the direction of the triangular arrow head's base.
			//Eg: If given vector is <a,b> then the orthogonal vector will be <-b, a>.
			var orthogonal:Point = new Point(-unitVector.y,unitVector.x); 
			
			//Organise the points into three vertices that form the triangular arrow head.
			var vertex1:Point = new Point(unitVector.x+start.x, unitVector.y+start.y);
			var vertex2:Point = new Point(-orthogonal.x+start.x, -orthogonal.y+start.y);
			var vertex3:Point = new Point(orthogonal.x+start.x, orthogonal.y+start.y);
			return Vector.<Number>([vertex1.x, vertex1.y, 
				vertex2.x, vertex2.y, vertex3.x, vertex3.y]);
		}
	}
}