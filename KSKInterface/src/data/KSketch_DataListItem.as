/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package data {
	
	public class KSketch_DataListItem {
		
		private var _fileData:XML;
		private var _fileName:String;
		private var _originalName:String;
		private var _id:String;
		private var _modified:Date
		private var _changeDescription:String;
		private var _sketchId:int;
		private var _originalSketchId:int;
		private var _version:int;
		private var _newVersion:int;
		private var _lowerFileName:String;
		private var _thumbnailData:String;
		
	    public function KSketch_DataListItem(fileData:String, fileName:String, originalName:String, id:String, 
											 modified:String, changeDescription:String, sketchId:int, version:int) {
			_fileData = new XML(fileData);
			_fileName = fileName;
			_id = id;
			_changeDescription = changeDescription;
			
			_modified = new Date();
			if(modified != "")
			{
				_modified.setTime(Date.parse(modified));
			}
			
			if(originalName != "")
			{
				_originalName = originalName;	
			}	
			else
			{
				_originalName = _fileName;
			}
			
			if(sketchId > 0)
			{
				_sketchId = sketchId;
			}
			else
			{
				_sketchId = -1;
			}
			_originalSketchId = _sketchId;
			
			_version = version;
			if(_version == 0)
			{
				_newVersion = -1;
			}
			else
			{
				_newVersion = _version;
			}
			_lowerFileName = fileName.toLowerCase();
		}
		
		public function set fileData(value:XML):void
		{
			_fileData = value;
		}
		
		public function get fileData():XML
		{
			return _fileData;
		}
		
		public function set fileName(value:String):void
		{
			_fileName = value;
		}
		
		public function get fileName():String
		{
			return _fileName;
		}
		
		public function set originalName(value:String):void
		{
			_originalName = value;
		}
		
		public function get originalName():String
		{
			return _originalName;
		}
		
		public function set id(value:String):void
		{
			_id = value;
		}
		
		public function get id():String
		{
			return _id;
		}
		
		public function set modified(value:Date):void
		{
			_modified = value;
		}
		
		public function get modified():Date
		{
			return _modified;
		}
		
		public function set changeDescription(value:String):void
		{
			_changeDescription = value;
		}
		
		public function get changeDescription():String
		{
			return _changeDescription;
		}
		
		public function set sketchId(value:int):void
		{
			_sketchId = value;
		}
		
		public function get sketchId():int
		{
			return _sketchId;
		}
		
		public function set originalSketchId(value:int):void
		{
			_originalSketchId = value;
		}
		
		public function get originalSketchId():int
		{
			return _originalSketchId;
		}
		
		public function set version(value:int):void
		{
			_version = value;
		}
		
		public function get version():int
		{
			return _version;
		}
		
		public function set newVersion(value:int):void
		{
			_newVersion = value;
		}
		
		public function get newVersion():int
		{
			return _newVersion;
		}

		public function get lowerFileName():String {
			return _lowerFileName;
		}

		public function set lowerFileName(value:String):void {
			_lowerFileName = value;
		}

		public function get thumbnailData():String {
			return _thumbnailData;
		}

		public function set thumbnailData(value:String):void {
			_thumbnailData = value;
		}
	}
}
