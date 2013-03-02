package utils
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	public class StudyIO
	{	
		public static const STUDY_DIRECTORY:String = "study/"
		public static const TASK_DIRECTORY:String = "tasks";
		
		public static function participantAvailable(participantID:String):Boolean
		{
			var file:File = File.applicationStorageDirectory.resolvePath(STUDY_DIRECTORY+participantID);

			if(file.isDirectory)
				return true;
			else
				return false;
		}
		
		public static function save(participantID:String, doc:KSketchDocument):void
		{
			var toWriteXMl:String = doc.xml.toXMLString();
			var currentFile:File = File.applicationStorageDirectory.resolvePath("study/"+participantID+"/"+participantID+" "+doc.name+".kmv"); 
			var stream:FileStream = new FileStream();
			stream.open(currentFile, FileMode.WRITE);                
			stream.writeUTFBytes(toWriteXMl);
			stream.close();
		}
	}
}