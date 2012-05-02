/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.components
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch.event.KWidgetEvent;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.utilities.IModelObjectList;
	import sg.edu.smu.ksketch.utilities.KAppState;
	import sg.edu.smu.ksketch.utilities.KMathUtil;
	
	public class KWidget extends KWidgetAsset_v1 implements IWidget
	{
		private var _center:Point;
		private var _isMovingCenter:Boolean;
		
		private var _appState:KAppState;
		
		public function KWidget(appState:KAppState)
		{
			super();
			
			_appState = appState;
			_isMovingCenter = false;
			
			if(KAppState.IS_AIR)
			{
				this.trans_ring.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightDown);
				this.rotate_ring.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightDown);
				this.scale1.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightDown);
				this.scale2.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightDown);
				this.scale3.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightDown);
				this.scale4.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightDown);
				this.move_center.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightDown);
				
				this.trans_ring.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onUp);
				this.rotate_ring.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onUp);
				this.scale1.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onUp);
				this.scale2.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onUp);
				this.scale3.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onUp);
				this.scale4.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onUp);
				this.move_center.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onUp);
			}
			
			_center = new Point();
		}
		
		private function onRightDown(event:MouseEvent):void
		{
			if(!enabled)
				return;
			
			switch(event.target)
			{
				case this.trans_ring:
					this.dispatchEvent(new KWidgetEvent(KWidgetEvent.RIGHT_DOWN_TRANSLATE, event.stageX, event.stageY));
					break;
				case this.rotate_ring:
					this.dispatchEvent(new KWidgetEvent(KWidgetEvent.RIGHT_DOWN_ROTATE, event.stageX, event.stageY));
					break;
				case this.scale1:
				case this.scale2:
				case this.scale3:
				case this.scale4:
					this.dispatchEvent(new KWidgetEvent(KWidgetEvent.RIGHT_DOWN_SCALE, event.stageX, event.stageY));
					break;
				case this.move_center:
					this.dispatchEvent(new KWidgetEvent(KWidgetEvent.RIGHT_DOWN_CENTER, event.stageX, event.stageY));
					break;
			}
		}
		
		private function onUp(event:MouseEvent):void
		{
			if(!enabled)
				return;
			
			switch(event.target)
			{
				case this.trans_ring:
					this.dispatchEvent(new KWidgetEvent(KWidgetEvent.UP_TRANSLATE, event.stageX, event.stageY));
					break;
				case this.rotate_ring:
					this.dispatchEvent(new KWidgetEvent(KWidgetEvent.UP_ROTATE, event.stageX, event.stageY));
					break;
				case this.scale1:
				case this.scale2:
				case this.scale3:
				case this.scale4:
					this.dispatchEvent(new KWidgetEvent(KWidgetEvent.UP_SCALE, event.stageX, event.stageY));
					break;
				case this.move_center:
					this.dispatchEvent(new KWidgetEvent(KWidgetEvent.UP_CENTER, event.stageX, event.stageY));
					break;
			}
		}
		
		public function get center():Point
		{
			return _center;
		}
		
		public function set isMovingCenter(value:Boolean):void
		{
			_isMovingCenter = value;
			if(_isMovingCenter)
				alpha = 0.5;
			else
				alpha = 1;
		}
		
		public function get isMovingCenter():Boolean
		{
			return _isMovingCenter;
		}
		
		public function highlightSelection():void
		{
			var objects:IModelObjectList = _appState.selection == null?null:_appState.selection.objects;
			if(objects == null || objects.length() == 0)
				visible = false;
			else
			{
				var angle:Number;
				if(objects.length() == 1)
				{
					var obj:KObject = objects.getObjectAt(0);
					var m:Matrix = obj.getFullPathMatrix(_appState.time);
					angle = KMathUtil.getRotation(m);
				}
				else
					angle = 0;
				
				var newC:Point = _appState.selection.centerAt(_appState.time);
				visible = true;
				_center.x = newC.x;
				_center.y = newC.y;
				x = _center.x;
				y = _center.y;
				rotation = angle;
			}
		}

	}
}