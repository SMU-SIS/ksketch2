/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.controls.widgets
{
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch2.controls.interactioncontrol.IInteractionControl;
	import sg.edu.smu.ksketch2.utils.KSelection;

	public interface IWidget
	{
		function init(interactionControl:IInteractionControl):void
		function get center():Point;
		function set isMovingCenter(value:Boolean):void;
		function get isMovingCenter():Boolean;
		function get visible():Boolean;
		function set visible(value:Boolean):void;
		function highlightSelection(selection:KSelection, time:int):void;
	}
}