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