/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.utils
{
	import mx.collections.ArrayCollection;
	
	import sg.edu.smu.ksketch2.KSketch_UserSketches;

	/**
 	 * The KSketchDocument class serves as the concrete class for handling
 	 * sketch documents in K-Sketch.
 	 */
	[Bindable]
	public class KSketchDocument
	{
		public var xml:XML;
		public var name:String;
		public var id:String;
		public var lastEdited:Date
		public var description:String
		public var originalName:String
		public var originalVersion:int;
		public var originalSketch:int;
		public var version:String;
		public var sketchId:int;
		
		/**
 		 * The main constructor of the KSketchDocument class. Sets the
 		 * sketch document's various information.
 		 * 
 		 * @param name The target name.
 		 * @param xml The target XML object.
 		 * @param id The target ID.
 		 * @param date The target date.
 		 * @param description The target description.
 		 */
		public function KSketchDocument(name:String, xml:XML, id:String,  date:Date, originalName:String, version:int, sketchId:int, description:String = "")
		{
			this.xml = xml;						//The model itself, the <scene> tag
			this.name = name;					//The title of the document, user defined
			this.id = id;						//The server generated UID for this KSketch document instance
			this.lastEdited = date;				//The last time this document is changed/saved
			this.description = description;		//A short description of this document, user defined
			
			if(sketchId || sketchId > 0)
				this.sketchId = sketchId;
			else
				this.sketchId = -1;
				
			if(originalName || originalName != "")
				this.originalName = originalName;	
			else
				this.originalName = name;
			
			this.originalVersion = version;
			
			if(version == 0)
				this.version = "";
			else
				this.version = "" + version;
			
			this.originalSketch = this.sketchId;

		}
	}
}