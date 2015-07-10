package sg.edu.smu.ksketch2.canvas.controls
{
	import com.adobe.serialization.json.JSON;
	
	import flash.net.SharedObject;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import data.KSketch_ListItem;
	
	import org.as3commons.collections.SortedList;
	
	import sg.edu.smu.ksketch2.KSketchWebLinks;

	public class KSketch_CacheControl
	{
		//class variables
		public var informationArr:Array;
		private var _mySO:SharedObject = SharedObject.getLocal("mydata");
		private var httpService:HTTPService = new HTTPService();
		private var webList:SortedList = new SortedList();
		
		public function KSketch_CacheControl()
		{
			informationArr = new Array(2);
			informationArr[0] = null;	//user: user object
			informationArr[1] = null;	//cachedSketchList: cached sketch list
			informationArr[2] = null;	//webSketchList: web sketch list
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
				
				if(_mySO.data.webSketchList)
				{
					informationArr[0] = _mySO.data.webSketchList;
				}
				
				if(_mySO.data.syncSketchList)
				{
					informationArr[1] = _mySO.data.syncSketchList;
				}
			}
			
			httpService.addEventListener(FaultEvent.FAULT, faultHandler);
			httpService.addEventListener(ResultEvent.RESULT, resultHandler);
		}
		
		public function get user():Object
		{
			return informationArr[0];
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
		
		/** set user based on received user object **/
		public function set user(userObject:Object):void
		{
			informationArr[0] = userObject;
		}
		
		public function retrieveAllSketchList():void
		{
			var allList:SortedList = new SortedList();
			
			
			//var webSketchArr:Array = retrieveUserSketchList();
		}
		
		public function retrieveWebSketchList():void
		{
			if(user.id != "n.a" && (user.status.indexOf("success") >= 0))
			{
				//make web request to pull list of sketches
				var parameter:String = "{\"sketchID\":[],\"userid\":" + user.id + "}";
				
				httpService.url = KSketchWebLinks.jsonurlSketch + "/" + parameter;
				httpService.send();
			}
		}
		
		private function resultHandler(event:ResultEvent):Array
		{
			//TODO: RAM check for negative cases
			var rawData:String = String(event.result);
			var resultObj:Object = com.adobe.serialization.json.JSON.decode(rawData,true);
			
			var tempArr:Array = (resultObj.entities as Array);
			for each(var tempObj:Object in tempArr)
			{
				var _ksketchListItem:KSketch_ListItem = new KSketch_ListItem();
				_ksketchListItem.fromWebData(tempObj);
				webList.add(_ksketchListItem);
			}
		}
		
		private function faultHandler(event:FaultEvent):void
		{
			//TODO: RAM check for negative cases
		}
	}
}