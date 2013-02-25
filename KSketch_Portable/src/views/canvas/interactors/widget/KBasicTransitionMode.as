package views.canvas.interactors.widget
{
	import sg.edu.smu.ksketch2.KSketch2;
	
	import views.canvas.components.transformWidget.KTouchWidgetBase;
	import views.canvas.interactioncontrol.KMobileInteractionControl;
	import views.canvas.interactors.KTouchRotateInteractor;
	import views.canvas.interactors.KTouchScaleInteractor;
	import views.canvas.interactors.KTouchTranslateInteractor;
	
	public class KBasicTransitionMode extends KTouchWidgetMode
	{
		private var _translateInteractor:KTouchTranslateInteractor;
		private var _rotateInteractor:KTouchRotateInteractor;
		private var _scaleInteractor:KTouchScaleInteractor;
		
		public function KBasicTransitionMode(KSketchInstance:KSketch2, interactionControl:KMobileInteractionControl, widgetBase:KTouchWidgetBase)
		{
			super(KSketchInstance, interactionControl, widgetBase);
			
			_translateInteractor = new KTouchTranslateInteractor(KSketchInstance, interactionControl, widgetBase.topTrigger);
			_rotateInteractor = new KTouchRotateInteractor(KSketchInstance, interactionControl, widgetBase.middleTrigger);
			_scaleInteractor = new KTouchScaleInteractor(KSketchInstance, interactionControl, widgetBase);
		}
		
		override public function activate():void
		{
			demonstrationMode = false;
			_translateInteractor.activate();
			_rotateInteractor.activate();
			_scaleInteractor.activate();
		}
		
		override public function deactivate():void
		{
			_translateInteractor.deactivate();
			_rotateInteractor.deactivate();
			_scaleInteractor.deactivate();
		}
		
		override public function set demonstrationMode(value:Boolean):void
		{
			if(!value)
			{
				_widget.middleTrigger.graphics.clear();
				_widget.middleTrigger.graphics.beginFill(KTouchWidgetBase.COLOR1, 0.6);
				_widget.middleTrigger.graphics.drawCircle(0,0,200);
				_widget.middleTrigger.graphics.drawCircle(0,0,150);
				_widget.middleTrigger.graphics.endFill();
				
				_widget.topTrigger.graphics.clear();
				_widget.topTrigger.graphics.beginFill(KTouchWidgetBase.COLOR2, 0.6);
				_widget.topTrigger.graphics.drawCircle(0,0,150);
				_widget.topTrigger.graphics.drawCircle(0,0,30);
				_widget.topTrigger.graphics.endFill();
				
				_widget.centroid.graphics.clear()
				_widget.centroid.graphics.beginFill(KTouchWidgetBase.COLOR_BASE, 0.6);
				_widget.centroid.graphics.drawCircle(0,0,30);
				_widget.centroid.graphics.endFill();
			}
			else
			{
				_widget.middleTrigger.graphics.clear();
				_widget.middleTrigger.graphics.beginFill(KTouchWidgetBase.COLOR4, 0.6);
				_widget.middleTrigger.graphics.drawCircle(0,0,200);
				_widget.middleTrigger.graphics.drawCircle(0,0,150);
				_widget.middleTrigger.graphics.endFill();
				
				_widget.topTrigger.graphics.clear();
				_widget.topTrigger.graphics.beginFill(KTouchWidgetBase.COLOR3, 0.6);
				_widget.topTrigger.graphics.drawCircle(0,0,150);
				_widget.topTrigger.graphics.drawCircle(0,0,30);
				_widget.topTrigger.graphics.endFill();
				
				_widget.centroid.graphics.clear()
				_widget.centroid.graphics.beginFill(KTouchWidgetBase.COLOR_BASE, 0.6);
				_widget.centroid.graphics.drawCircle(0,0,30);
				_widget.centroid.graphics.endFill();
			}
		}
	}
}