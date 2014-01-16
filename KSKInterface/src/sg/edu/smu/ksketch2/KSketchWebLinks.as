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
		public static const url:String = "http://ksketchweb.appspot.com/app/login.html";								//Page displayed on stagewebview
		public static const jsonurlUser:String = "http://ksketchweb.appspot.com/user/getuser";							//To retrieve user information after login
		public static const redirecturl_login:String = "http://ksketchweb.appspot.com/app/profile.html";				//Indicates successful login
		public static const redirecturl_index:String = "http://ksketchweb.appspot.com/app/index.html";					
		public static const redirecturl_skip:String = "http://ksketchweb.appspot.com/app/skip.html";					//Indicates user chooses to skip login process
		public static const jsonurlSketch:String = "http://ksketchweb.appspot.com/list/sketch/user/"; 					//To retrieve list of sketches
		public static const jsonurlSketchXML:String = "http://ksketchweb.appspot.com/get/sketch/view"; 					//To retrieve XML of a specific sketch
		public static const jsonurlPostXML:String = "http://ksketchweb.appspot.com/post/sketchxml";						//To save a sketch to Datastore
		public static const jsonurlOverwritePostXML:String = "http://ksketchweb.appspot.com/post/overwritesketchxml";	//To save a sketch from an older version to Datastore
	}
}