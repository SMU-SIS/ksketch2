package views.canvas.interactors.widget
{
	import flash.display.DisplayObject;
	
	import sg.edu.smu.ksketch2.KSketch2;
	
	import views.canvas.components.transformWidget.KTouchWidgetBase;
	import views.canvas.interactioncontrol.KMobileInteractionControl;
	import views.canvas.interactors.KTouchFreeTransformInteractor;
	
	public class KFreeTransformMode extends KTouchWidgetMode
	{
		private var _freeTransformInteractor:KTouchFreeTransformInteractor;
		
		public function KFreeTransformMode(KSketchInstance:KSketch2, interactionControl:KMobileInteractionControl,
										   widgetBase:KTouchWidgetBase, modelSpace:DisplayObject)
		{
			super(KSketchInstance, interactionControl, widgetBase);
			_freeTransformInteractor = new KTouchFreeTransformInteractor(KSketchInstance, interactionControl, widgetBase, modelSpace);
		}
		
		override public function activate():void
		{
			demonstrationMode = false;
			_freeTransformInteractor.activate();
		}
		
		override public function deactivate():void
		{
			_freeTransformInteractor.deactivate();
		}
		
		override public function set demonstrationMode(value:Boolean):void
		{
			_widget.reset();
			
			if(!value)
			{
				_widget.middleTrigger.graphics.beginFill(KTouchWidgetBase.COLOR1, 0.6);
				_widget.middleTrigger.graphics.drawCircle(0,0,200);
				_widget.middleTrigger.graphics.endFill();
			}
			else
			{
				_widget.middleTrigger.graphics.beginFill(KTouchWidgetBase.COLOR4, 0.6);
				_widget.middleTrigger.graphics.drawCircle(0,0,200);
				_widget.middleTrigger.graphics.endFill();
			}
		}
	}
}