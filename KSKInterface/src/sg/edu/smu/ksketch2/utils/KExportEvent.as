package sg.edu.smu.ksketch2.utils
{
	import flash.display.BitmapData;
	import flash.events.Event;
	
	public class KExportEvent extends Event
	{
		public static const EVENT_EXPORT:String = "export save";
		
		public var data:Vector.<BitmapData>;
		
		public function KExportEvent(type:String, exportData:Vector.<BitmapData>)
		{
			super(type);
			
			data = exportData;
		}
	}
}