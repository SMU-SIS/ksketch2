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
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.core.FlexGlobals;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.canvas.components.popup.KSketch_Widget_ContextMenu;
	import sg.edu.smu.ksketch2.canvas.components.timebar.KSketch_TimeControl;
	import sg.edu.smu.ksketch2.canvas.components.transformWidget.KSketch_Widget_Component;
	import sg.edu.smu.ksketch2.canvas.components.view.KSketch_CanvasView;
	import sg.edu.smu.ksketch2.canvas.controls.KActivityControl;
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

		private var _enabled:Boolean;								// the enabled state boolean flag
		private var _isInteracting:Boolean;							// the interacting state boolean flag
		private var _keyDown:Boolean;								// the key down state boolean flag
		private var _longPressTimer:Timer;							// the long press timer
		private var _isLongPress:Boolean = false;					// the long press state boolean flag
		private var _doubleClickTimer:Timer;
		private var DOUBLE_CLICK_SPEED:int = 250;
		private var mouseTimeout = "undefined";
		private var _isDoubleTap:Boolean = false;
		private var _prevTransitionMode:int;
		
		private var _activeMode:IWidgetMode;						// the active widget mode
		public var defaultMode:IWidgetMode;							// the default widget mode
		public var steeringMode:IWidgetMode;						// the steering widget mode
		public var centerMode:IWidgetMode;							// the center widget mode
		public var freeTransformMode:IWidgetMode;					// the free transform widget mode
				
		//KSKETCH-SYNPHNE
		private var _activityControl:KActivityControl;
		private var _widgetHighlight:Boolean = false;
		
		/**
 		 * The main constructor for the KWidgetInteractorManager class.
 		 * 
		 * @param KSketchInstance The ksketch instance.
		 * @param interactionControl The interaction control.
 		 * @param widgetBase The sketch widget base component.
 		 * @param modelSpace The model space.
 		 */
		public function KWidgetInteractorManager(KSketchInstance:KSketch2, interactionControl:KInteractionControl, activityControl:KActivityControl,
												 widgetBase:KSketch_Widget_Component, modelSpace:DisplayObject)
		{
			_KSketch = KSketchInstance;
			_interactionControl = interactionControl;
			_keyDown = false;
			
			//KSKETCH-SYNPHNE
			_activityControl = activityControl;
			
			_widget = widgetBase;
			_widget.doubleClickEnabled = true;
			_widget.mouseEnabled = true;
			_widget.addEventListener(MouseEvent.CLICK, _handleTap, false, 0, true);
			_widget.addEventListener(MouseEvent.DOUBLE_CLICK, _handleTap, false, 0, true);
			
			_modelSpace = modelSpace;
			_widgetSpace = _widget.parent;
			
			_contextMenu = new KSketch_Widget_ContextMenu();
			_contextMenu.init(_KSketch, _interactionControl, this);
			
			defaultMode = new KBasicTransitionMode(_KSketch, _interactionControl, _widget, modelSpace);
			centerMode = new KMoveCenterMode(_KSketch, _interactionControl, _widget, modelSpace);
			activeMode = defaultMode;

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
			transitionMode = KSketch2.TRANSITION_INTERPOLATED;
			
			if(_interactionControl.selection.selectionTransformable(_KSketch.time))
			{
				_activeMode.activate();
				_activeMode.enabled = true;
			}
			else
			{
				_activeMode.deactivate();
				_activeMode.enabled = false;
			}
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
		
		private function _handleTap(event:MouseEvent):void {
			if (mouseTimeout != "undefined") {
				_doubleTap(event);
				clearTimeout(mouseTimeout);
				mouseTimeout = "undefined";
			} else {
				function _handleSingleTap():void {
					_singleTap(event);
					mouseTimeout = "undefined";
				}
				mouseTimeout = setTimeout(_handleSingleTap, DOUBLE_CLICK_SPEED);
			}
		}
		
		/**
 		 * Handles single tap detection.
 		 * 
 		 * @param event The target event.
 		 */
		private function _singleTap(event:MouseEvent):void
		{
			var action:String;
			
			if (_interactionControl.transitionMode == KSketch2.TRANSITION_INTERPOLATED && !KSketch_TimeControl.isPlaying && !_isDoubleTap)
			{
				action = "Activate Demonstration Mode";
				transitionMode = KSketch2.TRANSITION_DEMONSTRATED;
			}	
			else if(KSketch_TimeControl.isPlaying)
			{
				action = "Activate Demonstration Mode";
				transitionMode = KSketch2.TRANSITION_DEMONSTRATED;
			}
			else if(_isDoubleTap)
			{
				transitionMode = _prevTransitionMode;
				_isDoubleTap = false;
			}
			else
			{
				action = "Deactivate Demonstration Mode";
				transitionMode = KSketch2.TRANSITION_INTERPOLATED;
			}
			
			//LOG
			_KSketch.logCounter ++;
			var log:XML = <Action/>;
			var date:Date = new Date();
			log.@category = "Widget";
			log.@type = action;
			//trace("ACTION " + _KSketch.logCounter + ": " + action);
			KSketch2.log.appendChild(log);
		}
		
		/**
		 * Handles double tap action.
		 * 
		 * @param event The target event.
		 */
		private function _doubleTap(event:MouseEvent):void
		{
			_isDoubleTap = true;
			_prevTransitionMode = _interactionControl.transitionMode;
			
			var action:String = "Open widget context menu";
			
			if(_widget.visible)
				_contextMenu.open(_widget, true);
			
			//LOG
			_KSketch.logCounter ++;
			var log:XML = <Action/>;
			var date:Date = new Date();
			log.@category = "Widget";
			log.@type = action;
			//trace("ACTION " + _KSketch.logCounter + ": " + action);
			KSketch2.log.appendChild(log);
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
		 * Updates the widget.
		 * 
		 * @param event The target event.
		 */
		public function updateWidget(event:Event):void
		{
			//KSKETCH-SYNPHNE
			_widgetHighlight = false;
			
			_widget.visible = false;
			
			if(event.type == KInteractionControl.EVENT_INTERACTION_BEGIN)
				_isInteracting = true;
			
			if(event.type == KInteractionControl.EVENT_INTERACTION_END)
			{
				_isInteracting = false;
				transitionMode = KSketch2.TRANSITION_INTERPOLATED;
			}
			
			if(!_interactionControl.selection || _isInteracting ||
				!_interactionControl.selection.isVisible(_KSketch.time))
			{
				_widget.visible = false;
				activeMode = defaultMode;
				_contextMenu.close();
				return;	
			}
			
			if(!_isInteracting)
				transitionMode = KSketch2.TRANSITION_INTERPOLATED;
			
			if(KSketch_TimeControl.isPlaying && !_isInteracting)
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
				
				if(_interactionControl.selection.selectionTransformable(_KSketch.time) || KSketch_TimeControl.isPlaying)
					enabled = true;
			}
		}
		
		/**
 		 * Sets the transition mode.
 		 * 
 		 * @param mode The target transition mode.
 		 */
		public function updateMovingWidget(event:Event):void
		{
			//KSKETCH-SYNPHNE
			if(_activityControl && !_widgetHighlight)
			{
				if(_activityControl.activityType == "TRACK")
				{
					//select the object to track and set it to demonstration mode
					transitionMode = KSketch2.TRANSITION_DEMONSTRATED;
					_activityControl.autoSelectObjectToAnimate();
					_widget.visible = true;
					_widgetHighlight = true;
				}
			}
			
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
				_activeMode.activate();
			else
				_activeMode.deactivate();
			
			if(_activeMode)
				_activeMode.enabled = _enabled;
		}
	}
}