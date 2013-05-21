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
	public class KVisibilityKey extends KKeyFrame implements IVisibilityKey
	{
		private var _visible:Boolean;
		
		public function KVisibilityKey(newTime:int)
		{
			super(newTime);
			_visible = false;
		}
		
		public function get visible():Boolean
		{
			return _visible;
		}
		
		public function set visible(value:Boolean):void
		{
			_visible = value;
		}
		
		override public function serialize():XML
		{
			var keyXML:XML = <visibilitykey time="0" visibility="false"/>;
			
			keyXML.@time = _time.toString();
			keyXML.@visibility = _visible.toString();
			
			return keyXML;
		}
		
		override public function deserialize(xml:XML):void
		{
			
		}
	}
}