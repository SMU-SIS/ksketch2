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
	
	/**
	 * The KWidgetMode class serves as the concrete class for widget mode
	 * in K-Sketch.
	 */
	public class KWidgetMode implements IWidgetMode
	{
		protected var _KSketch:KSketch2;							// the ksketch instance
		protected var _demoMode:Boolean;							// the demo mode boolean flag
		protected var _enabled:Boolean;								// the enabled state boolean flag
		protected var _activated:Boolean;							// the activated state boolean flag
		protected var _interactionControl:KInteractionControl;		// the interaction control
		protected var _widget:KSketch_Widget_Component;				// the widget instance
		
		/**
		 * The main constructor of the KWidgetMode class.
		 * 
		 * @param KSketchInstance The ksketch instance.
		 * @param interactionControl The interaction control.
		 * @param widgetBase The widget base component.
		 */
		public function KWidgetMode(KSketchInstance:KSketch2, interactionControl:KInteractionControl,  widgetBase:KSketch_Widget_Component)
		{
			// initialize the settings
			_KSketch = KSketchInstance;
			_interactionControl = interactionControl;
			_widget = widgetBase;
			
			// disable the boolean flags
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