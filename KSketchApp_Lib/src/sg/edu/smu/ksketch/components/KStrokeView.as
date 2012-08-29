/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package sg.edu.smu.ksketch.components
{
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch.event.KObjectEvent;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.model.KStroke;
	import sg.edu.smu.ksketch.utilities.KAppState;
	
	public class KStrokeView extends KObjectView
	{		
		public function KStrokeView(appState:KAppState, astroke:KStroke)
		{
			super(appState,astroke);
			_draw();			
			stroke.addEventListener(KObjectEvent.EVENT_POINTS_CHANGED, _objectChangedEventHandler);
			stroke.addEventListener(KObjectEvent.EVENT_COLOR_CHANGED, _objectChangedEventHandler);
		}
		
		public override function removeListeners():void
		{
			super.removeListeners();
			stroke.removeEventListener(KObjectEvent.EVENT_POINTS_CHANGED, _objectChangedEventHandler);
			stroke.removeEventListener(KObjectEvent.EVENT_COLOR_CHANGED, _objectChangedEventHandler);
		}
		
		public override function set selected(value:Boolean):void
		{
			if(_selected != value)
			{
				_selected = value;
				_redrawGraphic();
			}
		}
		
		public override function set debug(value:Boolean):void
		{
			if(_debug != value)
			{
				_debug = value;
				_redrawGraphic();
			}
		}
		
		public function get stroke():KStroke
		{
			return object as KStroke;
		}
		
		protected override function _objectChangedEventHandler(event:KObjectEvent):void
		{
			super._objectChangedEventHandler(event);
			switch(event.type)
			{
				case KObjectEvent.EVENT_POINTS_CHANGED:
				case KObjectEvent.EVENT_COLOR_CHANGED:
					_redrawGraphic();
					break;
			}
		}		
		
		private function _draw():void
		{
			_redrawGraphic();
			var alpha:Number = object.getVisibility(time);
			updateVisibility(alpha);
			if(alpha > KObjectView.GHOST_ALPHA)
				updateTransform(object.getFullMatrix(time));
		}
		
		// Updating display object
		private function _redrawGraphic():void
		{
			var points:Vector.<Point> = stroke.points;
			if(points.length == 1)
				points.push(new Point(points[0].x+1, points[0].y));
			
			this.graphics.clear();
			if(_selected)
			{
				_redrawPoints(stroke.thickness+4, stroke.color, points);
				_redrawPoints(stroke.thickness, 0xFFFFFF, points);
			}
			else
				_redrawPoints(stroke.thickness, stroke.color, points);
			
			if(_debug)
				_drawDottedLines(this.getBounds(this),2,0xFF0000,1);
			if (_selected && object != null && object.getParent(time) != null &&
				object.getParent(time).getParent(time) == null)
				_drawDottedLines(this.getBounds(this),2,0x0000FF,0.5);
		}
		
		private function _redrawPoints(thickness:Number, color:uint, points:Vector.<Point>):void
		{
			this.graphics.lineStyle(thickness, color);
			for(var i:int = 0;i<points.length;i++)
			{
				if(i == 0)
					this.graphics.moveTo(points[i].x, points[i].y);
				else					
					this.graphics.lineTo(points[i].x, points[i].y);
			}			
		}		
	}
}