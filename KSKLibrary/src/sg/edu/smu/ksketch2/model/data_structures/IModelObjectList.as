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

	public interface IModelObjectList
	{
		function add(object:KObject, index:int = -1):void
		function remove(object:KObject):void;
		function length():int;
		function contains(object:KObject):Boolean;
		function getObjectAt(index:int):KObject;
		function toIDs():Vector.<int>;
	}
}