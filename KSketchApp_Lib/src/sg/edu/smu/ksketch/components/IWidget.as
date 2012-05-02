/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

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