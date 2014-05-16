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
	import sg.edu.smu.ksketch2.model.data_structures.KModelObjectList;
	import sg.edu.smu.ksketch2.model.objects.KGroup;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.model.objects.KStroke;
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;
	
	public class KStrokeView extends KObjectView
	{
		private var _points:Vector.<Point>;
		private var _thickness:Number = KDrawInteractor.penThickness;
		private var _color:uint = KDrawInteractor.penColor;
		private var _glowFilter:Array;
		
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
			if(hitTestPoint(xPoint, yPoint, true))
			{
				_object.visibilityControl.setVisibility(false, time, op);
				_object.transformInterface.clearAllMotionsAfterTime(time, op);	
				
				//do a check if object belongs to a group and if all the objects in the group are erased at that time
				
				var parent:KGroup = _object.parent;
				while(parent.id > 0)
				{
					var isErasedGroup:Boolean = false;
					var children:KModelObjectList = parent.children;
					
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
							isErasedGroup = true;
					}
					
					if(isErasedGroup)
					{
						//parent.visibilityControl.setVisibility(false, time, op);
						parent.transformInterface.clearAllMotionsAfterTime(time, op);
						parent = parent.parent;
					}
					else
						break;
						
				}
			}
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
			if(!_points)
				return;
			
			var length:int = _points.length;

			if(length < 2)
				return;
			
			graphics.lineStyle(_thickness, newColor);

			graphics.moveTo(_points[0].x, _points[0].y);
			
			var i:int;
			for(i = 1; i < length; i++)
				graphics.lineTo(_points[i].x, _points[i].y);
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
	}
}