/**
 * Copyright 2010-2015 Singapore Management University
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
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
		private var _autoSaveCounter:int = 0;
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
					tempItem.lowerFileName = arr.getItemAt(i).lowerFileName;
					
					if(!arr.getItemAt(i).deleteFlag)
					{
						arrDG.addItem(tempItem);
					}	
				}
				
				//initialize the auto save counter
				if(arr.getItemAt(i).fileName.indexOf("My Sketch") >= 0)
				{
					var tempFilename:String = arr.getItemAt(i).fileName;
					var trimFilename:String = tempFilename.replace("My Sketch", ""); 
					var isANumber:Boolean = !isNaN(Number(trimFilename));
					
					if(isANumber)
					{
						var tempNo:int = int(trimFilename);
						if(tempNo > _autoSaveCounter)
							_autoSaveCounter = tempNo;	
					}
				}
			}
		}
		
		public function getUserSketchArray():ArrayCollection
		{
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
		
		public function get autoSaveCounter():int
		{
			return _autoSaveCounter;
		}
		
		public function set autoSaveCounter(num:int):void
		{
			_autoSaveCounter = num;
		}
	}	
}