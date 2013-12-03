package sg.edu.smu.ksketch2
{
	import com.adobe.serialization.json.JSON;
	
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
				
				if(tempId == id || tempId == "n.a")
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
				arrDG.refresh();
			}
			return arrDG;
		}
		
		public static function getSketchArrayToSync(arr:Array):ArrayCollection
		{
			var syncArr:ArrayCollection = new ArrayCollection();
			
			for(var i:int=0; i<arr.length; i++)
			{
				if(arr[i].data.sketchId == "-1")
				{
					if(!syncArr.contains(arr[i]))
						syncArr.addItem(arr[i]);		
				}
			}
			
			return syncArr;
		}
		
		public static function getSketchDocumentArrayToSync(arr:Array, arrColl:ArrayCollection):ArrayCollection
		{
			var syncArr:ArrayCollection = new ArrayCollection();
			
			//only get documents that belong to sketches in arrColl
			for(var i:int=0; i<arr.length; i++)
			{
				var sketchDocObj:Object = com.adobe.serialization.json.JSON.decode(arr[i], true);
				for(var j:int=0; j<arrColl.length; j++)
				{
					if(!sketchDocObj.data.sketchId && (sketchDocObj.data.originalName == arrColl.getItemAt(j).data.fileName))
					{
						if(!syncArr.contains(arr[i]))
							syncArr.addItem(arr[i]);	
					}
				}
			}
			
			return syncArr;
		}
		
		public static function getSketchDocumentObjectByName(arr:Array, name:String):String
		{
			var rawData:String;
			for(var i:int=0; i<arr.length; i++)
			{
				var sketchObj:Object = com.adobe.serialization.json.JSON.decode(arr[i], true);
				
				//get sketchID and versionNo.
				var tempSketchName:String = sketchObj.data.fileName;
				var tempSketchId:String = sketchObj.data.sketchId;
				var tempSketchVer:String = sketchObj.data.version;
				
				if (tempSketchName == name)
				{
					tempSketchName = "";
					tempSketchId = "";
					tempSketchVer = "";
					rawData = arr[i];
				}
			}
			
			return rawData;
		}
		
		public static function hasToSyncSketches(arrStr:String):Boolean
		{
			var hasToSync:Boolean = false;
			
			if(arrStr)
			{
				var obj:Object = com.adobe.serialization.json.JSON.decode(arrStr, true);
				var arr:Array = [];
				arr = (obj.entities as Array);
				
				for(var i:int=0; i<arr.length; i++)
				{
					if(arr[i].data.sketchId == "-1")
					{
						hasToSync = true;
						break;
					}
				}
			}
			
			return hasToSync;
		}
		
		public static function initializeAutoSaveSketchName(arrUserSketch:KSketch_UserSketches):int
		{
			var autoSaveCounter:int = 0;
			var sortBy:String = "fileName";
			var arrTemp:ArrayCollection = arrUserSketch.getUserSketchArray(sortBy); 
			
			for(var i:int = 0; i<arrTemp.length; i++)
			{
				if(arrTemp.getItemAt(i).name.indexOf("My Sketch") >= 0)
				{
					var tempFilename:String = arrTemp.getItemAt(i).name;
					var trimFilename:String = tempFilename.replace("My Sketch", ""); 
					var isANumber:Boolean = !isNaN(Number(trimFilename));
					
					if(isANumber)
					{
						var tempNo:int = int(trimFilename);
						if(tempNo > autoSaveCounter)
							autoSaveCounter = tempNo;	
					}
				}
			}
			
			return autoSaveCounter;
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