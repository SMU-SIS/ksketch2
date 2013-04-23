package sg.edu.smu.ksketch2.model.objects
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import mx.graphics.codec.PNGEncoder;
	import mx.utils.Base64Decoder;
	import mx.utils.Base64Encoder;
	
	import sg.edu.smu.ksketch2.operators.KSingleReferenceFrameOperator;
	import sg.edu.smu.ksketch2.utils.Encoding;

	public class KImage extends KObject
	{
		protected var _points:Vector.<Point>;
		
		private var _imgData:BitmapData;
		
		public function KImage(id:int, newImgData:BitmapData)
		{
			super(id);
			
			_imgData = newImgData;
			this._center = new Point(_imgData.width/2, _imgData.height/2);
			_points = new Vector.<Point>;
			_points.push(this._center.clone());
			transformInterface = new KSingleReferenceFrameOperator(this);
		}
		
		override public function get centroid():Point
		{
			return _center.clone();
		}
		
		/**
		 * Returns BitmapData of this KImage
		 */
		public function get imgData():BitmapData
		{
			return _imgData;
		}
		
		/**
		 * Returns the some points that are within this KImage
		 */
		public function get points():Vector.<Point>
		{
			return _points;
		}
		
		override public function serialize():XML
		{
			var objectXML:XML = super.serialize();
			objectXML.@type = "image";
				
			var imageXML:XML = <imageData x="0" y="0" width="" height="" data=""/>;
			var encoder:Base64Encoder = new Base64Encoder();
			var data:ByteArray = _imgData.getPixels(_imgData.rect);
			objectXML.appendChild(imageXML);
			encoder.encodeBytes(data);
			imageXML.@data = encoder.toString();
			imageXML.@width = _imgData.width.toString();
			imageXML.@height = _imgData.height.toString();			
			
			return objectXML;
		}
		
		public static function imageFromXML(xml:XML):KImage
		{
			var imageSerial:String = xml.imageData.@data;
			var decoder:Base64Decoder = new Base64Decoder();
			decoder.decode(imageSerial);
			var bytes:ByteArray = decoder.toByteArray();
			
			var width:Number = Number(xml.imageData.@width);
			var height:Number = Number(xml.imageData.@height);
			var bitmapData:BitmapData = new BitmapData(width,height,true);
			bitmapData.setPixels(new Rectangle(0,0,width, height), bytes)

			var x:Number = xml.imageData.@x;
			var y:Number = xml.imageData.@y;
			
			return new KImage(int(xml.@id), bitmapData);
		}
		
		override public function clone(newObjectID:int, withMotions:Boolean = false):KObject
		{
//			var clonedPoints:Vector.<Point> = new Vector.<Point>();
//			
//			for(var i:int = 0; i<_points.length; i++)
//				clonedPoints.push(_points[i].clone());
//			
//			var newStroke:KStroke = new KStroke(id, clonedPoints, _color, _thickness);
//			
//			if(withMotions)
//				newStroke.transformInterface = transformInterface.clone();
//			
//			return newStroke;
			return null;
		}
	}
}