/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.controls.inputmethods
{
	import mx.core.UIComponent;
	
	import sg.edu.smu.ksketch2.controls.interactioncontrol.IInteractionControl;
	import sg.edu.smu.ksketch2.controls.widgets.KWidget;
	import sg.edu.smu.ksketch2.view.KModelDisplay;

	/**
	 * The IInteractionMethod interface adds the necessary listeners to the input component
	 */
	public interface IInteractionMethod
	{
		function init(inputComponent:UIComponent, interactionControl:IInteractionControl, widget:KWidget, display:KModelDisplay):void;
	}

}