/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.view.objects
{
	import sg.edu.smu.ksketch2.events.KObjectEvent;
	import sg.edu.smu.ksketch2.model.objects.KObject;

	public class KGroupView extends KObjectView
	{
		private var _glowFilter:Array;
		
		public function KGroupView(object:KObject)
		{
			super(object);
			_ghost = new KGroupGhost();
			addChild(_ghost);
		}
		
		override protected function _updateSelection(event:KObjectEvent):void
		{
			super._updateSelection(event);
		}
	}
}