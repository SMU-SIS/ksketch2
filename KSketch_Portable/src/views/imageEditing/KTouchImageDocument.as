package views.imageEditing
{
	import flash.display.BitmapData;
	import flash.filesystem.File;

	public class KTouchImageDocument
	{
		public var imageFile:File;
		public var imageObject:BitmapData;
		
		public function KTouchImageDocument(file:File)
		{
			imageFile = file;
		}
		
		
	}
}