/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.controls.interactionmodes
{
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.controls.interactioncontrol.IInteractionControl;
	import sg.edu.smu.ksketch2.controls.interactors.KDrawInteractor;
	import sg.edu.smu.ksketch2.controls.interactors.KEraserInteractor;
	import sg.edu.smu.ksketch2.controls.interactors.KInteractor;
	import sg.edu.smu.ksketch2.view.KModelDisplay;
	
	public class KDrawingMode extends EventDispatcher implements IInteractionMode
	{
		public static const ERASER_MODE:String = "eraser mode";
		public static const DRAW_MODE:String = "draw mode";
		
		private var _KSketch:KSketch2;
		private var _interactorDisplay:KModelDisplay;
		private var _modelDisplay:KModelDisplay;

		private var _interactionControl:IInteractionControl;
		private var _currentInteractor:KInteractor;
		private var _drawInteractor:KDrawInteractor;
		private var _eraseInteractor:KEraserInteractor;
		
		public function KDrawingMode(ksketchInstance:KSketch2, interactorDisplay:KModelDisplay
									 , interactionControl:IInteractionControl)
		{
			_KSketch = ksketchInstance;
			_interactionControl = interactionControl;
			_interactorDisplay = interactorDisplay;
			super(this);
		}
		
		public function init():void
		{
			_drawInteractor = new KDrawInteractor(_KSketch, _interactorDisplay, _interactionControl);
			_eraseInteractor = new KEraserInteractor(_KSketch, _interactionControl, _interactorDisplay);
			drawMode = DRAW_MODE;
		}
		
		public function activate():void
		{
			_currentInteractor.activate();
		}
		
		public function reset():void
		{
			_currentInteractor.reset();
		}
		
		public function set drawMode(mode:String):void
		{
			if(mode == DRAW_MODE)
				_currentInteractor = _drawInteractor;
			else
				_currentInteractor = _eraseInteractor;
		}
		
		public function beginInteraction(point:Point):void
		{
			_currentInteractor.interaction_Begin(point);
		}
		
		public function updateInteraction(point:Point):void
		{
			_currentInteractor.interaction_Update(point);
		}
		
		public function endInteraction():void
		{
			_currentInteractor.interaction_End();
			_currentInteractor.reset();
		}
	}
}