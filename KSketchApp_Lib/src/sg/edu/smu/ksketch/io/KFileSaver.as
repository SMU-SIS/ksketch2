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
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	
	import sg.edu.smu.ksketch.logger.KLogger;
	import sg.edu.smu.ksketch.logger.KPlaySketchLogger;
		
	public class KFileSaver extends KFileAccessor
	{		
		/**
		 * Will dispatch an event when KMV file is loaded.
		 * Event type is KFileSavedEvent.EVENT_FILE_SAVED.
		 */		
		public function save(content:XML, name:String, completeListener:Function=null):void
		{
			var fileRef:FileReference = _isRunningInAIR() ? new File() : new FileReference();
			var extensionChecker:Function = function (fileEvent:Event):void
			{
				if((fileEvent.target as FileReference).extension != KFileParser.KMV_EXTENSION)
					Alert.show("The filename you chose does not end in '.kmv'. " +
						"You must add this extension yourself.\n" +
						"Would you like to choose another filename?",
						"Warning", Alert.YES|Alert.NO, null,
						function (closeEvent:CloseEvent):void
						{
							if (closeEvent.detail == Alert.YES)
								save(content,(fileEvent.target as FileReference).name);
						});
			};
			if (completeListener != null)
				fileRef.addEventListener(Event.COMPLETE, completeListener);
			fileRef.addEventListener(Event.COMPLETE ,extensionChecker);
			fileRef.save(content, name);
		}

		public function saveToDir(content:XML, folder:String, name:String):void
		{
			var dir:File = File.applicationStorageDirectory.resolvePath(folder);
			if (!dir.exists)
				dir.createDirectory();
			var file:File = File.applicationStorageDirectory.resolvePath(folder+"/"+name);
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeUTFBytes(content.toXMLString());
			fileStream.close();			
		}		
	}
}