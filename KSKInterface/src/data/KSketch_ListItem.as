/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package data {

import org.as3commons.collections.framework.IComparator;
// Wrapper class for keeping the list items retrieved from the web service
public class KSketch_ListItem implements IComparator{
    private var _sketchId:Number;
    private var _fileName:String;
    private var _thumbnailData:String;
	private var _created:String;
    private var _version:int;
    private var _isSaved:Boolean;
    private var _uniqueId:String;
    private var _lowerFileName:String;

    public function KSketch_ListItem() {
        this._sketchId = -1;
        this._fileName = "";
        this._thumbnailData = "";
		this._created = "";
        this._version = 0;
        this._isSaved = true;
        this._lowerFileName = "";
    }

    public function fromWebData(webData:Object):void {
        this._sketchId = webData.data.sketchId;
        this._fileName = webData.data.fileName;
        this._thumbnailData = webData.data.thumbnailData;
		this._created = webData.data.created;
        this._version = webData.data.version;
        this._isSaved = true;
        this._lowerFileName = this._fileName.toLowerCase();
    }

    public function fromCache(cacheData:Object):void {
        if(cacheData.sketchId == ""){
            this._sketchId = -1;
        }else {
            this._sketchId = int(cacheData.sketchId);
        }
        this._fileName = cacheData.fileName;
        this._thumbnailData = cacheData.thumbnailData;
        this._created = cacheData.created;
        this._version = cacheData.version;
        this._isSaved = cacheData.isSaved;
        this._uniqueId = cacheData.uniqueId;
        this._lowerFileName = this._fileName.toLowerCase();
    }
    public function compare(item1:*, item2:*):int {
        if(item1._sketchId < item2._sketchId)
            return -1;
        if(item1._sketchId > item2._sketchId)
            return 1;
        return 0;
    }

    public function get sketchId():Number {
        return _sketchId;
    }

    public function set sketchId(value:Number):void {
        _sketchId = value;
    }

    public function get fileName():String {
        return _fileName;
    }

    public function set fileName(value:String):void {
        _fileName = value;
    }

    public function get thumbnailData():String {
        return _thumbnailData;
    }

    public function set thumbnailData(value:String):void {
        _thumbnailData = value;
    }
	
	public function get created():String {
		return _created;
	}
	
	public function set created(value:String):void {
		_created = value;
	}

    public function get version():int {
        return _version;
    }

    public function set version(value:int):void {
        _version = value;
    }

    public function get isSaved():Boolean {
        return _isSaved;
    }

    public function set isSaved(value:Boolean):void {
        _isSaved = value;
    }

    public function get uniqueId():String {
        return _uniqueId;
    }

    public function set uniqueId(value:String):void {
        _uniqueId = value;
    }

    public function get lowerFileName():String {
        return _lowerFileName;
    }

    public function set lowerFileName(value:String):void {
        _lowerFileName = value;
    }
}
}
