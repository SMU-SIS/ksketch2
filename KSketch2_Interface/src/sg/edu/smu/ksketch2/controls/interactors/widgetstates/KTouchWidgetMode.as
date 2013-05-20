package sg.edu.smu.ksketch2.controls.interactors.widgetstates
{
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.controls.components.transformWidget.KTouchWidgetBase;
	import sg.edu.smu.ksketch2.controls.interactioncontrol.KMobileInteractionControl;
	
	public class KTouchWidgetMode implements ITouchWidgetMode
	{
		protected var _KSketch:KSketch2;
		protected var _demoMode:Boolean;
		protected var _enabled:Boolean;
		protected var _activated:Boolean;
		protected var _interactionControl:KMobileInteractionControl;
		protected var _widget:KTouchWidgetBase;
		
		public function KTouchWidgetMode(KSketchInstance:KSketch2,
										 interactionControl:KMobileInteractionControl, 
										 widgetBase:KTouchWidgetBase)
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