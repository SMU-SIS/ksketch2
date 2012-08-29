/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package sg.edu.smu.ksketch.operation
{
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.model.KModel;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;
	
	public interface IGroupingUtil
	{
		function group(objectList:KModelObjectList, groupUnder:KGroup, groupTime:Number, model:KModel):KGroup;
		function ungroup(object:KObject, ungroupTime:Number, toParent:KGroup, model:KModel):void;
		function findToGroupUnder(objectList:KModelObjectList, type:int, groupTime:Number, root:KGroup):KGroup
		function removeSingletons(model:KModel):void;
	}
}