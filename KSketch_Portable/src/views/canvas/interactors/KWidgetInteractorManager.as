package views.canvas.interactors
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.TapGesture;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.events.KSketchEvent;
	import sg.edu.smu.ksketch2.events.KTimeChangedEvent;
	
	import views.canvas.components.transformWidget.TouchWidgetTemplate;
	import views.canvas.interactioncontrol.KMobileInteractionControl;

	public class KWidgetInteractorManager
	{
		//private var _directionInteractor:KTouchDragDirectionInteractor;
		private var _transformInteractor:KTouchFreeTransformInteractor;
		private var _dragInteractor:KTouchOrientatePathInteractor;
		private var _rotateInteractor:KTouchRotateInteractor;
		
		private var _KSketch:KSketch2;
		private var _interactionControl:KMobileInteractionControl;
		private var _widget:TouchWidgetTemplate;
		private var _modelSpace:DisplayObject;
		private var _widgetSpace:DisplayObject;
		
		private var _enabled:Boolean;
		private var _modeGesture:TapGesture;
		private var _isInteracting:Boolean;
		
		/**
		 * Instantiates widget and transition interactors.
		 * Also controls the appearance of the widget based on selection location
		 * This guy does not handle gesture events. Gesture events are handled in the interactors themselves.
		 * @param KSketchInstance: target KSketch object.
		 * @param interactionControl: host interaction control.
		 * @param widget: A component that is of TouchWidgetTemplate descent.
		 */
		// This class doesn't really do anything other than help in keeping JT a bit more sane
		// By keeping the code a bit neater
		public function KWidgetInteractorManager(KSketchInstance:KSketch2, interactionControl:KMobileInteractionControl, 
									 widget:TouchWidgetTemplate, modelSpace:DisplayObject):void
		{
			_KSketch = KSketchInstance;
			_interactionControl = interactionControl;
			_widget = widget;
			_modelSpace = modelSpace;
			_widgetSpace = widget.parent;
				
			_modeGesture = new TapGesture(_widget.centroid);
			_modeGesture.numTapsRequired = 1;
			
			//_directionInteractor = new KTouchDragDirectionInteractor(KSketchInstance, interactionControl, this, widget.dragTrigger, widget);
			_transformInteractor = new KTouchFreeTransformInteractor(KSketchInstance, interactionControl, widget.freeTransformTrigger);
			_dragInteractor = new KTouchOrientatePathInteractor(KSketchInstance, interactionControl, widget.dragTrigger);
			_rotateInteractor = new KTouchRotateInteractor(KSketchInstance, interactionControl, widget.rotationTrigger);			

			interactionControl.addEventListener(KSketchEvent.EVENT_SELECTION_SET_CHANGED, _updateWidget);
			interactionControl.addEventListener(KMobileInteractionControl.EVENT_INTERACTION_BEGIN, _updateWidget);
			interactionControl.addEventListener(KMobileInteractionControl.EVENT_INTERACTION_END, _updateWidget);
			_KSketch.addEventListener(KTimeChangedEvent.EVENT_TIME_CHANGED, _updateWidget);
			
//			_widget.contextTrigger1 = contextMenuTrigger1;
//			_widget.contextTrigger2 = contextMenuTrigger2;
			
			transitionMode = KSketch2.TRANSITION_INTERPOLATED;
			enabled = true;
			_isInteracting = false;
			_widget.drawMenu();
		}
		
		public function set transitionMode(mode:int):void
		{
			_interactionControl.transitionMode = mode;
			
			if(_interactionControl.transitionMode == KSketch2.TRANSITION_DEMONSTRATED)
			{
				if(!_enabled)
					enabled = true;	
				
				_widget.enterRecordState();
			}
			else if(_interactionControl.transitionMode == KSketch2.TRANSITION_INTERPOLATED)
				_widget.enterInterpolateState();
			else
				throw new Error("Unknow transition mode. Check what kind of modes the transition delegate is setting");
		}
		
		public function set enabled(isEnabled:Boolean):void
		{
			_enabled = isEnabled
				
			if(isEnabled)
			{
				_widget.enterEnabledState();
				_transformInteractor.activate();
				_dragInteractor.activate();
				_rotateInteractor.activate();
	
				if(!_modeGesture.hasEventListener(GestureEvent.GESTURE_RECOGNIZED))
					_modeGesture.addEventListener(GestureEvent.GESTURE_RECOGNIZED, _handleModeSwitch);
			}
			else
			{
				_widget.enterDisabledState();
				_transformInteractor.deactivate();
				_dragInteractor.deactivate();
				_rotateInteractor.deactivate();
			}
		}
		
		/**
		 * Handles ksketch events that changes the widget
		 */
		private function _updateWidget(event:Event):void
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
		
		/**
		 * Handles the double tapping for the centroid button
		 */
		private function _handleModeSwitch(event:GestureEvent):void
		{
			_widget.hideContextMenu();
			
			if(_interactionControl.transitionMode == KSketch2.TRANSITION_INTERPOLATED)
				transitionMode = KSketch2.TRANSITION_DEMONSTRATED;
			else
				transitionMode = KSketch2.TRANSITION_INTERPOLATED;
		}
		
		public function enterChangeDirectionMode():void
		{
			_widget.enterEditDirectionState();
			//_transformInteractor.deactivate();
			//_dragInteractor.deactivate();
			//_rotateInteractor.deactivate();
			//_modeGesture.removeAllEventListeners();
		}
		
		public function exitChangeDirectionMode():void
		{
			_widget.enterInteractionState();
			_transformInteractor.activate();
			_dragInteractor.activate();
			_rotateInteractor.activate();
			_modeGesture.addEventListener(GestureEvent.GESTURE_RECOGNIZED, _handleModeSwitch);
		}
	}
}