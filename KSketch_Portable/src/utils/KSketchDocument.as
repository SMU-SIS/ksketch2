package utils
{
	[Bindable]
	public class KSketchDocument
	{
		public var xml:XML;
		public var name:String;
		public var id:String;
		public var date:Number
		
		public function KSketchDocument(name:String, xml:XML, id:String, date:Number = 0)
		{
			this.xml = xml;
			this.name = name;
			this.id = id;
			this.date = date;
		}		
	}
}