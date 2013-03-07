package views.canvas.interactors.widget
{
	import flash.display.DisplayObject;
	import flash.system.Capabilities;
	
	import sg.edu.smu.ksketch2.KSketch2;
	
	import views.canvas.components.transformWidget.KTouchWidgetBase;
	import views.canvas.interactioncontrol.KMobileInteractionControl;
	import views.canvas.interactors.KTouchRotateInteractor;
	import views.canvas.interactors.KTouchScaleInteractor;
	import views.canvas.interactors.KTouchTranslateInteractor;
	
	public class KBasicTransitionMode extends KTouchWidgetMode
	{
		public static const TOP_TRIGGER_RADIUS:Number = Capabilities.screenDPI * 0.5;
		public static const MIDDLE_TRIGGER_RADIUS:Number = Capabilities.screenDPI * 0.75;
		public static const BASE_TRIGGER_RADIUS:Number = Capabilities.screenDPI;
		
		private var _translateInteractor:KTouchTranslateInteractor;
		private var _rotateInteractor:KTouchRotateInteractor;
		private var _scaleInteractor:KTouchScaleInteractor;
		
		public function KBasicTransitionMode(KSketchInstance:KSketch2, interactionControl:KMobileInteractionControl, widgetBase:KTouchWidgetBase
											,modelSpace:DisplayObject)
		{
			super(KSketchInstance, interactionControl, widgetBase);
			
			_translateInteractor = new KTouchTranslateInteractor(KSketchInstance, interactionControl, widgetBase.topTrigger, modelSpace);
			_rotateInteractor = new KTouchRotateInteractor(KSketchInstance, interactionControl, widgetBase.middleTrigger, modelSpace);
			_scaleInteractor = new KTouchScaleInteractor(KSketchInstance, interactionControl, widgetBase.baseTrigger, modelSpace);
		}
		
		override public function activate():void
		{
			demonstrationMode = false;
			_translateInteractor.activate();
			_rotateInteractor.activate();
			//_scaleInteractor.activate();
			
			super.activate();
		}
		
		override public function deactivate():void
		{
			_translateInteractor.deactivate();
			_rotateInteractor.deactivate();
			//_scaleInteractor.deactivate();
			
			super.deactivate();
		}
		
		override public function set enabled(value:Boolean):void
		{
			if(value)
				_widget.alpha = 1;
			else
				_widget.alpha = 0.2;
		}
		
		override public function set demonstrationMode(value:Boolean):void
		{
			_widget.reset();
			if(!value)
			{
				//_widget.baseTrigger.graphics.beginFill(KTouchWidgetBase.COLOR1, KTouchWidgetBase.BLEND_ALPHA);
				//_widget.baseTrigger.graphics.drawCircle(0,0,BASE_TRIGGER_RADIUS);
				//_widget.baseTrigger.graphics.drawCircle(0,0,MIDDLE_TRIGGER_RADIUS);
				//_widget.baseTrigger.graphics.endFill();
				
				_widget.middleTrigger.graphics.beginFill(KTouchWidgetBase.COLOR2, KTouchWidgetBase.BLEND_ALPHA);
				_widget.middleTrigger.graphics.drawCircle(0,0,MIDDLE_TRIGGER_RADIUS);
				_widget.middleTrigger.graphics.drawCircle(0,0,TOP_TRIGGER_RADIUS);
				_widget.middleTrigger.graphics.endFill();
				
				_widget.topTrigger.graphics.beginFill(KTouchWidgetBase.COLOR3, KTouchWidgetBase.BLEND_ALPHA);
				_widget.topTrigger.graphics.drawCircle(0,0,TOP_TRIGGER_RADIUS);
				_widget.topTrigger.graphics.endFill();
				
				_widget.topTrigger.graphics.beginFill(KTouchWidgetBase.COLOR1, KTouchWidgetBase.BLEND_ALPHA);
				_widget.topTrigger.graphics.drawCircle(0,0,TOP_TRIGGER_RADIUS*0.1);
				_widget.topTrigger.graphics.endFill();
				
			}
			else
			{
				//_widget.baseTrigger.graphics.beginFill(KTouchWidgetBase.COLOR4, KTouchWidgetBase.BLEND_ALPHA);
				//_widget.baseTrigger.graphics.drawCircle(0,0,BASE_TRIGGER_RADIUS);
				//_widget.baseTrigger.graphics.drawCircle(0,0,MIDDLE_TRIGGER_RADIUS);
				//_widget.baseTrigger.graphics.endFill();
				
				_widget.middleTrigger.graphics.beginFill(KTouchWidgetBase.COLOR4, KTouchWidgetBase.BLEND_ALPHA);
				_widget.middleTrigger.graphics.drawCircle(0,0,MIDDLE_TRIGGER_RADIUS);
				_widget.middleTrigger.graphics.drawCircle(0,0,TOP_TRIGGER_RADIUS);
				_widget.middleTrigger.graphics.endFill();
				
				_widget.topTrigger.graphics.beginFill(KTouchWidgetBase.COLOR3, KTouchWidgetBase.BLEND_ALPHA);
				_widget.topTrigger.graphics.drawCircle(0,0,TOP_TRIGGER_RADIUS);
				_widget.topTrigger.graphics.endFill();
				
				_widget.topTrigger.graphics.beginFill(KTouchWidgetBase.COLOR1, KTouchWidgetBase.BLEND_ALPHA);
				_widget.topTrigger.graphics.drawCircle(0,0,TOP_TRIGGER_RADIUS*0.1);
				_widget.topTrigger.graphics.endFill();
				
			}
		}
	}
}