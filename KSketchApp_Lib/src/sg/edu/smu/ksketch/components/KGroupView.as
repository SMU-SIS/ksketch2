/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package sg.edu.smu.ksketch.components
{	
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.utilities.KAppState;
	
	public class KGroupView extends KObjectView
	{
		public function KGroupView(appState:KAppState, group:KGroup)
		{
			super(appState,group);
			this.mouseEnabled = false;
			updateVisibility(group.getVisibility(time));
			updateTransform(group.getFullMatrix(group.createdTime));
		}		
	}
}