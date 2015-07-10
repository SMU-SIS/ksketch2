/**
 * Created by ramvibhakar on 10/07/15.
 */
package data {

import org.as3commons.collections.framework.IComparator;
// Wrapper class for keeping the list items retrieved from the web service
public class KSketch_ListItem implements IComparator{
    private var _sketchId:Number;
    private var _fileName:String;
    private var _thumbnailData:String;
    private var _version:int;
    private var _isSaved:Boolean;

    public function KSketch_ListItem() {
        this.sketchId = 0;
        this.fileName = "";
        this.thumbnailData = "";
        this.version = 0;
        this.isSaved = true;
    }

    public function fromWebData(webData:Object) {
        this.sketchId = webData.sketchId;
        this.fileName = webData.fileName;
        this.thumbnailData = webData.thumbnailData;
        this.version = webData.version;
        this.isSaved = true;
    }

    public function compare(item1:*, item2:*):int {
        if(item1.sketchId < item2.sketchId)
            return -1;
        if(item1.sketchId > item2.sketchId)
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
}
}
