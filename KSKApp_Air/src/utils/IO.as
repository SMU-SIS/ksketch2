package utils
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import sg.edu.smu.ksketch2.utils.KSketchDocument;

	public class IO
	{
		public static var KMV_DIRECTORY:String = "kmvs/"
		
		//Load a local file
		public static function storageAvailable():Boolean
		{
			var file:File = File.applicationStorageDirectory.resolvePath(KMV_DIRECTORY);
			
			if(file.isDirectory)
				return true;
			else
				return false;
		}
		
		//Save to local
		public static function saveLocal(doc:KSketchDocument):void
		{
			var saveXML:XML = doc.xml;
			
			trace("Num document properties",saveXML.documentProperties.length());
			if(saveXML.documentProperties.length() == 0)
			{
				saveXML.appendChild(<documentProperties name="" time="" description=""/>);
				saveXML.documentProperties.@name = doc.name.toString();
				saveXML.documentProperties.@time = doc.lastEdited.toString();
				saveXML.documentProperties.@description = doc.description;
			}
			
			var toWriteXML:String = doc.xml.toXMLString();
			var currentFile:File = File.applicationStorageDirectory.resolvePath("kmvs/"+doc.id+".kmv"); 
			var stream:FileStream = new FileStream();
			stream.open(currentFile, FileMode.WRITE);                
			stream.writeUTFBytes(toWriteXML);
			stream.close();
		}
		
		//Delete Locally
		public static function deleteDocument(doc:KSketchDocument):void
		{
			var currentFile:File = File.applicationStorageDirectory.resolvePath("kmvs/"+doc.id+".kmv");
			
			if(currentFile)
				currentFile.deleteFile();
		}
		
		public static function saveToAccount(doc:KSketchDocument):void
		{
			
		}
		
		public static function loadFromAccount(doc:KSketchDocument):void
		{
			
		}
		
		public static function deleteFromAccount(doc:KSketchDocument):void
		{
			
		}
	}
}