package views.document.scrollerColumn
{
	import flash.events.Event;
	
	import utils.KSketchDocument;
	
	public class KDocumentSelectedEvent extends Event
	{
		public static const DOCUMENT_SELECTED:String = "docSelected";
		
		public var selectedDocument:KSketchDocument;
		
		public function KDocumentSelectedEvent(type:String, doc:KSketchDocument, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			selectedDocument = doc;
		}
	}
}