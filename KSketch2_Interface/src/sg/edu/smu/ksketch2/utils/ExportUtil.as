package sg.edu.smu.ksketch2.utils
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	
	import leelib.util.flvEncoder.ByteArrayFlvEncoder;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.view.KModelDisplay;

	public class ExportUtil
	{
		public static var exportedContent:ByteArray;

		public static const WIDTH_480P:Number = 854;
		public static const HEIGHT_480P:Number = 480;
		
		
		public static function convertSceneToFLVBytes(display:KModelDisplay, ksketch:KSketch2):Vector.<BitmapData>
		{
			var captureArea:Rectangle = new Rectangle(0,0,WIDTH_480P,HEIGHT_480P);
			var drawnFrames:Vector.<BitmapData> = new Vector.<BitmapData>();
			
			var currentTime:int = 0;
			var endTime:int = ksketch.maxTime;
			var currentFrame:BitmapData;
			
			var toScaleX:Number = KSketch2.CANONICAL_WIDTH/captureArea.width;
			var toScaleY:Number = KSketch2.CANONICAL_HEIGHT/captureArea.height;
			var matrix:Matrix = new Matrix();
			matrix.scale(1/toScaleX, 1/toScaleY);
			
			while(currentTime <= endTime)
			{
				ksketch.time = currentTime;
				currentFrame = new BitmapData(captureArea.width, captureArea.height, false, 0xFFFFFF);	
				currentFrame.draw(display, matrix);				
				drawnFrames.push(currentFrame);
				currentTime += KSketch2.ANIMATION_INTERVAL;				
			}
			
			return drawnFrames;
		}
	}
}