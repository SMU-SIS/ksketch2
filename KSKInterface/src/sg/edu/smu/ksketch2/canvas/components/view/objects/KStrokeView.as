/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.canvas.components.view.objects
{
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch2.canvas.controls.interactors.draw.KDrawInteractor;
	import sg.edu.smu.ksketch2.events.KObjectEvent;
	import sg.edu.smu.ksketch2.model.data_structures.IKeyFrame;
	import sg.edu.smu.ksketch2.model.data_structures.KModelObjectList;
	import sg.edu.smu.ksketch2.model.objects.KGroup;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.model.objects.KStroke;
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;
	import sg.edu.smu.ksketch2.utils.KMathUtil;
	
	//KSKETCH-SYNPHNE
	import sg.edu.smu.ksketch2.KSketchGlobals;
	
	public class KStrokeView extends KObjectView
	{
		private var _points:Vector.<Point>;
		private var _thickness:Number = KDrawInteractor.penThickness;
		private var _color:uint = KDrawInteractor.penColor;
		private var _glowFilter:Array;
		
		//KSKETCH-SYNPHNE
		private var _hide:Boolean;
		
		/**
		 * Object view representing strokes
		 */
		public function KStrokeView(object:KStroke)
		{
			super(object);
			
			if(object)
			{
				points = object.points;
				_color = object.color;
				_thickness = object.thickness;
				_ghost = new KStrokeGhost(object.points, object.color, object.thickness);
				
				//KSKETCH-SYNPHNE
				_hide = object.hide;
			}
			else
				_points = new Vector.<Point>();

			
			var filter:GlowFilter = new GlowFilter(_color, 1,14,14,32,1, false, false);
			_glowFilter = [filter];
			_render_DrawStroke(_color);
			cacheAsBitmap = true;
		}
		
		override public function eraseIfHit(xPoint:Number, yPoint:Number, time:Number, op:KCompositeOperation):void
		{
			//if(hitTestPoint(xPoint, yPoint, true))
			//KSKETCH-SYNPHNE
			if(hitTestPoint(xPoint, yPoint, true) && !_object.template)
			{
				//do a check if object belongs to a group and if all the objects in the group are erased at that time
				var parent:KGroup = _object.parent;
				_object.visibilityControl.setVisibility(false, time, op, false);
				_object.transformInterface.clearAllMotionsAfterTime(time, op);	
				
				if(parent.id > 0)
				{
					var isErasedGroup:Boolean = false;
					
					isErasedGroup = checkEraseInGroup(parent, time);
					
					if(isErasedGroup)
					{
						//parent.visibilityControl.setVisibility(true, time, op, false);
						parent.visibilityControl.setVisibility(false, time, op, false);
						parent.transformInterface.clearAllMotionsAfterTime(time, op);
						parent = parent.parent;
					}
				}
			}
		}
		
		public function checkObjectErased(time:Number):Boolean
		{
			var isErased:Boolean = false;
			
			var parent:KGroup = _object.parent;
			var isInGroup:Boolean = false;
			
			if(parent)
				if(parent.id > 0)
					isInGroup = true;
			
			if(!isInGroup)
			{
				if(_object.visibilityControl.alpha(time) <= 0.2)
					isErased = true;
			}
			else
				isErased = checkEraseInGroup(parent, time);
			
			return isErased;
		}
		
		private function checkEraseInGroup(parent:KGroup, time:Number):Boolean
		{
			var isErased:Boolean = false;
			
			var children:KModelObjectList = parent.children;
			
			if(children.length() < 1)
				return true;
			
			var visibilityArr:Array = new Array(children.length());
			var i:int;
			
			for(i=0; i<visibilityArr.length; i++)
			{
				var child:KObject = children.getObjectAt(i);
				
				visibilityArr[i] = 0;
				if(child.visibilityControl.alpha(time) == 0.2 || child.visibilityControl.alpha(time) == 0)
					visibilityArr[i] = 1;
			}
			
			var checkNum:Number=0;
			
			for(i=0; i< visibilityArr.length; ++i)
			{
				if(visibilityArr[0] == visibilityArr[i])
					++checkNum;
			}
			
			if(checkNum==visibilityArr.length)
			{
				if(visibilityArr[0] == 1)
					isErased = true;
			}
			
			return isErased;
		}
		
		public function checkObjectDynamic(time:Number):Boolean
		{
			var isDynamic:Boolean = false;
			
			var parent:KGroup = _object.parent;
			var isInGroup:Boolean = false;
			
			if(parent)
				if(parent.id > 0)
					isInGroup = true;
			
			if(!isInGroup)
			{
				var activeKey:IKeyFrame = object.transformInterface.getActiveKey(0);
				if(activeKey.previous || activeKey.next)
					isDynamic = true;
			}
			else
				isDynamic = checkDynamicInGroup(parent, time);
			
			return isDynamic;
		}
		
		private function checkDynamicInGroup(parent:KGroup, time:Number):Boolean
		{
			var isDynamic:Boolean = false;
			var activeKey:IKeyFrame;
			
			var children:KModelObjectList = parent.children;
			
			if(children.length() < 1)
				return true;
			
			activeKey = parent.transformInterface.getActiveKey(0);
			if(activeKey.previous || activeKey.next)
				return true;
			
			var dynamicArr:Array = new Array(children.length());
			var i:int;
			
			for(i=0; i<dynamicArr.length; i++)
			{
				var child:KObject = children.getObjectAt(i);
				
				dynamicArr[i] = 0;
				
				activeKey = object.transformInterface.getActiveKey(0);
				if(activeKey.previous || activeKey.next)
					dynamicArr[i] = 1;
			}
			
			var checkNum:Number=0;
			
			for(i=0; i< dynamicArr.length; ++i)
			{
				if(dynamicArr[0] == dynamicArr[i])
					++checkNum;
			}
			
			if(checkNum==dynamicArr.length)
			{
				if(dynamicArr[0] == 1)
					isDynamic = true;
			}
			
			return isDynamic;
		}
		
		/**
		 * Setting this explicitly changes the points that will be drawn
		 */
		public function set points(newPoints:Vector.<Point>):void
		{
			_points = newPoints;
			_render_DrawStroke(_color);
		}
		
		/**
		 * Adds a point to the end of this stroke view. Forces a rerender
		 */
		public function edit_AddPoint(newPoint:Point):void
		{
			_points.push(newPoint);
			_render_DrawStroke(_color);
		}
		
		/**
		 * Changes the color for this stroke view. Forces a rerender
		 */
		public function set color(newColor:uint):void
		{
			_color = newColor;
			_render_DrawStroke(_color);
		}
		
		/**
		 * Changes the color for this stroke view. Forces a rerender
		 */
		public function set thickness(newThickness:Number):void
		{
			_thickness = newThickness;
			_render_DrawStroke(_color);
		}
		
		/**
		 * Draws this stroke view
		 */
		protected function _render_DrawStroke(newColor:uint):void
		{
			graphics.clear();
			if(!_points || _points.length == 0)
				return;
			
			// Initialize for rendering the path				
			if (_points.length == 1 || (_points.length == 2 && _points[0].x == _points[1].x && _points[0].y == _points[1].y))
			{
				graphics.lineStyle();
				graphics.beginFill(newColor);
				graphics.drawCircle(_points[0].x, _points[0].y, 0.5*_thickness);
				graphics.endFill();				
				return;	
			}
			
			var i:int;
			var p0:Point = null;
			var p1:Point = null;
			var p2:Point = null;
			var p3:Point = null;
			
			var b0:Point = new Point(0,0);
			var b1:Point = new Point(0,0);
			var b2:Point = new Point(0,0);
			var b3:Point = new Point(0,0);
			

			p1 = _points[0];
			p2 = _points[1];
			if (_points.length > 2) {
				p3 = _points[2];
			} 
			graphics.lineStyle(_thickness, newColor);
			graphics.moveTo(p1.x, p1.y);

			// Draw the line
			for (i = 1; i < _points.length; i++) 
			{
				// Draw the curve segment
				if (KMathUtil.catmullRomToBezier(p0, p1, p2, p3, b0, b1, b2, b3))
				{
					graphics.cubicCurveTo(b1.x, b1.y, b2.x, b2.y, b3.x, b3.y);
				}
				
				p0 = p1;
				p1 = p2;
				p2 = p3;
				p3 = (i + 1 < _points.length) ?  _points[i+1] : null;
			}
		}
		
		/**
		 * Updates the selection for this stroke view by adding/removing a filter to it
		 */
		override protected function _updateSelection(event:KObjectEvent):void
		{
			if(_object.selected)
			{
				_render_DrawStroke(0xffffff);
				filters = _glowFilter;
			}
			else
			{
				_render_DrawStroke(_color);
				filters = [];
			}
				
			
			super._updateSelection(event);
		}
		
		//KSKETCH-SYNPHNE
		public function changeActivityHighlight(time:int, hide:Boolean):void
		{
			if(!hide)
				_render_DrawStroke(KSketchGlobals.COLOR_GREY_LIGHT);
			else
				_render_DrawStroke(KSketchGlobals.COLOR_WHITE);
			
			_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_VISIBILITY_CHANGED, _object, time));
		}
		
		public function resetActivityHighlight(time:int):void
		{
			_render_DrawStroke(_color);
			_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_VISIBILITY_CHANGED, _object, time));
		}
		
		public function hardErase(time:Number, op:KCompositeOperation):void
		{
			_object.visibilityControl.setVisibility(false, time, op, false);
			_object.transformInterface.clearAllMotionsAfterTime(time, op);	
		}
	}
}