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
			redraw(KAppState.getCurrentTime());
		}
		
		private function _handleMouseOut(e:MouseEvent):void
		{
			_thickness[e.target] = _THICKNESS_THIN;
			redraw(KAppState.getCurrentTime());
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
		
		public function redraw(kskTime:Number):void
		{
			if(_object == null || _object.getVisibility(kskTime) == 0)
			{
				this.visible = false;
				return;
			}
			
			_pathT.graphics.clear();
			_pathR.graphics.clear();
			_pathS.graphics.clear();
			
			var m:Matrix;			
			var translationRef:int = KTransformMgr.TRANSLATION_REF;
			var rotationRef:int = KTransformMgr.ROTATION_REF;
			var scaleRef:int = KTransformMgr.SCALE_REF;
			var key:KSpatialKeyFrame = _object.transformMgr.getKeyFrame(
				translationRef, kskTime) as KSpatialKeyFrame;
			
			if(key)
			{
				var ctr:Point = _object.defaultCenter;
				m = _object.getFullMatrix(key.startTime());
				if(0 < (key.endTime-key.startTime()))
				{
					_drawCursorPath(key.translate.path.path, m.transformPoint(ctr),_pathT);
				}	
				
				key = key.next as KSpatialKeyFrame;
					
				//Draw the next key if it exists
				if(key)
				{
					if(0 < (key.endTime-key.startTime()))
					{
						m = _object.getFullMatrix(key.startTime());
						_drawCursorPath(key.translate.path.path, m.transformPoint(ctr),_pathT);
					}
				}
				
			}
			
			m = _object.getFullMatrix(kskTime);

			key = _object.transformMgr.getKeyFrame(rotationRef,kskTime) as KSpatialKeyFrame;
			if (key != null)
			{
				if(0 < (key.endTime-key.startTime()))
					_drawCursorPath(key.rotate.path.path,m.transformPoint(key.center),_pathR);
			}
			
			key = _object.transformMgr.getKeyFrame(scaleRef,kskTime) as KSpatialKeyFrame;
			if (key != null)
			{
				if(0 < (key.endTime-key.startTime()))
					_drawCursorPath(key.scale.path.path,m.transformPoint(key.center),_pathS);
			}
			
			this.visible = true;
		}
	
		private function _drawCursorPath(points:Vector.<KPathPoint>, 
										 origin:Point, path:Sprite):void
		{
			var min:Number = KPath.MINIMUM_DISPLAY_DURATION;
			var length:uint = points.length;
			if(length <= 0 || (length == 2 && Math.abs(points[0].time-points[1].time) <= min))
				return;
			var color:uint = _colors[path];
			var thickness:int = _thickness[path];
			var grph:Graphics = _graphics[path];
			var prevTime:Number = 0;
			grph.lineStyle(thickness, color);			
			if((path == _pathR || path == _pathS) && thickness == _THICKNESS_THICK)
			{
				grph.beginFill(color);
				grph.drawCircle(origin.x, origin.y, 5);
				grph.endFill();
			}
			grph.moveTo(origin.x+points[0].x, origin.y+points[0].y);
			for(var i:int = 0; i<length; i++)
			{
				var p:Point = points[i].add(origin);
				grph.lineTo(p.x, p.y);
			}	
			if (length > 10)
			{
				var n:uint = length - 1;
				var startPoint:Point = points[n].add(origin);
				var vector:Point = points[n-1].subtract(points[n-5]);
				grph.beginFill(color);
				grph.drawTriangles(_getTriangleVertices(vector,startPoint));
				grph.endFill();
			}
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