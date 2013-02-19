package views.startup.document
{
	public class KSketchDocument
	{
		public var xml:XML;
		public var name:String;
		
		public function KSketchDocument(name:String, xml:XML)
		{
			this.xml = xml;
			this.name = name;
		}
	}
}