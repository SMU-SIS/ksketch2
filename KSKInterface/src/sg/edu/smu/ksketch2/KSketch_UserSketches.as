package sg.edu.smu.ksketch2
{
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	
	import spark.utils.DataItem;

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
		
		public function getLatestVersionArr():void
		{
			if(arrDG)
			{
				trace("array length original: " + arrDG.length);
				var tempArr:ArrayCollection = new ArrayCollection();
				
				for(var i:int=0; i< arrDG.length; i++)
				{
					var currItem:Object = arrDG.getItemAt(i);
					//if(currItem.originalName == "N/A")
					tempArr.addItem(currItem);
					if(currItem.originalName != "N/A")
					{
						for(var j:int=0; j<arrDG.length; j++)
						{
							var compareItem:Object = arrDG.getItemAt(j);
							if(currItem.originalName == compareItem.originalName && currItem.version > compareItem.version)
							{
								for(var k:int=0; k<tempArr.length; k++)
								{
									if(tempArr.getItemAt(k).originalName == currItem.originalName)
										tempArr.removeItemAt(k);
									
									tempArr.addItem(currItem);
								}
							}
						}
					}
				}
				
				/*for(var i:int=0; i<arrDG.length; i++)
				{
					var currItem:Object = arrDG.getItemAt(i);
					if(tempArr.length != 0)
					{
						for(var j:int=0; j<tempArr.length; j++)
						{
							var	arrItem:Object = tempArr.getItemAt(j);
							if(currItem.orignalName.indexOf("N/A") == -1 && currItem.originalName == arrItem.originalName)
							{
								if(currItem.version > arrItem.version)
								{
									tempArr.removeItemAt(j);
									tempArr.addItemAt(currItem, j);
								}
							}
							else
								tempArr.addItem(currItem);
							
								
						}
					}
					else
						tempArr.addItem(currItem);
				}*/
				
				arrDG.removeAll();
				arrDG = tempArr;
				tempArr = null;
				
				trace("array length after: " + arrDG.length);
			}
		}
		
		public function getUserSketchArray():ArrayCollection
		{
			getLatestVersionArr();
			var dataSortField:SortField = new SortField();
			dataSortField.name = "sketchId";
			dataSortField.numeric = true;
			
			var numericDataSort:Sort = new Sort();
			numericDataSort.fields = [dataSortField];
			
			arrDG.sort = numericDataSort;
			arrDG.filterFunction = removedDuplicates;
			arrDG.refresh();
			
			return arrDG;
		}
		
		private function removedDuplicates(item:Object):Boolean {
			if (keys.hasOwnProperty(item.name)) {
				/* If the keys Object already has this property,
				return false and discard this item. */
				return false;
			} else {
				/* Else the keys Object does *NOT* already have
				this key, so add this item to the new data
				provider. */
				keys[item.name] = item;
				return true;
			}
		}
		
	}	
}