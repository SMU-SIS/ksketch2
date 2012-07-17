/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.interactor
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	import sg.edu.smu.ksketch.components.KCanvas;
	import sg.edu.smu.ksketch.components.KWidget;
	import sg.edu.smu.ksketch.event.KCommandEvent;
	import sg.edu.smu.ksketch.event.KWidgetEvent;
	import sg.edu.smu.ksketch.gestures.GestureDesign;
	import sg.edu.smu.ksketch.gestures.Recognizer;
	import sg.edu.smu.ksketch.io.KFileParser;
	import sg.edu.smu.ksketch.logger.KLogger;
	import sg.edu.smu.ksketch.logger.KPlaySketchLogger;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.model.geom.KPathPoint;
	import sg.edu.smu.ksketch.model.geom.KPathProcessor;
	import sg.edu.smu.ksketch.operation.KModelFacade;
	import sg.edu.smu.ksketch.utilities.KAppState;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;

	public class KLoggerCommandExecutor extends KCommandExecutor
	{
		public function KLoggerCommandExecutor(appState:KAppState, canvas:KCanvas, facade:KModelFacade)
		{
			super(appState, canvas, facade);
		}
		
		public function initCommand(commandNode:XML):void
		{
			var command:String = commandNode.name();			
			switch (command)
			{
				case KPlaySketchLogger.BTN_TOGGLE_TIMEBAR_EXPAND:
					dispatchEvent(new KCommandEvent(
						KCommandEvent.EVENT_TIMEBAR_CHANGED,KPlaySketchLogger.BTN_TOGGLE_TIMEBAR_EXPAND));
					break;
				case KLogger.CHANGE_TIME:
					_appState.time = Number(commandNode.attribute(KLogger.TIME_TO));
					break;
				case KPlaySketchLogger.INTERACTION_DRAG_CENTER:
					_showInteraction(KPlaySketchLogger.INTERACTION_DRAG_CENTER,commandNode);
					break;
				case KPlaySketchLogger.INTERACTION_MOVE_CENTER:
					_showInteraction(KPlaySketchLogger.INTERACTION_MOVE_CENTER,commandNode);
					break;
				case KPlaySketchLogger.INTERACTION_DESELECT:
					_showInteraction(KPlaySketchLogger.INTERACTION_DESELECT,commandNode);
					break;
				case KPlaySketchLogger.INTERACTION_DRAW:
					_showInteraction(KPlaySketchLogger.INTERACTION_DRAW,commandNode);
					break;
				case KPlaySketchLogger.INTERACTION_ERASE:
					_showInteraction(KPlaySketchLogger.INTERACTION_ERASE,commandNode);
					break;
				case KPlaySketchLogger.INTERACTION_TRANSLATE:
					_showInteraction(KPlaySketchLogger.INTERACTION_TRANSLATE,commandNode);
					break;
				case KPlaySketchLogger.INTERACTION_ROTATE:
					_showInteraction(KPlaySketchLogger.INTERACTION_ROTATE,commandNode);
					break;
				case KPlaySketchLogger.INTERACTION_SCALE:
					_showInteraction(KPlaySketchLogger.INTERACTION_SCALE,commandNode);
					break;
				case KPlaySketchLogger.INTERACTION_GESTURE:
					_showInteraction(KPlaySketchLogger.INTERACTION_GESTURE,commandNode);
					break;
				default:
					_doOtherCommand(command,commandNode);
			}
		}
		
		public function redoCommand(command:String,commandNode:XML):void
		{
			switch (command)
			{
				case KPlaySketchLogger.BTN_TOGGLE_TIMEBAR_EXPAND:
					dispatchEvent(new KCommandEvent(
						KCommandEvent.EVENT_TIMEBAR_CHANGED,KPlaySketchLogger.BTN_TOGGLE_TIMEBAR_EXPAND));
					break;
				case KLogger.CHANGE_TIME:
					_appState.time = Number(commandNode.attribute(KLogger.TIME_TO));
					break;
				case KPlaySketchLogger.INTERACTION_DRAG_CENTER:
					_tapCenter();
					break;
				case KPlaySketchLogger.INTERACTION_MOVE_CENTER:
					_interact(commandNode);
					break;
				case KPlaySketchLogger.INTERACTION_DESELECT:
					_interact(commandNode);
					break;
				//		case KLogger.INTERACTION_HIDE_POPUP:
				//			_specialInteractor.mode = KSpecialInteractor.MODE_HIDE_POPUP;
				//			_interact(_specialInteractor,commandNode);
				//			break;
				case KPlaySketchLogger.INTERACTION_DRAW:
					_appState.redo();
					break;
				case KPlaySketchLogger.INTERACTION_ERASE:
					_appState.redo();
					break;
				case KPlaySketchLogger.INTERACTION_TRANSLATE:
					_appState.redo();
					break;
				case KPlaySketchLogger.INTERACTION_ROTATE:
					_appState.redo();
					break;
				case KPlaySketchLogger.INTERACTION_SCALE:
					_appState.redo();
					break;
				case KPlaySketchLogger.INTERACTION_GESTURE:
					_redoGesture(commandNode);
					break;
				default:
					_doOtherCommand(command,commandNode);
			}
		}
		
		public function undoCommand(command:String,commandNode:XML):void
		{
			switch (command)
			{
				case KPlaySketchLogger.BTN_TOGGLE_TIMEBAR_EXPAND:
					dispatchEvent(new KCommandEvent(
						KCommandEvent.EVENT_TIMEBAR_CHANGED,KPlaySketchLogger.BTN_TOGGLE_TIMEBAR_EXPAND));
					break;
				case KLogger.CHANGE_TIME:
					_appState.time = Number(commandNode.attribute(KLogger.TIME_FROM));
					break;
				case KPlaySketchLogger.INTERACTION_GESTURE:
					_undoGesture(commandNode);
					break;
				case KPlaySketchLogger.INTERACTION_DRAG_CENTER:
					_undoTapCenter();
					break;
				case KPlaySketchLogger.INTERACTION_MOVE_CENTER:
					_select(commandNode.attribute(KPlaySketchLogger.SELECTED_ITEMS));
					_tapCenter();
					break;
				case KPlaySketchLogger.INTERACTION_DESELECT:
					_select(commandNode.attribute(KPlaySketchLogger.SELECTED_ITEMS));
					break;
				case KPlaySketchLogger.INTERACTION_HIDE_POPUP:
					break;				
				case KPlaySketchLogger.INTERACTION_DRAW:
					_undo();
					break;
				case KPlaySketchLogger.INTERACTION_ERASE:
					_undo();
					break;
				case KPlaySketchLogger.INTERACTION_TRANSLATE:
					_undo();
					break;
				case KPlaySketchLogger.INTERACTION_ROTATE:
					_undo();
					break;
				case KPlaySketchLogger.INTERACTION_SCALE:
					_undo();
					break;
				case KPlaySketchLogger.BTN_CUT:
					_undo();
					break;
				case KPlaySketchLogger.BTN_COPY:
					break;
				case KPlaySketchLogger.BTN_PASTE:
					_undo();
					break;				
				case KPlaySketchLogger.BTN_UNDO:
					_redo();					
					break;
				case KPlaySketchLogger.BTN_REDO:
					_undo();					
					break;
				case KPlaySketchLogger.BTN_GROUP:
					_undo();					
					break;
				case KPlaySketchLogger.BTN_UNGROUP:
					_undo();					
					break;
				case KPlaySketchLogger.BTN_ERASER:
					_configurePen(commandNode.attribute(KPlaySketchLogger.BTN_PEN_PREVIOUS_STATE));
					break;
				case KPlaySketchLogger.BTN_BLACK_PEN:
					_configurePen(commandNode.attribute(KPlaySketchLogger.BTN_PEN_PREVIOUS_STATE));
					break;
				case KPlaySketchLogger.BTN_RED_PEN:					
					_configurePen(commandNode.attribute(KPlaySketchLogger.BTN_PEN_PREVIOUS_STATE));
					break;
				case KPlaySketchLogger.BTN_GREEN_PEN:					
					_configurePen(commandNode.attribute(KPlaySketchLogger.BTN_PEN_PREVIOUS_STATE));
					break;
				case KPlaySketchLogger.BTN_BLUE_PEN:					
					_configurePen(commandNode.attribute(KPlaySketchLogger.BTN_PEN_PREVIOUS_STATE));
					break;
				case KPlaySketchLogger.BTN_FIRST:
					_appState.time = commandNode.attribute(KLogger.TIME_FROM);
					break;
				case KPlaySketchLogger.BTN_PREVIOUS:
					_next();
					break;
				case KPlaySketchLogger.BTN_NEXT:
					_previous();
					break;
	//			case KPlaySketchLogger.BTN_TOGGLE_VISIBILITY:
	//				_toggleVisibility();
					break;
				case KPlaySketchLogger.CHANGE_SELECTION_MODE:
					_appState.groupSelectMode = commandNode.attribute(KPlaySketchLogger.CHANGE_SELECTION_MODE_FROM);
					break;
				case KPlaySketchLogger.CHANGE_GROUPING_MODE:
					_appState.groupingMode = commandNode.attribute(KPlaySketchLogger.CHANGE_GROUPING_MODE_FROM);
					break;
				case KPlaySketchLogger.CHANGE_GESTURE_DESIGN:
					_appState.gestureDesignName = commandNode.attribute(KPlaySketchLogger.CHANGE_GESTURE_DESIGN_FROM);
					break;
				case KPlaySketchLogger.CHANGE_GESTURE_ACCEPTANCE_SCORE:
					Recognizer.ACCEPT_SCORE =commandNode.attribute(KPlaySketchLogger.CHANGE_GESTURE_ACCEPTANCE_SCORE_FROM);
					break;
				case KPlaySketchLogger.CHANGE_GESTURE_RECOGNITION_TIMEOUT:
					KGestureRecognizer.PEN_PAUSE_TIME = commandNode.attribute(KPlaySketchLogger.CHANGE_GESTURE_RECOGNITION_TIMEOUT_FROM);
					break;
				case KPlaySketchLogger.CHANGE_CREATION_MODE:
					_appState.creationMode = commandNode.attribute(KPlaySketchLogger.CHANGE_CREATION_MODE_FROM);
					break;
				case KPlaySketchLogger.CHANGE_PATH_VISIBILITY:
					_appState.userOption.showPath = commandNode.attribute(KPlaySketchLogger.CHANGE_PATH_VISIBILITY_FROM);
					break;
				case KPlaySketchLogger.CHANGE_CORRECT_FUTURE_MOTION:
					KAppState.erase_real_time_future = commandNode.attribute(KPlaySketchLogger.CHANGE_CORRECT_FUTURE_MOTION_FROM);
					break;
	//			case KLogger.CHANGE_DEMO_MERGE_MODE:
	//				_facade.setDemoMergeMode(commandNode.attribute(KLogger.CHANGE_DEMO_MERGE_MODE_FROM));
	//				break;
				case KPlaySketchLogger.CHANGE_RIGHT_MOUSE_ENABLED:
					_appState.userOption.rightMouseButtonEnabled = commandNode.attribute(KPlaySketchLogger.CHANGE_RIGHT_MOUSE_ENABLED_FROM);
					break;
				case KPlaySketchLogger.CHANGE_CONFIRM_DIALOG_ENABLED:
					_appState.userOption.showConfirmWindow = commandNode.attribute(KPlaySketchLogger.CHANGE_CONFIRM_DIALOG_ENABLED_FROM);
					KPlaySketchLogger;
				case KPlaySketchLogger.CHANGE_APPLICATION_LOG_ENABLED:
					KLogger.enabled = commandNode.attribute(KPlaySketchLogger.CHANGE_APPLICATION_LOG_ENABLED_FROM);
					break;
				case KPlaySketchLogger.CHANGE_ASPECT_RATIO:
					break;
				case KLogger.NEW_SESSION:
					break;
			}
		}

		private function _doOtherCommand(command:String,commandNode:XML):void
		{
			switch (command)
			{
				case KPlaySketchLogger.CHANGE_SELECTION_MODE:
					_appState.groupSelectMode = commandNode.attribute(KPlaySketchLogger.CHANGE_SELECTION_MODE_TO);
					break;
				case KPlaySketchLogger.CHANGE_GROUPING_MODE:
					_appState.groupingMode = commandNode.attribute(KPlaySketchLogger.CHANGE_GROUPING_MODE_TO);
					break;
				case KPlaySketchLogger.CHANGE_GESTURE_DESIGN:
					_appState.gestureDesignName = commandNode.attribute(KPlaySketchLogger.CHANGE_GESTURE_DESIGN_TO);
					break;
				case KPlaySketchLogger.CHANGE_GESTURE_ACCEPTANCE_SCORE:
					Recognizer.ACCEPT_SCORE =commandNode.attribute(KPlaySketchLogger.CHANGE_GESTURE_ACCEPTANCE_SCORE_TO);
					break;
				case KPlaySketchLogger.CHANGE_GESTURE_RECOGNITION_TIMEOUT:
					KGestureRecognizer.PEN_PAUSE_TIME = commandNode.attribute(KPlaySketchLogger.CHANGE_GESTURE_RECOGNITION_TIMEOUT_TO);
					break;
				case KPlaySketchLogger.CHANGE_CREATION_MODE:
					_appState.creationMode = commandNode.attribute(KPlaySketchLogger.CHANGE_CREATION_MODE_TO);
					break;
				case KPlaySketchLogger.CHANGE_PATH_VISIBILITY:
					_appState.userOption.showPath = commandNode.attribute(KPlaySketchLogger.CHANGE_PATH_VISIBILITY_TO);
					break;
				case KPlaySketchLogger.CHANGE_CORRECT_FUTURE_MOTION:
					KAppState.erase_real_time_future = commandNode.attribute(KPlaySketchLogger.CHANGE_CORRECT_FUTURE_MOTION_TO);
					break;
		//			case KLogger.CHANGE_DEMO_MERGE_MODE:
		//				_facade.setDemoMergeMode(commandNode.attribute(KLogger.CHANGE_DEMO_MERGE_MODE_TO));
		//				break;
				case KPlaySketchLogger.CHANGE_RIGHT_MOUSE_ENABLED:
					_appState.userOption.rightMouseButtonEnabled = commandNode.attribute(KPlaySketchLogger.CHANGE_RIGHT_MOUSE_ENABLED_TO);
					break;
				case KPlaySketchLogger.CHANGE_CONFIRM_DIALOG_ENABLED:
					_appState.userOption.showConfirmWindow = commandNode.attribute(KPlaySketchLogger.CHANGE_CONFIRM_DIALOG_ENABLED_TO);
					break;
				case KPlaySketchLogger.CHANGE_APPLICATION_LOG_ENABLED:
					KLogger.enabled = commandNode.attribute(KPlaySketchLogger.CHANGE_APPLICATION_LOG_ENABLED_TO);
					break;
				case KPlaySketchLogger.CHANGE_ASPECT_RATIO:
					break;
				case KPlaySketchLogger.BTN_NEW:
					break;
				case KPlaySketchLogger.BTN_LOAD:
					break;
				case KPlaySketchLogger.BTN_SAVE:
					break;
				case KLogger.NEW_SESSION:
					break;
				default:
					doButtonCommand(command);
			}			
		}
				
		private function _interact(commandNode:XML):void
		{
	//		_canvas.showInteraction(_getPath(commandNode));
		}
		
		// Ignore toggle pen/eraser gesture, as it is also log as a Pen/Eraser button command
		private function _gesture(commandNode:XML):void
		{
			if (commandNode.attribute(KPlaySketchLogger.SELECTED_ITEMS).length() > 0)
				_select(commandNode.attribute(KPlaySketchLogger.SELECTED_ITEMS));
			else if (commandNode.attribute(KPlaySketchLogger.MATCH) != GestureDesign.NAME_PRE_TOGGLE)
			{
				var event:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN);
				event.keyCode = Keyboard.CONTROL;
				_canvas.systemManager.stage.dispatchEvent(event);
				_interact(commandNode);
				event = new KeyboardEvent(KeyboardEvent.KEY_UP);
				event.keyCode = Keyboard.CONTROL;
				_canvas.systemManager.stage.dispatchEvent(event);
			}
		}

		private function _tapCenter():void
		{
			(_canvas.interactorManager.widget as KWidget).dispatchEvent(
				new KWidgetEvent(KWidgetEvent.DOWN_CENTER, 0, 0));
			var p:Point = _canvas.globalToLocal(new Point(0, 0));
			_canvas.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP, true, false, p.x, p.y));
		}

		private function _showInteraction(interactionType:String,commandNode:XML):void
		{
			
		}

		// Ignore toggle pen/eraser gesture, as it is also log as a Pen/Eraser button command
		private function _redoGesture(commandNode:XML):void
		{
			var match:String = commandNode.attribute(KPlaySketchLogger.MATCH).toString();
			switch (match)
			{
				case GestureDesign.NAME_PRE_CUT:				
					_redo();					
					break;
				case GestureDesign.NAME_PRE_PASTE:
					_redo();
					break;
				case GestureDesign.NAME_PRE_REDO:					
					_redo();
					break;
				case GestureDesign.NAME_PRE_UNDO:
					_undo();
					break;
				default:
					_gesture(commandNode);
			}	
		}
		
		private function _undoGesture(commandNode:XML):void
		{
			var match:String = commandNode.attribute(KPlaySketchLogger.MATCH).toString();
			switch (match)
			{
				case GestureDesign.NAME_PRE_CUT:				
					_undo();					
					break;
				case GestureDesign.NAME_PRE_PASTE:
					_undo();
					break;
				case GestureDesign.NAME_PRE_REDO:					
					_undo();
					break;
				case GestureDesign.NAME_PRE_UNDO:
					_redo();
					break;
				default:
					_select(commandNode.attribute(KPlaySketchLogger.PREV_SELECTED_ITEMS));
			}	
		}
		
		private function _undoTapCenter():void
		{
			var p:Point = _canvas.interactorManager.widget.center;
			_canvas.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, p.x, p.y));
			_canvas.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP, true, false, p.x, p.y));
		}
		
		protected function _getObjectsByIDs(ids:Vector.<int>):KModelObjectList
		{
			var objs:KModelObjectList = new KModelObjectList();
			for (var i:int=0; i < ids.length; i++)
			{
				var obj:KObject = _facade.getObjectByID(ids[i]);
				if (obj)
					objs.add(obj);
			}
			return objs;
		}
		
		private function _select(selectedItems:String):void
		{
			var objs:KModelObjectList = _getObjectsByIDs(KFileParser.stringToInts(selectedItems));
			_appState.selection = objs.length()>0?new KSelection(objs,_appState.time):null;
		}	
		
		protected function _getPath(commandNode:XML):Vector.<KPathPoint>
		{
			return KPathProcessor.generatePathPointsFromString(
				commandNode.attribute(KLogger.CURSOR_PATH));			
			
		}
	}
}