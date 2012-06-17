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
	
	import sg.edu.smu.ksketch.logger.KLogger;
		
	public class KFileSaver extends KFileAccessor
	{		
		/**
		 * Will dispatch an event when KMV file is loaded.
		 * Event type is KFileSavedEvent.EVENT_FILE_SAVED.
		 */		
		public function save(content:XML, name:String, completeListener:Function=null):void
		{
			var fileRef:FileReference = _isRunningInAIR() ? new File() : new FileReference();
			var selected:Function = function (e:Event):void
			{
				var lastNode:XML;
				var list:XMLList = content.elements(KLogger.COMMANDS).elements(KLogger.BTN_SAVE);
				for each (var node:XML in list)
					lastNode = node;
				if (lastNode != null)
					lastNode.@filename = (e.target as FileReference).name;
			};
			if (completeListener != null)
				fileRef.addEventListener(Event.COMPLETE, completeListener);
			fileRef.addEventListener(Event.SELECT, selected);
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