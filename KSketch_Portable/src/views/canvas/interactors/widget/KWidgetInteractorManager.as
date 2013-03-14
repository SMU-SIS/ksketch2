package views.canvas.interactors.widget
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.TapGesture;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.controls.interactioncontrol.KInteractionControl;
	import sg.edu.smu.ksketch2.events.KSketchEvent;
	import sg.edu.smu.ksketch2.events.KTimeChangedEvent;
	
	import views.canvas.components.transformWidget.KTouchWidgetBase;
	import views.canvas.components.transformWidget.KTouchWidgetMenu;
	import views.canvas.interactioncontrol.KMobileInteractionControl;

	public class KWidgetInteractorManager
	{		
		protected var _KSketch:KSketch2;
		protected var _interactionControl:KMobileInteractionControl;
		protected var _widget:KTouchWidgetBase;
		protected var _modelSpace:DisplayObject;
		protected var _widgetSpace:DisplayObject;
		protected var _contextMenu:KTouchWidgetMenu;
	
		private var _modeGesture:TapGesture;
		private var _activateMenuGesture:TapGesture;

		private var _enabled:Boolean;
		private var _isInteracting:Boolean;
		
		private var _activeMode:ITouchWidgetMode;
		public var defaultMode:ITouchWidgetMode;
		public var steeringMode:ITouchWidgetMode;
		public var freeTransformMode:ITouchWidgetMode;	
		
		public function KWidgetInteractorManager(KSketchInstance:KSketch2,
												 interactionControl:KMobileInteractionControl, 
												 widgetBase:KTouchWidgetBase, modelSpace:DisplayObject)
		{
			_KSketch = KSketchInstance;
			_interactionControl = interactionControl;
			_widget = widgetBase;
			_modelSpace = modelSpace;
			_widgetSpace = _widget.parent;
			_contextMenu = new KTouchWidgetMenu(KSketchInstance, interactionControl, widgetBase, this);
			
			defaultMode = new KBasicTransitionMode(_KSketch, _interactionControl, _widget, modelSpace);
			//steeringMode = new KSteeringMode(_KSketch, _interactionControl, _widget);
			//freeTransformMode = new KFreeTransformMode(_KSketch, _interactionControl, _widget, modelSpace);
			activeMode = defaultMode;
			
			_modeGesture = new TapGesture(_widget);
			_modeGesture.addEventListener(GestureEvent.GESTURE_RECOGNIZED, _handleModeSwitch);
			
			_activateMenuGesture = new TapGesture(_widget);
			_activateMenuGesture.numTapsRequired = 2;
			_activateMenuGesture.maxTapDelay = 150;
			_activateMenuGesture.addEventListener(GestureEvent.GESTURE_RECOGNIZED, _handleOpenMenu);
			
			_modeGesture.requireGestureToFail(_activateMenuGesture);
			
			interactionControl.addEventListener(KSketchEvent.EVENT_SELECTION_SET_CHANGED, updateWidget);
			interactionControl.addEventListener(KMobileInteractionControl.EVENT_INTERACTION_BEGIN, updateWidget);
			interactionControl.addEventListener(KMobileInteractionControl.EVENT_INTERACTION_END, updateWidget);
			interactionControl.addEventListener(KInteractionControl.EVENT_UNDO_REDO, updateWidget);
			_KSketch.addEventListener(KSketchEvent.EVENT_MODEL_UPDATED, updateWidget);
			_KSketch.addEventListener(KTimeChangedEvent.EVENT_TIME_CHANGED, updateWidget);
		}
		
		public function set activeMode(mode:ITouchWidgetMode):void
		{
			if(_activeMode == mode)
				return;
			
			if(_activeMode)
				_activeMode.deactivate();
			
			_activeMode = mode;
			_activeMode.activate();
		}
		
		private function _handleModeSwitch(event:GestureEvent):void
		{
			if(_interactionControl.transitionMode == KSketch2.TRANSITION_INTERPOLATED)
				transitionMode = KSketch2.TRANSITION_DEMONSTRATED;
			else
				transitionMode = KSketch2.TRANSITION_INTERPOLATED;
		}
		
		private function _handleOpenMenu(event:GestureEvent):void
		{
			var point:Point = _widget.parent.localToGlobal(new Point(_widget.x, _widget.y));
			if(_widget.visible)
				_contextMenu.showMenu(_widget, false, point.x, point.y);
		}
		
		public function updateWidget(event:Event):void
		{
			if(event.type == KMobileInteractionControl.EVENT_INTERACTION_BEGIN)
				_isInteracting = true;
			
			if(event.type == KMobileInteractionControl.EVENT_INTERACTION_END)
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
				if(KSketch2.studyMode == KSketch2.STUDY_K && KSketch2.studyMode == KSketch2.STUDY_PK)
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