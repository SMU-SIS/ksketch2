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