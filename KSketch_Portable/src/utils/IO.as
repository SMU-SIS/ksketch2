package utils
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

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
			
			if(!saveXML.lastEdited)
				saveXML.appendChild(<lastEdited time=""/>);
			
			saveXML.lastEdited.@time = doc.lastEdited.toString();

			if(!saveXML.description)
				saveXML.appendChild(<description text=""/>);
			
			saveXML.description.@text = doc.description;
			
			var toWriteXML:String = doc.xml.toXMLString();
			var currentFile:File = File.applicationStorageDirectory.resolvePath("kmvs/"+doc.name+".kmv"); 
			var stream:FileStream = new FileStream();
			stream.open(currentFile, FileMode.WRITE);                
			stream.writeUTFBytes(toWriteXML);
			stream.close();
		}
		
		//Delete Locally
		public static function deleteDocument(doc:KSketchDocument):void
		{
			
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