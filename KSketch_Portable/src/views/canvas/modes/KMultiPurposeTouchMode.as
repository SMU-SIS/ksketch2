/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package views.canvas.modes
{
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
	
	import views.canvas.interactors.KTapSelectInteractor;
	
	public class KMultiPurposeTouchMode extends EventDispatcher implements IInteractionMode
	{
		private var _KSketch:KSketch2;
		private var _interactionControl:IInteractionControl;
		private var _inputComponent:UIComponent;
		private var _modelDisplay:KModelDisplay;

		private var _tapGesture:TapGesture;
		private var _drawGesture:PanGesture;
		
		private var _drawInteractor:KDrawInteractor;
		private var _loopSelectInteractor:KLoopSelectInteractor;
		private var _tapSelectInteractor:KTapSelectInteractor;
		
		private var _activeInteractor:IInteractor;
		
		public function KMultiPurposeTouchMode(KSketchInstance:KSketch2, interactionControl:IInteractionControl,
											   inputComponent:UIComponent, displayContainer:KModelDisplay)
		{
			super(this);
			_KSketch = KSketchInstance;
			_interactionControl = interactionControl;
			_inputComponent = inputComponent;
			_modelDisplay = displayContainer;
		}
		
		public function init():void
		{
			_drawInteractor = new KDrawInteractor(_KSketch, _modelDisplay, _interactionControl);
			
			_tapGesture = new TapGesture(_inputComponent);
			_tapGesture.addEventListener(GestureEvent.GESTURE_RECOGNIZED, _recogniseTap);
			
			_drawGesture = new PanGesture(_inputComponent);
			_drawGesture.addEventListener(GestureEvent.GESTURE_BEGAN, _recogniseDraw);
		}
		
		private function _recogniseTap(event:GestureEvent):void
		{
			trace("Tapping to select!");	
		}
		
		private function _recogniseDraw(event:GestureEvent):void
		{
			if(_drawGesture.touchesCount == 1)
				_activeInteractor = _drawInteractor;
			else if(_drawGesture.touchesCount == 2)
				_activeInteractor = _loopSelectInteractor;
			
			_activeInteractor.activate();
			_activeInteractor.interaction_Begin(_modelDisplay.globalToLocal(_drawGesture.location));
			
			_drawGesture.addEventListener(GestureEvent.GESTURE_CHANGED, _updateDraw);
			_drawGesture.addEventListener(GestureEvent.GESTURE_ENDED, _endDraw);
		}
		
		private function _updateDraw(event:GestureEvent):void
		{
			var currentPoint:Point = _drawGesture.location;
			var localPoint:Point = _modelDisplay.globalToLocal(currentPoint);
			
			
		}
		
		private function _endDraw(event:GestureEvent):void
		{
		
		}
	
		
		/**
		 * Does Nothing
		 */
		public function activate():void{}
		/**
		 * Does Nothing
		 */
		public function reset():void{}
		/**
		 * Does Nothing
		 */
		public function beginInteraction(point:Point):void{}
		/**
		 * Does Nothing
		 */
		public function updateInteraction(point:Point):void{}
		/**
		 * Does Nothing
		 */
		public function endInteraction():void{}
	}
}