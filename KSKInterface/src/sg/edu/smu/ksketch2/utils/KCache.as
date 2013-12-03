package sg.edu.smu.ksketch2.utils
{
	import com.adobe.serialization.json.JSON;
	
	import flash.net.SharedObject;
	
	import sg.edu.smu.ksketch2.canvas.mainView.KSketch_HomeView;

	public class KCache
	{
		public static var _mySO:SharedObject = SharedObject.getLocal("mydata");
		
		public function KCache()
		{
		}
		
		public static function initFromCache(isLoggedIn:Boolean, isConnected:Boolean, user:String):Array
		{
			var arrCache:Array = new Array(4);
			arrCache[0] = null;
			arrCache[1] = null;
			arrCache[2] = null;
			arrCache[3] = null;
			
			if (_mySO.data) {
				
				var userObj:Object = com.adobe.serialization.json.JSON.decode(user, true);
				if(_mySO.data.user && !isLoggedIn && userObj.u_realname == "Anonymous")
					arrCache[0] = _mySO.data.user;	
				else
					arrCache[0] = user;
				
				if(_mySO.data.userSketch)
					arrCache[1] = _mySO.data.userSketch;
				
				if(_mySO.data.sketchDocs)
					arrCache[2] = _mySO.data.sketchDocs;
			
				if(_mySO.data.retrieval)// && (isLoggedIn && userObj.u_realname != "Anonymous"))
					arrCache[3] = _mySO.data.retrieval;	
				else if(_mySO.data.retrieval)
					arrCache[3] = "CACHE";
				else if(!isConnected)
					arrCache[3] = "CACHE";
			}
			
			return arrCache;
		}
		
		public static function appendCacheSketch(originalList:String, sketchObj:Object):String
		{
			trace("sketchObj to save: " + com.adobe.serialization.json.JSON.encode(sketchObj));
			var userObj:Object = com.adobe.serialization.json.JSON.decode(KSketch_HomeView._viewArr[0]);
			
			var newObj:Object = new Object();
			if(originalList)
			{
				var prevObj:Object = com.adobe.serialization.json.JSON.decode(originalList);
				trace("existing array: " + prevObj.entities.length);
				newObj.count = prevObj.count;
				newObj.en_type = prevObj.en_type;
				newObj.method = prevObj.method;
				
				newObj.entities = new Array(prevObj.entities.length + 1);
				
				for(var i:int = 0; i<newObj.entities.length; i++)
				{
					if(i < newObj.entities.length - 1)
						newObj.entities[i] = prevObj.entities[i];
					else
						newObj.entities[i] = sketchObj;
				}
			}
			else
			{	
				newObj.count = 0;
				newObj.en_type = "Sketch";
				newObj.method = "cached";
				
				newObj.entities = new Array(1);
				newObj.entities[0] = sketchObj;
			}
			
			trace("new array after append: " + newObj.entities.length);
			for(var c:int = 0; c<newObj.entities.length; c++)
			{
				trace(com.adobe.serialization.json.JSON.encode(newObj.entities[c]));
			}	
			var newList:String = com.adobe.serialization.json.JSON.encode(newObj);
			trace("NEW LIST: " + com.adobe.serialization.json.JSON.encode(newObj));
			return newList;
		}
		
		public static function appendCacheSketchDocuments(originalDocs:String, sketchDocObj:Object):String
		{
			var userObj:Object = com.adobe.serialization.json.JSON.decode(KSketch_HomeView._viewArr[0]);
			var docArr:Array;
			
			if(originalDocs)
				originalDocs += "%" + com.adobe.serialization.json.JSON.encode(sketchDocObj);
			else
				originalDocs = com.adobe.serialization.json.JSON.encode(sketchDocObj);
			
			return originalDocs;
		}
		
		public static function writeDataToCache(arr:Array):void
		{
			trace("KCache:write to cache");
			trace("arr0: " + arr[0]);
			trace("arr1: " + arr[1]);
			trace("arr2: " + arr[2]);
			trace("arr3: " + arr[3]);
			
			_mySO.clear();
			
			_mySO.data.user = arr[0];
			_mySO.data.userSketch = arr[1];
			_mySO.data.sketchDocs = arr[2];
			_mySO.data.retrieval = arr[3];
			
			_mySO.flush();
		}
	
		public static function softReset(arr:Array):Array
		{
			arr[1] = null;
			arr[2] = null;
			arr[3] = "CACHE";
			
			return arr;
		}
		
		public static function hardReset(arr:Array):Array
		{
			arr[0] = null;
			arr[1] = null;
			arr[2] = null;
			arr[3] = "CACHE";
			
			return arr;
		}
	}
}