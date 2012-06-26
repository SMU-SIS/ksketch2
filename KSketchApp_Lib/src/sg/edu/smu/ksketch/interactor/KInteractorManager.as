/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.interactor
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	import mx.managers.PopUpManager;
	
	import sg.edu.smu.ksketch.components.ConfirmDialog;
	import sg.edu.smu.ksketch.components.IWidget;
	import sg.edu.smu.ksketch.components.KCanvas;
	import sg.edu.smu.ksketch.event.KWidgetEvent;
	import sg.edu.smu.ksketch.logger.ILoggable;
	import sg.edu.smu.ksketch.logger.KLogger;
	import sg.edu.smu.ksketch.model.ISpatialKeyframe;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	import sg.edu.smu.ksketch.operation.KModelFacade;
	import sg.edu.smu.ksketch.operation.KTransformMgr;
	import sg.edu.smu.ksketch.operation.KUngroupUtil;
	import sg.edu.smu.ksketch.utilities.KAppState;
	import sg.edu.smu.ksketch.utilities.KMathUtil;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;
	import sg.edu.smu.ksketch.utilities.KSaveInfos;
	import sg.edu.smu.ksketch.utilities.KSavingUserPreferences;
	
	import spark.components.BorderContainer;
	
	public class KInteractorManager extends EventDispatcher implements IInteractorManager
	{
		private static const STATE_NORMAL_WAITING:String = "STATE_NORMAL_WAITING";
		private static const STATE_SPECIAL_WAITING:String = "STATE_SPECIAL_WAITING";
		private static const STATE_NORMAL_INTERACTING:String = "STATE_NORMAL_INTERACTING";
		private static const STATE_DRAGING_CENTER:String = "STATE_DRAGING_CENTER";
		private static const STATE_SELECTING_AND_RECOGNIZING:String = "STATE_SELECTING_AND_RECOGNIZING";
		
		private static const REGION_SCALE:String = "SCALE";
		private static const REGION_ROTATE:String = "ROTATE";
		private static const REGION_TRANSLATE:String = "TRANSLATE";
		private static const REGION_CENTER:String = "CENTER";
		private static const REGION_CANVAS:String = "CANVAS";
	//	public static const HIGHLITED_CURSOR_PATH_CLICKED:String = "HIGHLITED_CURSOR_PATH_CLICKED";
		
		private var _currentInteractor:IInteractor;
		
		// possible interactors:
		private var _pathInteractor:KPathCenterInteractor;
		private var _eraseInteractor:KEraseInteractor;
		private var _drawInteractor:IInteractor;
		private var _specialInteractor:KSpecialInteractor;
		private var _translateInteractor:IInteractor;
		private var _rotateInteractor:IInteractor;
		private var _scaleInteractor:IInteractor;
		private var _moveCenterInteractor:IInteractor;
		private var _selectInteractor:KSelectInteractor;
		private var _rectSelectInteractor:KRectangleSelectInteractor;
		private var _loopSelectInteractor:KLoopSelectInteractor;
		private var _gestureRecognizer:KGestureRecognizer;
		private var _dragHandleInteractor:KDragCenterInteractor; // detecting tap gesture while translating
		
		private var _canvas:KCanvas;
		private var _appState:KAppState;
		private var _widget:IWidget;
		
		private var _ctrlDown:Boolean;
		private var _altDown:Boolean;
		private var _pageDownHolding:Boolean;
		private var _pageUpHolding:Boolean;
		private var _shift:Boolean
		private var _state:String;
		
		private var _log:ILoggable;
		
		private var _confirmWindow:ConfirmDialog;
		
		private var _executor:KCommandExecutor;
		
		private var _eraserMode:Boolean;
		private var _facade:KModelFacade;
		private var _pathDetector:KHitDetector;
		
		public function KInteractorManager()
		{
		}
		
		public static function getEventCoordinate(event:MouseEvent,canvas:KCanvas):Point
		{			
			var p:Point = new Point();
			p.x = (event.stageX-canvas.mouseOffsetX)/canvas.contentScale;
			p.y = (event.stageY-canvas.mouseOffsetY)/canvas.contentScale;
			return p;
		}
		
		public static function getInverseCoordinate(p:Point,canvas:KCanvas):Point
		{			
			var pt:Point = new Point();
			pt.x = p.x*canvas.contentScale + canvas.mouseOffsetX;
			pt.y = p.y*canvas.contentScale + canvas.mouseOffsetY;
			return pt;
		}			

		public function activateOn(facade:KModelFacade, appState:KAppState, 
								   canvas:KCanvas, widget:IWidget):void
		{
			_canvas = canvas;
			_appState = appState;
			_widget = widget;
			_facade=facade;
			
			_pathDetector = new KHitDetector(canvas);
			
			_pathInteractor = new KPathCenterInteractor(facade, appState);
			_eraseInteractor = new KEraseInteractor(facade, appState, canvas);
			_drawInteractor = new KDrawInteractor(facade, appState);
			_specialInteractor = new KSpecialInteractor(appState);
			_translateInteractor = new KTranslateInteractor(facade, appState);
			_rotateInteractor = new KRotateInteractor(facade, appState,new KGhostMarker(canvas));
			_scaleInteractor = new KScaleInteractor(facade, appState,new KGhostMarker(canvas));
			_moveCenterInteractor = new KMoveCenterInteractor(appState, _widget,facade);
			_dragHandleInteractor = new KDragCenterInteractor(appState, 
				_translateInteractor as KTranslateInteractor);
			(_moveCenterInteractor as KMoveCenterInteractor).canvas = _canvas;
			_rectSelectInteractor = new KRectangleSelectInteractor(facade, appState, canvas);
			_loopSelectInteractor = new KLoopSelectInteractor(facade, appState, canvas);
			_selectInteractor = _loopSelectInteractor;
			_setSelectMode();
			_appState.addEventListener(KAppState.EVENT_SELECT_MODE_CHANGED, _setSelectMode);
			
			_executor = new KCommandExecutor(appState, canvas, facade);
			_gestureRecognizer = new KGestureRecognizer(
				facade, appState, canvas, _executor, _loopSelectInteractor);
			
			_ctrlDown = false;
			_altDown = false;
			_pageUpHolding = false;
			_pageDownHolding = false;
			_shift = false;
			
			_canvas.systemManager.stage.addEventListener(
				KeyboardEvent.KEY_DOWN, _onHoldingKeyChanged, false, int.MAX_VALUE);
			_canvas.systemManager.stage.addEventListener(
				KeyboardEvent.KEY_UP, _onHoldingKeyChanged, false, int.MAX_VALUE);			
			_waiting();
		}
		
		public function reset():void
		{
			_executor.hasPopup = false;
			
			if(_state == STATE_NORMAL_INTERACTING)
				throw new Error("KInteractor.reset called when state is "+_state);
			
			if(_state == STATE_SPECIAL_WAITING)
				_endSpecialWaiting();
			else
				_endWaiting();
			
			_waiting();
		}
		
		public function get widget():IWidget
		{
			return _widget;
		}
		
		public function setEraseMode(b:Boolean):void
		{
			_eraserMode = b;
		}
		
		private function _setSelectMode(event:Event = null):void
		{
			var needChange:Boolean = false;
			if(_currentInteractor == _selectInteractor)
				needChange = true;
			if(_appState.selectMode == KLoopSelectInteractor.MODE)
				_selectInteractor = _loopSelectInteractor;
			else if(_appState.selectMode == KRectangleSelectInteractor.MODE)
				_selectInteractor = _rectSelectInteractor;
			if(needChange)
				_activate(_selectInteractor);
		}
		
		private function _onHoldingKeyChanged(event:KeyboardEvent):void
		{
			_onHoldingKeyChangedToggle(event.keyCode,event.type == KeyboardEvent.KEY_DOWN);
		}
		
		private function _onHoldingKeyChangedToggle(keycode:uint,bool:Boolean):void
		{
			if(keycode == Keyboard.CONTROL || keycode == Keyboard.COMMAND)
			{	
				if(_appState.ctrlEnabled)
				{
					_ctrlDown = bool;
					_appState.gestureMode = bool;
				}
				else
					_ctrlDown = false;					
			}
			else if(keycode == Keyboard.ALTERNATE)
			{
				if(_appState.altEnabled)
					_altDown = bool;
				else
					_altDown = false;	
			}
			else if(keycode == Keyboard.PAGE_DOWN)
			{
				if(_appState.pgDownEnabled)
					_pageDownHolding = bool;
				else
					_pageDownHolding = false;
			}
			else if(keycode == Keyboard.PAGE_UP)
			{
				if(_appState.pgUpEnabled)
					_pageUpHolding = bool;
				else
					_pageUpHolding = false;
			}
			else if(keycode == Keyboard.SHIFT)
			{
				_shift = bool;	
			}
		}
		
		// state machine
		
		private function _onTapDetected(event:Event):void
		{   
			_dragHandleInteractor.removeEventListener(
				KDragCenterInteractor.EVENT_TAP_RECOGNIZED, _onTapDetected);
			_dragHandleInteractor.removeEventListener(
				KDragCenterInteractor.EVENT_TAP_NOT_RECOGNIZED, _onTapDetected);
			_canvas.dispatchEvent(new Event(KCanvas.EVENT_INTERACTION_STOP));
			
			if(event.type == KDragCenterInteractor.EVENT_TAP_RECOGNIZED)
			{
				if(_appState.userOption.showConfirmWindow)
					_popupConfirmWindow();
				else
					_specialWaiting();
			}
			else
				_waiting();
		}
		
		private function _popupConfirmWindow():void
		{
			
			if(_confirmWindow == null)
			{
				_confirmWindow = new ConfirmDialog();
				_confirmWindow.userOption = _appState.userOption;
				_confirmWindow.addEventListener(ConfirmDialog.EVENT_NO_CLICKED, _normalMode);
				_confirmWindow.addEventListener(ConfirmDialog.EVENT_YES_CLICKED, _specialMode);
			}
			PopUpManager.addPopUp(_confirmWindow, _canvas, true);
			PopUpManager.centerPopUp(_confirmWindow);		
			
		}
		
		private function _normalMode(event:Event):void 
		{
			PopUpManager.removePopUp(_confirmWindow);
			_waiting();
		}
		private function _specialMode(event:Event):void
		{
			PopUpManager.removePopUp(_confirmWindow);
			_specialWaiting();
		}
		
		// special waiting state(to move center):
		
		private function _specialWaiting():void
		{
			_state = STATE_SPECIAL_WAITING;
			_activate(_moveCenterInteractor);
			_canvas.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown_specialMode);
			if(KAppState.IS_AIR)
				_canvas.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, _onMouseDown_specialMode);
		}
		
		private function _endSpecialWaiting():void
		{
			if(KAppState.IS_AIR)
				_canvas.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN, _onMouseDown_specialMode);
			_canvas.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown_specialMode);
		}
		
		private function _onMouseDown_specialMode(event:MouseEvent):void
		{
			// If the mouse cursor is not in drawing region, do not perform special mode
			var y1:Number = _canvas.drawingRegion.y;
			var y2:Number = y1 + _canvas.drawingRegion.height;
			if (_canvas.mouseY < y1 || y2 < _canvas.mouseY)
				return;
			
			if(_state != STATE_SPECIAL_WAITING)
				throw new Error("KInteractorManager.onMouseDown_specialMode() called while in "
					+_state+" state!");
			
			var sbRoot:DisplayObject = _canvas.systemManager.getSandboxRoot();
			// MouseUp event listener
			if(event.type == MouseEvent.MOUSE_DOWN)
				sbRoot.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp_specialMode, true);
			else if(event.type == MouseEvent.RIGHT_MOUSE_DOWN)
			{
				if(!_appState.userOption.rightMouseButtonEnabled)
					return;
				sbRoot.addEventListener(MouseEvent.RIGHT_MOUSE_UP, _onMouseUp_specialMode, true);
			}
			// MouseMove event listener
			sbRoot.addEventListener(MouseEvent.MOUSE_MOVE, _updateInteraction, true);
			
			// add the mouse shield so we can drag over untrusted applications.
			_canvas.systemManager.deployMouseShields(true);
			
			// state transition
			_endSpecialWaiting();
			_state = STATE_NORMAL_INTERACTING;
			_canvas.dispatchEvent(new Event(KCanvas.EVENT_INTERACTION_START));
			
			_beginInteraction(event);
		}
		
		private function _onMouseUp_specialMode(event:MouseEvent):void
		{
			var sbRoot:DisplayObject = _canvas.systemManager.getSandboxRoot();
			sbRoot.removeEventListener(event.type, _onMouseUp_specialMode, true);
			sbRoot.removeEventListener(MouseEvent.MOUSE_MOVE, _updateInteraction, true);
			_canvas.systemManager.deployMouseShields(false);
			
			// state transition
			
			_canvas.dispatchEvent(new Event(KCanvas.EVENT_INTERACTION_STOP));
			_endInteraction(event);
			_waiting();
		}
		
		// normal waiting state:
		
		private function _waiting():void
		{	
			_state = STATE_NORMAL_WAITING; 
			
			if(!_ctrlDown && !_altDown && !_pageUpHolding && !_pageDownHolding)
			{
				if (_eraserMode)
					_activate(_eraseInteractor);
				else
					_activate(_drawInteractor);
			}
			else
				_activate(_selectInteractor);
			
			_widget.addEventListener(KWidgetEvent.UP_CENTER, _changeInteractor);
			_widget.addEventListener(KWidgetEvent.UP_ROTATE, _changeInteractor);
			_widget.addEventListener(KWidgetEvent.UP_SCALE, _changeInteractor);
			_widget.addEventListener(KWidgetEvent.UP_TRANSLATE, _changeInteractor);
			
			_resetTransitionType();
			
			_addWaitingTransition();
			_canvas.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown_onCanvas,false,0,true);
			_widget.addEventListener(KWidgetEvent.DOWN_CENTER, _onMouseDown_onWidget);
			_widget.addEventListener(KWidgetEvent.DOWN_ROTATE, _onMouseDown_onWidget);
			_widget.addEventListener(KWidgetEvent.DOWN_SCALE, _onMouseDown_onWidget);
			_widget.addEventListener(KWidgetEvent.DOWN_TRANSLATE, _onMouseDown_onWidget);
			
			if(KAppState.IS_AIR)
			{
				_canvas.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, _onMouseDown_onCanvas);
				_widget.addEventListener(KWidgetEvent.RIGHT_DOWN_CENTER, _onMouseDown_onWidget);
				_widget.addEventListener(KWidgetEvent.RIGHT_DOWN_ROTATE, _onMouseDown_onWidget);
				_widget.addEventListener(KWidgetEvent.RIGHT_DOWN_SCALE, _onMouseDown_onWidget);
				_widget.addEventListener(KWidgetEvent.RIGHT_DOWN_TRANSLATE, _onMouseDown_onWidget);
			}
			
			//This thing will break the unit test
			//removing it doesn't really break the app.
			//if(_canvas.stage != null)
			//_canvas.stage.focus = _canvas;
		}
		
		private function _endWaiting():void
		{
			// sub waiting states transition			
			_removeWaitingTransition();
			
			if(KAppState.IS_AIR)
			{
				_canvas.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN, _onMouseDown_onCanvas);
				_widget.removeEventListener(KWidgetEvent.RIGHT_DOWN_CENTER, _onMouseDown_onWidget);
				_widget.removeEventListener(KWidgetEvent.RIGHT_DOWN_ROTATE, _onMouseDown_onWidget);
				_widget.removeEventListener(KWidgetEvent.RIGHT_DOWN_SCALE, _onMouseDown_onWidget);
				_widget.removeEventListener(KWidgetEvent.RIGHT_DOWN_TRANSLATE, _onMouseDown_onWidget);
				
			}
			_canvas.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown_onCanvas);
			_widget.removeEventListener(KWidgetEvent.DOWN_CENTER, _onMouseDown_onWidget);
			_widget.removeEventListener(KWidgetEvent.DOWN_ROTATE, _onMouseDown_onWidget);
			_widget.removeEventListener(KWidgetEvent.DOWN_SCALE, _onMouseDown_onWidget);
			_widget.removeEventListener(KWidgetEvent.DOWN_TRANSLATE, _onMouseDown_onWidget);
			
			_widget.removeEventListener(KWidgetEvent.UP_CENTER, _changeInteractor);
			_widget.removeEventListener(KWidgetEvent.UP_ROTATE, _changeInteractor);
			_widget.removeEventListener(KWidgetEvent.UP_SCALE, _changeInteractor);
			_widget.removeEventListener(KWidgetEvent.UP_TRANSLATE, _changeInteractor);
		}
		
		private function _changeInteractor(event:KWidgetEvent):void
		{
			switch(event.type)
			{
				case KWidgetEvent.DOWN_CENTER:
				case KWidgetEvent.RIGHT_DOWN_CENTER:
				case KWidgetEvent.HOVER_CENTER:
				case KWidgetEvent.UP_CENTER:
					_activate(_dragHandleInteractor);
					break;
				case KWidgetEvent.DOWN_TRANSLATE:
				case KWidgetEvent.RIGHT_DOWN_TRANSLATE:
				case KWidgetEvent.HOVER_TRANSLATE:
				case KWidgetEvent.UP_TRANSLATE:
					_activate(_translateInteractor);
					break;
				case KWidgetEvent.DOWN_ROTATE:
				case KWidgetEvent.RIGHT_DOWN_ROTATE:
				case KWidgetEvent.HOVER_ROTATE:
				case KWidgetEvent.UP_ROTATE:
					_activate(_rotateInteractor);
					break;
				case KWidgetEvent.DOWN_SCALE:
				case KWidgetEvent.RIGHT_DOWN_SCALE:
				case KWidgetEvent.HOVER_SCALE:
				case KWidgetEvent.UP_SCALE:
					_activate(_scaleInteractor);
					break;
				case KWidgetEvent.OUT:
					if(_ctrlDown || _altDown || _pageUpHolding || _pageDownHolding)
						_activate(_selectInteractor);
					else
						_activate(_drawInteractor);
					break;
				default:
					throw new Error("KInteractorManager.changeInteractor called on unhandled event type: "
						+event.type);
			}
		}
		
		private function _onMouseDown_onWidget(event:KWidgetEvent):void
		{
			_changeInteractor(event);
			if(event.type == KWidgetEvent.RIGHT_DOWN_CENTER ||
				(event.type == KWidgetEvent.DOWN_CENTER && 
					(_ctrlDown || _altDown || _pageUpHolding || _pageDownHolding)))
				_activate(_translateInteractor);
			// MouseUp or RightMouseUp event listener
			var sbRoot:DisplayObject = _canvas.systemManager.getSandboxRoot();
			if(event.type == KWidgetEvent.DOWN_CENTER || event.type == KWidgetEvent.DOWN_ROTATE ||
				event.type == KWidgetEvent.DOWN_SCALE || event.type == KWidgetEvent.DOWN_TRANSLATE)
				sbRoot.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp_downOnWidget, true);
			else // right mouse event
			{
				if(!_appState.userOption.rightMouseButtonEnabled)
					return;
				sbRoot.addEventListener(MouseEvent.RIGHT_MOUSE_UP, _onMouseUp_downOnWidget, true);
				
				if(KAppState.KEYBOARD_REALTIME.indexOf(KAppState.RIGHT_BUTTON_SAME_AS) >= 0)
					_appState.transitionType = KAppState.TRANSITION_REALTIME;
				else if(KAppState.KEYBOARD_INSTANT.indexOf(KAppState.RIGHT_BUTTON_SAME_AS) >= 0)
					_appState.transitionType = KAppState.TRANSITION_INSTANT;
				else if(KAppState.KEYBOARD_INTERPOLATED.indexOf(KAppState.RIGHT_BUTTON_SAME_AS) >= 0)
					_appState.transitionType = KAppState.TRANSITION_INTERPOLATED;
				else
					throw new Error(
						"Invalid right mouse button effect configuration: right mouse button same as "
						+KAppState.RIGHT_BUTTON_SAME_AS);
			}
			
			// MouseMove event listener
			sbRoot.addEventListener(MouseEvent.MOUSE_MOVE, _updateInteraction, true);
			
			// add the mouse shield so we can drag over untrusted applications.
			_canvas.systemManager.deployMouseShields(true);
			
			// state transition
			_endWaiting();
			switch(_currentInteractor)
			{
				case _translateInteractor:
				case _rotateInteractor:
				case _scaleInteractor:
					_state = STATE_NORMAL_INTERACTING;
					break;
				case _dragHandleInteractor:
					_state = STATE_DRAGING_CENTER;
					break;
			}
			
			if(!_appState.isUserTest && _appState.transitionType == KAppState.TRANSITION_REALTIME
				&& _state == STATE_NORMAL_INTERACTING)
				_appState.startRecording();
			else
				_canvas.dispatchEvent(new Event(KCanvas.EVENT_INTERACTION_START));
			
			_beginInteraction(event);
		}
		
		private function _onMouseUp_downOnWidget(event:MouseEvent):void
		{
			var sbRoot:DisplayObject = _canvas.systemManager.getSandboxRoot();
			sbRoot.removeEventListener(event.type, _onMouseUp_downOnWidget, true);
			sbRoot.removeEventListener(MouseEvent.MOUSE_MOVE, _updateInteraction, true);
			
			_canvas.systemManager.deployMouseShields(false);
			
			// state transition
			if(_state == STATE_DRAGING_CENTER)
			{
				_dragHandleInteractor.addEventListener(
					KDragCenterInteractor.EVENT_TAP_RECOGNIZED, _onTapDetected);
				_dragHandleInteractor.addEventListener(
					KDragCenterInteractor.EVENT_TAP_NOT_RECOGNIZED, _onTapDetected);
				_endInteraction(event);
			}
			else
			{
				if(_appState.isAnimating)
					_appState.stopRecording();
				else
					_canvas.dispatchEvent(new Event(KCanvas.EVENT_INTERACTION_STOP));
				
				_endInteraction(event);
				_waiting();
			}
		}
	/*	
		private function onCursorPath(event:Event):void
		{ 		
			_executor.execute(HIGHLITED_CURSOR_PATH_CLICKED, 
				_appState.selection.objects.getDefaultCenter(_appState.time));		
		}
	*/	
		private function _onMouseDown_onCanvas(event:MouseEvent):void
		{			
			if(event.currentTarget != _canvas)
				return;
			//	trace("before sb root");
			// self-transition within normal wating state
			var sbRoot:DisplayObject = _canvas.systemManager.getSandboxRoot();
			//	trace(sbRoot);
			// MouseUp or RightMouseUp event listener
			var interactor:IInteractor;
			
			if(event.type == MouseEvent.MOUSE_DOWN)
			{
	//			_pathInteractor.keyframe = _pathDetector.detectPath(_canvas,_appState.time,true);				
				if(_shift && _pathInteractor.keyframe != null)
				{
					sbRoot.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp_downOnCanvas, true);
					_pathInteractor.object = _pathDetector.lastPathView.object;
					interactor = _pathInteractor;
				}
				else if(_ctrlDown || _altDown || _pageUpHolding || _pageDownHolding)
				{
					sbRoot.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp_downOnCanvas, true);
					interactor = _selectInteractor;
				}
				else
				{
					if(_canvas.drawingRegion != null)
					{
						var myRect:Rectangle = new Rectangle(
							_canvas.drawingRegion.x, _canvas.drawingRegion.y,
							_canvas.drawingRegion.width, _canvas.drawingRegion.height);
						
						if(!myRect.containsPoint(new Point(event.stageX, event.stageY)))
							return;
					}
					
					sbRoot.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp_downOnCanvas, true);
					if (_eraserMode)
						interactor = _eraseInteractor;
					else
						interactor = _drawInteractor;
				}
			}
			else // right mouse event
			{
				if(!_appState.userOption.rightMouseButtonEnabled)
					return;
				sbRoot.addEventListener(MouseEvent.RIGHT_MOUSE_UP, _onMouseUp_downOnCanvas, true);
				interactor = _selectInteractor;
			}
			
			if(interactor == _selectInteractor && _selectInteractor == _loopSelectInteractor)
				interactor = _gestureRecognizer;
			if(interactor == _drawInteractor)
			{							
				if(_executor.hasPopup)
				{
					_specialInteractor.mode = KSpecialInteractor.MODE_HIDE_POPUP;
					interactor = _specialInteractor;
				}
				else if(_appState.selection != null && _appState.selection.objects.length() > 0)
				{	
			//		if(_onCursorPathMenu(event)=="SELECT")
					if(true)
						_specialInteractor.mode = KSpecialInteractor.MODE_DESELECT;
					else
						_specialInteractor.mode = KSpecialInteractor.MODE_HIDE_POPUP;				
						
				//	_specialInteractor.mode = KSpecialInteractor.MODE_HIDE_POPUP;				
	//				var key:ISpatialKeyframe = _pathDetector.detectPath(_canvas,_appState.time,true);
/*
					if (key != null && key is KCenteredKeyframe)
					{
						var obj:KObject = _pathDetector.lastPathView.object;
						var matrix:Matrix = obj.getFullMatrix(key.startTime);
						_centerWidget(matrix.transformPoint((key as KCenteredKeyframe).center));
					}
					else
						_specialInteractor.mode = KSpecialInteractor.MODE_DESELECT;
*/					
					interactor = _specialInteractor;
				}
			}
			
			_executor.hasPopup = false;
			_activate(interactor);
			
			// MouseMove event listener
			sbRoot.addEventListener(MouseEvent.MOUSE_MOVE, _updateInteraction, true);
			
			// add the mouse shield so we can drag over untrusted applications.
			_canvas.systemManager.deployMouseShields(true);
			
			// state transition
			_endWaiting();
			switch(_currentInteractor)
			{
				case _drawInteractor:
				case _selectInteractor:
					_state = STATE_NORMAL_INTERACTING;
					break;
				case _gestureRecognizer:
					_state = STATE_SELECTING_AND_RECOGNIZING;
					break;
			}
			
			// -- Show motion path if currentInteractor is  eraseInteractor or pathInteractor -- //
			if (_currentInteractor != _eraseInteractor && _currentInteractor != _pathInteractor)
				_canvas.dispatchEvent(new Event(KCanvas.EVENT_INTERACTION_START));
			
			_beginInteraction(event);
		}
		
		// *** Reposition the widget with center on key.center when click on cursor path *** //  
		private function _centerWidget(center:Point):void
		{
			_moveCenterInteractor.activate();
			_moveCenterInteractor.begin(_widget.center);
			_moveCenterInteractor.update(center);
			_moveCenterInteractor.end(center);
			_moveCenterInteractor.deactivate();
		}

		private function _onMouseUp_downOnCanvas(event:MouseEvent):void
		{			
			var sbRoot:DisplayObject = _canvas.systemManager.getSandboxRoot();
			sbRoot.removeEventListener(event.type, _onMouseUp_downOnCanvas, true);
			sbRoot.removeEventListener(MouseEvent.MOUSE_MOVE, _updateInteraction, true);
			
			_canvas.systemManager.deployMouseShields(false);
			
			//	_onCursorPathMenu(event);
			
			// state transition
			if(_appState.isAnimating)
				_appState.stopRecording();
			else
				_canvas.dispatchEvent(new Event(KCanvas.EVENT_INTERACTION_STOP));
			
			_endInteraction(event);
			_waiting();
		
			_appState.ungroupEnabled = KUngroupUtil.ungroupEnable(_facade.root,_appState);
			_appState.fireGroupingEnabledChangedEvent();
			_appState.fireEditEnabledChangedEvent();
		}
		
		private function _addWaitingTransition():void
		{
			_widget.addEventListener(KWidgetEvent.HOVER_TRANSLATE, _changeInteractor);
			_widget.addEventListener(KWidgetEvent.HOVER_ROTATE, _changeInteractor);
			_widget.addEventListener(KWidgetEvent.HOVER_SCALE, _changeInteractor);
			_widget.addEventListener(KWidgetEvent.HOVER_CENTER, _changeInteractor);
			_widget.addEventListener(KWidgetEvent.OUT, _changeInteractor);
			_canvas.systemManager.stage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyChanged);
			_canvas.systemManager.stage.addEventListener(KeyboardEvent.KEY_UP, _onKeyChanged);
		}
		
		private function _removeWaitingTransition():void
		{
			_widget.removeEventListener(KWidgetEvent.HOVER_TRANSLATE, _changeInteractor);
			_widget.removeEventListener(KWidgetEvent.HOVER_ROTATE, _changeInteractor);
			_widget.removeEventListener(KWidgetEvent.HOVER_SCALE, _changeInteractor);
			_widget.removeEventListener(KWidgetEvent.HOVER_CENTER, _changeInteractor);
			_widget.removeEventListener(KWidgetEvent.OUT, _changeInteractor);
			_canvas.systemManager.stage.removeEventListener(KeyboardEvent.KEY_DOWN, _onKeyChanged);
			_canvas.systemManager.stage.removeEventListener(KeyboardEvent.KEY_UP, _onKeyChanged);
		}
		
		private function _onKeyChanged(event:KeyboardEvent):void
		{
			// 1. change transition type
			_resetTransitionType();
			// 2. change interactor
			if(_currentInteractor == _drawInteractor || _currentInteractor == _selectInteractor)
			{
				if(!_ctrlDown && !_altDown && !_pageUpHolding && !_pageDownHolding)
					_activate(_drawInteractor);
				else
					_activate(_selectInteractor);
			}
		}
		
		private function _resetTransitionType():void
		{
			if(_ctrlDown)
			{
				if(KAppState.KEYBOARD_REALTIME.indexOf(Keyboard.CONTROL) >= 0)
					_appState.transitionType = KAppState.TRANSITION_REALTIME;
				else if(KAppState.KEYBOARD_INSTANT.indexOf(Keyboard.CONTROL) >= 0)
					_appState.transitionType = KAppState.TRANSITION_INSTANT;
				else if(KAppState.KEYBOARD_INTERPOLATED.indexOf(Keyboard.CONTROL) >= 0)
					_appState.transitionType = KAppState.TRANSITION_INTERPOLATED;
			}
			else if(_pageUpHolding)
			{
				if(KAppState.KEYBOARD_REALTIME.indexOf(Keyboard.PAGE_UP) >= 0)
					_appState.transitionType = KAppState.TRANSITION_REALTIME;
				else if(KAppState.KEYBOARD_INSTANT.indexOf(Keyboard.PAGE_UP) >= 0)
					_appState.transitionType = KAppState.TRANSITION_INSTANT;
				else if(KAppState.KEYBOARD_INTERPOLATED.indexOf(Keyboard.PAGE_UP) >= 0)
					_appState.transitionType = KAppState.TRANSITION_INTERPOLATED;
			}
			else if(_altDown)
			{
				if(KAppState.KEYBOARD_REALTIME.indexOf(Keyboard.ALTERNATE) >= 0)
					_appState.transitionType = KAppState.TRANSITION_REALTIME;
				else if(KAppState.KEYBOARD_INSTANT.indexOf(Keyboard.ALTERNATE) >= 0)
					_appState.transitionType = KAppState.TRANSITION_INSTANT;
				else if(KAppState.KEYBOARD_INTERPOLATED.indexOf(Keyboard.ALTERNATE) >= 0)
					_appState.transitionType = KAppState.TRANSITION_INTERPOLATED;
			}
			else if(_pageDownHolding)
			{
				if(KAppState.KEYBOARD_REALTIME.indexOf(Keyboard.PAGE_DOWN) >= 0)
					_appState.transitionType = KAppState.TRANSITION_REALTIME;
				else if(KAppState.KEYBOARD_INSTANT.indexOf(Keyboard.PAGE_DOWN) >= 0)
					_appState.transitionType = KAppState.TRANSITION_INSTANT;
				else if(KAppState.KEYBOARD_INTERPOLATED.indexOf(Keyboard.PAGE_DOWN) >= 0)
					_appState.transitionType = KAppState.TRANSITION_INTERPOLATED;
			}
			else
			{
				if(_appState.creationMode == KAppState.CREATION_DEMONSTRATE)
					_appState.transitionType = KAppState.TRANSITION_INSTANT;
				else
					_appState.transitionType = KAppState.TRANSITION_DEFAULT;
			}
			
			// --- Overide Ctrl/PageUp and Alt/PageDown when Interpolate and Demonstrate  --- //
			// --- option in the Animation Creation Mode of OptionWindow is not selected. --- //
			if ((_ctrlDown || _pageUpHolding) && 
				_appState.creationMode == KAppState.CREATION_INTERPOLATE)
				_appState.transitionType = KAppState.TRANSITION_INTERPOLATED;
			else if ((_altDown || _pageDownHolding) && 
				_appState.creationMode == KAppState.CREATION_DEMONSTRATE)
				_appState.transitionType = KAppState.TRANSITION_REALTIME;
		}
		
		private function _activate(interactor:IInteractor):void
		{
			if(_currentInteractor == interactor)
				return;
			
			if(_currentInteractor != null)
				_currentInteractor.deactivate();
			_currentInteractor = interactor;
			_currentInteractor.activate();
			//trace("---->"+_currentInteractor);
		}
		
		private function _beginInteraction(event:MouseEvent):void
		{
			if(KLogger.enabled)
				_log = _currentInteractor.enableLog();
			
			var p:Point = getEventCoordinate(event,_canvas);
			_currentInteractor.begin(p);
		}
		
		private function _updateInteraction(event:MouseEvent):void
		{
			var p:Point = getEventCoordinate(event,_canvas);
			_currentInteractor.update(p);
		}
		
		private function _endInteraction(event:MouseEvent):void
		{
			var p:Point = getEventCoordinate(event,_canvas);
			updateTargetTrack(event.stageX, event.stageY);
			_currentInteractor.end(p);
			if(_log != null)
			{
				KLogger.logObject(_log);
				_log = null;
			}
		}
		
		private function updateTargetTrack(x:Number, y:Number):void
		{
			if(boxContains(_appState.overViewTrackBox,x,y))
				_appState.targetTrackBox = KTransformMgr.ALL_REF;
			else if(boxContains(_appState.translateTrackBox,x,y))
				_appState.targetTrackBox = KTransformMgr.TRANSLATION_REF;
			else if(boxContains(_appState.rotateTrackBox,x,y))
				_appState.targetTrackBox = KTransformMgr.ROTATION_REF;
			else if(boxContains(_appState.scaleTrackBox,x,y))
				_appState.targetTrackBox = KTransformMgr.SCALE_REF;
			else
				_appState.targetTrackBox = KTransformMgr.NO_REF;
		}
		
		private function boxContains(trackBox:Rectangle, x:Number, y:Number):Boolean
		{
			if(trackBox.contains(x,y))
			{
				var approximateTime:Number = (x-trackBox.x+10)/trackBox.width*_appState.maxTime;
				_appState.trackTapTime =  KMathUtil.nearestFrameBoundary(approximateTime);
				return true;
			}
			else
				return false;
		}
	}
}