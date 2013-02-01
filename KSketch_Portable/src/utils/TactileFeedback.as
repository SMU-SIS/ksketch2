package utils
{
	import com.adobe.nativeExtensions.Vibration;

	public class TactileFeedback
	{
		public static const SHORT_VIBRATION:Number = 25;
		public static const MEDIUM_VIBRATION:Number = 150;
		public static const LONG_VIBRATION:Number = 500;
		
		public function TactileFeedback()
		{
			
		}
		
		public static function get isAvailable():Boolean
		{
			return Vibration.isSupported;
		}
		
		public static function vibrate(duration:Number = SHORT_VIBRATION):void
		{			
			if(Vibration.isSupported)
			{
				var vibration:Vibration = new Vibration();
				vibration.vibrate(duration);
			}
		}
	}
}