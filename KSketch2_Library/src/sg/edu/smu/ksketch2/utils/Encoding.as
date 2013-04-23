package sg.edu.smu.ksketch2.utils
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class Encoding
	{
		public static function encodeBMP(bitmapData:BitmapData):ByteArray {
			
			// image/file properties
			var bmpWidth:int = bitmapData.width;
			var bmpHeight:int = bitmapData.height;
			var imageBytes:ByteArray = bitmapData.getPixels(bitmapData.rect);
			var imageSize:int = imageBytes.length;
			var imageDataOffset:int = 0x36;
			var fileSize:int = imageSize + imageDataOffset;
			
			// binary BMP data
			var bmpBytes:ByteArray = new ByteArray();
			bmpBytes.endian = Endian.LITTLE_ENDIAN; // byte order
			
			// header information
			bmpBytes.length = fileSize;
			bmpBytes.writeByte(0x42); // B
			bmpBytes.writeByte(0x4D); // M (BMP identifier)
			bmpBytes.writeInt(fileSize); // file size
			bmpBytes.position = 0x0A; // offset to image data
			bmpBytes.writeInt(imageDataOffset);
			bmpBytes.writeInt(0x28); // header size
			bmpBytes.position = 0x12; // width, height
			bmpBytes.writeInt(bmpWidth);
			bmpBytes.writeInt(bmpHeight);
			bmpBytes.writeShort(1); // planes (1)
			bmpBytes.writeShort(32); // color depth (32 bit)
			bmpBytes.writeInt(0); // compression type
			bmpBytes.writeInt(imageSize); // image data size
			bmpBytes.position = imageDataOffset; // start of image data...
			
			// write pixel bytes in upside-down order
			// (as per BMP format)
			var col:int = bmpWidth;
			var row:int = bmpHeight;
			var rowLength:int = col * 4; // 4 bytes per pixel (32 bit)
			try {
				
				// make sure we're starting at the
				// beginning of the image data
				imageBytes.position = 0;
				
				// bottom row up
				while (row--) {
					// from end of file up to imageDataOffset
					bmpBytes.position = imageDataOffset + row*rowLength;
					
					// read through each column writing
					// those bits to the image in normal
					// left to rightorder
					col = bmpWidth;
					while (col--) {
						bmpBytes.writeInt(imageBytes.readInt());
					}
				}
				
			}catch(error:Error){
				// end of file
			}
			
			// return BMP file
			return bmpBytes;
		}
	}
}