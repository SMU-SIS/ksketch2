package sg.edu.smu.ksketch2.model.objects
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch2.operators.KSingleReferenceFrameOperator;

	public class KImage extends KObject
	{
		private var _img:BitmapData;
		
		public function KImage(id:int, newImg:BitmapData)
		{
			super(id);
			_img = newImg;
			this._center = new Point(150, 150);
			transformInterface = new KSingleReferenceFrameOperator(this);
		}
		
		override public function get centroid():Point
		{
			return _center.clone();
		}
		
		public function get imgData():BitmapData
		{
			return _img;
		}
	}
}