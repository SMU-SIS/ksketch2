package views.canvas.interactors
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	
	import org.gestouch.events.GestureEvent;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.model.data_structures.KModelObjectList;
	import sg.edu.smu.ksketch2.utils.KSelection;
	
	import views.canvas.interactioncontrol.KMobileInteractionControl;

	public class KTouchTransitionInteractor
	{
		protected var _activated:Boolean = false;
		protected var _KSketch:KSketch2;
		protected var _interactionControl:KMobileInteractionControl;
		protected var _modelSpace:DisplayObject;
		
		protected var _startTime:int;
		protected var _endTime:int;
		protected var _oldSelection:KSelection;
		protected var _newSelection:KSelection;
		
		protected var _transitionObjects:KModelObjectList;
		/**
		 * KTouch Transition Interactor defines the basic functions required by a touch transition interactors.
		 * @param KSketchInstance Working Ksketch instance
		 * @param InteractionControl IInteractionControl interface that this interactor gets its working selection and undo/redo stacks from.
		 * @param inputComponent Target component that is will activate the transition gesture inputs.
		 */
		public function KTouchTransitionInteractor(KSketchInstance:KSketch2, interactionControl:KMobileInteractionControl,
													modelSpace:DisplayObject)
		{
			_KSketch = KSketchInstance;
			_interactionControl = interactionControl;
			_modelSpace = modelSpace;
		}
		
		/**
		 * Activates the gesture recognition for this interactor
		 */
		public function activate():void
		{
			_activated = true;
		}
		
		/**
		 * Deactivates the gesture recognition for this interactor
		 */
		public function deactivate():void
		{
			_activated = false;
		}
		
		/**
		 * Returns this interactor to the state after its construction
		 */
		public function reset():void
		{
			deactivate();
			_oldSelection = null;
			_newSelection = null;
			_startTime = NaN;
			_endTime = NaN;
		}
		
		protected function _interaction_begin(event:GestureEvent):void
		{
			//Begin an Interaction Operation here.
			//Keep values required.
			_startTime = _KSketch.time;
			_oldSelection = _interactionControl.selection;
		
			//Handle general interaction implicit grouping here in this class
			_newSelection = _interactionControl.selection; // For the time being. We have to put it thru a grouping algo to get the correct one
			_transitionObjects = _newSelection.objects;
			
			_interactionControl.begin_interaction_operation();
			_interactionControl.dispatchEvent(new Event(KMobileInteractionControl.EVENT_INTERACTION_BEGIN));
			
			if(_interactionControl.transitionMode == KSketch2.TRANSITION_DEMONSTRATED)
				_interactionControl.beginRecording();
		}
		
		protected function _interaction_end(event:GestureEvent):void
		{
			if(_interactionControl.transitionMode == KSketch2.TRANSITION_DEMONSTRATED)
				_interactionControl.stopRecording();
			
			//Handle interaction operation wrap up here in this class
			_interactionControl.end_interaction_operation();
			_interactionControl.dispatchEvent(new Event(KMobileInteractionControl.EVENT_INTERACTION_END));

		}
		
		protected function getGlobalCenter():Point
		{
			var selectionCenter:Point = _interactionControl.selection.centerAt(_KSketch.time);
			selectionCenter = _modelSpace.localToGlobal(selectionCenter);
			
			return selectionCenter;
		}
	}
}