/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.controls.interactors
{
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	
	public interface IInteractor extends IEventDispatcher
	{
		/**
		 * Sets up an IInteraction implementation before interaction begin
		 */
		function activate():void;
		
		/**
		 * Cleans up any mess created by the previous interaction. Returns the IInteractor implementation
		 * to its default state
		 */
		function reset():void;
		
		/**
		 * Generic interaction begin function for an IInteraction implementation
		 */
		function interaction_Begin(point:Point):void;
		
		/**
		 * Generic interaction update function for an IInteraction implementation
		 */
		function interaction_Update(point:Point):void;
		
		/**
		 * Generic interaction end function for an IInteraction implementation
		 */
		function interaction_End():void;
	}
}