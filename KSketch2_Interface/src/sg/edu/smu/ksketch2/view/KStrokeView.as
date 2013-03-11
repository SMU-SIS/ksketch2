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
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch2.controls.interactors.KDrawInteractor;
	import sg.edu.smu.ksketch2.events.KObjectEvent;
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
		public function KStrokeView(object:KStroke, isGhost:Boolean = false, showPath:Boolean = true)
		{
			if(!isGhost)
				_ghost = new KStrokeView(object, true, showPath);
			super(object, isGhost, showPath);
			
			if(object)
			{
				points = object.points;
				_color = object.color;
				_thickness = object.thickness;
			}
			else
				_points = new Vector.<Point>();
			

			var filter:GlowFilter = new GlowFilter(_color, 1,10,10,8,1,true, true);
			_glowFilter = [filter];
			_render_DrawStroke();
			cacheAsBitmap = true;
		}
		
		override public function eraseIfHit(xPoint:Number, yPoint:Number, time:int, op:KCompositeOperation):void
		{
			if(hitTestPoint(xPoint, yPoint, true))
				_object.visibilityControl.setVisibility(false, time, op);
		}
		
		/**
		 * Setting this explicitly changes the points that will be drawn
		 */
		public function set points(newPoints:Vector.<Point>):void
		{
			_points = newPoints;
			_render_DrawStroke();
		}
		
		/**
		 * Adds a point to the end of this stroke view. Forces a rerender
		 */
		public function edit_AddPoint(newPoint:Point):void
		{
			_points.push(newPoint);
			_render_DrawStroke();
		}
		
		/**
		 * Changes the color for this stroke view. Forces a rerender
		 */
		public function set color(newColor:uint):void
		{
			_color = newColor;
			_render_DrawStroke();
		}
		
		/**
		 * Changes the color for this stroke view. Forces a rerender
		 */
		public function set thickness(newThickness:Number):void
		{
			_thickness = newThickness;
			_render_DrawStroke();
		}
		
		/**
		 * Draws this stroke view
		 */
		protected function _render_DrawStroke():void
		{
			graphics.clear();
			if(!_points)
				return;
			
			var length:int = _points.length;

			if(length < 2)
				return;
			
			graphics.lineStyle(_thickness, _color);

			graphics.moveTo(_points[0].x, _points[0].y);
			
			var i:int;
			for(i = 1; i < length; i++)
				graphics.lineTo(_points[i].x, _points[i].y);
			
			//For debug!
			//if(_object && _object.centroid)
				//graphics.drawCircle(_object.centroid.x, _object.centroid.y, 3);
		}
		
		/**
		 * Updates the selection for this stroke view by adding/removing a filter to it
		 */
		override protected function _updateSelection(event:KObjectEvent):void
		{
			if(_object.selected)
				filters = _glowFilter;
			else
				filters = [];
			
			super._updateSelection(event);
		}
	}
}