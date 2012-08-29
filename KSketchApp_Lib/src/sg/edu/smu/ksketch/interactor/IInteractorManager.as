/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package sg.edu.smu.ksketch.interactor
{
	import sg.edu.smu.ksketch.components.IWidget;
	import sg.edu.smu.ksketch.components.KCanvas;
	import sg.edu.smu.ksketch.operation.KModelFacade;
	import sg.edu.smu.ksketch.utilities.KAppState;

	public interface IInteractorManager
	{
		function activateOn(facade:KModelFacade, appState:KAppState, canvas:KCanvas, widget:IWidget):void;
		function reset():void;
		function get widget():IWidget;
	}
}