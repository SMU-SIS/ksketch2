package sg.edu.smu.ksketch2.view.objects
{	
	import flash.display.Bitmap;
	
	import sg.edu.smu.ksketch2.model.objects.KImage;
	
	public class KImageView extends KObjectView
	{
		public var imgDisplay:Bitmap = new Bitmap();
		
		public function KImageView(object:KImage)
		{
			super(object);
			
			imgDisplay.bitmapData = object.imgData;
			imgDisplay.x = (object as KImage).x;
			imgDisplay.y = (object as KImage).y;
			addChild(imgDisplay);			
		}
	}
}