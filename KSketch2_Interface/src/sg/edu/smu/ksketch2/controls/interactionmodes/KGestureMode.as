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
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.controls.interactioncontrol.IInteractionControl;
	import sg.edu.smu.ksketch2.controls.interactioncontrol.KInteractionControl;
	import sg.edu.smu.ksketch2.controls.interactors.KSelectInteractor;
	
	import spark.core.SpriteVisualElement;
	
	public class KGestureMode extends EventDispatcher implements IInteractionMode
	{
		private var _KSketch:KSketch2;
		private var _interactorDisplay:SpriteVisualElement;
		private var _interactionControl:IInteractionControl;
		private var _selectInteractor:KSelectInteractor;
		
		public function KGestureMode(ksketchInstance:KSketch2, interactorDisplay:SpriteVisualElement, interactionControl:IInteractionControl)
		{
			_KSketch = ksketchInstance;
			_interactionControl = interactionControl;
			_interactorDisplay = interactorDisplay;
			super(this);
		}
		
		public function init():void
		{
			_selectInteractor = new KSelectInteractor(_KSketch, _interactorDisplay, _interactionControl);
		}
		
		public function activate():void
		{
			
		}
		
		public function reset():void
		{
			_selectInteractor.reset();
		}
		
		public function beginInteraction(point:Point):void
		{
			_selectInteractor.interaction_Begin(point);
		}
		
		public function updateInteraction(point:Point):void
		{
			_selectInteractor.interaction_Update(point);
		}
		
		public function endInteraction():void
		{
			_selectInteractor.interaction_End();
		}
	}
}