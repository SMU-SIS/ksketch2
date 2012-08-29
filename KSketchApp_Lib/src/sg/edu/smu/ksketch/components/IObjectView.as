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