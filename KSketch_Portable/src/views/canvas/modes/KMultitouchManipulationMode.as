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
	
	import sg.edu.smu.ksketch2.controls.interactionmodes.IInteractionMode;
	
	public class KMultitouchManipulationMode extends EventDispatcher implements IInteractionMode
	{
		public function KMultitouchManipulationMode()
		{
			super(this);
		}
		
		public function init():void
		{
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
	}
}