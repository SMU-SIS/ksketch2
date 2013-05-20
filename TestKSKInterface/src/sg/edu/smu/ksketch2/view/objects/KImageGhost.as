package sg.edu.smu.ksketch2.view.objects
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;

	/**
	 * Ghost for KImageView
	 */
	public class KImageGhost extends Sprite
	{
		private var image:Bitmap;
		
		public function KImageGhost(bitmapData:BitmapData, x:Number, y:Number)
		{
			super();
			image = new Bitmap(bitmapData);
			image.x = x;
			image.y = y;
			addChild(image);
			alpha = KObjectView.GHOST_ALPHA;
			visible = false;
		}
	}
}