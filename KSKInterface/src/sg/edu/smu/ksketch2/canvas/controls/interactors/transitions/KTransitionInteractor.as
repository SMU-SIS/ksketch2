/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.canvas.controls.interactors.transitions
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	
	import org.gestouch.events.GestureEvent;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.canvas.controls.KInteractionControl;
	import sg.edu.smu.ksketch2.model.data_structures.KModelObjectList;
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;
	import sg.edu.smu.ksketch2.utils.KSelection;
	
	/**
	 * The KInteractor class serves as the concrete class for touch
	 * transition interactors in K-Sketch. Specifically, the basic
	 * functions required by touch transition interactors.
	 */
	public class KTransitionInteractor
	{
		protected var _activated:Boolean = false;					// the activated status boolean flag
		protected var _KSketch:KSketch2;							// the ksketch instance
		protected var _interactionControl:KInteractionControl;		// the interaction control
		protected var _modelSpace:DisplayObject;					// the model space
		
		protected var _startTime:int;								// the start time
		protected var _endTime:int;									// the end time
		protected var _oldSelection:KSelection;						// the old selection
		protected var _newSelection:KSelection;						// the new selection
		
		protected var _transitionObjects:KModelObjectList;			// the transition objects
		
		/**
		 * The main constructor of the KTransitionInteractor class.
		 * 
		 * @param KSketchInstance The target working ksketch instance.
		 * @param InteractionControl The target interaction control interface where it gets its working selection and undo/redo stacks from.
		 * @param modelSpace The target model space display object.
		 */
		public function KTransitionInteractor(KSketchInstance:KSketch2, interactionControl:KInteractionControl, modelSpace:DisplayObject)
		{
			// sets the ksketch instance
			_KSketch = KSketchInstance;
			
			// sets the interaction control
			_interactionControl = interactionControl;
			
			// sets the model space
			_modelSpace = modelSpace;
		}
		
		/**
		 * Activates the gesture recognition for the transition interactor.
		 */
		public function activate():void
		{
			// activates the gesture recognition
			_activated = true;
		}
		
		/**
		 * Deactivates the gesture recognition for the transition interactor.
		 */
		public function deactivate():void
		{
			// deactivates the gesture recognition
			_activated = false;
		}
		
		/**
		 * Resets the transition interactor to the state after its creation.
		 */
		public function reset():void
		{
			// deactivate the gesture recognition
			deactivate();
			
			// nullify the old and new selections
			_oldSelection = null;
			_newSelection = null;
			
			// remove the start and end times
			_startTime = NaN;
			_endTime = NaN;
		}
		
		/**
		 * Begins the transition's interaction.
		 * 
		 * @param event The target gesture event.
		 */
		protected function _interaction_begin(event:GestureEvent):void
		{
			// begin an interaction operation here
			// keep the required values
			_startTime = _KSketch.time;						// set the start time to the ksketch instance's current time
			_oldSelection = _interactionControl.selection;	// set the old selection to the current interaction control's selection
		
			// handle the general interaction's implicit grouping here
			var rawSelection:KSelection = _interactionControl.selection;		// get the interaction control's raw selection
			var op:KCompositeOperation = new KCompositeOperation();				// initialize the corresponding composite operation
			_interactionControl.begin_interaction_operation();					// begin the interaction
			var savedTransitionMode:int = _interactionControl.transitionMode;	// save the transition mode

			// case: there are multiple objects in the raw selection
			if(rawSelection.objects.length() > 1 )
			{
				// group the raw selection's objects
				var newObjectList:KModelObjectList = _KSketch.hierarchy_Group(rawSelection.objects, _KSketch.time, false, op);
				
				// set the interaction control's selection to the raw selection's objects
				_interactionControl.selection = new KSelection(newObjectList);
				
				// set the interaction control's transition mode to the previously saved transition mode
				_interactionControl.transitionMode = savedTransitionMode;
				
				// add the corresponding composite operation to the current operation
				_interactionControl.currentInteraction.addOperation(op);
			}
			
			// for the time being, put the new selection through a grouping algorithm to get the correct one
			_newSelection = _interactionControl.selection; 
			
			// get the transition interaction's selected objects
			_transitionObjects = _newSelection.objects;
			
			// broadcast the interaction's start
			_interactionControl.dispatchEvent(new Event(KInteractionControl.EVENT_INTERACTION_BEGIN));
			
			// case: the interaction control's transition mode is a demonstrated transition
			// begin recording
			if(_interactionControl.transitionMode == KSketch2.TRANSITION_DEMONSTRATED)
				_interactionControl.beginRecording();
		}
		
		/**
		 * Ends the transition's interaction.
		 * 
		 * @param event The gesture event.
		 */
		protected function _interaction_end(event:GestureEvent):void
		{
			// stop recording the interaction control
			_interactionControl.stopRecording();
			
			// end the interaction operation
			_interactionControl.end_interaction_operation();
			
			// broadcast the interaction's end
			_interactionControl.dispatchEvent(new Event(KInteractionControl.EVENT_INTERACTION_END));

		}
		
		/**
		 * Gets the global center.
		 * 
		 * @return The global center.
		 */
		protected function getGlobalCenter():Point
		{
			// get the local center of the interaction control's selection at the ksetch's current time
			var selectionCenter:Point = _interactionControl.selection.centerAt(_KSketch.time);
			
			// convert the local center to the global center
			selectionCenter = _modelSpace.localToGlobal(selectionCenter);
			
			// return the global center
			return selectionCenter;
		}
	}
}