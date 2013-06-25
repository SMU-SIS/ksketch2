/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.canvas.controls.interactors.widgetstates
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	import mx.core.FlexGlobals;
	
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.TapGesture;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.canvas.KSketch_CanvasView;
	import sg.edu.smu.ksketch2.canvas.components.popup.KSketch_Widget_ContextMenu;
	import sg.edu.smu.ksketch2.canvas.components.transformWidget.KSketch_Widget_Component;
	import sg.edu.smu.ksketch2.canvas.controls.KInteractionControl;
	import sg.edu.smu.ksketch2.events.KSketchEvent;
	import sg.edu.smu.ksketch2.events.KTimeChangedEvent;
	
	public class KWidgetInteractorManager
	{		
		protected var _KSketch:KSketch2;
		protected var _interactionControl:KInteractionControl;
		protected var _widget:KSketch_Widget_Component;
		protected var _modelSpace:DisplayObject;
		protected var _widgetSpace:DisplayObject;
		protected var _contextMenu:KSketch_Widget_ContextMenu;
	
		private var _modeGesture:TapGesture;
		private var _activateMenuGesture:TapGesture;

		private var _enabled:Boolean;
		private var _isInteracting:Boolean;
		private var _keyDown:Boolean;
		private var _longPressTimer:Timer;
		private var _isLongPress:Boolean = false;
		
		private var _activeMode:IWidgetMode;
		public var defaultMode:IWidgetMode;
		public var steeringMode:IWidgetMode;
		public var freeTransformMode:IWidgetMode;	
		
		public function KWidgetInteractorManager(KSketchInstance:KSketch2,
												 interactionControl:KInteractionControl, 
												 widgetBase:KSketch_Widget_Component, modelSpace:DisplayObject)
		{
			_KSketch = KSketchInstance;
			_interactionControl = interactionControl;
			_keyDown = false;
			_widget = widgetBase;
			_modelSpace = modelSpace;
			_widgetSpace = _widget.parent;
			
			_contextMenu = new KSketch_Widget_ContextMenu();
			_contextMenu.init(_KSketch, _interactionControl, this);
			
			
			defaultMode = new KBasicTransitionMode(_KSketch, _interactionControl, _widget, modelSpace);
			//steeringMode = new KSteeringMode(_KSketch, _interactionControl, _widget);
			//freeTransformMode = new KFreeTransformMode(_KSketch, _interactionControl, _widget, modelSpace);
			activeMode = defaultMode;
			
			_longPressTimer = new Timer(500);
			_modeGesture = new TapGesture(_widget);
			_modeGesture.addEventListener(GestureEvent.GESTURE_POSSIBLE, _handleTapStart);
			
			interactionControl.addEventListener(KSketchEvent.EVENT_SELECTION_SET_CHANGED, updateWidget);
			interactionControl.addEventListener(KInteractionControl.EVENT_INTERACTION_BEGIN, updateWidget);
			interactionControl.addEventListener(KInteractionControl.EVENT_INTERACTION_END, updateWidget);
			interactionControl.addEventListener(KInteractionControl.EVENT_UNDO_REDO, updateWidget);
			_KSketch.addEventListener(KSketchEvent.EVENT_MODEL_UPDATED, updateWidget);
			_KSketch.addEventListener(KTimeChangedEvent.EVENT_TIME_CHANGED, updateWidget);
			
			if(!KSketch_CanvasView.isMobile)
				FlexGlobals.topLevelApplication.addEventListener(KeyboardEvent.KEY_DOWN, _keyTrigger);
		}
		
		public function set activeMode(mode:IWidgetMode):void
		{
			if(_activeMode == mode)
				return;
			
			if(_activeMode)
				_activeMode.deactivate();
			
			_activeMode = mode;
			_activeMode.activate();
		}
		
		private function _keyTrigger(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.COMMAND || event.keyCode == Keyboard.CONTROL
				|| event.keyCode == Keyboard.SPACE)
				_keyDown = event.type == KeyboardEvent.KEY_DOWN;
			
			if(_keyDown)
				transitionMode = KSketch2.TRANSITION_DEMONSTRATED;
			else
				transitionMode = KSketch2.TRANSITION_INTERPOLATED;
			
			if(_keyDown)
			{
				FlexGlobals.topLevelApplication.removeEventListener(KeyboardEvent.KEY_DOWN, _keyTrigger);
				FlexGlobals.topLevelApplication.addEventListener(KeyboardEvent.KEY_UP, _keyTrigger);
			}
			else
			{
				FlexGlobals.topLevelApplication.addEventListener(KeyboardEvent.KEY_DOWN, _keyTrigger);
				FlexGlobals.topLevelApplication.removeEventListener(KeyboardEvent.KEY_UP, _keyTrigger);
			}
		}
		
		private function _handleTapStart(event:Event):void
		{
			_isLongPress = false;
			_longPressTimer.start();
			_longPressTimer.addEventListener(TimerEvent.TIMER, _activatedLongPress);

			_modeGesture.addEventListener(GestureEvent.GESTURE_RECOGNIZED, _handleModeSwitch);
			_modeGesture.addEventListener(GestureEvent.GESTURE_FAILED, _handleTapFail);
		}
		
		private function _activatedLongPress(event:TimerEvent):void
		{
			_isLongPress = true;
			_longPressTimer.stop();
			_longPressTimer.removeEventListener(TimerEvent.TIMER, _activatedLongPress);
		}
		
		private function _handleTapFail(event:Event):void
		{
			_modeGesture.removeEventListener(GestureEvent.GESTURE_RECOGNIZED, _handleModeSwitch);
			_modeGesture.removeEventListener(GestureEvent.GESTURE_FAILED, _handleTapFail);
			_modeGesture.addEventListener(GestureEvent.GESTURE_POSSIBLE, _handleTapStart);
		}
		
		private function _handleModeSwitch(event:Event):void
		{
			if(_isLongPress)
			{
				_handleOpenMenu();
			}
			else
			{
				if(_interactionControl.transitionMode == KSketch2.TRANSITION_INTERPOLATED)
					transitionMode = KSketch2.TRANSITION_DEMONSTRATED;
				else
					transitionMode = KSketch2.TRANSITION_INTERPOLATED;
			}
			
			_modeGesture.removeEventListener(GestureEvent.GESTURE_RECOGNIZED, _handleModeSwitch);
			_modeGesture.removeEventListener(GestureEvent.GESTURE_FAILED, _handleTapFail);
			_modeGesture.addEventListener(GestureEvent.GESTURE_POSSIBLE, _handleTapStart);
		}
		
		private function _handleOpenMenu():void
		{
			if(_widget.visible)
				_contextMenu.open(_widget, true);
		}
		
		public function updateWidget(event:Event):void
		{
			if(event.type == KInteractionControl.EVENT_INTERACTION_BEGIN)
				_isInteracting = true;
			
			if(event.type == KInteractionControl.EVENT_INTERACTION_END)
			{
				_isInteracting = false;
				transitionMode = KSketch2.TRANSITION_INTERPOLATED;
			}
			
			if(!_interactionControl.selection || _isInteracting||
				!_interactionControl.selection.isVisible(_KSketch.time))
			{
				_widget.visible = false;
				_contextMenu.close();
				return;
			}
			
			if(!_isInteracting)
				transitionMode = KSketch2.TRANSITION_INTERPOLATED;
			
			_widget.visible = true;
			
			//Need to localise the point
			var selectionCenter:Point = _interactionControl.selection.centerAt(_KSketch.time);
			selectionCenter = _modelSpace.localToGlobal(selectionCenter);
			selectionCenter = _widgetSpace.globalToLocal(selectionCenter);
			
			_widget.x = selectionCenter.x;
			_widget.y = selectionCenter.y;
			
			if(_interactionControl.selection.selectionTransformable(_KSketch.time))
				enabled = true;
			else
				enabled = false;
		}
		
		public function set transitionMode(mode:int):void
		{
			if(KSketch2.studyMode == KSketch2.STUDY_K)
				mode = KSketch2.TRANSITION_INTERPOLATED
			
			_interactionControl.transitionMode = mode;
			
			if(_interactionControl.transitionMode == KSketch2.TRANSITION_DEMONSTRATED)
			{
				if(!_enabled)
					enabled = true;	
				
				_activeMode.demonstrationMode = true;

			}
			else if(_interactionControl.transitionMode == KSketch2.TRANSITION_INTERPOLATED)
			{
				if(_interactionControl.selection && !_isInteracting)
					enabled = _interactionControl.selection.selectionTransformable(_KSketch.time);
				_activeMode.demonstrationMode = false;
			}
			else
				throw new Error("Unknow transition mode. Check what kind of modes the transition delegate is setting");
		}
		
		public function set enabled(isEnabled:Boolean):void
		{
			if(_enabled.valueOf() == isEnabled)
				return;

			_enabled = isEnabled;	
			
			if(isEnabled)
			{
				_activeMode.activate();
				if(!_modeGesture.hasEventListener(GestureEvent.GESTURE_RECOGNIZED))
					_modeGesture.addEventListener(GestureEvent.GESTURE_RECOGNIZED, _handleModeSwitch);
			}
			else
				_activeMode.deactivate();
				
			if(_activeMode)
				_activeMode.enabled = _enabled;
		}
	}
}