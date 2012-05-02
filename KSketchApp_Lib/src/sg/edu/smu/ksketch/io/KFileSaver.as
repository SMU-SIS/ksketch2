/**------------------------------------------------
 * Copyright 2012 Singapore Management University
 * All Rights Reserved
 *
 *-------------------------------------------------*/

package sg.edu.smu.ksketch.io
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.FileReference;
	import sg.edu.smu.ksketch.event.KFileSavedEvent;
	
	public class KFileSaver extends KFileAccessor
	{		
		/**
		 * Will dispatch an event when KMV file is loaded.
		 * Event type is KFileSavedEvent.EVENT_FILE_SAVED.
		 */		
		public function saveKMV(content:XML, originalName:String = null):void
		{
			var defaultName:String;
			if(originalName != null)
				defaultName = originalName;
			else
				defaultName = _generateTimeString()+"-K-Movie.kmv";
			
			_save(content, [_getKMVTypeFilter()], defaultName);
		}
		
		/**
		 * Will dispatch an event when log file is loaded.
		 * Event type is KFileSavedEvent.EVENT_FILE_SAVED.
		 */		
		public function saveLog(content:XML, originalName:String = null):void
		{
			var defaultName:String;
			if(originalName != null)
				defaultName = originalName;
			else
				defaultName = _generateTimeString()+"-K-Log.klg";
			
			_save(content, [_getLogTypeFilter()], defaultName);
		}
		
		private function _save(content:XML, typeFilter:Array = null, defaultFileName:String = null):void
		{
			var fileRef:FileReference;
			if(_isRunningInAIR())
			{
				fileRef = new File();
				fileRef.addEventListener(Event.COMPLETE, _fileSaved_AIR);
			}
			else
			{
				fileRef = new FileReference();
				fileRef.addEventListener(Event.COMPLETE, _fileSaved_WEB);
			}
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