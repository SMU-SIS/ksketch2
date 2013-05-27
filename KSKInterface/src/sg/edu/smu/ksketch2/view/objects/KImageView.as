package sg.edu.smu.ksketch2.view.objects
{	
	import flash.display.Bitmap;
	import flash.filters.GlowFilter;
	
	import sg.edu.smu.ksketch2.events.KObjectEvent;
	import sg.edu.smu.ksketch2.model.objects.KImage;
	
	public class KImageView extends KObjectView
	{
		public var imgDisplay:Bitmap = new Bitmap();
		private var _glowFilter:Array;
		
		public function KImageView(object:KImage)
		{
			super(object);
			
			imgDisplay.bitmapData = object.imgData;
			imgDisplay.x = (object as KImage).x;
			imgDisplay.y = (object as KImage).y;
			addChild(imgDisplay);
			
			_ghost = new KImageGhost(imgDisplay.bitmapData, imgDisplay.x, imgDisplay.y);
			
			var filter:GlowFilter = new GlowFilter(0xFF0000, 1,14,14,32);
			_glowFilter = [filter];
			cacheAsBitmap = true;
		}
		
		/**
		 * Updates the selection for this stroke view by adding/removing a filter to it
		 */
		override protected function _updateSelection(event:KObjectEvent):void
		{
			if(_object.selected)
			{
				filters = _glowFilter;
			}
			else
				filters = [];
			
			super._updateSelection(event);
		}
	}
}