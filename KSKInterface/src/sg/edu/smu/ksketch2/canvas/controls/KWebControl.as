package sg.edu.smu.ksketch2.canvas.controls
{
	import com.adobe.serialization.json.JSON;
	
	import mx.collections.ArrayCollection;
	
	import sg.edu.smu.ksketch2.canvas.controls.KFileControl;
	import sg.edu.smu.ksketch2.utils.KWebData;

	public class KWebControl
	{
		//class variables
		public var informationArr:Array;
		private var _mobileControl:KMobileControl;
		private var _isConnected:Boolean;
		
		public function KWebControl(userObj:Object, mobileControl:KMobileControl)
		{	
			informationArr = new Array(2);
			_mobileControl = mobileControl;

			var setNew:Boolean = false;
			if(_mobileControl)
			{
				if(_mobileControl.user)
				{
					if(_mobileControl.user.id == userObj.id)
					{
						initUser(_mobileControl.user);
						informationArr[1] = _mobileControl.informationArr[1];	
					}
					else
						setNew = true;
				}
				else 
					setNew = true;
			}
			else
				setNew = true;
			
			if(setNew)
			{
				initUser(userObj);		
				informationArr[1] = null;
			}
		}
		
		public function initUser(userObj:Object):void
		{
			//add in user object to informationArr[0]
			if(userObj.status.indexOf("success") >= 0)
				informationArr[0] = com.adobe.serialization.json.JSON.encode(userObj);
			else
				informationArr[0] = null;
		}
	
		public function initSketchList(sketchObj:Object):void
		{
			//add in list of sketches to informationArr[1]
			var newArr:ArrayCollection = new ArrayCollection();
			var tempArr:Array = (sketchObj.entities as Array);
			if(tempArr.length > 0)
			{
				var newTempArr:ArrayCollection = KFileControl.convertArrayToArrayCollection(tempArr);
				for each(var tempObj:Object in newTempArr)
				{
					tempObj = KWebData.convertWebObjForMobile(tempObj);
					newArr.addItem(tempObj);
				}
			}
			
			sketchObj = new Object();
			if(tempArr.length > 0)
				sketchObj.sketches = newArr.source;
			else
				sketchObj.sketches = null;
			
			//stringify the JSON objects to store in informationArr[1]
			informationArr[1] = com.adobe.serialization.json.JSON.encode(sketchObj);
		}
	
		public function addSketchToList(docObj:Object):void
		{
			var sketchDocsArr:ArrayCollection;
			sketchDocsArr = KFileControl.addNewSketchDocument(informationArr[1], docObj);
			
			docObj = new Object();
			if(sketchDocsArr)															
				docObj.sketches = sketchDocsArr.source;
			else
				docObj.sketches = null;
			
			informationArr[1] = com.adobe.serialization.json.JSON.encode(docObj);	//stringify the JSON objects to store in informationArr[2]
			sketchDocsArr.removeAll();												//empty array used
		}
	
		public function get sketchList():ArrayCollection
		{
			var arr:ArrayCollection;
			arr = KFileControl.getSketchArr(informationArr[1]);
			return arr;
		}
	}
}