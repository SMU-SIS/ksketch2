package sg.edu.smu.ksketch2.canvas.controls.interactors.widgetstates
{
	import flash.display.DisplayObject;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.KSketchStyles;
	import sg.edu.smu.ksketch2.canvas.components.transformWidget.KSketch_Widget_Component;
	import sg.edu.smu.ksketch2.canvas.controls.KInteractionControl;
	import sg.edu.smu.ksketch2.canvas.controls.interactors.KMoveCenterInteractor;
	
	public class KMoveCenterMode extends KWidgetMode implements IWidgetMode
	{
		private var _centerInteractor:KMoveCenterInteractor;
		
		public function KMoveCenterMode(KSketchInstance:KSketch2, interactionControl:KInteractionControl, widget:KSketch_Widget_Component
										,modelSpace:DisplayObject)
		{
			super(KSketchInstance, interactionControl, widget);
			_centerInteractor = new KMoveCenterInteractor(KSketchInstance, interactionControl, widget.centroid, modelSpace);
		}
		
		override public function activate():void
		{
			super.activate();
			_centerInteractor.activate();
			enabled = true;
		}
		
		override public function deactivate():void
		{
			super.deactivate();
			_centerInteractor.deactivate();
			enabled = false;
		}
		
		override public function set enabled(value:Boolean):void
		{
			_widget.alpha = KSketchStyles.WIDGET_ENABLED_ALPHA;
			
			if(value)
			{
				_widget.baseTrigger.alpha = KSketchStyles.WIDGET_DISABLED_ALPHA;
				_widget.middleTrigger.alpha = KSketchStyles.WIDGET_DISABLED_ALPHA;
				_widget.topTrigger.alpha = KSketchStyles.WIDGET_DISABLED_ALPHA;
			}
			else
			{
				_widget.baseTrigger.alpha = KSketchStyles.WIDGET_ENABLED_ALPHA;
				_widget.middleTrigger.alpha = KSketchStyles.WIDGET_ENABLED_ALPHA;
				_widget.topTrigger.alpha = KSketchStyles.WIDGET_ENABLED_ALPHA;
			}
		}
	}
}