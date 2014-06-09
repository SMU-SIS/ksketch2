package sg.edu.smu.ksketch2.canvas.controls
{
	import com.adobe.serialization.json.JSON;
	
	import mx.collections.ArrayCollection;
	
	public class KFileControl
	{
		public static const DELETE_CACHE:String = "deleteFromCache";
		public static const DELETE_WEB:String = "deleteFromWeb";
		
		public static const ADD_SAVE_CACHE:String = "save";
		public static const ADD_SAVE_WEB:String = "saveCurrentFromWeb";
		public static const ADD_SYNC:String = "sync";
		
		//main variable to store information
		//[0] = user information
		//[1] = list of sketches
		//[3] = sketch documents
		private var informationArr:Array;
		private var sync_sketchArr:ArrayCollection = new ArrayCollection();
		private var sync_sketchDocArr:ArrayCollection = new ArrayCollection();
		
		public function addNewSketchDocument(record:String, obj:Object, type:String):ArrayCollection
		{
			//get array of sketch documents from informationArr[1]
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
						
						if(type == ADD_SAVE_WEB)
							overwrite = true;
						else if (type == ADD_SYNC)
						{
							obj.fileData = arrObj.fileData;
							overwrite = true;
						}
						else
						{
							var datePrev:Date = new Date();
							datePrev.setTime(Date.parse(arrObj.date));
							
							var dateNext:Date = new Date();
							dateNext.setTime(Date.parse(obj.date));
							
							//if it is a more recent sketch, overwrite
							if(dateNext.getTime() > datePrev.getTime())
								overwrite = true;
							
							//if both are same versions and cached sketch doesn't contain any fileData, overwrite
							if(obj.version == arrObj.version)
							{
								if(arrObj.fileData == null)
									overwrite = true;	
								
								if(obj.save == -1)
									overwrite = true;
								
								if(obj.save == 0)
								{
									if(obj.revert == 0)
										overwrite = true;
								}
							}
							
							//if a save has been made, overwrite
							if(obj.save == 0)
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
		
		public function deleteSketchDocument(record:String, obj:Object, type:String):ArrayCollection
		{
			//get array of sketch documents from informationArr[1]
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
			
			if(sketchExist(arr, obj.fileName, obj.sketchId))
			{
				for(var i:int=0; i<arr.length; i++)
				{
					var arrObj:Object = arr.getItemAt(i);
					if(arrObj.fileName == obj.fileName && arrObj.sketchId == obj.sketchId)
					{
						if(type == DELETE_WEB)
						{
							obj.deleteFlag = 1;
							arr.removeItemAt(i);
							arr.addItem(obj);
						}
						else if (type == DELETE_CACHE)
						{
							arr.removeItemAt(i);
						}
					}
				}
			}
			
			return arr;
		}

		public function solveDiscrepancy(cacheStr:String, webStr:String):String
		{
			var newInformationArr:String;
			
			//get sketches from cache
			var cacheArr_sketch:ArrayCollection;
			cacheArr_sketch = convertStringToArrayCollection(cacheStr);
			
			if(!cacheArr_sketch)
				cacheArr_sketch = new ArrayCollection();
			
			//get sketches from the web
			var webArr_sketch:ArrayCollection;
			webArr_sketch = convertStringToArrayCollection(webStr);
			
			//compare web and mobile objects
			//if mobile is out of date, then replace with web object
			if(webArr_sketch)
			{
				for(var i:int=0; i<webArr_sketch.length; i++)
				{
					var obj:Object = webArr_sketch.getItemAt(i);
					var index:int = sketchExistIndex(cacheArr_sketch, obj.fileName, obj.sketchId);
					
					if(index != -1)
					{
						var cacheObj:Object = cacheArr_sketch.getItemAt(index);
						
						var datePrev:Date = new Date();
						datePrev.setTime(Date.parse(cacheObj.date));
						
						var dateNext:Date = new Date();
						dateNext.setTime(Date.parse(obj.date));
						
						if(dateNext.getTime() > datePrev.getTime())
						{
							if(cacheObj.fileData != null && obj.fileData == null)// && cacheObj.version == "")
								obj.fileData = cacheObj.fileData;	
							
							cacheArr_sketch.removeItemAt(index);
							obj.save = 0;
							cacheArr_sketch.addItem(obj);
						}
						
						if(dateNext.getTime() == datePrev.getTime())
						{
							if(cacheObj.fileData != null)
							{
								obj.fileData = cacheObj.fileData;
							
								cacheArr_sketch.removeItemAt(index);
								obj.save = 0;
								cacheArr_sketch.addItem(obj);
							}
						}
					}
					else
					{
						obj.save = 0;
						cacheArr_sketch.addItem(obj);
					}
					
				}
			}
			
			var docObj:Object = new Object();
			if(cacheArr_sketch)															
				docObj.sketches = cacheArr_sketch.source;
			else
				docObj.sketches = null;
			
			newInformationArr = com.adobe.serialization.json.JSON.encode(docObj);
			
			if(cacheArr_sketch)
				cacheArr_sketch.removeAll();
			
			if(webArr_sketch)
				webArr_sketch.removeAll();	
				
			return newInformationArr;
		}
		
		public function getUserObject(userStr:String):Object
		{
			var obj:Object;
			
			if(userStr)
				obj = com.adobe.serialization.json.JSON.decode(userStr, true);
			
			return obj;
		}
		
		public function getSketchArr(sketchString:String):ArrayCollection
		{
			var sketchArr:ArrayCollection;
			
			if(sketchString)
			{
				var sketchObj:Object = com.adobe.serialization.json.JSON.decode(sketchString, true);
				var tempArr:Array = (sketchObj.sketches as Array);
				
				if(tempArr)
				{
					sketchArr = convertArrayToArrayCollection(tempArr);
				}
			}
			
			return sketchArr;
		}
		
		public function getSyncSketchObjects(cacheStr:String, deleteSketch:Boolean):ArrayCollection
		{
			var sync_sketchArr:ArrayCollection = new ArrayCollection();
			
			//get sketches from cache
			var cacheArr_sketch:ArrayCollection;
			cacheArr_sketch = convertStringToArrayCollection(cacheStr);
			
			//if there are new objects in cache that don't exist in the web, add them to sync_sketchArr
			if(cacheArr_sketch)
			{
				var selectedDoc:Object;
				for each(var obj:Object in cacheArr_sketch)
				{
					if(deleteSketch)
					{
						if(obj.deleteFlag == 1)
						{
							if(!sketchExist(sync_sketchArr, obj.fileName, obj.sketchId))
								sync_sketchArr.addItem(obj);
						}
					}
					else
					{
						if(obj.save == -1)
						{
							if(!sketchExist(sync_sketchArr, obj.fileName, obj.sketchId))
								sync_sketchArr.addItem(obj);
						}
					}
				}
			}
			return sync_sketchArr;
		}
		
		public function convertArrayToArrayCollection(arr:Array):ArrayCollection
		{
			var arrColl:ArrayCollection = new ArrayCollection();
			
			for(var i:int=0; i<arr.length; i++)
				arrColl.addItem(arr[i]);
			
			return arrColl;
		}
		
		public function convertStringToArrayCollection(arrStr:String):ArrayCollection
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
		public function sketchExist(arr:*, fileName:String, sketchId:String):Boolean
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
		
		public function sketchExistIndex(arr:*, fileName:String, sketchId:String):int
		{
			var index:int = -1;
			var i:int;
			
			if(arr)
			{
				if(arr is Array)
				{
					for(i=0; i<arr.length; i++)
					{
						if(arr[i].fileName == fileName)
						{
							if(arr[i].sketchId == sketchId)
							{
								index = i;
								break;	
							}
							else if(arr[i].sketchId != sketchId && arr[i].sketchId == "")
							{
								if(arr[i].save == 0)
								{
									index = i;
									break;
								}
							}
							
						}
					}
				}
				else if(arr is ArrayCollection)
				{
					for(i=0; i<arr.length; i++)
					{
						if(arr.getItemAt(i).fileName == fileName)
						{
							if(arr.getItemAt(i).sketchId == sketchId)
							{
								index = i;
								break;	
							}
							else if(arr.getItemAt(i).sketchId != sketchId && arr.getItemAt(i).sketchId == "")
							{
								if(arr.getItemAt(i).save == 0)
								{
									index = i;
									break;
								}
							}
							
						}
					}
				}
			}
			
			return index;
		}
		
		public function unsavedSketchExist(cachedStr:String):Boolean
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
					if(obj.save == -1)
					{
						exist = true;
						break;
					}
					
					if(obj.deleteFlag == 1)
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