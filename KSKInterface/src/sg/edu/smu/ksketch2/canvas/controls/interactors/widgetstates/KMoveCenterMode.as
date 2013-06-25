package sg.edu.smu.ksketch2.canvas.controls.interactors.widgetstates
{
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.KSketchStyles;
	import sg.edu.smu.ksketch2.canvas.components.transformWidget.KSketch_Widget_Component;
	import sg.edu.smu.ksketch2.canvas.controls.KInteractionControl;
	
	public class KMoveCenterMode extends KWidgetMode implements IWidgetMode
	{
		
		
		public function KMoveCenterMode(KSketchInstance:KSketch2, interactionControl:KInteractionControl, widgetBase:KSketch_Widget_Component)
		{
			super(KSketchInstance, interactionControl, widgetBase);
		}
		
		override public function activate():void
		{
			super.activate();
		}
		
		override public function deactivate():void
		{
			super.deactivate();
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