/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package sg.edu.smu.ksketch.components
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import mx.core.UIComponent;
	
	import sg.edu.smu.ksketch.event.KDebugHighlightChanged;
	import sg.edu.smu.ksketch.event.KModelEvent;
	import sg.edu.smu.ksketch.event.KObjectEvent;
	import sg.edu.smu.ksketch.event.KSelectionChangedEvent;
	import sg.edu.smu.ksketch.event.KTimeChangedEvent;
	import sg.edu.smu.ksketch.interactor.IInteractorManager;
	import sg.edu.smu.ksketch.interactor.KInteractorManager;
	import sg.edu.smu.ksketch.logger.KLogger;
	import sg.edu.smu.ksketch.model.IActivityKeyFrame;
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.model.KImage;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.model.KStroke;
	import sg.edu.smu.ksketch.operation.KModelFacade;
	import sg.edu.smu.ksketch.utilities.IIterator;
	import sg.edu.smu.ksketch.utilities.KAppState;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;
	
	import spark.components.BorderContainer;
	
	public class KCanvas extends BorderContainer
	{
		public static const EVENT_INTERACTION_START:String = "EVENT_INTERACTION_START";
		public static const EVENT_INTERACTION_STOP:String = "EVENT_INTERACTION_STOP";
		
		protected var _facade:KModelFacade;
		protected var _appState:KAppState;
		
		protected var _contentContainer:UIComponent;
		protected var _visibleGestureLayer:UIComponent;
		protected var _drawingRegion:UIComponent;
		protected var _alphaTracker:UIComponent;
		protected var _objectRoot:IObjectView;
		protected var _viewsTable:Dictionary;
		
		protected var _mouseOffsetX:Number;
		protected var _mouseOffsetY:Number;
		protected var _contentScale:Number;
		
		protected var _clockState:ICanvasClockState;
		
		protected var _playingState:KCanvasPlayingState;
		protected var _stoppedState:KCanvasStoppedState;
		protected var _interactingState:KCanvasInteractingState;
		protected var _recordingState:KCanvasRecordingState;
		
		protected var _widget:IWidget;
		protected var _interactorManager:IInteractorManager;
		protected var _initiated:Boolean;
				
		public function KCanvas()
		{
			super();
		}
		
		public function initKCanvas(facade:KModelFacade, appState:KAppState, 
									widget:IWidget, interactorManager:IInteractorManager):void
		{
			_facade = facade;
			_appState = appState;
			_viewsTable = new Dictionary();
			
			_contentContainer = new UIComponent();
			addElement(contentContainer);
			
			_objectRoot = _createObjectView(_facade.root);
			_contentContainer.addChild(_objectRoot as Sprite);
			
			_initKAppStateEventsHandler();
			
			_widget = widget;
			_initWidget();
			_widget.visible = false;

			_interactorManager = interactorManager;
			_interactorManager.activateOn(_facade, _appState, this, _widget);
			
			_initStatesMachine(_widget);
			_startStateMachine();
			
			//Extra stuffs that should be refactored and placed somewhere else
			_visibleGestureLayer = new UIComponent;
			_alphaTracker = new UIComponent();
			addElement(_visibleGestureLayer);
			addElement(_alphaTracker);
			
			_mouseOffsetX = 0;
			_mouseOffsetY = 0;
			_contentScale = 1;
			
		}
		
		//Interactor Related Functions
		public function get interactorManager():IInteractorManager
		{
			return _interactorManager;
		}
		
		protected function _initWidget():void
		{
			if(_widget is DisplayObject)
			{
				var widgetContainer:MovieClip = new MovieClip();
				_contentContainer.addChild(widgetContainer);
				widgetContainer.addChild((_widget as DisplayObject));
			}
			else
				throw new Error("Widget "+_widget+" is not a DisplayObject!");
		}
		
		public function get widget():IWidget
		{
			return _interactorManager.widget;
		}
						
		public function resetCanvas():void
		{
			_interactorManager.reset();
			_appState.selection = null;
			_appState.clearStacks();
			_startStateMachine();
			_appState.time = 0;
			_appState.maxTime = KAppState.DEFAULT_MAX_TIME;
			_facade.root.addEventListener(KObjectEvent.EVENT_OBJECT_ADDED, _objectHandleObjectParented);
			_facade.root.addEventListener(KObjectEvent.EVENT_OBJECT_REMOVED, _objectHandleObjectDiscarded);
			_facade.newFile();

			_contentContainer.removeChild(_objectRoot as Sprite);
			_viewsTable = new Dictionary();
			_objectRoot = _createObjectView(_facade.root);
			_contentContainer.addChild(_objectRoot as Sprite);
			_initStatesMachine(_widget);
			_startStateMachine();
		}
		
		/**
		 * Resets the canvas to its original state and
		 * adds in the contents from the given group.
		 * Expects an override for this function
		 * Make sure the root is at newContents.getObjectAt(0);
		 */
		public function switchContents(newContents:KModelObjectList):KModelObjectList
		{
			//Resetting interactors and data
			_interactorManager.reset();
			_appState.selection = null;
			_appState.time = 0;
			_appState.maxTime = KAppState.DEFAULT_MAX_TIME;
			
			//Clearing the current view/scene
			_viewsTable = new Dictionary();
			
			_contentContainer.removeChild(_objectRoot as Sprite);
			_objectRoot = _createObjectView(newContents.getObjectAt(0));
			_contentContainer.addChild(_objectRoot as Sprite);
			_contentContainer.swapChildren(_objectRoot as Sprite, (_widget as KWidget).parent);
			
			//Changing the model
			return _facade.switchContent(newContents);
		}
		
		public function loadFile(xml:XML):void
		{
			resetCanvas();
			_facade.loadFile(xml);
		}
		
		public function get contentContainer():UIComponent
		{
			return _contentContainer;
		}

		public function unscaleWidget(xScale:Number, yScale:Number):void
		{
			(_widget as KWidget).scaleX = 1/xScale;
			(_widget as KWidget).scaleY = 1/yScale;
		}
		
		public function get objectRoot():IObjectView
		{
			return _objectRoot;
		}
		
		public function set drawingRegion(component:UIComponent):void
		{
			_drawingRegion = component;
		}
		
		public function get drawingRegion():UIComponent
		{
			if(!_drawingRegion)
				_drawingRegion = new UIComponent();
			return _drawingRegion;
		}
		
		public function get gestureLayer():UIComponent
		{
			return _visibleGestureLayer;
		}
		
		public function set mouseOffsetX(offset:Number):void
		{
			_mouseOffsetX = offset;
			gestureLayer.x = _mouseOffsetX;
		}
		
		public function get mouseOffsetX():Number
		{
			return _mouseOffsetX;
		}
		
		public function set mouseOffsetY(offset:Number):void
		{
			_mouseOffsetY = offset;	
			gestureLayer.y = _mouseOffsetY;
		}
		
		public function get mouseOffsetY():Number
		{
			return _mouseOffsetY;
		}
		
		public function set contentScale(myScale:Number):void
		{
			_contentScale = myScale;
			gestureLayer.scaleX = _contentScale;
			gestureLayer.scaleY = _contentScale;
		}
		
		public function get contentScale():Number
		{
			return _contentScale;
		}
		
		//State machine functions
		public function set clockState(value:ICanvasClockState):void
		{
			if(_clockState == value)
				return;
			_clockState.exit();
			_clockState = value;
			_clockState.entry();
		}
		
		//================================
		//Application states
		//Another set of tightly coupled code!
		//Dont touch anything in this region yet until richard gives us the go
		//===============================
		protected function _startStateMachine():void
		{
			_stoppedState.init();
			_clockState = _stoppedState;
			_clockState.entry();
		}
		
		protected function _initStatesMachine(widget:IWidget):void
		{
			_playingState = new KCanvasPlayingState(_appState, widget);
			_stoppedState = new KCanvasStoppedState(_appState, _viewsTable, _facade, widget);
			_interactingState = new KCanvasInteractingState(_appState, widget);
			_recordingState = new KCanvasRecordingState(this, _appState, widget);
			
			_appState.addEventListener(KAppState.EVENT_ANIMATION_START, function(event:Event):void{clockState = _playingState});
			_appState.addEventListener(KAppState.EVENT_ANIMATION_STOP, function(event:Event):void{clockState = _stoppedState});
			
			_appState.addEventListener(KAppState.EVENT_RECORDING_START, function(event:Event):void{clockState = _recordingState});
			_appState.addEventListener(KAppState.EVENT_RECORDING_STOP, function(event:Event):void{clockState = _stoppedState});
			
			this.addEventListener(EVENT_INTERACTION_START, function(event:Event):void{clockState = _interactingState});
			this.addEventListener(EVENT_INTERACTION_STOP, function(event:Event):void{clockState = _stoppedState});
		}
		
		protected function _initKAppStateEventsHandler():void
		{
			_appState.addEventListener(KSelectionChangedEvent.EVENT_SELECTION_CHANGING, _selectionChangedEventHandler);
			_appState.addEventListener(KSelectionChangedEvent.EVENT_SELECTION_CHANGED, _selectionChangedEventHandler);
			_appState.addEventListener(KDebugHighlightChanged.EVENT_DEBUG_CHANGED, _debugSelectionChangedEventHandler);
			_appState.addEventListener(KTimeChangedEvent.TIME_CHANGED, _updateViews);
		}
		//====================================================

		
		/**
		 * View creation function. Adds an object to the viewtable.
		 * It will stay in the view table forever.
		 */
		protected function _createObjectView(object:KObject):IObjectView
		{
			if(_viewsTable[object]!=null)
				throw new Error("object view already exists!");
			
			var view:IObjectView;
			if(object is KStroke)
				view = new KStrokeView(_appState, object as KStroke);
			else if(object is KGroup)
			{
				trace("group",object.id,"is being added to the view");
				view = new KGroupView(_appState, object as KGroup);
				object.addEventListener(KObjectEvent.EVENT_OBJECT_ADDED, _objectHandleObjectParented);
				object.addEventListener(KObjectEvent.EVENT_OBJECT_REMOVED, _objectHandleObjectDiscarded);
			}
			else if(object is KImage)
				view = new KImageView(_appState, object as KImage);
			else
				throw new Error("no view supported for this kobject type!");
			_viewsTable[object] = view;
			return view;
		}
		
		protected function _objectHandleObjectParented(event:KObjectEvent):void
		{
			var parent:KGroup = event.parent;
			var parentView:IObjectView = _viewsTable[parent];
			
			var newChild:KObject = event.object;
			var newChildView:IObjectView = _viewsTable[newChild];
			
			if(!newChildView)
				newChildView = _createObjectView(newChild);
			
			trace("group",parent.id,parentView,"is taking in", newChild.id, newChildView);
			newChildView.updateParent(parentView as KGroupView);
		}
		
		protected function _objectHandleObjectDiscarded(event:KObjectEvent):void
		{
			var objectView:IObjectView = _viewsTable[event.object];
			objectView.removeFromParent();
		}
		
		protected function _selectionChangedEventHandler(event:KSelectionChangedEvent):void
		{
			var i:IIterator;
			if(event.oldSelection != null)
				_selectOnObjectIterate(event.oldSelection.objects.iterator,event.oldSelection.selectedTime,false);
			if(event.newSelection != null)
				_selectOnObjectIterate(event.newSelection.objects.iterator,event.newSelection.selectedTime,true);
		}
		protected function _selectOnObjectIterate(i:IIterator,selectedTime:Number,selected:Boolean):void
		{
			while(i.hasNext())
				_selectOnObject(i.next(), selectedTime, selected);			
		}
		
		protected function _selectOnObject(object:KObject, time:Number, selected:Boolean):void
		{
			if(object is KGroup)
			{
				_setObjectSelect(object, selected);
				var i:IIterator = (object as KGroup).allChildrenIterator(time);
				while(i.hasNext())
					_setObjectSelect(i.next(), selected);
			}
			else
				_setObjectSelect(object, selected);			
		}
		
		protected function _setObjectSelect(object:KObject,selected:Boolean):void
		{
			var view:IObjectView = _viewsTable[object];
			if (view != null)
				view.selected = selected;			
		}
		
		protected function _debugSelectionChangedEventHandler(event:KDebugHighlightChanged):void
		{
			if(event.oldSelection != null)
				_toggleViewDebug(event.oldSelection.iterator,false);
			if(event.newSelection != null)
				_toggleViewDebug(event.newSelection.iterator,true);
		}
		
		protected function _toggleViewDebug(i:IIterator,bool:Boolean):void
		{
			var view:IObjectView;
			while(i.hasNext())
			{
				view = _viewsTable[i.next()];
				view.debug = bool;
			}			
		}
		
		protected function _updateViews(event:KTimeChangedEvent):void
		{
			_alphaTracker.graphics.clear();
			_alphaTracker.graphics.lineStyle(1, 0, 0.3);
			if(event.newTime != event.oldTime)
			{
				for(var obj:Object in _viewsTable)
					_updateObjectView(obj as KObject, event.oldTime, event.newTime);
			}
		}
		
		protected function _updateObjectView(object:KObject, fromKSKTime:Number, toKSKTime:Number):void
		{
			if(fromKSKTime == -1)
				fromKSKTime = 0;
			if(toKSKTime == -1)
				toKSKTime = 0;
			
			var view:IObjectView = _viewsTable[object];
			if(view == null)
				throw new Error("object has no view");
			
			var changedAlpha:Number = object.getVisibility(toKSKTime);
			view.updateVisibility(changedAlpha);

			var changedTransform:Matrix = object.getFullMatrix(toKSKTime);
			view.updateTransform(changedTransform);
			
		}
		
		//Alpha Functions
		protected function _objectAlphaEventHandler(event:KObjectEvent):void
		{
			var time:Number =  _appState.time;
			var obj:KObject = event.object;
			var view:IObjectView = _viewsTable[obj];
			if (view && obj.getVisibility(time) == 0 && 
				obj.createdTime < time && !_isErased(obj,time))
				_drawTracker((view as KObjectView).getRect(this));
		}
		
		protected function _drawTracker(rect:Rectangle):void
		{
			var centerX:Number = (2*rect.x + rect.width)/2;
			var centerY:Number = (2*rect.y + rect.height)/2;
			_alphaTracker.graphics.drawRect(rect.x,rect.y,rect.width,rect.height);
			_alphaTracker.graphics.moveTo(centerX - 5,centerY);
			_alphaTracker.graphics.lineTo(centerX + 5,centerY);
			_alphaTracker.graphics.moveTo(centerX,centerY - 5);
			_alphaTracker.graphics.lineTo(centerX,centerY + 5);
		}
		
		protected function _isErased(object:KObject,time:Number):Boolean
		{
			var key:IActivityKeyFrame = object.getActivityKeyBeforeAt(time) as IActivityKeyFrame;
			while (key != null)
			{
				if (key.alpha == KObjectView.GHOST_ALPHA)
					return true;
				key = key.previous as IActivityKeyFrame;
			}
			return false;
		}
	}
}