/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.model.objects
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import mx.utils.Base64Decoder;
	import mx.utils.Base64Encoder;
	
	import sg.edu.smu.ksketch2.operators.KSingleReferenceFrameOperator;

	/**
	 * The KImage class serves as the concrete class for representing
	 * image objects in the model in K-Sketch.
	 */
	public class KImage extends KObject
	{
		protected var _points:Vector.<Point>;	// the image's list of points
		
		private var _imgData:BitmapData;	// the image data
		public var x:Number;				// the image's x-position
		public var y:Number;				// the image's y-position
		
		/**
		 * The main constructor for the KImage class.
		 * 
		 * @param id The target ID.
		 * @param newImgData The target image data.
		 * @param imgX The target x-position.
		 * @param imgY The target y-position.
		 */		
		public function KImage(id:int, newImgData:BitmapData, imgX:Number, imgY:Number)
		{
			// set the image's ID
			super(id);
			
			// set the image's spatial coordinates
			x = imgX;
			y = imgY;
			
			// set the image's data
			_imgData = newImgData;
			
			// calculate and add the image's geometric center
			this._center = new Point(x+_imgData.width/2, y+_imgData.height/2);
			_points = new Vector.<Point>;
			_points.push(this._center.clone());
			
			// initialize the image's transform
			transformInterface = new KSingleReferenceFrameOperator(this);
		}
		
		override public function get center():Point
		{
			return _center.clone();
		}
		
		/**
		 * Gets the image's data.
		 * 
		 * @return The image's data.
		 */
		public function get imgData():BitmapData
		{
			return _imgData;
		}
		
		/**
		 * Gets the image's list of points.
		 * 
		 * @return The image's list of points.
		 */
		public function get points():Vector.<Point>
		{
			return _points;
		}
		
		/**
		 * Serializes the image to an XML object in base 64.
		 * 
		 * @return The serialized XML object of the image.
		 */
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
			imageXML.@x = x.toString();
			imageXML.@y = y.toString();
			imageXML.@width = _imgData.width.toString();
			imageXML.@height = _imgData.height.toString();			
			
			return objectXML;
		}
		
		/**
		 * Deserializes the XML object to an image.
		 * 
		 * @param The target XML object.
		 * @return The deserialized image.
		 */
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
			
			return new KImage(int(xml.@id), bitmapData,x,y);
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