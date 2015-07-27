/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.canvas.controls
{
	import com.adobe.serialization.json.JSON;

import flash.events.HTTPStatusEvent;

import flash.net.SharedObject;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import data.KSketch_DataListItem;
	import data.KSketch_ListItem;
	
	import org.as3commons.collections.SortedList;
	import org.as3commons.collections.framework.IComparator;
	import org.as3commons.collections.framework.IIterator;

	import sg.edu.smu.ksketch2.KSketchWebLinks;
	import sg.edu.smu.ksketch2.canvas.components.view.KSketch_HomeView;

	public class KSketch_CacheControl
	{
		//class variables
		private var _selectedSketch:Array;
		private var _homeView:KSketch_HomeView;
		private var _mySO:SharedObject = SharedObject.getLocal("mydata");
		private var _httpService:HTTPService = new HTTPService();
		private var _deleteService:HTTPService = new HTTPService();
		private var _webList:SortedList = new SortedList(new KSketch_ListItem() as IComparator);
		private var _isData:Boolean = false;
		
		
		public function KSketch_CacheControl(homeView:KSketch_HomeView)
		{
			_homeView = homeView;
			
			/*informationArr = new Array(4);
			informationArr[0] = null;	//user: user object
			informationArr[1] = null;	//cachedSketchList: cached sketch list
			informationArr[2] = null;	//syncSketchList: cached sketch list to sync with web
			informationArr[3] = null;	//syncSketchList: cached sketch list to sync with web

			if (_mySO.data) 
			{
				if(_mySO.data.user)
				{
					informationArr[0] = _mySO.data.user;
				}

				if(_mySO.data.cachedSketchList)
				{
					informationArr[1] = _mySO.data.cachedSketchList;
				}
				else
				{
					informationArr[1] = new SortedList();
				}	
			}
			*/
			_httpService.resultFormat = "text";
			_deleteService.resultFormat = "text";
		}
		
		public function get user():Object
		{
			if(_mySO.data.user) {
				return com.adobe.serialization.json.JSON.decode(String(_mySO.data.user), true);
			} else {
				return null;
			}
		}
		
		public function set user(userObject:Object):void
		{
			_mySO.data.user = com.adobe.serialization.json.JSON.encode(userObject);
		}

		public function get deletedSketches():Array
		{
			if(_mySO.data.deletedSketches){
				return com.adobe.serialization.json.JSON.decode(String(_mySO.data.deletedSketches), true);
			} else {
				return new Array();
			}
		}

		public function set deletedSketches(delArr:Array):void
		{
			_mySO.data.deletedSketches = com.adobe.serialization.json.JSON.encode(delArr);
		}
		
		/** set user as anonymous **/
		public function newUser():void
		{
			var userObject:Object = new Object();
			userObject.status = "failed";
			userObject.u_realname = "Anonymous";
			userObject.u_logincount = "n.a";
			userObject.u_lastlogin = "n.a";
			userObject.u_isadmin = "n.a";
			userObject.id = "n.a";
			userObject.g_hash = "n.a";
			userObject.u_name = "Anonymous";
			userObject.u_created = "n.a";
			userObject.u_login = "n.a";
			userObject.u_isactive = "n.a";
			userObject.u_version = "n.a";
			userObject.u_email = "n.a";

			this.user = userObject;
		}
		
		public function get cachedList():SortedList
		{
			if(_mySO.data.cachedList == null){
				return new SortedList(new KSketch_ListItem() as IComparator);
			} else {
				var list: SortedList = new SortedList(new KSketch_ListItem() as IComparator);
				var arr:Array = com.adobe.serialization.json.JSON.decode(_mySO.data.cachedList,true);
				for(var i=0; i<arr.length; i++) {
					var obj:KSketch_ListItem = new KSketch_ListItem();
					obj.fromCache(arr[i]);
					list.add(obj);
				}
				return list;
			}
		}

		public function set cachedList(list:SortedList){
			var iter:IIterator = list.iterator();
			var arr:Array = new Array();
			while(iter.hasNext()){
				arr.push(iter.next());
			}
			_mySO.data.cachedList = com.adobe.serialization.json.JSON.encode(arr);
		}

		public function get cachedDocuments():Array {
			if(_mySO.data.cachedDocuments == null){
				return null
			} else {
				return com.adobe.serialization.json.JSON.decode(_mySO.data.cachedDocuments, true) as Array;
			}
		}

		public function set cachedDocuments(list:Array){
			_mySO.data.cachedDocuments = com.adobe.serialization.json.JSON.encode(list);
		}

		public function retrieveAllSketchList(fromWeb:Boolean=true):SortedList
		{
			_isData = false;
			var result:Object;
			result = syncList(cachedList,_webList,fromWeb);
			cachedList = result.syncedList;
			//TODO: Handle toBeSavedList here
			//result.toBeSavedList
			return result.syncedList;

		}
		// Probably the most efficient way of syncing the sketch list in the cache and
		// sketch list from the web
		private function syncList(cacheList:SortedList,webList:SortedList,fromWeb:Boolean=true): Object {
			var comparator:IComparator = new KSketch_ListItem();
			var allList:SortedList = new SortedList(comparator);
			var updateList:SortedList = new SortedList(comparator);

			var ret:Object = new Object();
			var x:int = 0, y:int = 0;
			while ((x < cacheList.size) || (y < webList.size)) {
				if (y >= webList.size) {
					if (!cacheList.itemAt(x).isSaved) {
						updateList.add(cacheList.itemAt(x));
						allList.add(cacheList.itemAt(x));
					}
					x += 1;
				} else if (x >= cacheList.size) {
					allList.add(webList.itemAt(y));
					y += 1;
				} else if (comparator.compare(cacheList.itemAt(x),webList.itemAt(y)) == -1) {
					if (!cacheList.itemAt(x).isSaved) {
						updateList.add(cacheList.itemAt(x));
					}
					x += 1;
				} else if (comparator.compare(cacheList.itemAt(x),webList.itemAt(y)) == 1) {
					if(isDeletedSketch(webList.itemAt(y).sketchId)) {
						if(fromWeb) {
							deleteSketchOnWeb(isDeletedSketch(webList.itemAt(y).sketchId));
						}
					}else {
						allList.add(webList.itemAt(y));
					}
					y += 1;
				} else {
					allList.add(webList.itemAt(y));
					x += 1;
					y += 1;
				}
			}
			ret.syncedList = allList;
			ret.toBeSavedList = updateList;
			return ret;
		}
		
		public function retrieveWebSketchList(fromWeb:Boolean = true):void
		{
			if(user.id != "n.a" && (user.status.indexOf("success") >= 0))
			{
				if(fromWeb) {
					//make web request to pull list of sketches
					var parameter:String = "{\"sketchID\":[],\"userid\":" + user.id + ",\"token\":\"" + user.token + "\"}";

					_httpService.removeEventListener(ResultEvent.RESULT, dataResultHandler);
					_httpService.addEventListener(FaultEvent.FAULT, faultHandler);
					_httpService.addEventListener(ResultEvent.RESULT, listResultHandler);

					_httpService.url = KSketchWebLinks.jsonurlSketch + "/" + parameter;
					_httpService.send();
				} else {
					_homeView.displaySketchList(retrieveAllSketchList(fromWeb));
				}
			}
			else
			{
				_homeView.displaySketchList(cachedList);
			}
		}
		
		public function retrieveSketchData(sketchName:String, sketchId:String, version:String):void
		{
			_selectedSketch = new Array(3);
			_selectedSketch[0] = sketchName;
			_selectedSketch[1] = sketchId;
			_selectedSketch[2] = version;
			
			if(user.id != "n.a" && (user.status.indexOf("success") >= 0))
			{
				if(user.id != "n.a" && (user.status.indexOf("success") >= 0))
				{
					version = "-1";	//set to -1 to pull the latest version
				}	
				
				_httpService.removeEventListener(ResultEvent.RESULT, listResultHandler);
				_httpService.addEventListener(FaultEvent.FAULT, dataFaultHandler);
				_httpService.addEventListener(ResultEvent.RESULT, dataResultHandler);
				
				_httpService.url = KSketchWebLinks.jsonurlSketchXML + "/" + sketchId + "/" + version + "/" + user.id;
				_httpService.send();
			}
			else
			{
				var sketchData:KSketch_DataListItem = null;
				if(_selectedSketch[1] == "" || _selectedSketch[1]== -1){
					var arr:Array = cachedDocuments;
					if(arr !=null){
						for(var i:int=0;i<arr.length;i++){
							if(arr[i].fileName = _selectedSketch[0]){
								sketchData = new KSketch_DataListItem(arr[i].fileData, arr[i].fileName, arr[i].originalName,
										arr[i].owner_id, arr[i].modified, arr[i].changeDescription,
										arr[i].sketchId, int(arr[i].version));
								_homeView.displaySketchData(sketchData, _selectedSketch);
								return;
							}
						}
					}
				}
			}
		}	
		
		private function listResultHandler(event:ResultEvent):void
		{
			var rawData:String = String(event.result);
			var resultObj:Object = com.adobe.serialization.json.JSON.decode(rawData,true);
			_webList.clear();
			var tempArr:Array = (resultObj.entities as Array);
			if(resultObj) {
				if (resultObj.hasOwnProperty("status")) {
					if (resultObj.status == "session_expired") {
						_homeView.handleExpiredSession();
					}
				}else {
					for each(var tempObj:Object in tempArr) {
						var _ksketchListItem:KSketch_ListItem = new KSketch_ListItem();
						_ksketchListItem.fromWebData(tempObj);
						_webList.add(_ksketchListItem);
					}
				}
			}
			_homeView.displaySketchList(retrieveAllSketchList());
		}
		
		private function dataResultHandler(event:ResultEvent):void
		{
			var rawData:String = String(event.result);
			var resultObj:Object = com.adobe.serialization.json.JSON.decode(rawData,true);
			var sketchData:KSketch_DataListItem = null;
			
			if(resultObj.data.fileData)
			{
				sketchData = new KSketch_DataListItem(resultObj.data.fileData, resultObj.data.fileName, resultObj.data.originalName, 
													  resultObj.data.owner_id, resultObj.modified, resultObj.data.changeDescription, 
													  resultObj.data.sketchId, resultObj.data.version);
			}
			
			_homeView.displaySketchData(sketchData, _selectedSketch);
		}

		private function dataFaultHandler(event:FaultEvent):void
		{
			var sketchData:KSketch_DataListItem = null;
			if(_selectedSketch[1] == "" || _selectedSketch[1]== -1){
				var arr:Array = cachedDocuments;
				if(arr !=null){
					for(var i:int=0;i<arr.length;i++){
						if(arr[i].fileName = _selectedSketch[0]){
							sketchData = new KSketch_DataListItem(arr[i].fileData, arr[i].fileName, arr[i].originalName,
									arr[i].owner_id, arr[i].modified, arr[i].changeDescription,
									arr[i].sketchId, int(arr[i].version));
							_homeView.displaySketchData(sketchData, _selectedSketch);
						}
					}
				}
			}
		}

		private function faultHandler(event:FaultEvent):void
		{
			//TODO: RAM check for negative cases
			_homeView.displaySketchList(cachedList);
		}
		
		public function reset():void
		{
			_mySO.clear();
		}

		public function addToCache(sketchObj: Object):void
		{
			var arr:Array = cachedDocuments;
			if(arr == null){
				arr = new Array();
			}
			arr.push(sketchObj);
			cachedDocuments = arr;
			var list:SortedList = cachedList;
			var obj:KSketch_ListItem = new KSketch_ListItem();
			obj.fromCache(sketchObj);
			list.add(obj);
			cachedList = list;
		}

		public function updateSketchDocument(uniqueId:String, sketchId:Number){
			var arr:Array = cachedDocuments;
			for(var i:int=0;i<arr.length;i++){
				if(arr[i].uniqueId == uniqueId){
					arr[i].sketchId = sketchId;
					break;
				}
			}
			cachedDocuments = arr;
		}

		public function isLoggedIn():Boolean
		{
			if(user.id != "n.a") {
				return true;
			} else {
				return false;
			}

		}

		public function unsavedSketchExist():Boolean {
			var list:SortedList = cachedList;
			for(var i:int=0;i<list.size;i++) {
				if((list.itemAt(i) as KSketch_ListItem).isSaved == false)
					return true;
			}
			return false;
		}
		public function deleteSketchOnWeb (sketchID:Number) {
			var objToSend:Object = new Object();
			objToSend["sketchid"] = com.adobe.serialization.json.JSON.encode(sketchID);
			objToSend["userid"] = user.id;
			objToSend["token"] = user.token;

			_deleteService.url = KSketchWebLinks.jsonurlDeleteSketch;
			_deleteService.send(objToSend);
			_deleteService.addEventListener(ResultEvent.RESULT, deleteResultHandler(objToSend));
			_deleteService.addEventListener(FaultEvent.FAULT, deleteFaultHandler(objToSend));
		}

		function deleteResultHandler(obj:Object):Function {
			return function(event:ResultEvent):void {
				var delArr:Array  = deletedSketches;
				for(var i:int=0; i < delArr.length; i++) {
					if(delArr[i] == obj["sketchid"])
						delArr.splice(i,1);
				}
				deletedSketches = delArr;
			};
		}

		function deleteFaultHandler(obj:Object):Function {
			return function(event:FaultEvent):void {
				return; //Do nothing
			};
		}

		private function isDeletedSketch(sketchID:Number){
			var arr:Array = deletedSketches;
			for(var i:int =0; i<arr.length;i++){
				if(sketchID == arr[i])
					return true;
			}
			return false;
		}
		public function deleteFromCache(sketchID:String, fileName:String) {
			if (_mySO.data.cachedList != null) {
				var arr:Array = com.adobe.serialization.json.JSON.decode(_mySO.data.cachedList, true);
				for (var i:int = 0; i < arr.length; i++) {
					var obj:Object = arr[i];
					if ((obj.sketchId == sketchID) && (obj.fileName == fileName)) {
						arr.splice(i, 1);
						break;
					}
				}
				_mySO.data.cachedList = com.adobe.serialization.json.JSON.encode(arr);
			}
			if (_mySO.data.cachedDocuments){
				var arr:Array = com.adobe.serialization.json.JSON.decode(_mySO.data.cachedDocuments, true);
				for (var i:int = 0; i < arr.length; i++) {
					var obj:Object = arr[i];
					if ((obj.sketchId == sketchID) && (obj.fileName == fileName))
						arr.splice(i, 1);
				}
				_mySO.data.cachedDocuments = com.adobe.serialization.json.JSON.encode(arr);
			}
		}
		public function deleteSketch(sketchID:String,version:Number,fileName:String) {
			if((sketchID == "-1")||(sketchID == "")) {
				this.deleteFromCache(sketchID,fileName);
			} else {
				var delArr:Array  = deletedSketches;
				delArr.push(Number(sketchID));
				deletedSketches = delArr;
				deleteSketchOnWeb(Number(sketchID));
				this.deleteFromCache(sketchID,fileName);
			}
			_homeView.refresh(false);
		}
	}
}