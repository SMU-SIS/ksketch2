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
	
	public class KScaleInteractor extends KTransitionInteractor
	{
		private var _scaleGesture:PanGesture;
		private var _previousPoint:Point;
		private var _center:Point;
		private var _startScaleDistance:Number;
		private var _scale:Number;
		
		public function KScaleInteractor(KSketchInstance:KSketch2, interactionControl:KInteractionControl,
											  inputComponent:DisplayObject, modelSpace:DisplayObject)
		{
			super(KSketchInstance, interactionControl, modelSpace);
			_scaleGesture = new PanGesture(inputComponent);
			_scaleGesture.maxNumTouchesRequired = 1;
		}
		
		override public function reset():void
		{
			super.reset();
			_scaleGesture.removeAllEventListeners();
			
			activate();
			_scale = 1;
		}
		
		override public function activate():void
		{
			super.activate();
			_scaleGesture.addEventListener(GestureEvent.GESTURE_BEGAN, _interaction_begin);
		}
		
		override public function deactivate():void
		{
			super.deactivate();
			_scaleGesture.removeAllEventListeners();
		}
		
		override protected function _interaction_begin(event:GestureEvent):void
		{
			super._interaction_begin(event);
			
			_scale = 1;
			_previousPoint = _scaleGesture.location;
			_center = getGlobalCenter();
			_startScaleDistance = _scaleGesture.location.subtract(_center).length;
			
			var i:int = 0;
			var length:int = _transitionObjects.length();
			var currentObject:KObject;
			
			for(i; i < length; i++)
				_KSketch.beginTransform(_transitionObjects.getObjectAt(i),_interactionControl.transitionMode, _interactionControl.currentInteraction);
			
			_scaleGesture.addEventListener(GestureEvent.GESTURE_CHANGED, _update_Scale);
			_scaleGesture.addEventListener(GestureEvent.GESTURE_ENDED, _interaction_end);			
		}
		
		override protected function _interaction_end(event:GestureEvent):void
		{
			var i:int = 0;
			var length:int = _transitionObjects.length();
			var currentObject:KObject;
			
			for(i; i < length; i++)
				_KSketch.endTransform(_transitionObjects.getObjectAt(i),  _interactionControl.currentInteraction);
			
			super._interaction_end(event);
			reset();
		}
		
		private function _update_Scale(event:GestureEvent):void
		{
			_scale = _scaleGesture.location.subtract(_center).length/_startScaleDistance;

			var i:int = 0;
			var length:int = _transitionObjects.length();
			var currentObject:KObject;
	
			for(i; i < length; i++)
				_KSketch.updateTransform(_transitionObjects.getObjectAt(i), 0, 0, 0, _scale-1);
		}
	}
}