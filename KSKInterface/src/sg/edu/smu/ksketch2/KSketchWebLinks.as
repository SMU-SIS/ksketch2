/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2
{
	public class KSketchWebLinks
	{
		public static const pingurl:String = "http://google.com";
		public static const url:String = KSketch_Config.host_name+"/app/login.html";								//Page displayed on stagewebview
		public static const jsonurlUser:String = KSketch_Config.host_name+"/user/getuser";							//To retrieve user information after login
		public static const jsonurlUserMobile:String = KSketch_Config.host_name+"/user/getusermobile";				//To retrieve user information after login using ID
		public static const urlUser:String = KSketch_Config.host_name+"/user/urlUserV2";							//To retrieve user id through URL
		
		public static const login_success:String = KSketch_Config.host_name+"/app/login_successful";
		public static const redirecturl_login:String = KSketch_Config.host_name+"/app/profile.html";				//Indicates successful login
		public static const redirecturl_index:String = KSketch_Config.host_name+"/app/index.html";
		public static const redirecturl_skip:String = KSketch_Config.host_name+"/app/skip.html";					//Indicates user chooses to skip login process
		
		public static const jsonurlSketch:String = KSketch_Config.host_name+"/list/sketch/latest"; //user/"; 		//To retrieve list of sketches
		public static const jsonurlSketchXML:String = KSketch_Config.host_name+"/get/sketch/view"; 					//To retrieve XML of a specific sketch
		
		public static const jsonurlGetXML:String = KSketch_Config.host_name+"/get/sketchxml";						//To save a sketch to Datastore
		public static const jsonurlOverwriteGetXML:String = KSketch_Config.host_name+"/get/overwritesketchxml";	//To save a sketch from an older version to Datastore
		
		public static const jsonurlDeleteSketch:String = KSketch_Config.host_name+"/get/deletesketch";				//To delete a sketch from Datastore
		public static const urlApproval:String = KSketch_Config.host_name+"/app/register_complete.html";
	}
}