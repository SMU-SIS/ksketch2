/**
 * Copyright 2010-2015 Singapore Management University
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package document.scrollerColumn
{
	import flash.events.Event;
	
	import sg.edu.smu.ksketch2.utils.KSketchDocument;
	
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