package sg.edu.smu.ksketch2
{
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	
	import spark.utils.DataItem;
	
	import sg.edu.smu.ksketch2.utils.SortingFunctions;

	[Bindable]
	public class KSketch_UserSketches
	{
		private var keys:Object = {};
		public var arrEntities:Array = [];
		public var arrDG:ArrayCollection = new ArrayCollection();
		
		/*
		-- Each OBJECT in the array has the following attributes
		data:Object;
		id:Number;
		modified:String;
		created:String;
		
		-- Each DATA OBJECT has the following attributes
		comment: Number;
		thumbnailData: String;
		sketchId: Number;
		originalVersion: Number;
		p_edit: Boolean;
		changeDescription: String;
		fileName: String;
		like: Number;
		originalName: String;
		appVer: Number;
		version: Number;
		p_view: Boolean;
		owner: String;
		originalSketch: Number;
		p_comment: Boolean;
		owner_id: Number;
		*/
		
		//this object only carries "entities" property
		public function KSketch_UserSketches(obj:Object, id:String)
		{
			arrEntities = (obj as Array);
			createArray(id);
		}	
		
		public function createArray(id:String):void
		{
			//sketch image, name, description, date
			for (var i:String in arrEntities)
			{
				//check if the owner id is the same as logged-in id
				var tempId:String = arrEntities[i].data.owner_id;
				
				if(tempId == id)
				{
					var tempItem:DataItem = new DataItem();
					tempItem.name = arrEntities[i].data.fileName;
					tempItem.date = arrEntities[i].created;
					tempItem.sketchId = arrEntities[i].data.sketchId;
					tempItem.version = arrEntities[i].data.version;
					tempItem.originalName = arrEntities[i].data.originalName;
					tempItem.originalVersion = arrEntities[i].data.originalVersion;
					tempItem.image = arrEntities[i].data.thumbnailData;
					
					arrDG.addItem(tempItem);
				}
			}
		}
		
		public function getUserSketchObj():Object
		{
			return arrEntities;
		}
		
		public function getUserSketchArray(sortBy:String):ArrayCollection
		{
			if(arrDG)
			{
				arrDG = SortingFunctions.sortArray(arrDG, sortBy);
				//arrDG.filterFunction = removedDuplicates;
				arrDG.refresh();
			}
			return arrDG;
		}
		
		/*
		private function removedDuplicates(item:Object):Boolean {
			if (keys.hasOwnProperty(item.name)) {
				// If the keys Object already has this property,
				//return false and discard this item.
				return false;
			} else {
				//Else the keys Object does *NOT* already have
				//this key, so add this item to the new data
				//provider.
				keys[item.name] = item;
				return true;
			}
		}
		*/
	}	
}