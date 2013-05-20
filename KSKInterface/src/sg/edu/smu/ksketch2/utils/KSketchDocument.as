package sg.edu.smu.ksketch2.utils
{
	[Bindable]
	public class KSketchDocument
	{
		public var xml:XML;
		public var name:String;
		public var id:String;
		public var lastEdited:Number
		public var description:String
		
		public function KSketchDocument(name:String, xml:XML, id:String,  date:Number = 0, description:String = "")
		{
			this.xml = xml;
			this.name = name;
			this.id = id;
			this.lastEdited = date;
			this.description = description;
		}		
	}
}