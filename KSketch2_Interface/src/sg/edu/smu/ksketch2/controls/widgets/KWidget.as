/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.controls.widgets
{
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.system.System;
	
	import mx.controls.Button;
	import mx.core.UIComponent;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.controls.interactioncontrol.IInteractionControl;
	import sg.edu.smu.ksketch2.controls.interactioncontrol.KInteractionControl;
	import sg.edu.smu.ksketch2.utils.KSelection;
	import sg.edu.smu.ksketch2.view.KModelDisplay;
	
	import spark.components.ToggleButton;
	
	public class KWidget extends KWidgetAsset implements IWidget
	{
		public var display:KModelDisplay;
		protected var _center:Point;
		protected var _disabled:Boolean;
		protected var _colorFilter:Array;
		protected var _glowFilter:Array;
		protected var _rightClickEnabled:Boolean;
		protected var _isMovingCenter:Boolean
		protected var _interactionControl:IInteractionControl;
		
		public function KWidget()
		{
			super();
		}
		
		public function init(interactionControl:IInteractionControl):void
		{
			_rightClickEnabled = Capabilities.playerType == "Desktop";
			_interactionControl = interactionControl;
			_isMovingCenter = false;
			_center = new Point();
			
			//Create a color matrix filter to show the disabled mode
			//Magic numbers for grayscale matrix
			var r:Number=0.212671;
			var g:Number=0.715160;
			var b:Number=0.072169;
			
			var matrix:Array = [];
			matrix = matrix.concat([r, g, b, 0, 0]);// red
			matrix = matrix.concat([r, g, b, 0, 0]);// green
			matrix = matrix.concat([r, g, b, 0, 0]);// blue
			matrix = matrix.concat([0, 0, 0, 1, 0]);// alpha
			_colorFilter = [new ColorMatrixFilter(matrix)];
			
			_glowFilter = [new GlowFilter(0xFF0000)];
			
			if(false)
			{
				widget.trans_ring.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightDown);
				widget.rotate_ring.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightDown);
				widget.scale1.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightDown);
				widget.scale2.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightDown);
				widget.scale3.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightDown);
				widget.scale4.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightDown);
				widget.move_center.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightDown);
				
				widget.trans_ring.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onUp);
				widget.rotate_ring.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onUp);
				widget.scale1.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onUp);
				widget.scale2.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onUp);
				widget.scale3.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onUp);
				widget.scale4.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onUp);
				widget.move_center.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onUp);
			}
		}
		
		/**
		 * Right click event handlers to handle right click events that weren't handled in the flash object itself
		 */
		protected function onRightDown(event:MouseEvent):void
		{
			switch(event.target)
			{
				case widget.trans_ring:
					widget.dispatchEvent(new KWidgetEvent(KWidgetEvent.DOWN_TRANSLATE, event.stageX, event.stageY));
					break;
				case widget.rotate_ring:
					widget.dispatchEvent(new KWidgetEvent(KWidgetEvent.DOWN_ROTATE, event.stageX, event.stageY));
					break;
				case widget.scale1:
				case widget.scale2:
				case widget.scale3:
				case widget.scale4:
					widget.dispatchEvent(new KWidgetEvent(KWidgetEvent.DOWN_SCALE, event.stageX, event.stageY));
					break;
				case widget.move_center:
					widget.dispatchEvent(new KWidgetEvent(KWidgetEvent.DOWN_TRANSLATE, event.stageX, event.stageY));
					break;
			}
		}
		
		protected function onUp(event:MouseEvent):void
		{
			if(!enabled)
				return;
			
			switch(event.target)
			{
				case widget.trans_ring:
					widget.dispatchEvent(new KWidgetEvent(KWidgetEvent.UP_TRANSLATE, event.stageX, event.stageY));
					break;
				case widget.rotate_ring:
					widget.dispatchEvent(new KWidgetEvent(KWidgetEvent.UP_ROTATE, event.stageX, event.stageY));
					break;
				case widget.scale1:
				case widget.scale2:
				case widget.scale3:
				case widget.scale4:
					widget.dispatchEvent(new KWidgetEvent(KWidgetEvent.UP_SCALE, event.stageX, event.stageY));
					break;
				case widget.move_center:
					widget.dispatchEvent(new KWidgetEvent(KWidgetEvent.UP_CENTER, event.stageX, event.stageY));
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
		
		
		/**
		 * Displays the widget at centroid of the selection.
		 * If the selection has only 1 object, it will display the widget at the key's center
		 */
		public function highlightSelection(selection:KSelection, time:int):void
		{
			if(!selection)
			{
				visible = false;
				return;
			}
			
			if(!selection.isVisible(time))
			{
				visible = false;
				return;
			}
			else
				visible = true;
			
			var length:int = selection.objects.length();
			
			if(length == 0)
			{
				visible = false;
				return;
			}
			
			_center = selection.centerAt(time);
			
			x = _center.x;
			y = _center.y;
			
			if(display)
			{
				var point:Point = display.localToGlobal(_center);
				point = parent.globalToLocal(point);
				x = point.x;
				y = point.y;
			}
			
			if(selection.selectionTransformable(time)|| (_interactionControl.transitionMode == KSketch2.TRANSITION_DEMONSTRATED))
				_enableWidget();
			else
				_disableWidget();
		}
		
		/**
		 * Set demo mode handler
		 */
		public function set_DemoButtonState(isDemo:Boolean, time:int):void
		{
			if(isDemo)
			{
				demoButton.filters = _glowFilter;
				_enableWidget();
			}
			else
			{
				demoButton.filters = [];
				if(_interactionControl.selection)
				{
					if(_interactionControl.selection.selectionTransformable(time))
						_enableWidget();
					else
						_disableWidget();
				}
			}
		}
		
		private function _enableWidget():void
		{
			widget.filters = [];
			widget.alpha = 1.0;	
			widget.mouseChildren = true;
		}
		
		private function _disableWidget():void
		{
			widget.filters = _colorFilter;
			widget.alpha = 0.5;
			widget.mouseChildren = false;
		}
	}
}