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
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.model.geom.KPathPoint;
	import sg.edu.smu.ksketch.operation.KModelFacade;
	import sg.edu.smu.ksketch.utilities.KAppState;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;

	public class KLoggerCommandExecutor extends KCommandExecutor
	{
		public function KLoggerCommandExecutor(appState:KAppState, canvas:KCanvas, facade:KModelFacade)
		{
			super(appState, canvas, facade);
		}
		
		public function initCommand(command:String,commandNode:XML):void
		{
			switch (command)
			{
				case KLogger.BTN_TOGGLE_TIMEBAR_EXPAND:
					dispatchEvent(new KCommandEvent(
						KCommandEvent.EVENT_TIMEBAR_CHANGED,KLogger.BTN_TOGGLE_TIMEBAR_EXPAND));
					break;
				case KLogger.CHANGE_TIME:
					_appState.time = Number(commandNode.attribute(KLogger.CHANGE_TIME_TO));
					break;
				case KLogger.INTERACTION_DRAG_CENTER:
					_tapCenter();
					break;
				case KLogger.INTERACTION_MOVE_CENTER:
		//			_moveCenter(commandNode);
					_interact(commandNode);
					break;
				case KLogger.INTERACTION_DESELECT:
					_interact(commandNode);
					break;
				case KLogger.INTERACTION_DRAW:
					_interact(commandNode);
					break;
				case KLogger.INTERACTION_ERASE:
					_interact(commandNode);
					break;
				case KLogger.INTERACTION_TRANSLATE:
					_transform(KWidgetEvent.DOWN_TRANSLATE,commandNode);
					break;
				case KLogger.INTERACTION_ROTATE:
					_transform(KWidgetEvent.DOWN_ROTATE,commandNode);
					break;
				case KLogger.INTERACTION_SCALE:
					_transform(KWidgetEvent.DOWN_SCALE,commandNode);
					break;
				case KLogger.INTERACTION_GESTURE:
					_gesture(commandNode);
					break;
				default:
					_doOtherCommand(command,commandNode);
			}
		}
		
		public function redoCommand(command:String,commandNode:XML):void
		{
			switch (command)
			{
				case KLogger.BTN_TOGGLE_TIMEBAR_EXPAND:
					dispatchEvent(new KCommandEvent(
						KCommandEvent.EVENT_TIMEBAR_CHANGED,KLogger.BTN_TOGGLE_TIMEBAR_EXPAND));
					break;
				case KLogger.CHANGE_TIME:
					_appState.time = Number(commandNode.attribute(KLogger.CHANGE_TIME_TO));
					break;
				case KLogger.INTERACTION_DRAG_CENTER:
					_tapCenter();
					break;
				case KLogger.INTERACTION_MOVE_CENTER:
					_interact(commandNode);
					break;
				case KLogger.INTERACTION_DESELECT:
					_interact(commandNode);
					break;
				//		case KLogger.INTERACTION_HIDE_POPUP:
				//			_specialInteractor.mode = KSpecialInteractor.MODE_HIDE_POPUP;
				//			_interact(_specialInteractor,commandNode);
				//			break;
				case KLogger.INTERACTION_DRAW:
					_appState.redo();
					break;
				case KLogger.INTERACTION_ERASE:
					_appState.redo();
					break;
				case KLogger.INTERACTION_TRANSLATE:
					_appState.redo();
					break;
				case KLogger.INTERACTION_ROTATE:
					_appState.redo();
					break;
				case KLogger.INTERACTION_SCALE:
					_appState.redo();
					break;
				case KLogger.INTERACTION_GESTURE:
					_gesture(commandNode);
					break;
				default:
					_doOtherCommand(command,commandNode);
			}
		}
		
		public function undoCommand(command:String,commandNode:XML):void
		{
			switch (command)
			{
				case KLogger.BTN_TOGGLE_TIMEBAR_EXPAND:
					dispatchEvent(new KCommandEvent(
						KCommandEvent.EVENT_TIMEBAR_CHANGED,KLogger.BTN_TOGGLE_TIMEBAR_EXPAND));
					break;
				case KLogger.CHANGE_TIME:
					_appState.time = Number(commandNode.attribute(KLogger.CHANGE_TIME_FROM));
					break;
				case KLogger.INTERACTION_GESTURE:
					_undoGesture(commandNode);
					break;
				case KLogger.INTERACTION_DRAG_CENTER:
					_undoTapCenter();
					break;
				case KLogger.INTERACTION_MOVE_CENTER:
					_select(commandNode.attribute(KLogger.SELECTED_ITEMS));
					_tapCenter();
					break;
				case KLogger.INTERACTION_DESELECT:
					_select(commandNode.attribute(KLogger.SELECTED_ITEMS));
					break;
				case KLogger.INTERACTION_HIDE_POPUP:
					break;				
				case KLogger.INTERACTION_DRAW:
					_undo();
					break;
				case KLogger.INTERACTION_ERASE:
					_undo();
					break;
				case KLogger.INTERACTION_TRANSLATE:
					_undo();
					break;
				case KLogger.INTERACTION_ROTATE:
					_undo();
					break;
				case KLogger.INTERACTION_SCALE:
					_undo();
					break;
				case KLogger.BTN_CUT:
					_undo();
					break;
				case KLogger.BTN_COPY:
					break;
				case KLogger.BTN_PASTE:
					_undo();
					break;				
				case KLogger.BTN_UNDO:
					_redo();					
					break;
				case KLogger.BTN_REDO:
					_undo();					
					break;
				case KLogger.BTN_GROUP:
					_undo();					
					break;
				case KLogger.BTN_UNGROUP:
					_undo();					
					break;
				case KLogger.BTN_ERASER:
					_configurePen(commandNode.attribute(KLogger.BTN_PEN_PREVIOUS_STATE));
					break;
				case KLogger.BTN_BLACK_PEN:
					_configurePen(commandNode.attribute(KLogger.BTN_PEN_PREVIOUS_STATE));
					break;
				case KLogger.BTN_RED_PEN:					
					_configurePen(commandNode.attribute(KLogger.BTN_PEN_PREVIOUS_STATE));
					break;
				case KLogger.BTN_GREEN_PEN:					
					_configurePen(commandNode.attribute(KLogger.BTN_PEN_PREVIOUS_STATE));
					break;
				case KLogger.BTN_BLUE_PEN:					
					_configurePen(commandNode.attribute(KLogger.BTN_PEN_PREVIOUS_STATE));
					break;
				case KLogger.BTN_FIRST:
					_appState.time = commandNode.attribute(KLogger.CHANGE_TIME_FROM);
					break;
				case KLogger.BTN_PREVIOUS:
					_next();
					break;
				case KLogger.BTN_NEXT:
					_previous();
					break;
				case KLogger.BTN_TOGGLE_VISIBILITY:
					_toggleVisibility();
					break;
				case KLogger.CHANGE_SELECTION_MODE:
					_appState.groupSelectMode = commandNode.attribute(KLogger.CHANGE_SELECTION_MODE_FROM);
					break;
				case KLogger.CHANGE_GROUPING_MODE:
					_appState.groupingMode = commandNode.attribute(KLogger.CHANGE_GROUPING_MODE_FROM);
					break;
				case KLogger.CHANGE_CREATION_MODE:
					_appState.creationMode = commandNode.attribute(KLogger.CHANGE_CREATION_MODE_FROM);
					break;
				case KLogger.CHANGE_PATH_VISIBILITY:
					_appState.userOption.showPath = commandNode.attribute(KLogger.CHANGE_PATH_VISIBILITY_FROM);
					break;
	//			case KLogger.CHANGE_DEMO_MERGE_MODE:
	//				_facade.setDemoMergeMode(commandNode.attribute(KLogger.CHANGE_DEMO_MERGE_MODE_FROM));
	//				break;
				case KLogger.CHANGE_GESTURE_DESIGN:
					_appState.gestureDesignName = commandNode.attribute(KLogger.CHANGE_GESTURE_DESIGN_FROM);
					break;
				case KLogger.CHANGE_GESTURE_ACCEPTANCE_SCORE:
					Recognizer.ACCEPT_SCORE =commandNode.attribute(KLogger.CHANGE_GESTURE_ACCEPTANCE_SCORE_FROM);
					break;
				case KLogger.CHANGE_GESTURE_RECOGNITION_TIMEOUT:
					KGestureRecognizer.PEN_PAUSE_TIME = commandNode.attribute(KLogger.CHANGE_GESTURE_RECOGNITION_TIMEOUT_FROM);
					break;
				case KLogger.CHANGE_RIGHT_MOUSE_ENABLED:
					_appState.userOption.rightMouseButtonEnabled = commandNode.attribute(KLogger.CHANGE_RIGHT_MOUSE_ENABLED_FROM);
					break;
				case KLogger.CHANGE_CONFIRM_DIALOG_ENABLED:
					_appState.userOption.showConfirmWindow = commandNode.attribute(KLogger.CHANGE_CONFIRM_DIALOG_ENABLED_FROM);
					break;
				case KLogger.CHANGE_APPLICATION_LOG_ENABLED:
					KLogger.enabled = commandNode.attribute(KLogger.CHANGE_APPLICATION_LOG_ENABLED_FROM);
					break;
				case KLogger.CHANGE_ASPECT_RATIO:
					break;
			}
		}

		private function _doOtherCommand(command:String,commandNode:XML):void
		{
			switch (command)
			{
				case KLogger.CHANGE_SELECTION_MODE:
					_appState.groupSelectMode = commandNode.attribute(KLogger.CHANGE_SELECTION_MODE_TO);
					break;
				case KLogger.CHANGE_GROUPING_MODE:
					_appState.groupingMode = commandNode.attribute(KLogger.CHANGE_GROUPING_MODE_TO);
					break;
				case KLogger.CHANGE_CREATION_MODE:
					_appState.creationMode = commandNode.attribute(KLogger.CHANGE_CREATION_MODE_TO);
					break;
				case KLogger.CHANGE_PATH_VISIBILITY:
					_appState.userOption.showPath = commandNode.attribute(KLogger.CHANGE_PATH_VISIBILITY_TO);
					break;
				//			case KLogger.CHANGE_DEMO_MERGE_MODE:
				//				_facade.setDemoMergeMode(commandNode.attribute(KLogger.CHANGE_DEMO_MERGE_MODE_TO));
				//				break;
				case KLogger.CHANGE_GESTURE_DESIGN:
					_appState.gestureDesignName = commandNode.attribute(KLogger.CHANGE_GESTURE_DESIGN_TO);
					break;
				case KLogger.CHANGE_GESTURE_ACCEPTANCE_SCORE:
					Recognizer.ACCEPT_SCORE =commandNode.attribute(KLogger.CHANGE_GESTURE_ACCEPTANCE_SCORE_TO);
					break;
				case KLogger.CHANGE_GESTURE_RECOGNITION_TIMEOUT:
					KGestureRecognizer.PEN_PAUSE_TIME = commandNode.attribute(KLogger.CHANGE_GESTURE_RECOGNITION_TIMEOUT_TO);
					break;
				case KLogger.CHANGE_RIGHT_MOUSE_ENABLED:
					_appState.userOption.rightMouseButtonEnabled = commandNode.attribute(KLogger.CHANGE_RIGHT_MOUSE_ENABLED_TO);
					break;
				case KLogger.CHANGE_CONFIRM_DIALOG_ENABLED:
					_appState.userOption.showConfirmWindow = commandNode.attribute(KLogger.CHANGE_CONFIRM_DIALOG_ENABLED_TO);
					break;
				case KLogger.CHANGE_APPLICATION_LOG_ENABLED:
					KLogger.enabled = commandNode.attribute(KLogger.CHANGE_APPLICATION_LOG_ENABLED_TO);
					break;
				case KLogger.CHANGE_ASPECT_RATIO:
					break;
				case KLogger.BTN_SAVE:
					break;
				default:
					doButtonCommand(command);
			}			
		}
				
		private function _interact(commandNode:XML):void
		{
			_dispatchMouseEvents(_getPath(commandNode));
		}
		
		private function _gesture(commandNode:XML):void
		{
			var event:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN);
			event.keyCode = Keyboard.CONTROL;
			_canvas.systemManager.stage.dispatchEvent(event);
			_interact(commandNode);
			event = new KeyboardEvent(KeyboardEvent.KEY_UP);
			event.keyCode = Keyboard.CONTROL;
			_canvas.systemManager.stage.dispatchEvent(event);
			if (commandNode.attribute(KLogger.SELECTED_ITEMS).length() > 0)
				_select(commandNode.attribute(KLogger.SELECTED_ITEMS));
		}

		private function _tapCenter():void
		{
			(_canvas.interactorManager.widget as KWidget).dispatchEvent(
				new KWidgetEvent(KWidgetEvent.DOWN_CENTER, 0, 0));
			var p:Point = _canvas.globalToLocal(new Point(0, 0));
			_canvas.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP, true, false, p.x, p.y));
		}

		private function _transform(widgetEventType:String,commandNode:XML):void
		{
			var path:Vector.<KPathPoint> = _getPath(commandNode);		
			var type:int = commandNode.attribute(KLogger.TRANSITION_TYPE);
			_appState.transitionType = isNaN(type) ? _appState.transitionType : type;
			_appState.time = path[0].time;
			var p:Point = KInteractorManager.getInverseCoordinate(
				_canvas.localToGlobal(path[0]),_canvas);
			var widget:KWidget = _canvas.interactorManager.widget as KWidget;
			widget.dispatchEvent(new KWidgetEvent(widgetEventType, p.x, p.y));
			_dispatchMouseMoveAndUpEvents(path);		
		}

		private function _undoGesture(commandNode:XML):void
		{
			var match:String = commandNode.attribute(KLogger.MATCH).toString();
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
					_select(commandNode.attribute(KLogger.PREV_SELECTED_ITEMS));
			}	
		}
		
		private function _undoTapCenter():void
		{
			var p:Point = _canvas.interactorManager.widget.center;
			_canvas.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, p.x, p.y));
			_canvas.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP, true, false, p.x, p.y));
		}
		
		private function _select(selectedItems:String):void
		{
			var ids:Array = selectedItems.split(" ");
			var objs:KModelObjectList = new KModelObjectList();
			for (var i:int=0; i < ids.length; i++)
			{
				var obj:KObject = _facade.getObjectByID(ids[i]);
				if (obj)
					objs.add(obj);
			}
			_appState.selection = objs.length()>0?new KSelection(objs,_appState.time):null;
		}	
		
		private function _dispatchMouseEvents(cursorPath:Vector.<KPathPoint>):void
		{
			var length:uint = cursorPath.length;
			if(length <= 1)
				throw new Error("Interaction on canvas must at least has 2 points!");
			
			_appState.time = cursorPath[0].time;
			var p:Point = KInteractorManager.getInverseCoordinate(cursorPath[0],_canvas);
			_canvas.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, p.x, p.y));
			_dispatchMouseMoveAndUpEvents(cursorPath);
		}
		
		private function _dispatchMouseMoveAndUpEvents(cursorPath:Vector.<KPathPoint>):void
		{
			var p:Point;
			var length:uint = cursorPath.length;
			for(var i:uint = 1;i<length-1;i++)
			{
				_appState.time = cursorPath[i].time;
				p = KInteractorManager.getInverseCoordinate(cursorPath[i],_canvas);
				_canvas.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE, true, false, p.x, p.y));
			}
			_appState.time = cursorPath[length-1].time;
			p = KInteractorManager.getInverseCoordinate(cursorPath[length-1],_canvas);
			_canvas.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP, true, false, p.x, p.y));
		}		
		
		private function _getPath(commandNode:XML):Vector.<KPathPoint>
		{
			return KFileParser.generatePathPoints(commandNode.attribute(KLogger.CURSOR_PATH));			
			
		}
	}
}