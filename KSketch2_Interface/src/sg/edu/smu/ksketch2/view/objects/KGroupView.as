/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.view.objects
{
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	
	import sg.edu.smu.ksketch2.events.KObjectEvent;
	import sg.edu.smu.ksketch2.model.objects.KObject;

	public class KGroupView extends KObjectView
	{
		private var _glowFilter:Array;
		public static const BOUNDS_THICKNESS:Number = Capabilities.screenDPI/25;
		public static const DOT_LENGTH:Number = Capabilities.screenDPI/6;
		
		public function KGroupView(object:KObject)
		{
			super(object);
			_ghost = new KGroupGhost();
			addChild(_ghost);
			
			if(_object.id == 0)
				_ghost.visible = true;
		}
		
		override protected function _updateSelection(event:KObjectEvent):void
		{
			super._updateSelection(event);
			
			graphics.clear();
			
			if(!visible)
				return;

			if(parent && _object.selected)
			{
				var rect:Rectangle = this.getRect(parent);
				graphics.lineStyle(BOUNDS_THICKNESS, 0x000000, 0.3);
				
				_dottedLine(rect.x, rect.y,
							rect.x + rect.width, rect.y);
				_dottedLine(rect.x + rect.width, rect.y,
							rect.x + rect.width, rect.y + rect.height);
				_dottedLine(rect.x + rect.width, rect.y + rect.height,
							rect.x, rect.y + rect.height);
				_dottedLine(rect.x, rect.y + rect.height,
							rect.x, rect.y);
			}
		}
		
		/**
		 * Draws a dotted line from the left to right, top to bottom (flash coordinate space!) direction
		 */
		private function _dottedLine(fromX:Number, fromY:Number, toX:Number, toY:Number):void
		{
			//Figure out where to start and end
			var startX:Number = Math.min(fromX, toX);
			var startY:Number = Math.min(fromY, toY);
			var endX:Number = Math.max(fromX, toX);
			var endY:Number = Math.max(fromY, toY);
			
			var draw:Boolean = false;
			var currentX:Number = startX;
			var currentY:Number = startY;
			
			//Loop and draw the dotted line!
			while(currentX < endX || currentY < endY)
			{
				if(draw)
					graphics.lineTo(currentX, currentY);
				else
					graphics.moveTo(currentX, currentY);
				
				if(currentX < endX)
				{
					currentX += DOT_LENGTH;
					
					if(endX < currentX)
						currentX = endX;
				}
				
				if(currentY < endY)
				{
					currentY += DOT_LENGTH;
					
					if(endY < currentY)
						currentY = endY;
				}
				
				draw = !draw;
			}
		}
	}
}