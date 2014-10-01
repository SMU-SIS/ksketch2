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
	import sg.edu.smu.ksketch2.canvas.components.timebar.KSketch_TimeControl;
	import sg.edu.smu.ksketch2.canvas.components.view.KSketch_CanvasView;
	import sg.edu.smu.ksketch2.canvas.controls.KInteractionControl;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.utils.KMathUtil;
	
	/**
 	 * The KRotateInteractor class serves as the concrete class for touch
 	 * rotation interactors in K-Sketch.
 	 */
	public class KRotateInteractor extends KTransitionInteractor
	{
		public static const PIx2:Number = 6.283185307;		// the constant pi value
		public static var rotateFlag:Boolean = false;		// the rotate flag
		private var _rotateGesture:PanGesture;				// the rotate gesture
		private var _theta:Number;							// the rotational value

		private var _center:Point;							// the center point
		private var _previousPoint:Point;					// the previous point
		private var _startPoint:Point;						// the start point
		
		/**
 -		 * The main constructor for the KRotateInteractor class.
 -		 * 
 -		 * @param KSketchInstance The ksketch instance.
 -		 * @param interactionControl The interaction control.
 -		 * @param inputComponent The input component display object.
 -		 * @param modelSpace The model space display object.
 -		 */
		public function KRotateInteractor(KSketchInstance:KSketch2, interactionControl:KInteractionControl,
											inputComponent:DisplayObject, modelSpace:DisplayObject)
		{
			super(KSketchInstance, interactionControl, modelSpace);
			_rotateGesture = new PanGesture(inputComponent);
			_rotateGesture.maxNumTouchesRequired = 1;
		}
		
		override public function reset():void
		{
			super.reset();
			_rotateGesture.removeAllEventListeners();
			_theta = NaN;
			
			activate();
			
			rotateFlag = false;
		}
		
		override public function activate():void
		{
			super.activate();
			_rotateGesture.addEventListener(GestureEvent.GESTURE_BEGAN, _interaction_begin);
		}
		
		override public function deactivate():void
		{
			super.deactivate();
			_rotateGesture.removeAllEventListeners();
		}
		
		override protected function _interaction_begin(event:GestureEvent):void
		{
			rotateFlag = true;
			
			KSketch_CanvasView.tracker.trackPageview("/canvas/rotate");
			super._interaction_begin(event);
			
			_theta = 0;
			_previousPoint = _rotateGesture.location;
			_center = getGlobalCenter();
			
			var i:int = 0;
			var length:int = _transitionObjects.length();
			var currentObject:KObject;

			for(i; i < length; i++)
				_KSketch.beginTransform(_transitionObjects.getObjectAt(i),_interactionControl.transitionMode, _interactionControl.currentInteraction);
			
			_rotateGesture.addEventListener(GestureEvent.GESTURE_CHANGED, _update_Rotate);
			_rotateGesture.addEventListener(GestureEvent.GESTURE_ENDED, _interaction_end);			
		}
		
		override protected function _interaction_end(event:GestureEvent):void
		{
			// iterate through each transition object
			// transform the ksketch
			var i:int = 0;									// loop counter (i.e., initial 0 value)
			var length:int = _transitionObjects.length();	// loop size (i.e, number of transition objects)
			
			// stop the rotation
			for(i; i < length; i++)
				_KSketch.endTransform(_transitionObjects.getObjectAt(i),  _interactionControl.currentInteraction);
			
			// end the interaction
			super._interaction_end(event);
			
			// reset the interaction
			reset();
			
			//LOG
			_KSketch.logCounter ++;
			var log:XML = <Action/>;
			var date:Date = new Date();
			log.@category = "Transition";
			
			if(_interactionControl.transitionMode == KSketch2.TRANSITION_DEMONSTRATED)
			{
				log.@type = "Perform Rotate";
				//trace("ACTION " + _KSketch.logCounter + ": Perform Rotate");
			}
			else
			{
				log.@type = "Interpolate Rotate";
				//trace("ACTION " + _KSketch.logCounter + ": Interpolate Rotate");
			}
			
			log.@KSketchDuration = KSketch_TimeControl.toTimeCode(_KSketch.time - _startTime);
			log.@elapsedTime = KSketch_TimeControl.toTimeCode(date.time - _KSketch.logStartTime);
			KSketch2.log.appendChild(log);
		}

		
		private function _update_Rotate(event:GestureEvent):void
		{
			// set the touch location to the rotate gesture's current location
			var touchLocation:Point = _rotateGesture.location;
			
			// calculate the angle change
			var angleChange:Number = KMathUtil.angleOf(_previousPoint.subtract(_center), touchLocation.subtract(_center));
			
			// case: the angle is greater than pi
			// reset the angle to below pi
			if(angleChange > Math.PI)
				angleChange = angleChange - PIx2;
			
			// update the rotational value
			_theta += angleChange;
			
			var i:int = 0;									// loop variable
			var length:int = _transitionObjects.length();	// loop size
			
			// update the rotation
			for(i; i < length; i++)
				_KSketch.updateTransform(_transitionObjects.getObjectAt(i), 0, 0, _theta, 0 );
			
			// set the previous point as the current touch location
			_previousPoint = touchLocation;
		}
	}
}