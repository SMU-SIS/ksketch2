/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.model
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class KImage extends KObject
	{		
		public static var NUM_BOUNDING_POINTS:Number = 1;
		public var _cachedCenter:Point;
		private var _data64:String;
		private var _imageData:BitmapData;
		private var _imagePosition:Point;
		
		public function KImage(id:int, xPos:Number, yPos:Number, createdTime:Number=0)
		{
			super(id, createdTime);			
			_imagePosition = new Point(xPos, yPos);
		}
		
		public function set data64(data:String):void
		{
			_data64 = data;
		}
		
		public function get data64():String
		{
			return _data64;
		}
		
		public function get imageData():BitmapData
		{
			return _imageData;
		}
		
		public function set imageData(data:BitmapData):void
		{
			_imageData = data.clone();
			updateCenter();
			defaultBoundingBox = _imageData.rect;
			defaultBoundingBox.x = _imagePosition.x;
			defaultBoundingBox.y = _imagePosition.y;
		}
		
		public function get imagePosition():Point
		{
			return _imagePosition.clone();
		}

		public function updateCenter():void
		{
			var rect:Rectangle = _imageData ? _imageData.rect : new Rectangle(0,0,0,0);
			_cachedCenter = new Point(rect.x+rect.width/2, rect.y + rect.height/2);
			_cachedCenter.x += _imagePosition.x;
			_cachedCenter.y += _imagePosition.y;
		}

		public override function get defaultCenter():Point
		{
			if(!_cachedCenter)
				updateCenter();
			return _cachedCenter.clone();			
		}		
		
		public override function handleCenter(kskTime:Number):Point
		{
			return defaultCenter;
		}		
	}
}