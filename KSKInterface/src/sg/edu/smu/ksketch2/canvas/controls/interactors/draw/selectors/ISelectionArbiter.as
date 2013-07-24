/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.canvas.controls.interactors.draw.selectors
{
	import flash.utils.Dictionary;
	
	import sg.edu.smu.ksketch2.model.data_structures.KModelObjectList;
	import sg.edu.smu.ksketch2.model.objects.KGroup;

	/**
	 * The ISelectionArbiter class serves as the interface class for
	 * selection arbitration in K-Sketch.
	 */
	public interface ISelectionArbiter
	{
		/**
		 * Gets the best guess of the list of model objects in the selection
		 * set.
		 * 
		 * @param rawData The target raw data.
		 * @param time The target time.
		 * @param searchRoot The root node of the group.
		 * @return The best guess of the list of model objects in the selection set.
		 */
		function bestGuess(rawData:Dictionary, time:Number, searchRoot:KGroup):KModelObjectList;
	}
}