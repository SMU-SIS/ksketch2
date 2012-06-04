/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.components
{
	import flash.display.DisplayObjectContainer;
	import flash.geom.Matrix;
	
	public interface IObjectView
	{
		/**
		 * A boolean value that indicates whether the object rendered by this view is selected.
		 * @param selected True if selected, else false.
		 * 
		 */		
		function set selected(selected:Boolean):void;
		
		function set showCursorPathMode(mode:Boolean):void;
		function set showCursorPath(show:Boolean):void;
		/**
		 * A boolean value that indicates whether the object rendered by this view is selected for debug purpose.
		 * @param value True if selected, else false.
		 * 
		 */		
		function set debug(value:Boolean):void;	
		/**
		 * Remove all listeners from the view.
		 * 
		 */	
		function removeListeners():void;
		
		function updateParent(newParent:DisplayObjectContainer):void;
		
		function removeFromParent():void;
	
		function updateTransform(newTransform:Matrix):void;
		
		function updateVisibility(newAlpha:Number):void;
	}
}