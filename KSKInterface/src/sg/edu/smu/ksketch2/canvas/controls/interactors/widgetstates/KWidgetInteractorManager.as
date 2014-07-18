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
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	import mx.core.FlexGlobals;
	
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.TapGesture;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.canvas.components.popup.KSketch_Widget_ContextMenu;
	import sg.edu.smu.ksketch2.canvas.components.timebar.KSketch_TimeControl;
	import sg.edu.smu.ksketch2.canvas.components.transformWidget.KSketch_Widget_Component;
	import sg.edu.smu.ksketch2.canvas.components.view.KSketch_CanvasView;
	import sg.edu.smu.ksketch2.canvas.controls.KInteractionControl;
	import sg.edu.smu.ksketch2.canvas.controls.interactors.KMoveCenterInteractor;
	import sg.edu.smu.ksketch2.events.KSketchEvent;
	import sg.edu.smu.ksketch2.events.KTimeChangedEvent;
	
	/**
 	 * The KWidgetInteractorManager class serves as the concrete class
 	 * for managing widget interactors in K-Sketch.
 	 */
	public class KWidgetInteractorManager extends EventDispatcher
	{		
		protected var _KSketch:KSketch2;							// the ksketch instance
		protected var _interactionControl:KInteractionControl;		// the interaction control
		protected var _widget:KSketch_Widget_Component;				// the widget
		protected var _modelSpace:DisplayObject;					// the model space
		protected var _widgetSpace:DisplayObject;					// the widget space
		protected var _contextMenu:KSketch_Widget_ContextMenu;		// the context menu
		
		private var _modeGesture:TapGesture;						// the mode gesture
		private var _activateMenuGesture:TapGesture;				// the activate menu gesture

		private var _enabled:Boolean;								// the enabled state boolean flag
		private var _isInteracting:Boolean;							// the interacting state boolean flag
		private var _keyDown:Boolean;								// the key down state boolean flag
		private var _longPressTimer:Timer;							// the long press timer
		private var _isLongPress:Boolean = false;					// the long press state boolean flag
		
		private var _activeMode:IWidgetMode;						// the active widget mode
		public var defaultMode:IWidgetMode;							// the default widget mode
		public var steeringMode:IWidgetMode;						// the steering widget mode
		public var centerMode:IWidgetMode;							// the center widget mode
		public var freeTransformMode:IWidgetMode;					// the free transform widget mode
		
		/**
 		 * The main constructor for the KWidgetInteractorManager class.
 		 * 
		 * @param KSketchInstance The ksketch instance.
		 * @param interactionControl The interaction control.
 		 * @param widgetBase The sketch widget base component.
 		 * @param modelSpace The model space.
 		 */
		public function KWidgetInteractorManager(KSketchInstance:KSketch2, interactionControl:KInteractionControl,
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
			centerMode = new KMoveCenterMode(_KSketch, _interactionControl, _widget, modelSpace);
			activeMode = defaultMode;
			
			_longPressTimer = new Timer(500);
			_modeGesture = new TapGesture(_widget);
			_modeGesture.addEventListener(GestureEvent.GESTURE_POSSIBLE, _handleTapStart);

			interactionControl.addEventListener(KSketchEvent.EVENT_SELECTION_SET_CHANGED, updateWidget);
			interactionControl.addEventListener(KInteractionControl.EVENT_INTERACTION_BEGIN, updateWidget);
			interactionControl.addEventListener(KInteractionControl.EVENT_INTERACTION_END, updateWidget);
			interactionControl.addEventListener(KInteractionControl.EVENT_UNDO_REDO, updateWidget);
			interactionControl.addEventListener(KMoveCenterInteractor.CENTER_CHANGE_ENDED, _handleCenterChange);
			_KSketch.addEventListener(KSketchEvent.EVENT_MODEL_UPDATED, updateWidget);
			_KSketch.addEventListener(KTimeChangedEvent.EVENT_TIME_CHANGED, updateWidget);
			
			if(!KSketch_CanvasView.isMobile)
				FlexGlobals.topLevelApplication.addEventListener(KeyboardEvent.KEY_DOWN, _keyTrigger);
		}
		
		/**
 		 * Sets and activates the active widget mode.
 		 * 
 		 * @param mode The target active widget mode.
 		 */
		public function set activeMode(mode:IWidgetMode):void
		{
			if(_activeMode == mode)
				return;
			
			if(_activeMode)
				_activeMode.deactivate();
			
			_activeMode = mode;
			_activeMode.activate();
		}
		
		/**
 		 * Handles center changes by setting the active mode to the default
 		 * mode.
 		 * 
 		 * @param event The target event.
 		 */
		private function _handleCenterChange(event:Event):void
		{
			activeMode = defaultMode;
		}
		
		
		/**
 		 * Handles key triggers from the keyboard.
 		 * 
 		 * @param event The target keyboard event.
 		 */
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
		
		
		/**
 		 * Handles tap starts.
 		 * 
 		 * @param event The target event.
 		 */
		private function _handleTapStart(event:Event):void
		{
			_isLongPress = false;
			_longPressTimer.start();
			_longPressTimer.addEventListener(TimerEvent.TIMER, _activatedLongPress);

			_modeGesture.addEventListener(GestureEvent.GESTURE_RECOGNIZED, _handleModeSwitch);
			_modeGesture.addEventListener(GestureEvent.GESTURE_FAILED, _handleTapFail);
		}
		
		/**
 		 * Handles activated long presses.
 		 * 
 		 * @param event The target timer event.
 		 */
		private function _activatedLongPress(event:TimerEvent):void
		{
			_isLongPress = true;
			_longPressTimer.stop();
			_longPressTimer.removeEventListener(TimerEvent.TIMER, _activatedLongPress);
		}
		
		/**
 		 * Handles tap fails.
 		 * 
 		 * @param event The target event.
 		 */
		private function _handleTapFail(event:Event):void
		{
			_modeGesture.removeEventListener(GestureEvent.GESTURE_RECOGNIZED, _handleModeSwitch);
			_modeGesture.removeEventListener(GestureEvent.GESTURE_FAILED, _handleTapFail);
			_modeGesture.addEventListener(GestureEvent.GESTURE_POSSIBLE, _handleTapStart);
		}
		
		/**
 		 * Handles mode switches.
 		 * 
 		 * @param event The target event.
 		 */
		private function _handleModeSwitch(event:Event):void
		{
			var action:String;
			
			if(_isLongPress)
			{
				action = "Open Widget Menu";
				_handleOpenMenu();
			}
			else
			{
				if(_interactionControl.transitionMode == KSketch2.TRANSITION_INTERPOLATED && !KSketch_TimeControl._isPlaying)
				{
					action = "Activate Demonstration Mode";
					transitionMode = KSketch2.TRANSITION_DEMONSTRATED;
				}	
				else if(KSketch_TimeControl._isPlaying)
				{
					action = "Activate Demonstration Mode";
					transitionMode = KSketch2.TRANSITION_DEMONSTRATED;
				}
				else
				{
					action = "Deactivate Demonstration Mode";
					transitionMode = KSketch2.TRANSITION_INTERPOLATED;
				}
						
			}
			
			_modeGesture.removeEventListener(GestureEvent.GESTURE_RECOGNIZED, _handleModeSwitch);
			_modeGesture.removeEventListener(GestureEvent.GESTURE_FAILED, _handleTapFail);
			_modeGesture.addEventListener(GestureEvent.GESTURE_POSSIBLE, _handleTapStart);
			
			//LOG
			_KSketch.logCounter ++;
			var log:XML = <Action/>;
			var date:Date = new Date();
			log.@category = "Widget";
			log.@type = action;
			trace("Action " + _KSketch.logCounter + ": " + action);
			KSketch2.log.appendChild(log);
		}
		
		/**
 		 * Handles open menu.
 		 */
		private function _handleOpenMenu():void
		{
			if(_widget.visible)
				_contextMenu.open(_widget, true);
		}
		
		/**
		 * Updates the widget.
		 * 
		 * @param event The target event.
		 */
		public function updateWidget(event:Event):void
		{
			_widget.visible = false;
			
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
				activeMode = defaultMode;
				_contextMenu.close();
				return;
			}
			
			if(!_isInteracting)
				transitionMode = KSketch2.TRANSITION_INTERPOLATED;
			
			if(KSketch_TimeControl._isPlaying && !_isInteracting)
				transitionMode = KSketch2.TRANSITION_DEMONSTRATED;
				
			var _isErasedObject:Boolean = _interactionControl.isSelectionErased(_interactionControl.selection);
			if(!_isErasedObject)
			{
				_widget.visible = true;
				
				var selectionCenter:Point = _interactionControl.selection.centerAt(_KSketch.time);
				selectionCenter = _modelSpace.localToGlobal(selectionCenter);
				selectionCenter = _widgetSpace.globalToLocal(selectionCenter);
				
				_widget.x = selectionCenter.x;
				_widget.y = selectionCenter.y;
				
				if(_interactionControl.selection.selectionTransformable(_KSketch.time) ||
					KSketch_TimeControl._isPlaying)
					enabled = true;
				else
					enabled = false;	
				
			}
		}
		
		/**
 		 * Sets the transition mode.
 		 * 
 		 * @param mode The target transition mode.
 		 */
		public function updateMovingWidget(event:Event):void
		{
			if(_interactionControl.selection)
			{
				_widget.visible = true;
				
				//Need to localise the point
				var selectionCenter:Point = _interactionControl.selection.centerAt(_KSketch.time);
				
				selectionCenter = _modelSpace.localToGlobal(selectionCenter);
				selectionCenter = _widgetSpace.globalToLocal(selectionCenter);
				
				_widget.x = selectionCenter.x;
				_widget.y = selectionCenter.y;
			}
		}
		
		/**
 		 * Sets the transition mode.
 		 * 
 		 * @param mode The target transition mode.
 		 */
		public function set transitionMode(mode:int):void
		{
			//if(KSketch2.studyMode == KSketch2.STUDYMODE_K)
			//	mode = KSketch2.TRANSITION_INTERPOLATED
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
		
		/**
		 * Sets the enabled status boolean flag and enables active mode.
		 * 
		 * @param isEnabled Whether the active mode is enabled.
		 */
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