/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package sg.edu.smu.ksketch.components
{
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch.utilities.IModelObjectList;

	public interface IWidget extends IEventDispatcher
	{
		function get center():Point;
		function set isMovingCenter(value:Boolean):void;
		function get isMovingCenter():Boolean;
		function get visible():Boolean;
		function set visible(value:Boolean):void;
		function highlightSelection():void;
	}
}