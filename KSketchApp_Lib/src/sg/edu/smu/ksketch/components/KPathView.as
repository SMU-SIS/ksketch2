/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.components
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import sg.edu.smu.ksketch.model.IKeyFrame;
	import sg.edu.smu.ksketch.model.IReferenceFrame;
	import sg.edu.smu.ksketch.model.ISpatialKeyframe;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.model.geom.KPath;
	import sg.edu.smu.ksketch.model.geom.KPathPoint;
	import sg.edu.smu.ksketch.model.implementations.KSpatialKeyFrame;
	import sg.edu.smu.ksketch.operation.KTransformMgr;
	import sg.edu.smu.ksketch.utilities.KAppState;
	
	public class KPathView extends Sprite
	{
		private static const _THICKNESS_THIN:int = 2;
		private static const _THICKNESS_THICK:int = 4;
				
		private var _object:KObject;
		private var _pathR:Sprite;
		private var _pathS:Sprite;
		private var _pathT:Sprite;
		
		private var _colors:Dictionary;
		private var _thickness:Dictionary;
		private var _graphics:Dictionary;
		
		public function KPathView(object:KObject)
		{
			super();
			_pathR = new Sprite();
			_pathS = new Sprite();
			_pathT = new Sprite();
			addChild(_pathR);
			addChild(_pathS);
			addChild(_pathT);
			_object = object;
	
			_colors = new Dictionary();
			_thickness = new Dictionary();
			_graphics = new Dictionary();

			_colors[_pathT] = 0x0000ff;
			_thickness[_pathT] = _THICKNESS_THIN;
			_graphics[_pathT] = _pathT.graphics;
			
			_colors[_pathR] = 0x00ff00;
			_thickness[_pathR] = _THICKNESS_THIN;
			_graphics[_pathR] = _pathR.graphics;
			
			_colors[_pathS] = 0xff0000;
			_thickness[_pathS] = _THICKNESS_THIN;
			_graphics[_pathS] = _pathS.graphics;
						
			/*_pathT.addEventListener(MouseEvent.MOUSE_OVER, _handleMouseOver);
			_pathT.addEventListener(MouseEvent.MOUSE_OUT,_handleMouseOut);
			_pathR.addEventListener(MouseEvent.MOUSE_OVER, _handleMouseOver);
			_pathR.addEventListener(MouseEvent.MOUSE_OUT,_handleMouseOut);
			_pathS.addEventListener(MouseEvent.MOUSE_OVER, _handleMouseOver);
			_pathS.addEventListener(MouseEvent.MOUSE_OUT,_handleMouseOut);*/
		}

		private function _handleMouseOver(e:MouseEvent):void
		{	
			_thickness[e.target] = _THICKNESS_THICK;
//			redraw(KAppState.getCurrentTime(), _show);
		}
		
		private function _handleMouseOut(e:MouseEvent):void
		{
			_thickness[e.target] = _THICKNESS_THIN;
//			redraw(KAppState.getCurrentTime());
		}
		
		public function get object():KObject
		{
			return _object;
		}
		
		public function getTranslatePath():Sprite
		{
			return _pathT;
		}
		
		public function getRotatePath():Sprite
		{
			return _pathR;
		}
		
		public function getScalePath():Sprite
		{
			return _pathS;
		}
		
		public function redraw(time:Number, showAll:Boolean):void
		{
			_pathT.graphics.clear();
			_pathR.graphics.clear();
			_pathS.graphics.clear();
			_pathT.graphics.lineStyle(_thickness[_pathT],_colors[_pathT]);
			_pathR.graphics.lineStyle(_thickness[_pathR],_colors[_pathR]);
			_pathS.graphics.lineStyle(_thickness[_pathS],_colors[_pathS]);
			
			_drawKeyPaths(_getKeyToDraw(KTransformMgr.TRANSLATION_REF,time,showAll), showAll, KTransformMgr.TRANSLATION_REF);
			_drawKeyPaths(_getKeyToDraw(KTransformMgr.ROTATION_REF,time,showAll), showAll, KTransformMgr.ROTATION_REF);
			_drawKeyPaths(_getKeyToDraw(KTransformMgr.SCALE_REF,time,showAll), showAll, KTransformMgr.SCALE_REF);
		}
		
		private function _drawKeyPaths(targetKey:ISpatialKeyframe, showAll:Boolean, type:int):void
		{
			var position:Point;
			var transformAtTime:Matrix;
			
			while(targetKey)
			{
				if(targetKey.hasTransform())
				{
					transformAtTime = targetKey.getFullMatrix(targetKey.startTime(), new Matrix());
					position = transformAtTime.transformPoint(targetKey.center);
					
					if(type == KTransformMgr.TRANSLATION_REF)
						_drawCursorPath(targetKey.translate.path.path, position,_pathT);
					else if(type == KTransformMgr.ROTATION_REF)
						_drawCursorPath(targetKey.rotate.path.path, position,_pathR);
					else if(type == KTransformMgr.SCALE_REF)
						_drawCursorPath(targetKey.scale.path.path, position,_pathS);
				}
				
				if(showAll)
					targetKey = targetKey.next as ISpatialKeyframe;
				else
					targetKey = null;				
			}
		}
		
		
		private function _drawCursorPath(points:Vector.<KPathPoint>, origin:Point, path:Sprite):void
		{
			var length:int = points.length;
			var drawLayer:Graphics = path.graphics;
			if(length <= 0 || (length == 2 && Math.abs(points[0].time-points[1].time) <= 0))
				return;
			
			var currentPoint:Point = points[0].add(origin);
			
			drawLayer.moveTo(currentPoint.x, currentPoint.y);
			
			var i:int = 1;
			for(i; i<length; i++)
			{
				currentPoint = points[i].add(origin);
				drawLayer.lineTo(currentPoint.x, currentPoint.y);
			}
		}
		
		private function _getKeyToDraw(type:int, time:Number, showAll:Boolean):ISpatialKeyframe
		{
			if(showAll)
				return _object.getSpatialKeyAtOfAfter(_object.createdTime, type);
			else
				return _object.getSpatialKeyAtOfAfter(time, type);
		}
		
		//Construct a triangular arrow head.
		private function _getTriangleVertices(vector:Point,start:Point):Vector.<Number>
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