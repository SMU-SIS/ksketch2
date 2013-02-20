package views.document
{
	[Bindable]
	public class KSketchDocument
	{
		public var xml:XML;
		public var name:String;
		public var id:String;
		
		public function KSketchDocument(name:String, xml:XML, id:String)
		{
			this.xml = xml;
			this.name = name;
			this.id = id;
		}
	}
}