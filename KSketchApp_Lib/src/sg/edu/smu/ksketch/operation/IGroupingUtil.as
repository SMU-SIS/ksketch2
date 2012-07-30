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