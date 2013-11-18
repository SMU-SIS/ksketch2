/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.canvas.components.view.objects
{
	import flash.events.IEventDispatcher;

	public interface IObjectView extends IEventDispatcher
	{
		function displayable():KObjectView;
		
		/**
		 * Update view uses the given time to generate updated values from
		 * the model object. Uses these updated values to update this view object
		 */
		function updateView(time:Number):void;
			
		/**
		 * Update parent switches the parent of this view object in the flash display list
		 * If the new parent is not in the scenegraph, this view object will not be displayed
		 */
		function updateParent(newParent:IObjectView):void;
		
		/**
		 * Removes this object from its view parent
		 */
		function removeFromParent():void;
		
		function debug(debugSpacing:String=""):void;
	}
}