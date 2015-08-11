package sg.edu.smu.ksketch2.canvas.components.popup
{
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import spark.components.Image;
	import spark.layouts.HorizontalLayout;
	
	import sg.edu.smu.ksketch2.KSketchAssets;
	import sg.edu.smu.ksketch2.KSketchGlobals;
	import sg.edu.smu.ksketch2.KSketch_Config;
	import sg.edu.smu.ksketch2.canvas.components.buttons.KSketch_DialogButton;

	public class KSketch_DialogBox_Help
	{
		private var PADDINGLEFT:Number = 10 * KSketchGlobals.SCALE;
		
		private var _dialogPopUp:KSketch_DialogBox_Skin;
		private var _image:Image;
		private var _moreButton:KSketch_DialogButton;
		private var _closeButton:KSketch_DialogButton;
		
		public function KSketch_DialogBox_Help(dialogPopUp:KSketch_DialogBox_Skin)
		{
			_dialogPopUp = dialogPopUp;
			_dialogPopUp.header.text = "Help";
			_dialogPopUp.header.setStyle("fontSize", KSketchGlobals.FONT_SIZE_26);
			
			_initContentComponent();
			_initButtonComponent();
		}
		
		private function _initContentComponent():void
		{
			var horizontalLayout:HorizontalLayout = new HorizontalLayout();
			horizontalLayout.verticalAlign = "middle";
			_dialogPopUp.contentComponent.layout = horizontalLayout;
			
			_image = new Image();
			_image.source = KSketchAssets.image_help;
			
			if(KSketchGlobals.SCALE == 1)
			{
				_image.width = 600;
				_image.height = 410;
			}
			
			_dialogPopUp.contentComponent.addElement(_image);
		}
		
		private function _initButtonComponent():void
		{
			_dialogPopUp.buttonComponent.percentWidth = 100;
			var horizontalLayout:HorizontalLayout = new HorizontalLayout();
			horizontalLayout.horizontalAlign = "right";
			horizontalLayout.paddingLeft = PADDINGLEFT;
			_dialogPopUp.buttonComponent.layout = horizontalLayout;
			
			_moreButton = new KSketch_DialogButton();
			_moreButton.init("More");
			_moreButton.initSkin();
			_moreButton.addEventListener(MouseEvent.CLICK, _more);
			
			_closeButton = new KSketch_DialogButton();
			_closeButton.init("Close");
			_closeButton.initSkin();
			_closeButton.addEventListener(MouseEvent.CLICK, _close);
			
			_dialogPopUp.buttonComponent.addElement(_moreButton);
			_dialogPopUp.buttonComponent.addElement(_closeButton);
		}
		
		private function _more(event:MouseEvent):void
		{
			_moreButton.removeEventListener(MouseEvent.CLICK, _more);
			navigateToURL(new URLRequest(KSketch_Config.host_name+"/app/help.html"),"_blank");
			
			_closeButton.removeEventListener(MouseEvent.CLICK, _close);
			_dialogPopUp.close();
		}
		
		private function _close(event:MouseEvent):void
		{
			_closeButton.removeEventListener(MouseEvent.CLICK, _close);
			_dialogPopUp.close();
		}
	}
}