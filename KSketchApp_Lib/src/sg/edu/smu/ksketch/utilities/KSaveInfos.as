package sg.edu.smu.ksketch.utilities	
{  
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.SharedObject;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;

	
	/*	Paths containing mySave file
        For Webaps 
        C:\Documents and Settings\dzydczak\Application Data\Macromedia\Flash Player\#SharedObjects\4PBXS9GX\
	       localhost\Documents and Settings\dzydczak\Adobe Flash Builder 4.5\Webps\bin-debug\Webps.swf
        For Air 
        C:\Documents and Settings\dzydczak\Application Data\PlaySketch\Local Store\#SharedObjects\PlaySketch.swf	
      C:\Documents and Settings\dzydczak\Application Data\Macromedia\Flash Player\#SharedObjects\4PBXS9GX\learn.adobe.com\
	       wiki\download\attachments\5767251\SharedObjectExample.swf	
    */	
	
	public class KSaveInfos
	{
		private var savedObject:SharedObject;
		
		public function KSaveInfos():void
		{
			savedObject = SharedObject.getLocal("PlaySketchPreferences");
		}
		
		public function saveDataToCookies():void 
		{  			
			savedObject.data["showMoveCenterDialog"] = KSavingUserPreferences.showMoveCenterDialog;
			savedObject.data["showPath"] = KSavingUserPreferences.showPath;
			savedObject.data["rightMouseButtonEnabled"] = KSavingUserPreferences.rightMouseButtonEnabled;
			savedObject.flush();
		}
		
		public function retrievingCookieData():SharedObject
		{
			if(savedObject.size != 0)
			{
				return savedObject;
			}
			else
			{
				return null;
			}
	    }	
	}
}