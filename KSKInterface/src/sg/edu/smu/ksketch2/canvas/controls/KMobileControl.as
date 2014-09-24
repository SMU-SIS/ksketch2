package sg.edu.smu.ksketch2.canvas.controls
{
	import com.adobe.serialization.json.JSON;
	
	import flash.net.SharedObject;
	
	import mx.collections.ArrayCollection;

	public class KMobileControl
	{
		//class variables
		public var informationArr:Array;
		private var _mySO:SharedObject = SharedObject.getLocal("mydata");
		private var _fileControl:KFileControl = new KFileControl();
		
		public function KMobileControl()
		{
			initFromCache();
		}
		
		/**
		 * Read stored data from cache
		 * Initializes informationArr[0], [1] and [2]
		 */
		public function initFromCache():void
		{
			informationArr = new Array(2);
			informationArr[0] = null;
			informationArr[1] = null;
			
			if (_mySO.data) {
				if(_mySO.data.user)
					informationArr[0] = _mySO.data.user;
				if(_mySO.data.userSketch)
					informationArr[1] = _mySO.data.userSketch;
			}
		}
		
		/**
		 * Writes informationArr[0], [1] to cache
		 */
		public function writeToCache(arr:Array):void
		{
			_mySO.clear();
			
			_mySO.data.user = arr[0];
			_mySO.data.userSketch = arr[1];
			
			_mySO.flush();
		}
		
		public function initUser(userObj:Object):void
		{
			//add in user object to informationArr[0]
			if(userObj.status.indexOf("success") >= 0)
				informationArr[0] = com.adobe.serialization.json.JSON.encode(userObj);
			else
				informationArr[0] = null;
		}
		
		public function addSketchToList(sketchObj:Object, type:String):void
		{
			var sketchArr:ArrayCollection;
			sketchArr = _fileControl.addNewSketchDocument(informationArr[1], sketchObj, type);
			
			sketchObj = new Object();
			if(sketchArr)															
				sketchObj.sketches = sketchArr.source;
			else
				sketchObj.sketches = null;
			
			informationArr[1] = com.adobe.serialization.json.JSON.encode(sketchObj);	//stringify the JSON objects to store in informationArr[2]
			sketchArr.removeAll();														//empty array used
		}
		
		public function deleteSketchFromList(sketchObj:Object, type:String):void
		{
			var sketchArr:ArrayCollection = _fileControl.deleteSketchDocument(informationArr[1], sketchObj, type);
			
			sketchObj = new Object();
			if(sketchArr)															
				sketchObj.sketches = sketchArr.source;
			else
				sketchObj.sketches = null;
			
			informationArr[1] = com.adobe.serialization.json.JSON.encode(sketchObj);	//stringify the JSON objects to store in informationArr[2]
			
			writeToCache(informationArr);
			
			sketchArr = null;	
			sketchObj = null;
		}
		
		public function get sketchList():ArrayCollection
		{
			var arr:ArrayCollection;
			arr = _fileControl.getSketchArr(informationArr[1]);
			return arr;
		}
		
		public function get user():Object
		{
			var obj:Object;
			obj = _fileControl.getUserObject(informationArr[0]);
			return obj;
		}
		
		public function set user(userObj:Object):void
		{
			informationArr[0] = com.adobe.serialization.json.JSON.encode(userObj);
		}
			
		public function get userSketch():Object
		{
			var obj:Object;
			obj = _fileControl.getUserObject(informationArr[1]);
			return obj;
		}
		
		public function discardSavedSketches():void
		{
			//get sketches from cache
			var cacheArr_sketch:ArrayCollection;
			cacheArr_sketch = _fileControl.convertStringToArrayCollection(informationArr[1]);
			
			var newArr:ArrayCollection = new ArrayCollection();
			
			for(var i:int=0; i<cacheArr_sketch.length; i++)
			{
				var obj:Object = cacheArr_sketch.getItemAt(i);
				if(obj.save != -1)
					newArr.addItem(obj);
			}
			
			var docObj:Object = new Object();
			docObj.sketches = newArr.source;
			
			informationArr[1] = com.adobe.serialization.json.JSON.encode(docObj);	//stringify the JSON objects to store in informationArr[2]
			cacheArr_sketch.removeAll();
			newArr.removeAll();	
		}
		
		public function reset():void
		{
			informationArr[0] = null;
			informationArr[1] = null;
		}
	}
}