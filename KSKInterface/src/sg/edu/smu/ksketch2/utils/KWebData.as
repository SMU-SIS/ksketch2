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
import mx.utils.UIDUtil;

/**
 	 * The KSketchDocument class serves as the concrete class for handling
 	 * sketch documents in K-Sketch.
 	 */
	[Bindable]
	public class KWebData
	{	
		public static function prepareSketchDocument(userData:Object, sketchName:String, userDetails:Object):Object
		{
			var data:Object = new Object();
			data.group_permissions = [];
			data.thumbnailData = userData.thumbnailData;
			data.p_edit = true;
			data.changeDescription = "";
			data.date = generateTimestamp(null);
			
			data.fileName = sketchName;
			data.lowerFileName = sketchName.toLowerCase();
			
			if(userData.sketchData.originalName != "" && (sketchName == userData.sketchData.originalName))
			{
				data.sketchId = userData.sketchData.sketchId;
				data.originalVersion = userData.sketchData.originalVersion;
				data.originalSketch = userData.sketchData.originalSketch;
				data.originalName = userData.sketchData.originalName;	
			}
			else
			{
				data.sketchId = -1;
				data.originalVersion = 1;
				data.originalSketch = -1;
				data.originalName = sketchName;
				data.uniqueId = UIDUtil.createUID();    //Since sketchID is not available. Let's identify locally by UID
			}
			
			data.appver = 1.0;
			data.version = userData.sketchData.version;
			data.p_view = 1;
			data.fileData = userData.fileData;
			data.p_comment = true;
			data.owner = userDetails.u_realname;
			data.owner_id = userDetails.id;
			return data;
		}
		
		public static function convertWebObjForMobile(obj:Object):Object
		{
			var data:Object = new Object();
			
			data.originalVersion = obj.data.originalVersion;
			data.thumbnailData = obj.data.thumbnailData;
			data.changeDescription = obj.data.changeDescription;
			data.p_comment = obj.data.p_comment;
			data.originalSketch = obj.data.originalSketch;
			data.p_view = obj.data.p_view;
			data.owner = obj.data.owner;
			data.appver = obj.data.appver;
			data.owner_id = obj.data.owner_id;
			data.sketchId = obj.data.sketchId;
			data.p_edit = obj.data.p_edit;
			data.version = obj.data.version;
			data.fileName = obj.data.fileName;
			data.originalName = obj.data.originalName;
			data.date = obj.created;
			data.like = obj.data.like;
			data.comment = obj.data.comment;
			data.fileData = obj.data.fileData;
			data.lowerFileName = obj.data.lowerFileName;
			
			return data;
		}
		
		public static function generateTimestamp(timestamp:Date):String
		{
			if (timestamp == null)
			{
				timestamp = new Date();
				var offsetMilliseconds:Number = timestamp.getTimezoneOffset() * 60 * 1000;
				timestamp.setTime(timestamp.getTime() + offsetMilliseconds);
			}
			
			var dateFormatter:DateFormatter = new DateFormatter();
			dateFormatter.formatString = "DD MMM YYYY, HH:NN:SS";
			return dateFormatter.format(timestamp);
		}
	}
}