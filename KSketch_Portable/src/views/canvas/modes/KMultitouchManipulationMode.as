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
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.controls.interactioncontrol.IInteractionControl;
	import sg.edu.smu.ksketch2.controls.interactionmodes.IInteractionMode;
	import sg.edu.smu.ksketch2.controls.widgets.IWidget;
	
	import views.canvas.components.MultiTouchTransformWidget;
	
	public class KMultitouchManipulationMode extends EventDispatcher implements IInteractionMode
	{
		private var _KSketch:KSketch2;
		private var _widget:IWidget;
		private var _interactionControl:IInteractionControl;
		
		public function KMultitouchManipulationMode(KSketchInstance:KSketch2, interactionControl:IInteractionControl, widget:IWidget)
		{
			super(this);
			
			_widget = widget;
			_KSketch = KSketchInstance;
			_interactionControl = interactionControl;
		}
		
		public function init():void
		{
			//The widget is the interactor now????
		}
		
		public function activate():void
		{
			
		}
		
		public function reset():void
		{
		}
		
		public function beginInteraction(point:Point):void
		{
		}
		
		public function updateInteraction(point:Point):void
		{
		}
		
		public function endInteraction():void
		{
		}
		
		public function refreshManipulationMode():void
		{
			_widget.highlightSelection(_interactionControl.selection, _KSketch.time);
		}
	}
}