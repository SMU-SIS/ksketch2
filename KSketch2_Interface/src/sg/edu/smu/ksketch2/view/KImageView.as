package sg.edu.smu.ksketch2.view
{	
	import sg.edu.smu.ksketch2.model.objects.KImage;
	import flash.display.Bitmap;
	
	public class KImageView extends KObjectView
	{
		private var _imgDisplay:Bitmap = new Bitmap();
		
		public function KImageView(object:KImage, isGhost:Boolean=false)
		{
			super(object, isGhost);
			_imgDisplay.bitmapData = object.imgData;
			addChild(_imgDisplay);			
		}
	}
}