/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.model.data_structures
{
	/**
	 * The KVisibility class serves as the concrete class that defines the core
	 * implementations of visibility key frames in K-Sketch.
	 */
	public class KVisibilityKey extends KKeyFrame implements IVisibilityKey
	{
		private var _visible:Boolean;		// visibility flag
		
		/**
		 * The main constructor of the KVisibilityKey object.
		 * 
		 * @param newTime The key frame's new time.
		 */
		public function KVisibilityKey(newTime:int)
		{
			// set the visibility key frame's time
			super(newTime);
			
			// set the visibility to invisible by default
			_visible = false;
		}
		
		/**
		 * Gets the visibility key frame's visibility status.
		 * 
		 * @return The visibility key frame's visibility status.
		 */
		public function get visible():Boolean
		{
			return _visible;
		}
		
		/**
		 * Sets the visibility key frame's visibility status.
		 * 
		 * @param value The visibility key frame's target visibility status.
		 */
		public function set visible(value:Boolean):void
		{
			_visible = value;
		}
		
		/**
		 * Serializes the visibility key frame to an XML object.
		 * 
		 * @return The serialized XML object of the visibility key frame.
		 */
		override public function serialize():XML
		{
			var keyXML:XML = <visibilitykey time="0" visibility="false"/>;
			
			keyXML.@time = _time.toString();
			keyXML.@visibility = _visible.toString();
			
			return keyXML;
		}
		
		/**
		 * Deserializes the XML object to a visibility key frame.
		 * 
		 * @param xml The target XML object.
		 */
		override public function deserialize(xml:XML):void
		{
			
		}
	}
}