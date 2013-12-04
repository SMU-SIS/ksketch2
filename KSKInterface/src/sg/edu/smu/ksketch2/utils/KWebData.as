/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.utils
{
	import mx.formatters.DateFormatter;
	
	/**
 	 * The KSketchDocument class serves as the concrete class for handling
 	 * sketch documents in K-Sketch.
 	 */
	[Bindable]
	public class KWebData
	{	
		public static function prepareSketchDoc_Save(userData:Object, sketchName:String):Object
		{
			var data:Object = new Object();
			data.group_permissions = [];
			data.thumbnailData = userData.thumbnailData;
			data.p_edit = true;
			data.changeDescription = "";
			
			if(userData.kSketchDocument.originalName != "" && (sketchName == userData.kSketchDocument.originalName))
			{
				data.fileName = sketchName;
				data.sketchId = userData.kSketchDocument.sketchId;
				data.originalVersion = userData.kSketchDocument.originalVersion;
				data.originalSketch = userData.kSketchDocument.originalSketch;
				
				data.originalName = userData.kSketchDocument.originalName;	
			}
			else
			{
				data.fileName = sketchName;
				data.sketchId = "";
				data.originalVersion = 1;
				data.originalSketch = 1;
				
				data.originalName = sketchName;
			}
			
			data.appver = 1.0;
			data.version = userData.kSketchDocument.version;
			data.p_view = 1;
			data.fileData = userData.kSketchDocument.xml.toXMLString();
			data.p_comment = true;
			data.owner = userData.kUser.u_realname;
			data.owner_id = userData.kUser.id;
			return data;
		}
		
		public static function prepareSketchDoc_Sync(user:Object, docObj:KSketchDocument, thumbnailData:String, fileName:String):Object
		{
			var data:Object = new Object();
			data.group_permissions = [];
			data.thumbnailData = thumbnailData;
			data.sketchId = ""; 
			data.p_edit = true;
			data.changeDescription = "";
			data.fileName = fileName;
			
			data.originalVersion = docObj.originalVersion;
			data.originalSketch = docObj.originalSketch;
			data.originalName = fileName;
			
			data.appver = 1.0;
			data.version = docObj.version;
			data.p_view = 1;
			data.fileData = docObj.xml.toXMLString();
			data.p_comment = true;
			data.owner = user.u_realname;
			data.owner_id = user.id;
			return data;
		}
		
		public static function prepareUserSketch(userData:Object, sketchName:String, isNewSketch:Boolean):Object
		{
			var data:Object = new Object();
			data.comment = 0;
			data.thumbnailData = userData.thumbnailData;
			
			if(!isNewSketch)
				data.sketchId = -1;
			else
				data.sketchId = userData.kSketchDocument.sketchId;
			
			data.originalVersion = userData.kSketchDocument.originalVersion;
			data.p_edit = true;
			data.changeDescription = "";
			data.fileName = sketchName;
			data.like = 0;
			
			if(userData.kSketchDocument.originalName == "")
				data.originalName = sketchName;
			else
				data.originalName = userData.kSketchDocument.originalName;
			
			data.appver = 1.0;
			data.version = userData.kSketchDocument.version;
			data.p_view = true;
			data.owner = userData.kUser.u_realname; 
			data.originalSketch =  userData.kSketchDocument.originalSketch;
			data.p_comment = true;
			data.owner_id = userData.kUser.id;
			
			return data;
		}
		
		public static function generateTimestamp(timestamp:Date):String
		{
			if (timestamp == null)
			{
				timestamp = new Date();
			}
			var dateFormatter:DateFormatter = new DateFormatter();
			dateFormatter.formatString = "YYYY-MM-DDTJJ:NN:SS"
			return dateFormatter.format(timestamp);
		}
	}
}