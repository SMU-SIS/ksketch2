/**------------------------------------------------
 * Copyright 2012 Singapore Management University
 * All Rights Reserved
 *
 *-------------------------------------------------*/

package sg.edu.smu.ksketch.io
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileReference;
	
	import sg.edu.smu.ksketch.event.KFileSavedEvent;
	
	public class KFileSaver extends KFileAccessor
	{		
		/**
		 * Will dispatch an event when KMV file is loaded.
		 * Event type is KFileSavedEvent.EVENT_FILE_SAVED.
		 */		
		public function save(content:XML, originalName:String = null):void
		{
			var defaultName:String = originalName ? originalName : 
				_generateTimeString() + "-K-Movie.kmv";			
			_save(content, [_getKMVTypeFilter()], defaultName);
		}
		
		public function saveToDir(content:XML, path:String = null):void
		{
			var dir:File = File.documentsDirectory.resolvePath(path);
			if (!dir.exists)
				dir.createDirectory();
				
			var fileName:String = _generateTimeString() + "-K-Movie.kmv";
			var file:File = File.documentsDirectory.resolvePath(path+"/"+fileName);
			if (file.exists)
			{
				fileName = _generateTimeString(true) + "-K-Movie.kmv";
				file = File.documentsDirectory.resolvePath(path+"/"+fileName);
			}
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeUTFBytes(content.toXMLString());
		}
		
		private function _save(content:XML, typeFilter:Array = null, defaultFileName:String = null):void
		{
			var fileRef:FileReference = _isRunningInAIR() ? new File() : new FileReference();
			var fileFunction:Function = _isRunningInAIR() ? _fileSaved_AIR : _fileSaved_WEB;
			fileRef.addEventListener(Event.COMPLETE, fileFunction);
			fileRef.save(content, defaultFileName);
		}
		
		private function _fileSaved_AIR(e:Event):void
		{
			this.dispatchEvent(new KFileSavedEvent((e.target as File).nativePath));
		}
		
		private function _fileSaved_WEB(e:Event):void
		{
			this.dispatchEvent(new KFileSavedEvent(null));
		}		
	}
}