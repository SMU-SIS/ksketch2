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
		public static const url:String = "http://ksketch.smu.edu.sg/app/login.html";								//Page displayed on stagewebview
		public static const jsonurlUser:String = "http://ksketch.smu.edu.sg/user/getuser";							//To retrieve user information after login
		public static const jsonurlUserMobile:String = "http://ksketch.smu.edu.sg/user/getusermobile";				//To retrieve user information after login using ID
		public static const urlUser:String = "http://ksketch.smu.edu.sg/user/urlUser";								//To retrieve user id through URL
		
		public static const login_success:String = "http://ksketch.smu.edu.sg/app/login_successful";		
		public static const redirecturl_login:String = "http://ksketch.smu.edu.sg/app/profile.html";				//Indicates successful login
		public static const redirecturl_index:String = "http://ksketch.smu.edu.sg/app/index.html";					
		public static const redirecturl_skip:String = "http://ksketch.smu.edu.sg/app/skip.html";					//Indicates user chooses to skip login process
		
		public static const jsonurlSketch:String = "http://ksketch.smu.edu.sg/list/sketch/user/"; 					//To retrieve list of sketches
		public static const jsonurlSketchXML:String = "http://ksketch.smu.edu.sg/get/sketch/view"; 					//To retrieve XML of a specific sketch
		
		public static const jsonurlPostXML:String = "http://ksketch.smu.edu.sg/post/sketchxml";						//To save a sketch to Datastore
		public static const jsonurlOverwritePostXML:String = "http://ksketch.smu.edu.sg/post/overwritesketchxml";	//To save a sketch from an older version to Datastore
	}
}