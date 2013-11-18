/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.model.data_structures
{
	import sg.edu.smu.ksketch2.model.objects.KObject;

	/**
	 * The IModelObjectList interface serves as the interface class for a model object list in K-Sketch.
	 */
	public interface IModelObjectList
	{
		/**
		 * Adds a KObject to the model object list. Its position in the list will
		 * be determined by its ID.
		 * 
		 * @param object The target KObject.
		 * @param index The index in the model object list.
		 */
		function add(object:KObject, index:int = -1):void
			
		/**
		 * Removes a KObject from the model object list.
		 * 
		 * @param object The target KObject.
		 */
		function remove(object:KObject):void;
		
		/**
		 * Gets the length of the model object list.
		 * 
		 * @return The length of the model object list.
		 */
		function length():int;
		
		/**
		 * Checks whether the model object list contains the target KObject.
		 * 
		 * @param object The target KObject.
		 * @return Whether the model object list contains the target KObject.
		 */
		function contains(object:KObject):Boolean;
		
		/**
		 * Gets the KObject at the target index.
		 * 
		 * @param index The target index.
		 * @return The KObject from the target index in the model object list.
		 */
		function getObjectAt(index:int):KObject;
		
		/**
		 * Gets the list of IDs for each KObject in the model object list.
		 * 
		 * @return The list of IDs for each KObject in the model object list.
		 */
		function toIDs():Vector.<int>;
	}
}