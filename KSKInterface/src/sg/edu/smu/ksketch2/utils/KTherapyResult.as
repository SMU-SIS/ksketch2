/**
 * Copyright 2010-2015 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.utils
{
	import flash.errors.EOFError;
	import flash.net.SharedObject;
	
	import mx.collections.ArrayList;
	import mx.core.UIComponent;
	import mx.managers.PopUpManager;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import sg.edu.smu.ksketch2.KSketchWebLinks;
	import sg.edu.smu.ksketch2.canvas.components.popup.KSketch_DialogBox_Message;
	import sg.edu.smu.ksketch2.canvas.components.view.KSketch_CanvasView;
	import sg.edu.smu.ksketch2.canvas.components.view.KSketch_HomeView;
	import sg.edu.smu.ksketch2.model.objects.KResult;

	public class KTherapyResult
	{
		public static const THERAPY_RESULT_NAME:String = "Therapy_Result"; 	
		public static const RESULT_NETWORKFAILURE:String = "Failed to connect to KSketch Web Service. Please check your network connection.";
		public static const RESULT_NODATA:String = "No Therapy data is available!";
		public static const RESULT_SUCCESS:String = "Therapy data is sent successfully.";
		public static const RESULT_CLEAR_SUCCESS:String = "Therapy data is reset.";
		public static const RESULT_ERROR:String = "Oops! Something happened while sending Therapy data.";
		public static const CONFIRM_RESET:String = "Are you sure you want to reset all therapy data?";		
		
		private var _httpService:HTTPService;
		private var _parentContainer:UIComponent;
		private var _dialogMessage:KSketch_DialogBox_Message;
		private var _totalItems:int;
		private var _currentCount:int = 0;
		private var _currentObject:Object;
		private var _currentMessage:String;
		
		public function KTherapyResult(parentContainer:UIComponent)
		{
			_parentContainer = parentContainer;	
			_initWebService();
		}
		
		/*
			Initializes web service to send Therapy data to datastore
		*/
		private function _initWebService():void{
			_httpService = new HTTPService();
			_httpService.url = KSketchWebLinks.jsonurlSendTherapyData;
			_httpService.addEventListener(ResultEvent.RESULT, _resultHandler);
			_httpService.addEventListener(FaultEvent.FAULT, _faultHandler);	
		}
		
		/*
			Retrieves a list of Therapy result to send to datastore using web service. 
		*/
		public function sendAllTherapyResult():void{
			var resultSO:SharedObject = SharedObject.getLocal(THERAPY_RESULT_NAME);
			var list:ArrayList = resultSO.data.result as ArrayList;
			
			if(list)
			{
				_totalItems = list.length;
				for(var i:int=0;i<list.length;i++)
				{
					var sharedObject:SharedObject = list.getItemAt(i) as SharedObject;
					if(!sharedObject)
					{
						_totalItems --;
						continue;
					}						
					var objTherapy:Object = getResultObject(sharedObject) as Object;	
					_currentObject = objTherapy;
					sendTherapyResult(_currentObject);
				}
				if(_totalItems == 0)
					_showSendTherapyDataResult(0);
			}
			else
				_showSendTherapyDataResult(0);
		}
		
		/*
			Sends Therapy data to datastore
		*/
		public function sendTherapyResult(objTherapy:Object):void{	
			_currentCount++;
			if(objTherapy)
			{
				_currentObject = objTherapy;
				if(objTherapy["resultRecall"] == "" && objTherapy["resultTrace"] == "" && objTherapy["resultTrack"] == "" && objTherapy["resultRecreate"] == "")
					_showSendTherapyDataResult(0);
				else
					_httpService.send(_currentObject);
			}
			else
				_showSendTherapyDataResult(0);
		}
		
		/*
			Cleans up Therapy data stored on device
		*/
		public function resetTherapyResult():void{
			var resultSO:SharedObject = SharedObject.getLocal(THERAPY_RESULT_NAME);
			var list:ArrayList = resultSO.data.result as ArrayList;
			
			if(list)
			{
				try{
					for(var i:int=0;i<list.length;i++)
					{
						var sharedObject:SharedObject = list.getItemAt(i) as SharedObject;
						if(sharedObject)
						{
							var actualSharedObject:SharedObject = SharedObject.getLocal(sharedObject.data.id);						
							if(actualSharedObject)
								actualSharedObject.clear();
						}
					}
					list.removeAll();
					resultSO.clear();
					_showClearTherapyDataResult(1);
				}
				catch(e:EOFError){
					_showClearTherapyDataResult(-1);
				}
			}
			else
				_showClearTherapyDataResult(0);
		}	
		
		/*
			Sets values of shared object data to empty string instead of using its default value 'undefined'.
		*/
		public function resetTherapyResultSharedObject(resultSO:SharedObject):SharedObject
		{
			if(resultSO && !resultSO.data.resultRecall && !resultSO.data.resultTrace && !resultSO.data.resultTrack && !resultSO.data.resultRecreate)
			{
				resultSO.data.resultRecall = "";
				resultSO.data.resultTrace = "";
				resultSO.data.resultTrack = "";
				resultSO.data.resultRecreate = "";	
			}		
			return resultSO;
		}
		
		/*
			Gets Therapy data from SharedObject for sending to web service.
		*/
		public static function getResultObject(result:SharedObject):Object
		{
			var objTherapy:Object = new Object();				
			if(result && result.data)
			{
				objTherapy["userName"] = result.data.userName;
				objTherapy["templateName"] = result.data.templateName;
				objTherapy["resultDate"] = result.data.resultDate;
				objTherapy["resultRecall"] = result.data.resultRecall;
				objTherapy["resultTrace"] = result.data.resultTrace;
				objTherapy["resultTrack"] = result.data.resultTrack;
				objTherapy["resultRecreate"] = result.data.resultRecreate;
				objTherapy["id"] = result.data.id;
			}			
			return objTherapy;
		}
		
		/*
			Extracts required Therapy data from KResult object
			Returns value in format: <template object id>::<trials>:<time given>:<time taken>:<stars>:<retry>
		*/
		public static function deserializeResult(templateObjectId:String, result:KResult):String
		{
			var resultString:String = "";
			var delimiter:String = ":";
			if(result != null)
			{
				resultString += templateObjectId + delimiter;
				resultString += result.quadrantAttempt.toString() + delimiter;
				resultString += result.timeGiven.toString() + delimiter;
				resultString += result.timeTaken.toString() + delimiter;
				resultString += result.stars.toString() + delimiter;
				resultString += result.retry ? "Yes" : "No";
				resultString += "|";
			}
			return resultString.replace("undefined","");
		}
		
		/*
			Returns name of a SharedObject which stores Therapy data locally
			Name format: <Therapy template>-<user name>-<YYYY-MM-DD>, all spaces are replaced with hyphen '-'
		*/
		public static function getTherapyCacheName(templateName:String, userName:String):String{
			var spaces:RegExp = / /gi; // match "spaces" in a string
			return templateName.replace(spaces, "-") + "_" + userName.replace(spaces, "-") + "_" + KTherapyResult.getCurrentDate();
		}
		
		/*
			Returns current date in format: YYYY-MM-DD
		*/
		public static function getCurrentDate():String
		{
			var date:Date = new Date();
			var month:String = (date.month+1).toString();
			if(month.length == 1)
				month = "0" + month;
			return date.fullYear.toString() + "-" + month + "-" + date.date.toString();
		}
		
		/*
			Handlers of successful sending data using web service.
		*/
		private function _resultHandler(event:ResultEvent):void {
			var status:int = (event.result.indexOf("error") > 0) ? 2 : 1;	
			_currentCount++;
			_showSendTherapyDataResult(status);	
		}
		
		/*
			Handlers of unsuccessful sending data using web service.
		*/
		private function _faultHandler(event:FaultEvent):void {
			_currentCount++;
			_showSendTherapyDataResult(-1);
		}
		
		/*
			Displays a message box to notify user about the status of sending of Therapy data to datastore.
		*/
		private function _showSendTherapyDataResult(status:int):void{
			if(status == -1) 
				_currentMessage = RESULT_NETWORKFAILURE;
			else if(status == 0)
				_currentMessage = RESULT_NODATA;
			else if(status == 1)
				_currentMessage = RESULT_SUCCESS;
			else if(status == 2)
				_currentMessage = RESULT_ERROR;
			
			// supress showing message box for simplication to user
			// only show the last message
			if(_currentCount == _totalItems || (_currentCount == 1 && _totalItems == 0))
			{
				_currentCount = 0;
				_showMessageDialog();
			}							
		}
		
		/*
			Displays a message box to notify user about the status of Therapy data reset.
		*/
		private function _showClearTherapyDataResult(status:int):void{
			if(status == -1) 
				_currentMessage = RESULT_ERROR;
			else if(status == 0)
				_currentMessage = RESULT_NODATA;
			else if(status == 1)
				_currentMessage = RESULT_CLEAR_SUCCESS;
			_showMessageDialog();				
		}
		
		/*
			Displays a message box to user.
		*/
		private function _showMessageDialog():void{
			_dialogMessage = new KSketch_DialogBox_Message();
			_dialogMessage.init(_parentContainer, _currentMessage, "Close","");
			_assignDialogToParent();
			_dialogMessage.showMessage();
			PopUpManager.centerPopUp(_dialogMessage);
		}
		
		/*
			Displays a message box to get user's confirmation.
		*/
		private function _showConfirmResetDialog():void{
			_dialogMessage = new KSketch_DialogBox_Message();
			_dialogMessage.init(_parentContainer, CONFIRM_RESET, "Yes","No");
			_assignDialogToParent();
			_dialogMessage.showMessage();
			PopUpManager.centerPopUp(_dialogMessage);
		}
		
		private function _assignDialogToParent():void{
			if(_parentContainer is KSketch_HomeView)
				(_parentContainer as KSketch_HomeView).dialogMessage = _dialogMessage;
			else if(_parentContainer is KSketch_CanvasView)
				(_parentContainer as KSketch_CanvasView).dialogMessage = _dialogMessage;
		}
			
	}
	
}