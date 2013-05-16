/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.controls.interactioncontrol
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.controls.interactionmodes.IInteractionMode;
	import sg.edu.smu.ksketch2.controls.interactionmodes.KDrawingMode;
	import sg.edu.smu.ksketch2.controls.interactionmodes.KGestureMode;
	import sg.edu.smu.ksketch2.controls.interactionmodes.KManipulationMode;
	import sg.edu.smu.ksketch2.controls.widgets.IWidget;
	import sg.edu.smu.ksketch2.controls.widgets.KTimeControl;
	import sg.edu.smu.ksketch2.controls.widgets.KWidget;
	import sg.edu.smu.ksketch2.controls.widgets.timewidget.KTimeMarkerWidget;
	import sg.edu.smu.ksketch2.events.KSketchEvent;
	import sg.edu.smu.ksketch2.events.KTimeChangedEvent;
	import sg.edu.smu.ksketch2.operators.operations.IModelOperation;
	import sg.edu.smu.ksketch2.utils.KInteractionOperation;
	import sg.edu.smu.ksketch2.utils.KMouseCursorEvent;
	import sg.edu.smu.ksketch2.utils.KSelection;
	import sg.edu.smu.ksketch2.view.KModelDisplay;
	
	public class KInteractionControl extends EventDispatcher implements IInteractionControl
	{
		public static var EVENT_UNDO_REDO:String = "undo redo";
		public static var EVENT_TRANSITION_MODE_CHANGED:String = "transition mode changed";
		public static var stickyDemonstration:Boolean = false;
		public static var pathVisible:Boolean = true;
		
		private var _KSketch:KSketch2;
		private var _timeControl:KTimeControl;
		private var _timeWidget:KTimeMarkerWidget;
		private var _manipulationWidget:IWidget;
		
		private var _selection:KSelection;
		private var _currentInteraction:KInteractionOperation;
		private var _transitionMode:int;
		
		private var _activeMode:IInteractionMode;
		private var _drawingMode:KDrawingMode;
		private var _gestureMode:KGestureMode;
		private var _manipulationMode:KManipulationMode;
		
		private var _undoStack:Vector.<IModelOperation>;
		private var _redoStack:Vector.<IModelOperation>;
		
		public function KInteractionControl(ksketchInstance:KSketch2, interactorDisplay:KModelDisplay
											, timeControl:KTimeControl, manipulationWidget:IWidget, timeWidget:KTimeMarkerWidget)
		{
			super(this);
			
			_KSketch = ksketchInstance;
			_manipulationWidget = manipulationWidget;
			_timeControl = timeControl;
			_timeWidget = timeWidget;
			
			_transitionMode = KSketch2.TRANSITION_INTERPOLATED;
			_drawingMode = new KDrawingMode(_KSketch, interactorDisplay, this);
			_gestureMode = new KGestureMode(_KSketch, interactorDisplay, this);
			_manipulationMode = new KManipulationMode(_KSketch, this, manipulationWidget);
			
			_KSketch.addEventListener(KSketchEvent.EVENT_MODEL_UPDATED, _modelUpdatedEventHandler);
			_KSketch.addEventListener(KTimeChangedEvent.EVENT_TIME_CHANGED, _timeChangedEventHandler);
		}
		
		public function init():void
		{
			_drawingMode.init();
			_gestureMode.init();
			_manipulationMode.init();
			
			reset();
		}
		
		public function reset():void
		{
			_undoStack = new Vector.<IModelOperation>();
			_redoStack = new Vector.<IModelOperation>();
			selection = null;
			_timeControl.time = 0;
			_drawingMode.reset();
			_gestureMode.reset();
			_manipulationMode.reset();
			triggerInterfaceUpdate();
			enterMode(_drawingMode);
		}
		
		public function set transitionMode(mode:int):void
		{
			_transitionMode = mode;
			
			(_manipulationWidget as KWidget).set_DemoButtonState(_transitionMode == KSketch2.TRANSITION_DEMONSTRATED, _KSketch.time);
			
			if(_transitionMode == KSketch2.TRANSITION_DEMONSTRATED)
			{
				if(_activeMode is KManipulationMode)
					dispatchEvent(new KMouseCursorEvent(KMouseCursorEvent.EVENT_CURSOR_CHANGED, KMouseCursorEvent.DEMO_MODE_CURSOR));
			}
			else
			{
				if(_activeMode is KManipulationMode)
					dispatchEvent(new KMouseCursorEvent(KMouseCursorEvent.EVENT_CURSOR_CHANGED, KMouseCursorEvent.INTERPOLTE_MODE_CURSOR));
			}
		}

		public function get transitionMode():int
		{
			return _transitionMode;
		}
		
		public function set selection(newSelection:KSelection):void
		{
			if(newSelection)
			{
				if(newSelection.objects.length() == 0)
					newSelection = null;
				else
				{
					if(!newSelection.isDifferentFrom(_selection))
						return;
				}
			}
			
			if(!_selection && !newSelection)
				return;
			
			var oldSelection:KSelection = _selection;
			_selection = newSelection;
			
			var i:int;
			var length:int;
			
			//Will trigger the selection/deselection
			//Will cause the objects to trigger their selection events
			if(oldSelection)
				oldSelection.triggerDeselected();
		
			if(newSelection)
				newSelection.triggerSelected();
			
			_selectionChangedEventHandler();
			
			dispatchEvent(new KSketchEvent(KSketchEvent.EVENT_SELECTION_SET_CHANGED));
		}
		
		public function get selection():KSelection
		{
			return _selection;
		}
		
		public function enterSelectionMode():void
		{
			if(_currentInteraction)
				return;
			
			enterMode(_gestureMode);
		}
		
		public function enterDrawingMode(drawModeType:String):void
		{
			if(_currentInteraction)
				throw new Error("Please sure that the previous operation was properly ended before entering drawing mode");
			
			_selection = null;
			
			determineMode();
			_drawingMode.drawMode = drawModeType;
			_drawingMode.activate();
		}
		
		public function determineMode():void
		{
			if(_currentInteraction)
				return;
			
			if(_selection)
				enterMode(_manipulationMode);	
			else
			{
				enterMode(_drawingMode);
			}
		}
		
		public function enterMode(mode:IInteractionMode):void
		{
			_activeMode = mode;
			
			//handle cursor change
			if(mode is KGestureMode)
				dispatchEvent(new KMouseCursorEvent(KMouseCursorEvent.EVENT_CURSOR_CHANGED, KMouseCursorEvent.SELECT_CURSOR));
			else if(mode is KDrawingMode)
				dispatchEvent(new KMouseCursorEvent(KMouseCursorEvent.EVENT_CURSOR_CHANGED, KMouseCursorEvent.DRAW_MODE_CURSOR));
			else if(mode is KManipulationMode)
				dispatchEvent(new KMouseCursorEvent(KMouseCursorEvent.EVENT_CURSOR_CHANGED, KMouseCursorEvent.INTERPOLTE_MODE_CURSOR));
			
			_activeMode.activate();
			
			if(!(_activeMode is KManipulationMode))
				_manipulationWidget.visible = false;
		}
		
		public function beginCanvasInput(point:Point, isManipulation:Boolean, manipulationType:String):void
		{
			pathVisible = false;
			
			if(isManipulation)
			{
				(_activeMode as KManipulationMode).isManipulation = isManipulation;
				(_activeMode as KManipulationMode).setManipulator(manipulationType);
				_activeMode.beginInteraction(point);
				if(_transitionMode == KSketch2.TRANSITION_DEMONSTRATED)
				{
					_timeControl.startRecording();
					dispatchEvent(new KMouseCursorEvent(KMouseCursorEvent.EVENT_CURSOR_CHANGED, KMouseCursorEvent.DEMO_RECORDING_CURSOR));
				}
			}
			else
				_activeMode.beginInteraction(point);
		}
		
		public function updateCanvasInput(point:Point):void
		{
			_activeMode.updateInteraction(point);
		}
		
		public function completeCanvasInput():void
		{
			_activeMode.endInteraction();	
			_timeControl.stopRecording();
			determineMode();
			pathVisible = true;
		}
		
		public function addToUndoStack(operation:IModelOperation):void
		{
			if(!operation.isValid())
				throw new Error(operation.errorMessage);
			_undoStack.push(operation);

			if(hasRedo)
				_redoStack = new Vector.<IModelOperation>();
			
			dispatchEvent(new Event(EVENT_UNDO_REDO));
		}
		
		public function undo():void
		{
			var undoOp:IModelOperation = _undoStack.pop();
			undoOp.undo();
			_redoStack.push(undoOp);
			dispatchEvent(new Event(EVENT_UNDO_REDO));
		}
		
		public function redo():void
		{
			var redoOp:IModelOperation = _redoStack.pop();
			redoOp.redo();
			_undoStack.push(redoOp);
			dispatchEvent(new Event(EVENT_UNDO_REDO));
		}
		
		public function get hasUndo():Boolean
		{
			return _undoStack.length > 0;
		}
		
		public function get hasRedo():Boolean
		{
			return _redoStack.length > 0;
		}
		
		public function get currentInteraction():KInteractionOperation
		{
			return _currentInteraction;
		}
		
		public function begin_interaction_operation():void
		{
			if(currentInteraction)
				throw new Error("Can't begin an interaction operation. The previous interaction was not properly closed.");
			_currentInteraction = new KInteractionOperation(this, _timeControl);
			_currentInteraction.startTime = _KSketch.time;
			_currentInteraction.oldSelection = selection;
		}
		
		public function end_interaction_operation(operation:IModelOperation=null, newSelection:KSelection=null):void
		{
			if(operation)
			{
				currentInteraction.addOperation(operation);
				currentInteraction.newSelection = newSelection;
				currentInteraction.endTime = _timeControl.time;
				addToUndoStack(currentInteraction);
			}
			_currentInteraction = null;
		}
		
		public function triggerInterfaceUpdate():void
		{
			_KSketch.dispatchEvent(new KSketchEvent(KSketchEvent.EVENT_MODEL_UPDATED));
			
			if(_activeMode is KManipulationMode)
			{
				(_activeMode as KManipulationMode).updateManipulationMode();
				dispatchEvent(new KSketchEvent(KSketchEvent.EVENT_SELECTION_SET_CHANGED));
			}
		}
		
		private function _modelUpdatedEventHandler(event:KSketchEvent):void
		{
			_timeWidget.refresh();
			if(_activeMode is KManipulationMode)
			{
				(_activeMode as KManipulationMode).updateManipulationMode();
				dispatchEvent(new KSketchEvent(KSketchEvent.EVENT_SELECTION_SET_CHANGED));
			}
		}
		
		private function _selectionChangedEventHandler():void
		{
			if(_activeMode is KManipulationMode)
				(_activeMode as KManipulationMode).updateManipulationMode();
			
			_timeWidget.refresh();
		}
		
		private function _timeChangedEventHandler(event:KTimeChangedEvent):void
		{
			if(_activeMode is KManipulationMode)
			{
				if(_selection)
					_selection.updateSelectionComposition(event.to);
				
				(_activeMode as KManipulationMode).updateManipulationMode();
				dispatchEvent(new KSketchEvent(KSketchEvent.EVENT_SELECTION_SET_CHANGED));
			}
		}
		
		
		public function debugView():void
		{
			
		}
	}
}