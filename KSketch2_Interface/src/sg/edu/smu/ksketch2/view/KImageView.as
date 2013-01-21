package sg.edu.smu.ksketch2.view
{
	import flash.display.Bitmap;
	
	import sg.edu.smu.ksketch2.model.objects.KImage;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	
	public class KImageView extends KObjectView
	{
		private var _bitmapDisplay:Bitmap;
		
		public function KImageView(object:KObject, isGhost:Boolean=false)
		{
			super(object, isGhost);
			_bitmapDisplay = new Bitmap((object as KImage).imgData);
			addChild(_bitmapDisplay);
			
		}
	}
}