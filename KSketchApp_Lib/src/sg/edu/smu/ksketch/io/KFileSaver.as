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
		public function save(content:XML, name:String):void
		{
			var fileRef:FileReference = _isRunningInAIR() ? new File() : new FileReference();
			var selected:Function = function (e:Event):void
			{
				var name2:String = (e.target as FileReference).name;
				if (name != name2)
				{
					var lastNode:XML;
					var list:XMLList = content.elements(KLogger.COMMANDS).elements(KLogger.BTN_SAVE);
					for each (var node:XML in list)
						lastNode = node;
					lastNode.@filename = name2;
				}
			};
			fileRef.addEventListener(Event.SELECT, selected);
			fileRef.save(content, name);
		}
		
		public function saveToDir(content:XML, folder:String, name:String):void
		{
			var dir:File = File.applicationStorageDirectory.resolvePath(folder);
			if (!dir.exists)
				dir.createDirectory();
			
			var file:File = File.applicationStorageDirectory.resolvePath(folder+"/"+name);
			if (file.exists)
			{
				var name2:String = name.split("-K-Movie.kmv")[0]+new Date().seconds+"-K-Movie.kmv";
				file = File.applicationStorageDirectory.resolvePath(folder+"/"+name2);
			}
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeUTFBytes(content.toXMLString());
		}
			
	}
}