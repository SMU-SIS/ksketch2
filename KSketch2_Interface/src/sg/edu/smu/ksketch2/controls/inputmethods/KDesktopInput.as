/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.controls.inputmethods
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.ui.MouseCursorData;
	
	import mx.core.UIComponent;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.controls.interactioncontrol.IInteractionControl;
	import sg.edu.smu.ksketch2.controls.widgets.IWidget;
	import sg.edu.smu.ksketch2.controls.widgets.KWidget;
	import sg.edu.smu.ksketch2.utils.KMouseCursorEvent;
	import sg.edu.smu.ksketch2.view.KModelDisplay;

	public class KDesktopInput implements IInteractionMethod
	{
		public static var isBrowser:Boolean = false;
		private var _widget:KWidget;
		private var _interactionComponent:UIComponent;
		private var _display:KModelDisplay
		
		private var _xScale:Number;
		private var _yScale:Number;
		private var _interactionControl:IInteractionControl;
		private var _keyAlreadyDown:Boolean;
		
		[Embed(source="assets/Demo_Cursor_Frame_1.png")]
		private var DemoModeFrame1:Class;
		[Embed(source="assets/Demo_Cursor_Frame_2.png")]
		private var DemoModeFrame2:Class;
		
		[Embed(source="assets/Demo_Mode_Cursor_Frame_1.png")]
		private var DemoRecordFrame1:Class;
		[Embed(source="assets/Demo_Mode_Cursor_Frame_2.png")]
		private var DemoRecordFrame2:Class;
		
		[Embed(source="assets/Selection_Cursor.png")]
		private var SelectionMode:Class;
		
		/**
		 * Desktopinput adds keyboard and mouse listeners to the application's input
		 */
		public function KDesktopInput()
		{
			_keyAlreadyDown = false;
			isBrowser = Capabilities.playerType != "Desktop";
		}
		
		public function init(interactionComponent:UIComponent, interactionControl:IInteractionControl, widget:KWidget, display:KModelDisplay):void
		{
			_widget = widget;
			_interactionComponent = interactionComponent;
			_display = display;
			_widget.display = _display;
			_interactionControl = interactionControl;
			
			if(!_interactionComponent || !_interactionControl || !_widget)
				throw new Error("Please give non-null inputs for your IInteractionMethod");

			_interactionComponent.stage.addEventListener(KeyboardEvent.KEY_DOWN, _handler_Keyboard_Change);
			_interactionComponent.stage.addEventListener(KeyboardEvent.KEY_UP, _handler_Keyboard_Change);
			_interactionComponent.addEventListener(MouseEvent.MOUSE_DOWN, _handler_Mouse_Down);
			_interactionComponent.addEventListener(KWidgetEvent.DOWN_TRANSLATE, _handler_Mouse_Down);
			_interactionComponent.addEventListener(KWidgetEvent.DOWN_ROTATE, _handler_Mouse_Down);
			_interactionComponent.addEventListener(KWidgetEvent.DOWN_SCALE, _handler_Mouse_Down);
			_interactionComponent.addEventListener(KWidgetEvent.DOWN_CENTER, _handler_Mouse_Down);

			if(!isBrowser)
				_interactionComponent.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, _handler_Right_Mouse_Down);
			
			
			_interactionControl.addEventListener(KMouseCursorEvent.EVENT_CURSOR_CHANGED, _handle_cursor_change);
			
			var demoModeData:Vector.<BitmapData> = new Vector.<BitmapData>(2, true);
			var demoMode1:Bitmap = new DemoModeFrame1();
			var demoMode2:Bitmap = new DemoModeFrame2();
			demoModeData[0] = (demoMode1.bitmapData);
			demoModeData[1] = (demoMode2.bitmapData);
			var demoModeCursorData:MouseCursorData = new MouseCursorData();
			demoModeCursorData.hotSpot = new Point(7.5,7.5);
			demoModeCursorData.data = demoModeData;
			demoModeCursorData.frameRate = 4;
			Mouse.registerCursor(KMouseCursorEvent.DEMO_MODE_CURSOR, demoModeCursorData);			
			
			demoModeData = new Vector.<BitmapData>(2, true);
			demoMode1 = new DemoRecordFrame1();
			demoMode2 = new DemoRecordFrame2();
			demoModeData[0] = (demoMode1.bitmapData);
			demoModeData[1] = (demoMode2.bitmapData);
			demoModeCursorData = new MouseCursorData();
			demoModeCursorData.hotSpot = new Point(11,11);
			demoModeCursorData.data = demoModeData;
			demoModeCursorData.frameRate = 4;
			Mouse.registerCursor(KMouseCursorEvent.DEMO_RECORDING_CURSOR, demoModeCursorData);			
			
			demoModeData = new Vector.<BitmapData>(1, true);
			demoMode1 = new SelectionMode();
			demoModeData[0] = (demoMode1.bitmapData);
			demoModeCursorData = new MouseCursorData();
			demoModeCursorData.hotSpot = new Point(4,10);
			demoModeCursorData.data = demoModeData;
			demoModeCursorData.frameRate = 1;
			Mouse.registerCursor(KMouseCursorEvent.SELECT_CURSOR, demoModeCursorData);
		}
		
		public function updateInputScale(xScale:Number, yScale:Number):void
		{
			_xScale = xScale;
			_yScale = yScale;
		}
		
		private function _handler_Right_Mouse_Down(event:MouseEvent):void
		{
			_interactionControl.enterSelectionMode();
			_handler_Mouse_Down(event);
		}
		
		private function _handler_Right_Mouse_Up(event:MouseEvent):void
		{
			_handler_Mouse_Up(event);
			_interactionControl.determineMode();
		}
		
		/**
		 * Keyboard handler function
		 */
		private function _handler_Keyboard_Change(event:KeyboardEvent):void
		{	
			if(event.keyCode == Keyboard.SHIFT)
			{
				if(event.shiftKey)
				{
					if(!_keyAlreadyDown)
					{
						_keyAlreadyDown = true;
						_interactionControl.enterSelectionMode();
					}
				}
				else
				{
					if(_keyAlreadyDown)
					{
						_keyAlreadyDown = false;
						_interactionControl.determineMode();
					}
				}
			}
		}
		
		private function _handler_Mouse_Down(event:MouseEvent):void
		{
			if(event.target == _widget.demoButton)
			{
				if(_interactionControl.transitionMode == KSketch2.TRANSITION_INTERPOLATED)
					_interactionControl.transitionMode = KSketch2.TRANSITION_DEMONSTRATED;
				else
					_interactionControl.transitionMode = KSketch2.TRANSITION_INTERPOLATED;
				return;
			}
			
			var eventCoordinates:Point = _convertToLocalCoordinates(event.stageX, event.stageY);
			
			if(event is KWidgetEvent)
				_interactionControl.beginCanvasInput(eventCoordinates, true, event.type);					
			else
				_interactionControl.beginCanvasInput(eventCoordinates, false, event.type);
			
			_interactionComponent.stage.removeEventListener(KeyboardEvent.KEY_DOWN, _handler_Keyboard_Change);
			_interactionComponent.stage.removeEventListener(KeyboardEvent.KEY_UP, _handler_Keyboard_Change);
			_interactionComponent.removeEventListener(MouseEvent.MOUSE_DOWN, _handler_Mouse_Down);
			_interactionComponent.removeEventListener(KWidgetEvent.DOWN_TRANSLATE, _handler_Mouse_Down);
			_interactionComponent.removeEventListener(KWidgetEvent.DOWN_ROTATE, _handler_Mouse_Down);
			_interactionComponent.removeEventListener(KWidgetEvent.DOWN_SCALE, _handler_Mouse_Down);
			_interactionComponent.removeEventListener(KWidgetEvent.DOWN_CENTER, _handler_Mouse_Down);
			
			_interactionComponent.addEventListener(MouseEvent.MOUSE_MOVE, _handler_Mouse_Move);
			
			if(!isBrowser)
				_interactionComponent.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN, _handler_Right_Mouse_Down);

			if(!isBrowser && event.type == MouseEvent.RIGHT_MOUSE_DOWN)
				_interactionComponent.addEventListener(MouseEvent.RIGHT_MOUSE_UP, _handler_Right_Mouse_Up);
			else
				_interactionComponent.addEventListener(MouseEvent.MOUSE_UP, _handler_Mouse_Up);
		}
		
		private function _handler_Mouse_Move(event:MouseEvent):void
		{
			_interactionControl.updateCanvasInput(_convertToLocalCoordinates(event.stageX, event.stageY));
		}
		
		private function _handler_Mouse_Up(event:MouseEvent):void
		{
			if(event.type == MouseEvent.MOUSE_OUT)
			{
				if(event.target != _interactionComponent)
				{
					_handler_Mouse_Move(event);
					return;
				}
			}
			
			_handler_Mouse_Move(event);
			_interactionControl.completeCanvasInput();
			
			_interactionComponent.removeEventListener(MouseEvent.MOUSE_MOVE, _handler_Mouse_Move);
			
			_interactionComponent.stage.addEventListener(KeyboardEvent.KEY_DOWN, _handler_Keyboard_Change);
			_interactionComponent.stage.addEventListener(KeyboardEvent.KEY_UP, _handler_Keyboard_Change);
			_interactionComponent.addEventListener(MouseEvent.MOUSE_DOWN, _handler_Mouse_Down);
			_widget.widget.addEventListener(KWidgetEvent.DOWN_TRANSLATE, _handler_Mouse_Down);
			_widget.widget.addEventListener(KWidgetEvent.DOWN_ROTATE, _handler_Mouse_Down);
			_widget.widget.addEventListener(KWidgetEvent.DOWN_SCALE, _handler_Mouse_Down);
			_widget.widget.addEventListener(KWidgetEvent.DOWN_CENTER, _handler_Mouse_Down);

			if(!isBrowser)
				_interactionComponent.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, _handler_Right_Mouse_Down);
	
			if(!isBrowser && event.type == MouseEvent.RIGHT_MOUSE_UP)
				_interactionComponent.removeEventListener(MouseEvent.RIGHT_MOUSE_UP, _handler_Right_Mouse_Up);
			else
				_interactionComponent.removeEventListener(MouseEvent.MOUSE_UP, _handler_Mouse_Up);
		}
		
		private function _convertToLocalCoordinates(x:Number, y:Number):Point
		{
			return _display.globalToLocal(new Point(x, y));
		}
		
		private function _handle_cursor_change(event:KMouseCursorEvent):void
		{
			return;
			Mouse.cursor = event.cursorName;
			Mouse.hide();
			Mouse.show();
		}
	}
}