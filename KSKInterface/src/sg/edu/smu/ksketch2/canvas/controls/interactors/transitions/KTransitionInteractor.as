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
	import sg.edu.smu.ksketch2.canvas.controls.interactors.widgetstates.KWidgetInteractorManager;
	import sg.edu.smu.ksketch2.utils.KSelection;
	
	public class KTransitionInteractor
	{
		protected var _activated:Boolean = false;
		protected var _KSketch:KSketch2;
		protected var _interactionControl:KInteractionControl;
		protected var _modelSpace:DisplayObject;
		
		protected var _startTime:Number;
		protected var _endTime:Number;
		protected var _oldSelection:KSelection;
		protected var _newSelection:KSelection;
		
		protected var _transitionObjects:KModelObjectList;
		/**
		 * KTouch Transition Interactor defines the basic functions required by a touch transition interactors.
		 * @param KSketchInstance Working Ksketch instance
		 * @param InteractionControl IInteractionControl interface that this interactor gets its working selection and undo/redo stacks from.
		 * @param inputComponent Target component that is will activate the transition gesture inputs.
		 */
		public function KTransitionInteractor(KSketchInstance:KSketch2, interactionControl:KInteractionControl,
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
			var rawSelection:KSelection = _interactionControl.selection;
			var op:KCompositeOperation = new KCompositeOperation();
			_interactionControl.begin_interaction_operation();
			var savedTransitionMode:int = _interactionControl.transitionMode;

			//If interaction is a rotation or scale demonstration, flag for possibility of a common parent for grouped objects
			var breakToRoot:Boolean = true;
			
			if(KWidgetInteractorManager.demonstrationFlag && (KRotateInteractor.rotateFlag || KScaleInteractor.scaleFlag))
				breakToRoot = false;
			
			if(KTranslateInteractor.translateFlag)
				KSketch2.translateFlag = true;
			
			if(rawSelection.objects.length() > 1 )
			{
				var newObjectList:KModelObjectList = _KSketch.hierarchy_Group(rawSelection.objects, _KSketch.time, breakToRoot, op);
				
				_interactionControl.selection = new KSelection(newObjectList);
				_interactionControl.transitionMode = savedTransitionMode;
				_interactionControl.currentInteraction.addOperation(op);
			}
			
			_newSelection = _interactionControl.selection; // For the time being. We have to put it thru a grouping algo to get the correct one
			_transitionObjects = _newSelection.objects;
			
			_interactionControl.dispatchEvent(new Event(KInteractionControl.EVENT_INTERACTION_BEGIN));
			
			if(_interactionControl.transitionMode == KSketch2.TRANSITION_DEMONSTRATED)
				_interactionControl.beginRecording();
		}
		
		protected function _interaction_end(event:GestureEvent):void
		{
			_interactionControl.stopRecording();
			
			//Handle interaction operation wrap up here in this class
			_interactionControl.end_interaction_operation();
			_interactionControl.dispatchEvent(new Event(KInteractionControl.EVENT_INTERACTION_END));

		}
		
		protected function getGlobalCenter():Point
		{
			var selectionCenter:Point = _interactionControl.selection.centerAt(_KSketch.time);
			selectionCenter = _modelSpace.localToGlobal(selectionCenter);
			
			return selectionCenter;
		}
	}
}