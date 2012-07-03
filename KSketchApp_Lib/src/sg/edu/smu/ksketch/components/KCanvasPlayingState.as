/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.components
{
	import flash.events.Event;
	
	import sg.edu.smu.ksketch.utilities.KAppState;
	import sg.edu.smu.ksketch.interactor.KSelection;

	public class KCanvasPlayingState implements ICanvasClockState
	{
		protected var _appState:KAppState;
		protected var _widget:IWidget;
		
		protected var _savedSelection:KSelection;
		protected var _savedVisibility:Boolean;
		
		public function KCanvasPlayingState(appState:KAppState, widget:IWidget)
		{
			_appState = appState;
			_widget = widget;
		}
		
		public function entry():void
		{
			_savedSelection = _appState.selection;
			_appState.selection = null;
			_savedVisibility = _widget.visible;
			_widget.visible = false;
		}
		
		public function exit():void
		{
			_appState.selection = _savedSelection;
			_widget.visible = _savedVisibility;
		}
	}
}