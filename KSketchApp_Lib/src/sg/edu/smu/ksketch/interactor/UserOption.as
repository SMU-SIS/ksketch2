/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.interactor
{
	import flash.events.Event;
	import flash.net.SharedObject;
	
	import sg.edu.smu.ksketch.utilities.KAppState;
	import sg.edu.smu.ksketch.utilities.KSaveInfos;
	import sg.edu.smu.ksketch.utilities.KSavingUserPreferences;

	public class UserOption
	{
		public static const SHOW_PATH_NONE:String = "NONE";
		public static const SHOW_PATH_ACTIVE:String = "ACTIVE";
		public static const SHOW_PATH_ALL:String = "ALL";
		
		private var _saveInfo:KSaveInfos;
		private var _appState:KAppState;
		
		private var _showConfirmWindow:Boolean;
		private var _showPath:String;
		private var _rightMouseButtonEnabled:Boolean;
		
		public function UserOption(appState:KAppState)
		{
			_saveInfo = new KSaveInfos();
			_appState = appState;
			
			var savedData:SharedObject = _saveInfo.retrievingCookieData();
			
			if(savedData)
			{
				_showConfirmWindow = savedData.data["showMoveCenterDialog"];
				_showPath = savedData.data["showPath"];
				_rightMouseButtonEnabled = savedData.data["rightMouseButtonEnabled"];
			}
			else
			{
				showConfirmWindow = true;
				showPath = SHOW_PATH_ACTIVE;
				rightMouseButtonEnabled = true;
			}
		}
		
		public function get rightMouseButtonEnabled():Boolean
		{
			return KAppState.IS_AIR && _rightMouseButtonEnabled;
		}
		public function set rightMouseButtonEnabled(value:Boolean):void
		{
			_rightMouseButtonEnabled = value;
			KSavingUserPreferences.rightMouseButtonEnabled = _rightMouseButtonEnabled;
			_saveInfo.saveDataToCookies();
		}
		
		public function get showPath():String
		{
			return _showPath;
		}
		public function set showPath(value:String):void
		{
			if(_showPath == value)
				return;
			
			_showPath = value;
			_appState.dispatchEvent(new Event(KAppState.EVENT_OBJECT_PATH));
			KSavingUserPreferences.showPath = _showPath;
			_saveInfo.saveDataToCookies();
		}

		public function get showConfirmWindow():Boolean
		{
			return _showConfirmWindow;
		}

		public function set showConfirmWindow(value:Boolean):void
		{
			_showConfirmWindow = value;
			KSavingUserPreferences.showMoveCenterDialog = _showConfirmWindow;
			_saveInfo.saveDataToCookies();
		}

		
	}
}