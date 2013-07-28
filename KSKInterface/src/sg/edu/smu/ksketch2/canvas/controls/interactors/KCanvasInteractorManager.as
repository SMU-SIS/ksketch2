/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.canvas.controls.interactors
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.PanGesture;
	import org.gestouch.gestures.TapGesture;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.canvas.KSketch_CanvasView;
	import sg.edu.smu.ksketch2.canvas.components.popup.KSketch_Feedback_Message;
	import sg.edu.smu.ksketch2.canvas.controls.KInteractionControl;
	import sg.edu.smu.ksketch2.canvas.controls.interactors.draw.IInteractor;
	import sg.edu.smu.ksketch2.canvas.controls.interactors.draw.KDrawInteractor;
	import sg.edu.smu.ksketch2.canvas.controls.interactors.draw.KLoopSelectInteractor;
	import sg.edu.smu.ksketch2.canvas.components.view.KModelDisplay;
	
	/**
	 * The KCanvasInteractorManager class serves as the concrete class for
	 * managing canvas interactions in K-Sketch. Specifically, it serves
	 * as the state machines that switches between draw, tap selection,
	 * and loop selection interactors. Note: This class's implementation
	 * is inconsistent with that of the transition delegator.
	 */
	public class KCanvasInteractorManager extends EventDispatcher
	{
		/**
		 * The left position constant.
		 */
		private const _LEFT:int = 0;
		
		/**
		 * The right position constant.
		 */
		private const _RIGHT:int = 1;
		
		private var _KSketch:KSketch2;									// the ksketch instance
		private var _interactionControl:KInteractionControl;			// the interaction control
		private var _inputComponent:UIComponent;						// the input component
		private var _modelDisplay:KModelDisplay;						// the model display
		private var _feedbackMessage:KSketch_Feedback_Message;			// the feedback manager
		
		private var _tapGesture:TapGesture;								// the tap gesture
		private var _doubleTap:TapGesture;								// the double-tap gesture
		private var _drawGesture:PanGesture;							// the draw gesture
		
		private var _drawInteractor:KMultiTouchDrawInteractor;			// the draw interactor
		private var _loopSelectInteractor:KLoopSelectInteractor;		// the loop select interactor
		private var _tapSelectInteractor:KMultiTouchSelectInteractor;	// the tap select interactor
		
		private var _activeInteractor:IInteractor;						// the active interactor
		private var _startPoint:Point;									// the start point
		private var _keyDown:Boolean;									// the key down boolean flag
		
		/**
		 * The main constructor for the KCanvasInteractorManager class.
		 * 
		 * @param KSketchInstance The target ksketch instance that interacts with the mode.
		 * @param interactionControl The target interaction control that oversees mode switching.
		 * @param inputComponent The target input component that dispatches gesture events for the mode.
		 * @param modelDisplay The model display linked to the given ksketch object.
		 * @param feedbackMessage The feedback message.
		 */
		public function KCanvasInteractorManager(KSketchInstance:KSketch2, interactionControl:KInteractionControl, inputComponent:UIComponent, modelDisplay:KModelDisplay, feedbackMessage:KSketch_Feedback_Message)
		{
			// set up the canvas interactor manager
			super(this);								// set up the event dispatcher
			_KSketch = KSketchInstance;					// initialize the ksketch instance
			_interactionControl = interactionControl;	// initialize the interaction control
			_inputComponent = inputComponent;			// initialize the input component
			_modelDisplay = modelDisplay;				// initialize the model display
			_feedbackMessage = feedbackMessage;			// initialize the feedback display
			_keyDown = false;							// set the key down boolean flag as off

			/**
			 * set the draw, tap, and loop select interactors
			 * this implementation is inconsistent with the transition module
			 * it's reusing the draw and loop select interactors, so implementation will feel a bit weird
			 * these interactors are sharing gesture inputs
			 */
			_drawInteractor = new KMultiTouchDrawInteractor(_KSketch, _modelDisplay, _interactionControl);
			_tapSelectInteractor = new KMultiTouchSelectInteractor(_KSketch, _interactionControl, _modelDisplay);
			_loopSelectInteractor = new KLoopSelectInteractor(_KSketch, _modelDisplay, _interactionControl);
			
			// set the draw interactor's pen settings
			KDrawInteractor.penColor = 0x000000;	// set the pen color
			KDrawInteractor.penThickness = 9;		// set the pen thickness
			
			// initialize the tap gesture
			_tapGesture = new TapGesture(_inputComponent);
			_tapGesture.addEventListener(GestureEvent.GESTURE_RECOGNIZED, _recogniseTap);
			_tapGesture.maxTapDuration = 200;
			
			// initialize the draw gesture
			_drawGesture = new PanGesture(_inputComponent);
			_drawGesture.addEventListener(GestureEvent.GESTURE_BEGAN, _recogniseDraw);
			_drawGesture.maxNumTouchesRequired = 2;
			
			// case: running non-mobile application
			// handle keyboard actions for non-mobile version
			if(!KSketch_CanvasView.isMobile)
				FlexGlobals.topLevelApplication.addEventListener(KeyboardEvent.KEY_DOWN, _keyTrigger);
			// case: running mobile version
			// handle touch actions for mobile version
			else
			{
				_doubleTap = new TapGesture(_inputComponent);
				_doubleTap.numTapsRequired = 2;
				_doubleTap.maxTapDelay = 125;
				_doubleTap.addEventListener(GestureEvent.GESTURE_RECOGNIZED, _recogniseDoubleTap);
				_tapGesture.requireGestureToFail(_doubleTap);
			}
		}
		
		/**
		 * Handles key trigger events.
		 * 
		 * @param event The target keyboard event.
		 */
		private function _keyTrigger(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.COMMAND || event.keyCode == Keyboard.CONTROL
				|| event.keyCode == Keyboard.SPACE)
				_keyDown = event.type == KeyboardEvent.KEY_DOWN;
			
			if(event.ctrlKey&&(event.keyCode == Keyboard.Z))
				_interactionControl.undo();
			
			if(event.ctrlKey&&(event.keyCode == Keyboard.Y))
				_interactionControl.redo();
			
			if(_keyDown)
			{
				FlexGlobals.topLevelApplication.removeEventListener(KeyboardEvent.KEY_DOWN, _keyTrigger);
				FlexGlobals.topLevelApplication.addEventListener(KeyboardEvent.KEY_UP, _keyTrigger);
			}
			else
			{
				FlexGlobals.topLevelApplication.addEventListener(KeyboardEvent.KEY_DOWN, _keyTrigger);
				FlexGlobals.topLevelApplication.removeEventListener(KeyboardEvent.KEY_UP, _keyTrigger);
			}
		}
		
		/**
		 * Handles double-tap gesture events.
		 * 
		 * @param event The target gesture event.
		 */
		private function _recogniseDoubleTap(event:GestureEvent):void
		{
			var left:Boolean = (_doubleTap.location.x/_inputComponent.width <= 0.5)? true:false;
			
			if(left)
			{
				if(_interactionControl.hasUndo)
				{
					_interactionControl.undo();
					_feedbackMessage.showMessage("Undo", _doubleTap.location);
				}
				else
					_feedbackMessage.showMessage("No Undo", _doubleTap.location);
			}
			else
			{
				if(_interactionControl.hasRedo)
				{
					_interactionControl.redo();
					_feedbackMessage.showMessage("Redo", _doubleTap.location);
				}
				else
					_feedbackMessage.showMessage("No Redo", _doubleTap.location);
			}
		}
		
		/**
		 * Handles tap gesture events. Requires double-tap to fail.
		 * 
		 * @param event The target gesture event.
		 */
		private function _recogniseTap(event:GestureEvent):void
		{
			if(_interactionControl.currentInteraction)
				return;
			
			_activeInteractor = _tapSelectInteractor;
			_tapSelectInteractor.tap(_modelDisplay.globalToLocal(_tapGesture.location));
		}
		
		/**
		 * Handles draw gesture events.
		 * 
		 * @param event The target gesture event.
		 */
		private function _recogniseDraw(event:GestureEvent):void
		{
			if(_interactionControl.currentInteraction)
				return;
			
			// switch interactor based on draw gesture's nTouches
			if(_keyDown || _drawGesture.touchesCount == 2)
				_activeInteractor = _loopSelectInteractor;	
			else if(_drawGesture.touchesCount == 1)
				_activeInteractor = _drawInteractor;
			
			_interactionControl.selection = null;

			_activeInteractor.activate();
			
			// make sure the input coordinates are in the correct coordinate space
			_activeInteractor.interaction_Begin(_modelDisplay.globalToLocal(_drawGesture.lastTouchLocation)); 

			_drawGesture.addEventListener(GestureEvent.GESTURE_CHANGED, _updateDraw);
			_drawGesture.addEventListener(GestureEvent.GESTURE_ENDED, _endDraw);
			_interactionControl.dispatchEvent(new Event(KInteractionControl.EVENT_INTERACTION_BEGIN));
		}
		
		/**
		 * Updates draw gesture events.
		 * 
		 * @param event The target gesture event.
		 */
		private function _updateDraw(event:GestureEvent):void
		{
			// update gesture change; a loop interactor should have two fingers
			if(_drawGesture.touchesCount == 2 && _activeInteractor is KDrawInteractor)
			{
				_endDraw(event);
				return;
			}
			
			// make sure the input coordinates are in the correct coordinate space
			_activeInteractor.interaction_Update(_modelDisplay.globalToLocal(_drawGesture.lastTouchLocation));
		}
		
		/**
		 * Ends draw gesture events.
		 * 
		 * @param event The target gesture event.
		 */
		private function _endDraw(event:GestureEvent):void
		{
			// clean up and do whatever the active interactor have to do at the end of an interaction
			_activeInteractor.interaction_End();
			_drawGesture.removeAllEventListeners();
			_drawGesture.addEventListener(GestureEvent.GESTURE_BEGAN, _recogniseDraw);
			_interactionControl.dispatchEvent(new Event(KInteractionControl.EVENT_INTERACTION_END));
		}	
	}
}