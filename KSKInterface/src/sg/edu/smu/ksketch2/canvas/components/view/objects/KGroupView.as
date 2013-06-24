/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.canvas.components.view.objects
{
	import sg.edu.smu.ksketch2.events.KObjectEvent;
	import sg.edu.smu.ksketch2.model.objects.KObject;

	public class KGroupView extends KObjectView
	{
		public function KGroupView(object:KObject)
		{
			super(object);
			_ghost = new KGroupGhost();
			addChild(_ghost);
			
			if(_object.id == 0)
				_ghost.visible = true;
		}
		
		override protected function _updateSelection(event:KObjectEvent):void
		{
			super._updateSelection(event);
		}
	}
}