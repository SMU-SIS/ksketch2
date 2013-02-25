package views.canvas.interactors.widget
{
	import sg.edu.smu.ksketch2.KSketch2;
	
	import views.canvas.components.transformWidget.KTouchWidgetBase;
	import views.canvas.interactioncontrol.KMobileInteractionControl;
	
	public class KSteeringMode extends KTouchWidgetMode
	{
		public function KSteeringMode(KSketchInstance:KSketch2, interactionControl:KMobileInteractionControl, widgetBase:KTouchWidgetBase)
		{
			super(KSketchInstance, interactionControl, widgetBase);
		}
	}
}