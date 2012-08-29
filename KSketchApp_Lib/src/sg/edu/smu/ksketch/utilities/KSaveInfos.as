/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

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