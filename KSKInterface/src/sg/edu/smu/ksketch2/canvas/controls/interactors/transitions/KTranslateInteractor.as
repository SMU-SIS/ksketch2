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
	import org.gestouch.gestures.PanGesture;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.canvas.components.timebar.KSketch_TimeControl;
	import sg.edu.smu.ksketch2.canvas.controls.KInteractionControl;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.utils.KSelection;
	
	/**
	 * The KTranslateInteractor class serves as the concrete class for
	 * touch translation interactors in K-Sketch.
	 */
	public class KTranslateInteractor extends KTransitionInteractor
	{
		private var _translateGesture:PanGesture;	// the translate gesture
		private var _previousPoint:Point;			// the previous point
		private var _startPoint:Point;				// the start point
		
		/**
		 * The main constructor for the KTranslateInteractor class.
		 * 
		 * @param KSketchInstance The ksketch instance.
		 * @param interactionControl The interaction control.
		 * @param inputComponent The input component display control.
		 * @param modelSpace The model space display control.
		 */
		public function KTranslateInteractor(KSketchInstance:KSketch2, interactionControl:KInteractionControl, inputComponent:DisplayObject, modelSpace:DisplayObject)
		{
			// set the translate interactor
			super(KSketchInstance, interactionControl, modelSpace);
			
			// set the translate gesture
			_translateGesture = new PanGesture(inputComponent);
			
			// set the translate gesture's maximum touches
			_translateGesture.maxNumTouchesRequired = 1;
		}
		
		override public function reset():void
		{
			// reset the translate interactor
			super.reset();
			
			// remove the translate interactor's event listeners
			_translateGesture.removeAllEventListeners();
			
			// discard the start point
			_startPoint = null;
			
			// reactivate the translate interactor
			activate();
		}
		
		override public function activate():void
		{
			// activate the translate interactor
			super.activate();
			
			// add the translate interactor's event listeners
			_translateGesture.addEventListener(GestureEvent.GESTURE_BEGAN, _interaction_begin);
		}
		
		override public function deactivate():void
		{
			// deactivate the translate interactor
			super.deactivate();
			
			// remove the translate interactor's event listeners
			_translateGesture.removeAllEventListeners();
		}
		
		override protected function _interaction_begin(event:GestureEvent):void
		{
			// begin the translate interaction
			super._interaction_begin(event);
			
			// get the raw selection from the interaction control
			var rawSelection:KSelection = _interactionControl.selection;
			
			// case: there exists one object in the raw selection
			// group the singleton object into a hierarchy
			if(rawSelection && rawSelection.objects.length() == 1)
				_KSketch.hierarchy_Group(rawSelection.objects, _KSketch.time, false, _interactionControl.currentInteraction);
			
			// set the start point to the translate gesture's location
			_startPoint = _translateGesture.location;
			
			// initialize the loop-related variables
			var i:int = 0;									// loop counter
			var length:int = _transitionObjects.length();	// loop size
			var currentObject:KObject;						// current object
			
			// start the translation
			for(i; i < length; i++)
				_KSketch.beginTransform(_transitionObjects.getObjectAt(i),_interactionControl.transitionMode, _interactionControl.currentInteraction);
			
			// broadcast the interaction's start
			_interactionControl.dispatchEvent(new Event(KInteractionControl.EVENT_INTERACTION_BEGIN));
			
			// add listeners for translation update and interaction end for the translate gesture 
			_translateGesture.addEventListener(GestureEvent.GESTURE_CHANGED, _update_Translate);
			_translateGesture.addEventListener(GestureEvent.GESTURE_ENDED, _interaction_end);			
		}
		
		private function _update_Translate(event:GestureEvent):void
		{
			var i:int = 0;															// loop variable
			var length:int = _transitionObjects.length();							// loop size
			var currentObject:KObject;												// current object
			var dxdy:Point = _translateGesture.location.subtract(_startPoint);		// translation
			
			// scale the translation
			dxdy.x /= _KSketch.scaleX;
			dxdy.y /= _KSketch.scaleY;
			
			// update the translation
			for(i; i < length; i++)
				_KSketch.updateTransform(_transitionObjects.getObjectAt(i), dxdy.x, dxdy.y, 0, 0 );
		}
		
		override protected function _interaction_end(event:GestureEvent):void
		{
			// initialize the XML logging values
			var log:XML = <op/>;
			var date:Date = new Date();

			// set the XML logging values
			log.@category = "Transition";
			if(_interactionControl.transitionMode == KSketch2.TRANSITION_DEMONSTRATED)
				log.@type = "Perform Translate";
			else
				log.@type = "Interpolate Translate";

			// log the interaction
			log.@KSketchDuration = KSketch_TimeControl.toTimeCode(_KSketch.time - _startTime);
			log.@elapsedTime = KSketch_TimeControl.toTimeCode(date.time - _KSketch.logStartTime);
			_KSketch.log.appendChild(log);
			
			// iterate through each transition object
			// transform the ksketch
			var i:int = 0;									// loop counter (i.e., initial 0 value)
			var length:int = _transitionObjects.length();	// loop size (i.e, number of transition objects)
			var currentObject:KObject;						// loop object (i.e., the first transition object)
			
			// stop the translation
			for(i; i < length; i++)
				_KSketch.endTransform(_transitionObjects.getObjectAt(i),  _interactionControl.currentInteraction);
			
			// end the interaction
			super._interaction_end(event);
			
			// reset the interaction
			reset();
		}
	}
}