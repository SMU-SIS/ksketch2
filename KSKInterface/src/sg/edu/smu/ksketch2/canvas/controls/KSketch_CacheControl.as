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

	import flash.net.SharedObject;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import data.KSketch_DataListItem;
	import data.KSketch_ListItem;
	
	import org.as3commons.collections.SortedList;
	
	import sg.edu.smu.ksketch2.KSketchWebLinks;
	import sg.edu.smu.ksketch2.canvas.components.view.KSketch_HomeView;

	public class KSketch_CacheControl
	{
		//class variables
		public var informationArr:Array;
		private var _selectedSketch:Array;
		private var _homeView:KSketch_HomeView;
		private var _mySO:SharedObject = SharedObject.getLocal("mydata");
		private var _httpService:HTTPService = new HTTPService();
		private var _webList:SortedList = new SortedList();
		private var _isData:Boolean = false;
		
		
		public function KSketch_CacheControl(homeView:KSketch_HomeView)
		{
			_homeView = homeView;
			
			informationArr = new Array(4);
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
			
			_httpService.resultFormat = "text";
		}
		
		public function get user():Object
		{
			return com.adobe.serialization.json.JSON.decode(String(informationArr[0]),true);
		}
		
		public function set user(userObject:Object):void
		{
			informationArr[0] = com.adobe.serialization.json.JSON.encode(userObject);
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
			
			informationArr[0] = userObject;
		}
		
		public function get cachedList():SortedList
		{
			return informationArr[1];
		}
		
		public function retrieveAllSketchList():SortedList
		{
			_isData = false;
			var result:Object;
			result = syncList(cachedList,_webList);
			//TODO: Handle toBeSavedList here
			//result.toBeSavedList
			return result.syncedList;

		}
		// Probably the most efficient way of syncing the sketch list in the cache and
		// sketch list from the web
		private function syncList(cacheList:SortedList,webList:SortedList): Object{
			var allList:SortedList = new SortedList();
			var updateList:SortedList = new SortedList();
			var ret:Object = new Object();
			var x:int =0 , y:int = 0;
			while((x < cacheList.size) || (y < webList.size)){
				if(y >= webList.size) {
					if(!cacheList.itemAt(x).isSaved) {
						updateList.add(cacheList.itemAt(x));
						allList.add(cacheList.itemAt(x));
					}
					x += 1;
				} else if (x >= cacheList.size) {
					allList.add(webList.itemAt(y));
					y+=1;
				} else if (cacheList.itemAt(x).compare(webList.itemAt(y)) == -1) {
					if(!cacheList.itemAt(x).isSaved) {
						updateList.add(cacheList.itemAt(x));
					}
					x += 1;
				} else if (cacheList.itemAt(x).compare(webList.itemAt(y)) == 1) {
					allList.add(webList.itemAt(y));
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
		
		public function retrieveWebSketchList():void
		{
			if(user.id != "n.a" && (user.status.indexOf("success") >= 0))
			{
				//make web request to pull list of sketches
				var parameter:String = "{\"sketchID\":[],\"userid\":" + user.id + ",\"token\":\""+user.token +"\"}";
				
				_httpService.removeEventListener(ResultEvent.RESULT, dataResultHandler);
				_httpService.addEventListener(FaultEvent.FAULT, faultHandler);
				_httpService.addEventListener(ResultEvent.RESULT, listResultHandler);
				
				_httpService.url = KSketchWebLinks.jsonurlSketch + "/" + parameter;
				_httpService.send();
			}
			else
			{
				_homeView.displaySketchList(null);
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
				_httpService.addEventListener(FaultEvent.FAULT, faultHandler);
				_httpService.addEventListener(ResultEvent.RESULT, dataResultHandler);
				
				_httpService.url = KSketchWebLinks.jsonurlSketchXML + "/" + sketchId + "/" + version + "/" + user.id;
				_httpService.send();
			}
			else
			{
				//loop through cachedSketchList for the object
				//then retrieve object from same index location in the cachedSketchData
				//_sketchData = "";
			}
		}	
		
		private function listResultHandler(event:ResultEvent):void
		{
			//TODO: RAM check for negative cases
			var rawData:String = String(event.result);
			var resultObj:Object = com.adobe.serialization.json.JSON.decode(rawData,true);
			
			var tempArr:Array = (resultObj.entities as Array);
			for each(var tempObj:Object in tempArr)
			{
				var _ksketchListItem:KSketch_ListItem = new KSketch_ListItem();
				_ksketchListItem.fromWebData(tempObj);
				_webList.add(_ksketchListItem);
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
		
		private function faultHandler(event:FaultEvent):void
		{
			//TODO: RAM check for negative cases
			_homeView.displaySketchList(null);
		}
		
		public function reset():void
		{
			informationArr[0] = null;
			informationArr[1] = null;
			informationArr[2] = null;
			informationArr[3] = null;
		}
	}
}