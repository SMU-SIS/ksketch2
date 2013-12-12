package sg.edu.smu.ksketch2.canvas.controls
{
	import com.adobe.serialization.json.JSON;
	
	import mx.collections.ArrayCollection;
	
	public class KFileControl
	{
		//main variable to store information
		//[0] = user information
		//[1] = list of sketches
		//[3] = sketch documents
		private var informationArr:Array;
		private var sync_sketchArr:ArrayCollection = new ArrayCollection();
		private var sync_sketchDocArr:ArrayCollection = new ArrayCollection();
		
		public static function addNewSketchDocument(record:String, obj:Object):ArrayCollection
		{
			//get array of sketch documents from informationArr[2]
			//sketchDocObj = {documents:[]}
			var arr:ArrayCollection;
			if(record)
			{
				var tempObj:Object = com.adobe.serialization.json.JSON.decode(record, true);
				var tempArr:Array = (tempObj.sketches as Array);
				
				if(tempArr)
					arr = convertArrayToArrayCollection(tempArr);
			}
			
			//overwrite existing document with the new objDoc
			if(!arr)
				arr = new ArrayCollection();
			
			if(!sketchExist(arr, obj.fileName, obj.sketchId))
				arr.addItem(obj);	
			else
			{
				for(var i:int=0; i<arr.length; i++)
				{
					var arrObj:Object = arr.getItemAt(i);
					if(arrObj.fileName == obj.fileName && arrObj.sketchId == obj.sketchId)
					{
						var overwrite:Boolean = false;
						
						var datePrev:Date = new Date();
						datePrev.setTime(Date.parse(arrObj.date));
					
						var dateNext:Date = new Date();
						dateNext.setTime(Date.parse(obj.date));
						
						if(dateNext.getTime() > datePrev.getTime())
							overwrite = true;
						else if(obj.version == arrObj.version)
						{
							if(arrObj.fileData == null)
								overwrite = true;	
						}
						
						if(overwrite)
						{
							arr.removeItemAt(i);
							arr.addItem(obj);
						}
					}
				}
			}
			
			return arr;
		}

		public static function getUserObject(userStr:String):Object
		{
			var obj:Object;
			
			if(userStr)
				obj = com.adobe.serialization.json.JSON.decode(userStr, true);
			
			return obj;
		}
		
		public static function getSketchArr(sketchString:String):ArrayCollection
		{
			var sketchArr:ArrayCollection;
			
			if(sketchString)
			{
				var sketchObj:Object = com.adobe.serialization.json.JSON.decode(sketchString, true);
				var tempArr:Array = (sketchObj.sketches as Array);
				
				if(tempArr)
					sketchArr = convertArrayToArrayCollection(tempArr);
			}
			
			return sketchArr;
		}
		
		public static function getSyncSketchList(cacheStr:String, webStr:String):ArrayCollection
		{
			var sync_sketchArr:ArrayCollection = new ArrayCollection();
			
			var tempArr:Array;
			var tempObj:Object;
			
			//get sketches from cache
			var cacheArr_sketch:ArrayCollection;
			cacheArr_sketch = convertStringToArrayCollection(cacheStr);
			
			//get sketches from the web
			var webArr_sketch:ArrayCollection;
			webArr_sketch = convertStringToArrayCollection(webStr);
			
			//if there are new objects in cache that don't exist in the web, add them to sync_sketchArr
			var selectedDoc:Object;
			if(cacheArr_sketch)
			{
				for each(var obj:Object in cacheArr_sketch)
				{
					//if it does not exist in new_sketchArr
					if(!sketchExist(webArr_sketch, obj.fileName, obj.sketchId))
						sync_sketchArr.addItem(obj);
				}
			}
			
			return sync_sketchArr;
		}
		
		public static function getSyncSketchObjects(cacheStr:String):ArrayCollection
		{
			var sync_sketchArr:ArrayCollection = new ArrayCollection();
			
			var tempArr:Array;
			var tempObj:Object;
			
			//get sketches from cache
			var cacheArr_sketch:ArrayCollection;
			cacheArr_sketch = convertStringToArrayCollection(cacheStr);
			
			//if there are new objects in cache that don't exist in the web, add them to sync_sketchArr
			if(cacheArr_sketch)
			{
				var selectedDoc:Object;
				for each(var obj:Object in cacheArr_sketch)
				{
					if(obj.sketchId == "")
					{
						if(!sketchExist(sync_sketchArr, obj.fileName, obj.sketchId))
							sync_sketchArr.addItem(obj);
					}
				}
			}
			return sync_sketchArr;
		}
		
		public static function convertArrayToArrayCollection(arr:Array):ArrayCollection
		{
			var arrColl:ArrayCollection = new ArrayCollection();
			
			for(var i:int=0; i<arr.length; i++)
				arrColl.addItem(arr[i]);
			
			return arrColl;
		}
		
		public static function convertStringToArrayCollection(arrStr:String):ArrayCollection
		{
			var arr:ArrayCollection;
			if(arrStr)
			{
				var tempObj:Object = com.adobe.serialization.json.JSON.decode(arrStr, true);
				var tempArr:Array = (tempObj.sketches as Array);	
				
				if(tempArr)
					arr = convertArrayToArrayCollection(tempArr);
			}
			return arr;
		}
		
		/**
		 * Check if filename falready exist in the exisiting record of sketches
		 */
		public static function sketchExist(arr:*, fileName:String, sketchId:String):Boolean
		{
			var exist:Boolean = false;
			var i:int;
			
			if(arr)
			{
				if(arr is Array)
				{
					for(i=0; i<arr.length; i++)
					{
						if(arr[i].fileName == fileName && arr[i].sketchId == sketchId)
						{
							exist = true;
							break;
						}
					}
				}
				else if(arr is ArrayCollection)
				{
					for(i=0; i<arr.length; i++)
					{
						if(arr.getItemAt(i).fileName == fileName && arr.getItemAt(i).sketchId == sketchId)
						{
							exist = true;
							break;
						}
					}
				}
			}
			
			return exist;
		}
		
		
		public static function unsavedSketchExist(cachedStr:String):Boolean
		{
			var exist:Boolean = false;
			var tempArr:Array;
			var tempObj:Object;
			
			//get sketches from cache
			var cacheArr_sketch:ArrayCollection;
			cacheArr_sketch = convertStringToArrayCollection(cachedStr);
			
			//if there are new objects in cache that don't exist in the web, add them to sync_sketchArr
			if(cacheArr_sketch)
			{
				var selectedDoc:Object;
				for each(var obj:Object in cacheArr_sketch)
				{
					if(obj.sketchId == "")
					{
						exist = true;
						break;
					}
				}
			}
			return exist;
		}
	}
}