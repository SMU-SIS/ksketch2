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
	import sg.edu.smu.ksketch2.canvas.controls.KInteractionControl;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.utils.GoogleAnalytics;
	import sg.edu.smu.ksketch2.utils.KSelection;
	
	/**
	 * The KTranslateInteractor class serves as the concrete class for
	 * touch translation interactors in K-Sketch.
	 */
	public class KTranslateInteractor extends KTransitionInteractor
	{
		public static var translateFlag:Boolean = false;		// the translate flag
		
		private var _translateGesture:PanGesture;	// the translate gesture
		private var _previousPoint:Point;			// the previous point
		private var _startPoint:Point;				// the start point
		private var _googleAnalytics:GoogleAnalytics;
		
		/**
 		 * The main constructor for the KTranslateInteractor class.
 		 * 
 		 * @param KSketchInstance The ksketch instance.
 		 * @param interactionControl The interaction control.
 		 * @param inputComponent The input component display control.
 		 * @param modelSpace The model space display control.
 		 */
		public function KTranslateInteractor(KSketchInstance:KSketch2, interactionControl:KInteractionControl,
											inputComponent:DisplayObject, modelSpace:DisplayObject,
											googleAnalytics:GoogleAnalytics)
		{
			super(KSketchInstance, interactionControl, modelSpace);
			_translateGesture = new PanGesture(inputComponent);
			_translateGesture.maxNumTouchesRequired = 1;
			_googleAnalytics = googleAnalytics;
		}
		
		override public function reset():void
		{
			super.reset();
			_translateGesture.removeAllEventListeners();
			_startPoint = null;
			
			activate();
			
			translateFlag = false;
		}
		
		override public function activate():void
		{
			super.activate();
			_translateGesture.addEventListener(GestureEvent.GESTURE_BEGAN, _interaction_begin);
		}
		
		override public function deactivate():void
		{
			super.deactivate();
			_translateGesture.removeAllEventListeners();
		}
		
		override protected function _interaction_begin(event:GestureEvent):void
		{
			translateFlag = true;
			
			_googleAnalytics.tracker.trackPageview("/canvas/translate");
			super._interaction_begin(event);
			
			var rawSelection:KSelection = _interactionControl.selection;
			
			if(rawSelection && rawSelection.objects.length() == 1)
				_KSketch.hierarchy_Group(rawSelection.objects, _KSketch.time, true, _interactionControl.currentInteraction);
			
			_startPoint = _translateGesture.location;
			
			var i:int = 0;
			var length:int = _transitionObjects.length();
			var currentObject:KObject;
			
			for(i; i < length; i++)
				_KSketch.beginTransform(_transitionObjects.getObjectAt(i),_interactionControl.transitionMode, _interactionControl.currentInteraction);
			
			_interactionControl.dispatchEvent(new Event(KInteractionControl.EVENT_INTERACTION_BEGIN));
			_translateGesture.addEventListener(GestureEvent.GESTURE_CHANGED, _update_Translate);
			_translateGesture.addEventListener(GestureEvent.GESTURE_ENDED, _interaction_end);			
		}
		
		override protected function _interaction_end(event:GestureEvent):void
		{
			/*
			var log:XML = <op/>;
			var date:Date = new Date();
			
			log.@category = "Transition";
			if(_interactionControl.transitionMode == KSketch2.TRANSITION_DEMONSTRATED)
				log.@type = "Perform Translate";
			else
				log.@type = "Interpolate Translate";

			log.@KSketchDuration = KSketch_TimeControl.toTimeCode(_KSketch.time - _startTime);
			log.@elapsedTime = KSketch_TimeControl.toTimeCode(date.time - _KSketch.logStartTime);
			_KSketch.log.appendChild(log);
			*/
			var i:int = 0;
			var length:int = _transitionObjects.length();
			var currentObject:KObject;
			
			for(i; i < length; i++)
				_KSketch.endTransform(_transitionObjects.getObjectAt(i),  _interactionControl.currentInteraction);
			
			super._interaction_end(event);
			
			reset();
		}
		
		private function _update_Translate(event:GestureEvent):void
		{
			var i:int = 0;
			var length:int = _transitionObjects.length();
			var dxdy:Point = _translateGesture.location.subtract(_startPoint);
			
			dxdy.x /= _KSketch.scaleX;
			dxdy.y /= _KSketch.scaleY;
			
			for(i; i < length; i++)
				_KSketch.updateTransform(_transitionObjects.getObjectAt(i), dxdy.x, dxdy.y, 0, 0 );

		}
	}
}