package sg.edu.smu.ksketch2.controls.interactors.widgetstates
{
	import flash.display.DisplayObject;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.canvas.components.transformWidget.KTouchWidgetBase;
	import sg.edu.smu.ksketch2.canvas.controls.KMobileInteractionControl;
	import sg.edu.smu.ksketch2.controls.interactors.transitions.KTouchRotateInteractor;
	import sg.edu.smu.ksketch2.controls.interactors.transitions.KTouchScaleInteractor;
	import sg.edu.smu.ksketch2.controls.interactors.transitions.KTouchTranslateInteractor;
	
	public class KBasicTransitionMode extends KTouchWidgetMode
	{
		public static const TOP_TRIGGER_RADIUS:Number = 80;
		public static const MIDDLE_TRIGGER_RADIUS:Number = 120;
		public static const BASE_TRIGGER_RADIUS:Number = 160;
		
		private var _translateInteractor:KTouchTranslateInteractor;
		private var _rotateInteractor:KTouchRotateInteractor;
		private var _scaleInteractor:KTouchScaleInteractor;
		
		public function KBasicTransitionMode(KSketchInstance:KSketch2, interactionControl:KMobileInteractionControl, widgetBase:KTouchWidgetBase
											,modelSpace:DisplayObject)
		{
			super(KSketchInstance, interactionControl, widgetBase);
			
			_translateInteractor = new KTouchTranslateInteractor(KSketchInstance, interactionControl, widgetBase.middleTrigger, modelSpace);
			_rotateInteractor = new KTouchRotateInteractor(KSketchInstance, interactionControl, widgetBase.topTrigger, modelSpace);
			_scaleInteractor = new KTouchScaleInteractor(KSketchInstance, interactionControl, widgetBase.baseTrigger, modelSpace);
		}
		
		override public function activate():void
		{
			demonstrationMode = false;
			_translateInteractor.activate();
			_rotateInteractor.activate();
			_scaleInteractor.activate();
			
			super.activate();
		}
		
		override public function deactivate():void
		{
			_translateInteractor.deactivate();
			_rotateInteractor.deactivate();
			_scaleInteractor.deactivate();
			
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
				_widget.strokeColor = 0x6E6F71;
				_widget.centroid.graphics.lineStyle(2, 0x58595B);
				_widget.centroid.graphics.beginFill(0x971C24);
				_widget.centroid.graphics.drawCircle(0,0,10);
				_widget.centroid.graphics.endFill();
			}
			else
			{
				_widget.strokeColor = 0x971C24;
				_widget.centroid.graphics.lineStyle(2, 0x58595B);
				_widget.centroid.graphics.beginFill(0x971C24);
				_widget.centroid.graphics.drawCircle(0,0,10);
				_widget.centroid.graphics.endFill();
			}
		}
	}
}