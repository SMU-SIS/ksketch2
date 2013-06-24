/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.canvas.controls.interactors.widgetstates
{
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.canvas.components.transformWidget.KSketch_Widget_Component;
	import sg.edu.smu.ksketch2.canvas.controls.KInteractionControl;
	
	public class KWidgetMode implements IWidgetMode
	{
		protected var _KSketch:KSketch2;
		protected var _demoMode:Boolean;
		protected var _enabled:Boolean;
		protected var _activated:Boolean;
		protected var _interactionControl:KInteractionControl;
		protected var _widget:KSketch_Widget_Component;
		
		public function KWidgetMode(KSketchInstance:KSketch2,
										 interactionControl:KInteractionControl, 
										 widgetBase:KSketch_Widget_Component)
		{
			_KSketch = KSketchInstance;
			_interactionControl = interactionControl;
			_widget = widgetBase;
			
			_demoMode = false;
			_enabled = false;
			_activated = false;
		}
		
		public function init():void
		{
			
		}
		
		public function activate():void
		{
			if(_activated)
				return;
			else
				_activated = true;
		}
		
		public function deactivate():void
		{
			if(!_activated)
				return;
			else
				_activated = false;
		}
		
		public function set demonstrationMode(value:Boolean):void
		{
			_demoMode = value;
		}
		
		public function set enabled(value:Boolean):void
		{
									
		}
	}
}