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
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	
	public interface IInteractionMode extends IEventDispatcher
	{
		/**
		 * Init must be called after this interaction mode has been constructed.
		 * Init will instantiate all the interactors that will be triggered by this IInteractionMode
		 */
		function init():void;
		
		/**
		 * Activate must be called whenever the application enters another interaction mode
		 */
		function activate():void;
		
		/**
		 * Reset must be called whenever the application leaves an interaction mode
		 */
		function reset():void;
		
		/**
		 * Input functions take in points, dependent on the interaction modes
		 */
		function beginInteraction(point:Point):void;
		function updateInteraction(point:Point):void;
		function endInteraction():void;
	}
}