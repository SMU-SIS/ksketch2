package sg.edu.smu.ksketch2
{
	import com.adobe.serialization.json.JSON;
	
	import mx.collections.ArrayCollection;
	
	import spark.utils.DataItem;
	
	import sg.edu.smu.ksketch2.utils.SortingFunctions;
	
	[Bindable]
	public class KSketch_UserSketches
	{
		private var keys:Object = {};
		
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
		
		public function createArray(arr:ArrayCollection, id:String):void
		{
			//sketch image, name, description, date
			for (var i:int=0; i<arr.length; i++)
			{
				//check if the owner id is the same as logged-in id
				var tempId:String = arr.getItemAt(i).owner_id;
				
				if(tempId == id || tempId == "n.a")
				{
					var tempItem:DataItem = new DataItem();
					tempItem.name = arr.getItemAt(i).fileName;
					tempItem.date = arr.getItemAt(i).created;
					tempItem.sketchId = arr.getItemAt(i).sketchId;
					tempItem.version = arr.getItemAt(i).version;
					tempItem.originalName = arr.getItemAt(i).originalName;
					tempItem.originalVersion = arr.getItemAt(i).originalVersion;
					tempItem.image = arr.getItemAt(i).thumbnailData;
					
					arrDG.addItem(tempItem);
				}
			}
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
		
		public function initializeAutoSaveSketchName(arrUserSketch:KSketch_UserSketches):int
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
	}	
}