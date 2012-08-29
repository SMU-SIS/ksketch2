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
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import sg.edu.smu.ksketch.components.KCanvas;
	import sg.edu.smu.ksketch.model.geom.KPathPoint;
	import sg.edu.smu.ksketch.utilities.KAppState;
	
	public class KInteractorTimer extends EventDispatcher
	{
		private var _appState:KAppState;
		private var _canvas:KCanvas;
		private var _interactor:IInteractor;
		private var _path:Vector.<KPathPoint>;
		
		public function KInteractorTimer(appState:KAppState,canvas:KCanvas)
		{
			_appState = appState;
			_canvas = canvas;
		}
	
		public function interact(interactor:IInteractor,path:Vector.<KPathPoint>):void
		{
			_interactor = interactor;
			_path = path;
			_appState.time = _path[0].time;
			_interactor.begin(_path[0]);
			for (var i:int=0; i < path.length; i++)
			{
				_appState.time = _path[i].time;
				_interactor.update(_path[i]);
			}
			_appState.time = _path[path.length-1].time;
			_interactor.end(_path[path.length-1]);
		}
	
		private function _interact(e:TimerEvent):void
		{
			var count:int = (e.target as Timer).currentCount-1;
			_appState.time = _path[count].time;
			if (count == _path.length-1)
				_interactor.end(_path[count]);
			else
				_interactor.update(_path[count]);
		}
		
		private function _complete(e:TimerEvent):void
		{
			dispatchEvent(new Event(KCanvas.EVENT_INTERACTION_STOP));
		}
	}
}