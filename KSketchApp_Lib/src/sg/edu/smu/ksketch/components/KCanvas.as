/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.components
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import mx.core.UIComponent;
	
	import sg.edu.smu.ksketch.event.KDebugHighlightChanged;
	import sg.edu.smu.ksketch.event.KGroupUngroupEvent;
	import sg.edu.smu.ksketch.event.KObjectEvent;
	import sg.edu.smu.ksketch.event.KSelectionChangedEvent;
	import sg.edu.smu.ksketch.event.KTimeChangedEvent;
	import sg.edu.smu.ksketch.interactor.IInteractorManager;
	import sg.edu.smu.ksketch.interactor.KInteractorManager;
	import sg.edu.smu.ksketch.model.IActivityKeyFrame;
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.model.KImage;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.model.KStroke;
	import sg.edu.smu.ksketch.operation.KModelFacade;
	import sg.edu.smu.ksketch.utilities.IIterator;
	import sg.edu.smu.ksketch.utilities.KAppState;
	
	import spark.components.BorderContainer;
	
	public class KCanvas extends BorderContainer
	{
		public static const EVENT_INTERACTION_START:String = "EVENT_INTERACTION_START";
		public static const EVENT_INTERACTION_STOP:String = "EVENT_INTERACTION_STOP";
		
		private var _facade:KModelFacade;
		private var _appState:KAppState;
		
		private var _contentContainer:UIComponent;
		private var _visibleGestureLayer:UIComponent;
		private var _drawingRegion:UIComponent;
		private var _alphaTracker:UIComponent;
		private var _objectRoot:MovieClip;
		private var _viewsTable:Dictionary;
		
		private var _mouseOffsetX:Number;
		private var _mouseOffsetY:Number;
		private var _contentScale:Number;
		
		private var _clockState:ICanvasClockState;
		
		private var _playingState:KCanvasPlayingState;
		private var _stoppedState:KCanvasStoppedState;
		private var _interactingState:KCanvasInteractingState;
		private var _recordingState:KCanvasRecordingState;
		
		private var _widget:IWidget;
		private var _interactorManager:IInteractorManager;
		private var _initiated:Boolean;
				
		public function KCanvas()
		{
			super();
			_alphaTracker = new UIComponent();
		}
		
		public function initKCanvas(facade:KModelFacade, appState:KAppState, 
									widget:IWidget = null, interactorManagerRef:Class = null):void
		{
			_facade = facade;
			_appState = appState;
			
			_mouseOffsetX = 0;
			_mouseOffsetY = 0;
			_contentScale = 1;
			
			_viewsTable = new Dictionary();
			_contentContainer = new UIComponent();
			_visibleGestureLayer = new UIComponent;
			addElement(contentContainer);
			addElement(_visibleGestureLayer);
			addElement(_alphaTracker);
			
			_objectRoot = new MovieClip();
			_contentContainer.addChild(_objectRoot);
			
			_initModelEventsHandler();
			_initKAppStateEventsHandler();
			
			_widget = widget;
			if(_widget == null)
				_widget = new KWidget(_appState);
			_widget.visible = false;
			if(_widget is DisplayObject)
			{
				var widgetContainer:MovieClip = new MovieClip();
				_contentContainer.addChild(widgetContainer);
				widgetContainer.addChild((_widget as DisplayObject));
			}
			else
				throw new Error("Widget "+_widget+" is not a DisplayObject!");
			
			if(interactorManagerRef == null)
				_interactorManager = new KInteractorManager();
			else
				_interactorManager = new interactorManagerRef() as IInteractorManager;
			
			_initStatesMachine(_widget);
			_startStateMachine();
			
			_initiated = true;
			createChildren();
			
		}
		
		public function get widget():IWidget
		{
			return _interactorManager.widget;
		}
		
		public function get interactorManager():IInteractorManager
		{
			return _interactorManager;
		}
		
		public function set clockState(value:ICanvasClockState):void
		{
			if(_clockState == value)
				return;
			_clockState.exit();
			_clockState = value;
			_clockState.entry();
		}
		
		public function newFile():void
		{
			_interactorManager.reset();
			_appState.selection = null;
			_appState.clearStacks();
			_startStateMachine();
			_appState.time = 0;
			_appState.maxTime = KAppState.DEFAULT_MAX_TIME;
			_facade.newFile();
			
			_viewsTable = new Dictionary();
			_initStatesMachine(_widget);
			_startStateMachine();
		}
		
		public function loadFile(xml:XML):void
		{
			newFile();
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
		
		public function get objectRoot():MovieClip
		{
			return _objectRoot;
		}
		
		public function set drawingRegion(component:UIComponent):void
		{
			_drawingRegion = component;
		}
		
		public function get drawingRegion():UIComponent
		{
			
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
		
		protected override function createChildren():void
		{	
			super.createChildren();
			
			if(_initiated)
			{
				_interactorManager.activateOn(_facade, _appState, this, _widget);
			}
		}
		
		private function _initStatesMachine(widget:IWidget):void
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
		
		private function _startStateMachine():void
		{
			_stoppedState.init();
			_clockState = _stoppedState;
			_clockState.entry();
		}
		
		private function _initModelEventsHandler():void
		{
			_facade.addEventListener(KObjectEvent.EVENT_VISIBILITY_CHANGED, _objectAlphaEventHandler);
			_facade.addEventListener(KObjectEvent.EVENT_OBJECT_ADDED, _objectAddedEventHandler);
			_facade.addEventListener(KObjectEvent.EVENT_OBJECT_REMOVED, _objectRemovedEventHandler);
			_facade.addEventListener(KGroupUngroupEvent.EVENT_GROUP, _groupEventHandler);
			_facade.addEventListener(KGroupUngroupEvent.EVENT_UNGROUP, _ungroupEventHandler);
		}
		
		private function _initKAppStateEventsHandler():void
		{
			_appState.addEventListener(KSelectionChangedEvent.EVENT_SELECTION_CHANGING, _selectionChangedEventHandler);
			_appState.addEventListener(KSelectionChangedEvent.EVENT_SELECTION_CHANGED, _selectionChangedEventHandler);
			_appState.addEventListener(KDebugHighlightChanged.EVENT_DEBUG_CHANGED, _debugSelectionChangedEventHandler);
			_appState.addEventListener(KTimeChangedEvent.TIME_CHANGED, _updateViews);
		}
		
		private function _objectAlphaEventHandler(event:KObjectEvent):void
		{
			var time:Number =  _appState.time;
			var obj:KObject = event.object;
			var view:IObjectView = _viewsTable[obj];
			if (view && obj.getVisibility(time) == 0 && 
				obj.createdTime < time && !_isErased(obj,time))
				_drawTracker((view as KObjectView).getRect(this));
		}
		
		private function _objectAddedEventHandler(event:KObjectEvent):void
		{
			var object:KObject = event.object;
			
			if(_viewsTable[object]!=null)
				throw new Error("object view already exists!");
			
			var view:IObjectView;
			if(object is KStroke)
				view = new KStrokeView(_appState, object as KStroke);
			else if(object is KGroup)
				view = new KGroupView(_appState, object as KGroup);
			else if(object is KImage)
				view = new KImageView(_appState, object as KImage);
			else
				throw new Error("no view supported for this kobject type!");
			
			_updateParentView(view, object.getParent(_appState.time));
			_viewsTable[object] = view;
		}
		
		private function _objectRemovedEventHandler(event:KObjectEvent):void
		{
			var view:IObjectView = _viewsTable[event.object];
			view.removeListeners();
			view.removeFromParent();
			delete _viewsTable[event.object];
		}
		
		private function _groupEventHandler(event:KGroupUngroupEvent):void
		{
			var g:KGroup = event.group;
			var obj:KObject;
			var i:IIterator = g.iterator;
			while(i.hasNext())
				_updateParentView(_viewsTable[i.next()] as IObjectView, g);
		}
		
		private function _ungroupEventHandler(event:KGroupUngroupEvent):void
		{
			var g:KGroup = event.group;
			var obj:KObject;
			var it:IIterator = g.iterator;
			while(it.hasNext())
			{
				obj = it.next();
				_updateParentView(_viewsTable[obj] as IObjectView, obj.getParent(_appState.time));
			}
		}
		
		private function _selectionChangedEventHandler(event:KSelectionChangedEvent):void
		{
			var i:IIterator;
			if(event.oldSelection != null)
				_selectOnObjectIterate(event.oldSelection.objects.iterator,event.oldSelection.selectedTime,false);
			if(event.newSelection != null)
				_selectOnObjectIterate(event.newSelection.objects.iterator,event.newSelection.selectedTime,true);
		}
		private function _selectOnObjectIterate(i:IIterator,selectedTime:Number,selected:Boolean):void
		{
			while(i.hasNext())
				_selectOnObject(i.next(), selectedTime, selected);			
		}
		
		private function _selectOnObject(object:KObject, time:Number, selected:Boolean):void
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
		
		private function _setObjectSelect(object:KObject,selected:Boolean):void
		{
			var view:IObjectView = _viewsTable[object];
			if (view != null)
				view.selected = selected;			
		}
		
		private function _debugSelectionChangedEventHandler(event:KDebugHighlightChanged):void
		{
			if(event.oldSelection != null)
				_toggleViewDebug(event.oldSelection.iterator,false);
			if(event.newSelection != null)
				_toggleViewDebug(event.newSelection.iterator,true);
		}
		
		private function _toggleViewDebug(i:IIterator,bool:Boolean):void
		{
			var view:IObjectView;
			while(i.hasNext())
			{
				view = _viewsTable[i.next()];
				view.debug = bool;
			}			
		}
		
		private function _updateViews(event:KTimeChangedEvent):void
		{
			_alphaTracker.graphics.clear();
			_alphaTracker.graphics.lineStyle(1, 0, 0.3);
			if(event.newTime != event.oldTime)
				for(var obj:Object in _viewsTable)
					_updateObjectView(obj as KObject, event.oldTime, event.newTime);
		}
		
		private function _updateObjectView(object:KObject, fromKSKTime:Number, toKSKTime:Number):void
		{
			var view:IObjectView = _viewsTable[object];
			if(view == null)
				throw new Error("object has no view");
			
			var changedParent:KGroup = object.parentChanged(fromKSKTime, toKSKTime);
			if(changedParent != null)
				_updateParentView(view, changedParent);
			
			var changedAlpha:Number = object.getVisibility(toKSKTime);
			view.updateVisibility(changedAlpha);

			var changedTransform:Matrix = object.getFullMatrix(toKSKTime);
			view.updateTransform(changedTransform);
			
		//	if (changedAlpha == 0 && object.createdTime < toKSKTime && !_isErased(object,toKSKTime))
		//		_drawTracker((view as KObjectView).getRect(this));
		}
		
		private function _drawTracker(rect:Rectangle):void
		{
			var centerX:Number = (2*rect.x + rect.width)/2;
			var centerY:Number = (2*rect.y + rect.height)/2;
			_alphaTracker.graphics.drawRect(rect.x,rect.y,rect.width,rect.height);
			_alphaTracker.graphics.moveTo(centerX - 5,centerY);
			_alphaTracker.graphics.lineTo(centerX + 5,centerY);
			_alphaTracker.graphics.moveTo(centerX,centerY - 5);
			_alphaTracker.graphics.lineTo(centerX,centerY + 5);
		}
		
		private function _updateParentView(view:IObjectView, parent:KGroup):void
		{
			var newParentView:Sprite = _viewsTable[parent];
			if(newParentView == null)
				newParentView = _objectRoot;
			view.updateParent(newParentView);
		}
		
		private function _isErased(object:KObject,time:Number):Boolean
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