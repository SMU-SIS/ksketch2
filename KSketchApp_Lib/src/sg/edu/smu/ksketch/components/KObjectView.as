/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

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
		private var _appState:KAppState;
		private var _object:KObject;
		private var _showPath:Boolean;
		private var _showAllPath:Boolean;
		private var _path:KPathView;
		
		public function KObjectView(appState:KAppState,object:KObject)
		{
			super();
			_appState = appState;
			_showAllPath = false;
			_object = object;
			_object.addEventListener(KObjectEvent.EVENT_TRANSFORM_CHANGED, _objectChangedEventHandler);
			_object.addEventListener(KObjectEvent.EVENT_VISIBILITY_CHANGED, _objectChangedEventHandler);
			_path = new KPathView(_object);
		}
		
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
			if(_showPath)
				this.parent.removeChild(_path);
			this.parent.removeChild(this);
		}
		
		public function updateTransform(newTransform:Matrix):void
		{
			transform.matrix = newTransform;
			if(_showPath)
				_path.redraw(_appState.time, _showAllPath);
		}
		
		public function updateVisibility(newAlpha:Number):void
		{
			this.alpha = newAlpha;
		}
		
		public function set debug(value:Boolean):void
		{
			this.graphics.clear();
			if(value)
				_drawDottedLines(this.getBounds(this),2,0xFF0000,1);
		}		
		
		public function set selected(selected:Boolean):void
		{
			this.graphics.clear();				
			if (selected && object != null && object.getParent(time) != null &&
				object.getParent(time).getParent(time) == null)
				_drawDottedLines(this.getBounds(this),2,0X0000FF,1);
		}
		
		public function set showCursorPath(show:Boolean):void
		{
			if(_showPath != show)
			{
				_showPath = show;
				if(_showPath)
				{
					_path.redraw(_appState.time, _showAllPath);
					this.parent.addChild(_path);
				}
				else
					this.parent.removeChild(_path);
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
		
		private function _drawDottedLine(startPoint:Point, endPoint:Point):void
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