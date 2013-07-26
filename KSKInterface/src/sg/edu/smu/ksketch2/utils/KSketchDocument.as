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
	/**
	 * The KSketchDocument class serves as the concrete class for handling
	 * sketch documents in K-Sketch.
	 */
	[Bindable]
	public class KSketchDocument
	{
		/**
		 * The sketch document's XML object.
		 */
		public var xml:XML;
		
		/**
		 * The sketch document's name.
		 */
		public var name:String;
		
		/**
		 * The sketch document's ID.
		 */
		public var id:String;
		
		/**
		 * The sketch document's last edited time.
		 */
		public var lastEdited:Number
		
		/**
		 * The sketch document's description.
		 */
		public var description:String
		
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