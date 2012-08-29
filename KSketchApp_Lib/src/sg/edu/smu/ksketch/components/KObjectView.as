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
	import flash.display.DisplayObjectContainer;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import sg.edu.smu.ksketch.event.KObjectEvent;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.utilities.KAppState;

	public class KObjectView extends Sprite implements IObjectView
	{
		public static const GHOST_ALPHA:Number = 0.3;
		protected var _debug:Boolean;
		protected var _selected:Boolean;
		protected var _appState:KAppState;
		protected var _object:KObject;
		protected var _showPath:Boolean;
		protected var _showAllPath:Boolean;
		protected var _pathVisible:Boolean;
		protected var _path:KPathView;
		
		public function KObjectView(appState:KAppState,object:KObject)
		{
			super();
			_appState = appState;
			_showAllPath = false;
			_object = object;
			_object.addEventListener(KObjectEvent.EVENT_TRANSFORM_CHANGED, _objectChangedEventHandler);
			_object.addEventListener(KObjectEvent.EVENT_VISIBILITY_CHANGED, _objectChangedEventHandler);
			_path = new KPathView(_object);
			pathVisible = true;
		}
		
		/**
		 * Forces this view object to always show its motion path
		 * Default is true.
		 */
		public function set pathVisible(value:Boolean):void
		{
			_pathVisible = value;
			
			if(!parent)
				return;
			
			if(pathVisible)
			{
				parent.addChild(_path);
			}
			else
			{
				if(_path.parent == parent)
				{
					parent.removeChild(_path);
				}
			}
			
		}
		
		public function get pathVisible():Boolean
		{
			return _pathVisible;
		}
		
		/**
		 * Forces this view object to either show its active keys or it's entire timeline
		 */
		public function set showCursorPathMode(showAll:Boolean):void
		{
			_showAllPath = showAll;
		}
		
		public function removeListeners():void
		{
			_object.removeEventListener(KObjectEvent.EVENT_TRANSFORM_CHANGED, _objectChangedEventHandler);
			_object.removeEventListener(KObjectEvent.EVENT_VISIBILITY_CHANGED, _objectChangedEventHandler);
		}
		
		public function updateParent(newParent:DisplayObjectContainer):void
		{
			newParent.addChild(this);
			_object.getFullPathMatrix(_appState.time);

			updateTransform(_object.getFullMatrix(_appState.time));
			if(_showPath)
				newParent.addChild(_path);
		}
		
		public function removeFromParent():void
		{
			if(_showPath && _path.parent == this.parent)
				this.parent.removeChild(_path);
			this.parent.removeChild(this);
		}
		
		public function updateTransform(newTransform:Matrix):void
		{
			transform.matrix = newTransform;
		
			if(_showPath && alpha != 0 && _selected)
			{
				if(!_path.parent)
					parent.addChild(_path);
				_path.redraw(_appState.time, _showAllPath);
			}
			else
			{
				_path.clear();
			}
		}
		
		public function updateVisibility(newAlpha:Number):void
		{
			this.alpha = newAlpha;

			if(alpha ==0)
				_path.clear();
		}
		
		public function set debug(value:Boolean):void
		{
			this.graphics.clear();
			if(value)
				_drawDottedLines(this.getBounds(this),2,0xFF0000,1);
		}		
		
		public function set selected(selected:Boolean):void
		{
			_selected = selected
			
			this.graphics.clear();				
			if (selected && object != null && object.getParent(time) != null &&
				object.getParent(time).getParent(time) == null)
				_drawDottedLines(this.getBounds(this),2,0X0000FF,1);
		}
		
		/**
		 * Toogles on/off for this object's motion paths.
		 * pathVisible takes precedence.
		 * showCursorPath = false will not work if pathVisible is true.
		 */
		public function set showCursorPath(show:Boolean):void
		{
			if(_showPath != show)
			{
				_showPath = show;
				if(_showPath)
					_path.redraw(_appState.time, _showAllPath);
				else
					_path.clear();
			}
		}		

		public function get object():KObject
		{
			return _object;
		}
		
		protected function get time():Number
		{
			return _appState.time;
		}

		protected function _objectChangedEventHandler(event:KObjectEvent):void
		{
			if(_object != event.object)
				throw new Error("view and object not matched!");
			switch(event.type)
			{
				case KObjectEvent.EVENT_TRANSFORM_CHANGED:
					if(_appState.time >= _object.createdTime)
					{
						updateTransform(_object.getFullMatrix(_appState.time));
					}
					break;
				case KObjectEvent.EVENT_VISIBILITY_CHANGED:
					updateVisibility(_object.getVisibility(_appState.time));
					break;
			}
		}		

		/**
		 * Bounding box function. Faulty so turned off.
		 */
		protected function _drawDottedLines(rect:Rectangle,thickness:Number, 
											color:uint, alpha:Number):void
		{			
			/*this.graphics.lineStyle(thickness, color, alpha, false, LineScaleMode.NONE);
			_drawDottedLine(new Point(rect.left, rect.top), new Point(rect.right, rect.top));
			_drawDottedLine(new Point(rect.right, rect.top), new Point(rect.right, rect.bottom));
			_drawDottedLine(new Point(rect.right, rect.bottom), new Point(rect.left, rect.bottom));
			_drawDottedLine(new Point(rect.left, rect.bottom), new Point(rect.left, rect.top));*/
		}
		
		protected function _drawDottedLine(startPoint:Point, endPoint:Point):void
		{
			var vectorX:Number = endPoint.x - startPoint.x;
			var vectorY:Number = endPoint.y - startPoint.y;
			var magnitude:Number = Math.sqrt(vectorX*vectorX + vectorY*vectorY);			
			var unitX:Number = vectorX/magnitude;
			var unitY:Number = vectorY/magnitude;
			for(var i:int = 0; i < magnitude; i += 10)
			{
				graphics.moveTo(startPoint.x+(unitX*i), startPoint.y+(unitY*i));
				graphics.lineTo(startPoint.x+(unitX*(i+2.5)), startPoint.y+(unitY*(i+2.5)))
			}
		}
	}
}