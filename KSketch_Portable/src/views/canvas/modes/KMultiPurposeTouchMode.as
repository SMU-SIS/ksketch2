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
	
	import spark.core.SpriteVisualElement;
	
	import views.canvas.interactors.KTouchSelectInteractor;
	
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
		private var _tapSelectInteractor:KTouchSelectInteractor;
		
		private var _activeInteractor:IInteractor;
		
		public function KMultiPurposeTouchMode(KSketchInstance:KSketch2, interactionControl:IInteractionControl,
											   inputComponent:UIComponent, modelDisplay:KModelDisplay)
		{
			super(this);
			_KSketch = KSketchInstance;
			_interactionControl = interactionControl;
			_inputComponent = inputComponent;
			_modelDisplay = modelDisplay;
		}
		
		public function init():void
		{
			_drawInteractor = new KDrawInteractor(_KSketch, _modelDisplay, _interactionControl);
			_tapSelectInteractor = new KTouchSelectInteractor(_KSketch, _interactionControl, _modelDisplay);
			_loopSelectInteractor = new KLoopSelectInteractor(_KSketch, _modelDisplay, _interactionControl);
			
			_tapGesture = new TapGesture(_inputComponent);
			_tapGesture.addEventListener(GestureEvent.GESTURE_RECOGNIZED, _recogniseTap);
			
			_drawGesture = new PanGesture(_inputComponent);
			_drawGesture.addEventListener(GestureEvent.GESTURE_BEGAN, _recogniseDraw);
		}
		
		private function _recogniseTap(event:GestureEvent):void
		{
			_activeInteractor = _tapSelectInteractor;
			_tapSelectInteractor.tap(_modelDisplay.globalToLocal(_tapGesture.location));
		}
		
		private function _recogniseDraw(event:GestureEvent):void
		{
			if(_drawGesture.touchesCount == 1)
				_activeInteractor = _drawInteractor;
			else if(_drawGesture.touchesCount == 2)
				_activeInteractor = _loopSelectInteractor;

			_activeInteractor.activate();
			_activeInteractor.interaction_Begin(_modelDisplay.globalToLocal(_drawGesture.lastTouchLocation));
			
			_drawGesture.addEventListener(GestureEvent.GESTURE_CHANGED, _updateDraw);
			_drawGesture.addEventListener(GestureEvent.GESTURE_ENDED, _endDraw);
		}
		
		private function _updateDraw(event:GestureEvent):void
		{
			if(_drawGesture.touchesCount == 1 && _activeInteractor is KLoopSelectInteractor)
			{
				_endDraw(event);
				return;
			}
			
			if(_drawGesture.touchesCount == 2 && _activeInteractor is KDrawInteractor)
				return;
			
			_activeInteractor.interaction_Update(_modelDisplay.globalToLocal(_drawGesture.lastTouchLocation));
		}
		
		private function _endDraw(event:GestureEvent):void
		{
			_activeInteractor.interaction_End();
			_drawGesture.removeAllEventListeners();
			_drawGesture.addEventListener(GestureEvent.GESTURE_BEGAN, _recogniseDraw);
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