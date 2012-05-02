/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

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