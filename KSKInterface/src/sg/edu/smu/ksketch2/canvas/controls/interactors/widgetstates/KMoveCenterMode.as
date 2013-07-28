package sg.edu.smu.ksketch2.canvas.controls.interactors.widgetstates
{
	import flash.display.DisplayObject;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.KSketchStyles;
	import sg.edu.smu.ksketch2.canvas.components.transformWidget.KSketch_Widget_Component;
	import sg.edu.smu.ksketch2.canvas.controls.KInteractionControl;
	import sg.edu.smu.ksketch2.canvas.controls.interactors.KMoveCenterInteractor;
	
	/**
	 * The KMoveCenterMode class serves as the concrete class for move
	 * center mode in K-Sketch.
	 */
	public class KMoveCenterMode extends KWidgetMode implements IWidgetMode
	{
		private var _centerInteractor:KMoveCenterInteractor; 	// the move center interactor instance
		
		/**
		 * The main constructor of the KMoveCenterMode class.
		 * 
		 * @param KSketchInstance The ksketch instance.
		 * @param interactionControl The interaction control.
		 * @param widget The sketch widget component.
		 * @param modelSpace The model space.
		 */
		public function KMoveCenterMode(KSketchInstance:KSketch2, interactionControl:KInteractionControl, widget:KSketch_Widget_Component, modelSpace:DisplayObject)
		{
			super(KSketchInstance, interactionControl, widget);
			_centerInteractor = new KMoveCenterInteractor(KSketchInstance, interactionControl, widget, modelSpace);
		}
		
		override public function activate():void
		{
			// activate the widget mode
			super.activate();
			
			// activate the move center interactor
			_centerInteractor.activate();
			
			// enable the move center interactor
			enabled = true;
		}
		
		override public function deactivate():void
		{
			// deactivate the widget mode
			super.deactivate();
			
			// deactivate the move center interactor
			_centerInteractor.deactivate();
			
			// disable the move center interactor
			enabled = false;
		}
		
		override public function set enabled(value:Boolean):void
		{
			// set the widget's alpha value to the enabled color
			_widget.alpha = KSketchStyles.WIDGET_ENABLED_ALPHA;
			
			// case: the widget is enabled
			// set the the trigger disabled alpha values
			if(value)
			{
				_widget.baseTrigger.alpha = KSketchStyles.WIDGET_DISABLED_ALPHA;
				_widget.middleTrigger.alpha = KSketchStyles.WIDGET_DISABLED_ALPHA;
				_widget.topTrigger.alpha = KSketchStyles.WIDGET_DISABLED_ALPHA;
			}
			// case: the widget is disabled
			// set the trigger enabled alpha values
			else
			{
				_widget.baseTrigger.alpha = KSketchStyles.WIDGET_ENABLED_ALPHA;
				_widget.middleTrigger.alpha = KSketchStyles.WIDGET_ENABLED_ALPHA;
				_widget.topTrigger.alpha = KSketchStyles.WIDGET_ENABLED_ALPHA;
			}
		}
	}
}