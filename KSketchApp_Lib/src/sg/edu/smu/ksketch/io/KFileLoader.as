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
	
	import sg.edu.smu.ksketch.event.KFileLoadedEvent;
	
	public class KFileLoader extends KFileAccessor
	{			
		/**
		 * Will dispatch an event when KMV file is loaded.
		 * Event type is KFileLoadedEvent.EVENT_FILE_LOADED.
		 */		
		public function loadKMV():void
		{
			_load([_getKMVTypeFilter()]);
		}
		
		/**
		 * Will dispatch an event when image file is loaded.
		 * Event type is KFileLoadedEvent.EVENT_FILE_LOADED.
		 */		
		public function loadImage():void
		{
			_load([_getImageTypeFilter()]);
		}
		
		/**
		 * Will dispatch an event when log file is loaded.
		 * Event type is KFileLoadedEvent.EVENT_FILE_LOADED.
		 */		
		public function loadLog():void
		{
			_load([_getLogTypeFilter()]);
		}
		
		private function _load(typeFilter:Array = null):void
		{
			var fileRef:FileReference = _isRunningInAIR() ? new File() : new FileReference();
			var fileLoaded:Function = _isRunningInAIR() ? _fileLoaded_AIR : _fileLoaded_WEB;
			fileRef.addEventListener(Event.SELECT, function(e:Event):void
			{
				fileRef.addEventListener(Event.COMPLETE, fileLoaded);
				fileRef.load();
			});
			fileRef.browse(typeFilter);
		}
		
		private function _fileLoaded_WEB(e:Event):void
		{
			var fileRef:FileReference = e.target as FileReference;
			this.dispatchEvent(new KFileLoadedEvent(null, fileRef.data));
		}
		
		private function _fileLoaded_AIR(e:Event):void
		{
			var file:File = e.target as File;
			this.dispatchEvent(new KFileLoadedEvent(file.nativePath, file.data));
		}
	}
}