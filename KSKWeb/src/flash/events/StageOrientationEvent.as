package flash.events
{
	public class StageOrientationEvent extends Event
	{
		static public const ORIENTATION_CHANGE:String = "orientationChange";
		static public const ORIENTATION_CHANGING:String = "orientationChanging";
		
		public function StageOrientationEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}