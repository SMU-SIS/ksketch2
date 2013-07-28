/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.canvas.controls.interactors.widgetstates
{
	/**
	 * The IWidgetMode class serves as the interface class for widget mode
	 * in K-Sketch.
	 */
	public interface IWidgetMode
	{
		/**
		 * Initializes the widget mode.
		 */
		function init():void;
		
		/**
		 * Activates the widget mode.
		 */
		function activate():void;
		
		/**
		 * Deactivates the widget mode.
		 */
		function deactivate():void;
		
		/**
		 * Sets the state of the demonstration mode.
		 * 
		 * @param demo The target state of the demonstration mode.
		 */
		function set demonstrationMode(demo:Boolean):void
		
		/**
		 * Sets the enable boolean flag of the widget mode.
		 * 
		 * @param The target enable boolean flag of the widget mode.
		 */
		function set enabled(enable:Boolean):void;
	}
}