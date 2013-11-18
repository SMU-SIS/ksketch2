/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.canvas.controls
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.StageOrientationEvent;
	import flash.display.StageOrientation;

	public class KOrientationControl
	{
		private var _stage:Stage;
		
		public function KOrientationControl(stage:Stage)
		{
			_stage = stage;
		}
		
		public function init(event:Event):void
		{
			_stage.setAspectRatio("landscape");
			_stage.autoOrients=true;
			preventOrient();
		}
		
		private function preventOrient():void { 
			if (_stage.autoOrients) {
				_stage.removeEventListener(StageOrientationEvent.ORIENTATION_CHANGE, orientationChangedHandler);
				_stage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGE, orientationChangedHandler);
			}
		}
		
		private function orientationChangedHandler(event:StageOrientationEvent):void {
			event.stopImmediatePropagation();
			if(event.afterOrientation == StageOrientation.ROTATED_RIGHT || event.afterOrientation == StageOrientation.ROTATED_LEFT)
				trace("Inside orientationChanging(): " + _stage.orientation);
		}
		
		public function get stageWidth():int
		{
			return _stage.stageWidth;
		}
		
		public function get stageHeight():int
		{
			return _stage.stageHeight;
		}
	}
}