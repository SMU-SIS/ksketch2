/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.canvas.controls.interactors.draw
{
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	
	/**
	 * The IInteractor class serves as the interface class for interactors
	 * in K-Sketch.
	 */
	public interface IInteractor extends IEventDispatcher
	{
		/**
		 * Activates the interactor by setting up the implementation
		 * before the interaction begins. Specifically, it prepares
		 * the interactor's values that will tend to fail less often.
		 */
		function activate():void;
		
		/**
		 * Resets the interactor by cleaning up any mess created by the
		 * previous interaction and then returning the interactor to its
		 * default state.
		 */
		function reset():void;
		
		/**
		 * Begins the interaction. Specifically, serves as a generic
		 * interaction begins method.
		 * 
		 * @param point The target point.
		 */
		function interaction_Begin(point:Point):void;
		
		/**
		 * Updates the interaction. Specifically, serves as a generic
		 * interaction update method that sets the interactor's values
		 * to their default values.
		 * 
		 * @param point The target point.
		 */
		function interaction_Update(point:Point):void;
		
		/**
		 * Ends the interaction. Specifically, serves as a generic
		 * interation end method.
		 */
		function interaction_End():void;
	}
}