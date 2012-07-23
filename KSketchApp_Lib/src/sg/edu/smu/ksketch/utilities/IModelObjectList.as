/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.utilities
{
	import sg.edu.smu.ksketch.model.KObject;
	
	public interface IModelObjectList
	{
		function add(object:KObject, index:int = -1):void
		function remove(object:KObject):void;
		function length():int;
		function getObjectAt(index:int):KObject;
		function toIDs():Vector.<int>;
		function get iterator():IIterator;
	}
}