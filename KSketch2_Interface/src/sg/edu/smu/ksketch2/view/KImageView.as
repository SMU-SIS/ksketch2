package sg.edu.smu.ksketch2.view
{	
	import flash.display.Bitmap;
	
	import sg.edu.smu.ksketch2.model.objects.KImage;
	
	public class KImageView extends KObjectView
	{
		private var _imgDisplay:Bitmap = new Bitmap();
		
		public function KImageView(object:KImage, isGhost:Boolean=false, showPath:Boolean = true)
		{
			super(object, isGhost, showPath);
			
			_imgDisplay.bitmapData = object.imgData;
			_imgDisplay.x = (object as KImage).x;
			_imgDisplay.y = (object as KImage).y;
			addChild(_imgDisplay);			
		}
	}
}