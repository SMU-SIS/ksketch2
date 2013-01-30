/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package views.canvas.interactors.selection
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	
	import org.gestouch.core.Touch;
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.PanGesture;
	import org.gestouch.gestures.TapGesture;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.controls.interactioncontrol.IInteractionControl;
	import sg.edu.smu.ksketch2.controls.interactionmodes.IInteractionMode;
	import sg.edu.smu.ksketch2.controls.interactors.IInteractor;
	import sg.edu.smu.ksketch2.controls.interactors.KDrawInteractor;
	import sg.edu.smu.ksketch2.controls.interactors.KLoopSelectInteractor;
	import sg.edu.smu.ksketch2.view.KModelDisplay;
	
	import spark.core.SpriteVisualElement;
	
	import views.canvas.interactioncontrol.KMobileInteractionControl;
	
	
	public class KSelectionInteractorManager extends EventDispatcher
	{
		private var _KSketch:KSketch2;
		private var _interactionControl:KMobileInteractionControl;
		private var _inputComponent:UIComponent;
		private var _modelDisplay:KModelDisplay;

		private var _tapGesture:TapGesture;
		private var _drawGesture:PanGesture;
		
		private var _drawInteractor:KDrawInteractor;
		private var _loopSelectInteractor:KLoopSelectInteractor;
		private var _tapSelectInteractor:KTouchSelectInteractor;
		
		private var _activeInteractor:IInteractor;
		
		/**
		 * KMobileSelection mode is the state machine that switches between
		 * drawing, tap selection and loop selection interactors.
		 * Note: This class's implementation is inconsistent with that of the transition delegator
		 * @param KSketchInstance: KSketch2 instance that this mode is going to interact with
		 * @param interactionControl: iInteractionControl that oversees application's mode switching.
		 * @param inputComponent: Target UIcomponent that will dispatch gesture events for this mode.
		 * @param modelDisplay: ModelDisplay linked to given KSketchInstance
		 * 
		 */
		public function KSelectionInteractorManager(KSketchInstance:KSketch2, interactionControl:KMobileInteractionControl,
											   inputComponent:UIComponent, modelDisplay:KModelDisplay)
		{
			super(this);
			_KSketch = KSketchInstance;
			_interactionControl = interactionControl;
			_inputComponent = inputComponent;
			_modelDisplay = modelDisplay;
			
			/**
			 * Implementation is inconsistent with the transition module
			 * Reusing Draw and loop select interactors so implementation will feel a bit weird
			 * These interactors are sharing gesture inputs
			 */
			_drawInteractor = new KDrawInteractor(_KSketch, _modelDisplay, _interactionControl);
			_tapSelectInteractor = new KTouchSelectInteractor(_KSketch, _interactionControl, _modelDisplay);
			_loopSelectInteractor = new KLoopSelectInteractor(_KSketch, _modelDisplay, _interactionControl);
			
			_tapGesture = new TapGesture(_inputComponent);
			_tapGesture.addEventListener(GestureEvent.GESTURE_RECOGNIZED, _recogniseTap);
			
			_drawGesture = new PanGesture(_inputComponent);
			_drawGesture.addEventListener(GestureEvent.GESTURE_BEGAN, _recogniseDraw);
			_drawGesture.maxNumTouchesRequired = 2;
		}
		
		/**
		 * Gesture handler for tap gesture
		 */
		private function _recogniseTap(event:GestureEvent):void
		{
			_activeInteractor = _tapSelectInteractor;
			_tapSelectInteractor.tap(_modelDisplay.globalToLocal(_tapGesture.location));
		}
		
		/**
		 * Gesture handler for draw gesture event
		 */
		private function _recogniseDraw(event:GestureEvent):void
		{
			//Switches interactor based on draw gesture's nTouches
			if(_drawGesture.touchesCount == 1)
				_activeInteractor = _drawInteractor;
			else if(_drawGesture.touchesCount == 2)
				_activeInteractor = _loopSelectInteractor;
			
			_interactionControl.selection = null;

			_activeInteractor.activate();
			//make sure the input coordinates are in the correct coordinate space
			_activeInteractor.interaction_Begin(_modelDisplay.globalToLocal(_drawGesture.lastTouchLocation)); 

			_drawGesture.addEventListener(GestureEvent.GESTURE_CHANGED, _updateDraw);
			_drawGesture.addEventListener(GestureEvent.GESTURE_ENDED, _endDraw);
			_interactionControl.dispatchEvent(new Event(KMobileInteractionControl.EVENT_INTERACTION_BEGIN));
		}
		
		/**
		 * Gesture handler for an update by the draw gesture
		 */
		private function _updateDraw(event:GestureEvent):void
		{
			//Gesture change updates. A loop interactor should have two fingers
			if((_drawGesture.touchesCount == 1 && _activeInteractor is KLoopSelectInteractor)||
				(_drawGesture.touchesCount == 2 && _activeInteractor is KDrawInteractor)) 
			{
				_endDraw(event);
				return;
			}
			
			//make sure the input coordinates are in the correct coordinate space
			_activeInteractor.interaction_Update(_modelDisplay.globalToLocal(_drawGesture.lastTouchLocation));
		}
		
		/**
		 * Gesture handler for draw gesture's end even
		 */
		private function _endDraw(event:GestureEvent):void
		{
			//Clean up and do whatever the active interactor have to do at the end of an interaction
			_activeInteractor.interaction_End();
			_drawGesture.removeAllEventListeners();
			_drawGesture.addEventListener(GestureEvent.GESTURE_BEGAN, _recogniseDraw);
			_interactionControl.dispatchEvent(new Event(KMobileInteractionControl.EVENT_INTERACTION_END));
		}	
	}
}