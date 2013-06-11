package sg.edu.smu.ksketch2.canvas.components.view.objects
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	
	import sg.edu.smu.ksketch2.operators.KVisibilityControl;

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
			alpha = KVisibilityControl.GHOST_ALPHA;
			visible = false;
		}
	}
}