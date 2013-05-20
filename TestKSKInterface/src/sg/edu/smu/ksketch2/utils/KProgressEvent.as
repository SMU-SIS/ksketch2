package sg.edu.smu.ksketch2.utils
{
	import flash.events.Event;
	
	public class KProgressEvent extends Event
	{
		public var progress:Number;
		
		public function KProgressEvent(type:String, progress:Number)
		{
			super(type);
			
			this.progress = progress;
		}
	}
}