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
	import flash.geom.Point;
	
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.PanGesture;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.canvas.controls.KInteractionControl;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	
	/**
	 * The KScaleInteractor class serves as the concrete class for
	 * scale translation interactors in K-Sketch.
	 */
	public class KScaleInteractor extends KTransitionInteractor
	{
		private var _scaleGesture:PanGesture;		// the scale gesture
		private var _previousPoint:Point;			// the previous point
		private var _center:Point;					// the center point
		private var _startScaleDistance:Number;		// the start scale distance
		private var _scale:Number;					// the scaling value
		
		/**
		 * The main constructor for the KScaleInteractor class.
		 * 
		 * @param KSketchInstance The ksketch instance.
		 * @param interactionControl The interaction control.
		 * @param inputComponent The input component display control.
		 * @param modelSpace The model space display control.
		 */
		public function KScaleInteractor(KSketchInstance:KSketch2, interactionControl:KInteractionControl, inputComponent:DisplayObject, modelSpace:DisplayObject)
		{
			// set the scale interactor
			super(KSketchInstance, interactionControl, modelSpace);
			
			// set the scale gesture
			_scaleGesture = new PanGesture(inputComponent);
			
			// set the scale gesture's maximum touches
			_scaleGesture.maxNumTouchesRequired = 1;
		}
		
		override public function reset():void
		{
			// reset the scale interactor
			super.reset();
			
			// remove the scale interactor's event listeners
			_scaleGesture.removeAllEventListeners();
			
			// discard the scaling value
			_scale = 1;
			
			// reactivate the scale interactor
			activate();
		}
		
		override public function activate():void
		{
			// activate the scale interactor
			super.activate();
			
			// add the scale interactor's event listeners
			_scaleGesture.addEventListener(GestureEvent.GESTURE_BEGAN, _interaction_begin);
		}
		
		override public function deactivate():void
		{
			// deactivate the scale interactor
			super.deactivate();
			
			// remove the scale interactor's event listeners
			_scaleGesture.removeAllEventListeners();
		}
		
		override protected function _interaction_begin(event:GestureEvent):void
		{
			// begin the scale interaction
			super._interaction_begin(event);
			
			// initialize the scale interactor's settings
			_scale = 1;																	// initialize the scaling value to 0
			_previousPoint = _scaleGesture.location; 									// set the previous point to the scale gesture's current location
			_center = getGlobalCenter();												// set the center point to the current global center
			_startScaleDistance = _scaleGesture.location.subtract(_center).length;		// set the start scale distance
			
			var i:int = 0;									// loop counter
			var length:int = _transitionObjects.length();	// loop size
			var currentObject:KObject;						// current object
			
			// begin the scaling
			for(i; i < length; i++)
				_KSketch.beginTransform(_transitionObjects.getObjectAt(i),_interactionControl.transitionMode, _interactionControl.currentInteraction);
			
			// add listeners for scale update and interaction end for the scale gesture 
			_scaleGesture.addEventListener(GestureEvent.GESTURE_CHANGED, _update_Scale);
			_scaleGesture.addEventListener(GestureEvent.GESTURE_ENDED, _interaction_end);			
		}
		
		private function _update_Scale(event:GestureEvent):void
		{
			// calculate the current scaling value
			_scale = _scaleGesture.location.subtract(_center).length/_startScaleDistance;
			
			var i:int = 0;									// loop counter
			var length:int = _transitionObjects.length();	// loop size
			var currentObject:KObject;						// current object
			
			// update the scaling
			for(i; i < length; i++)
				_KSketch.updateTransform(_transitionObjects.getObjectAt(i), 0, 0, 0, _scale-1);
		}
		
		override protected function _interaction_end(event:GestureEvent):void
		{
			var i:int = 0;									// loop counter
			var length:int = _transitionObjects.length();	// loop size
			var currentObject:KObject;						// current object
			
			// stop the scaling
			for(i; i < length; i++)
				_KSketch.endTransform(_transitionObjects.getObjectAt(i),  _interactionControl.currentInteraction);
			
			// end the interaction
			super._interaction_end(event);
			
			// reset the interaction
			reset();
		}
	}
}