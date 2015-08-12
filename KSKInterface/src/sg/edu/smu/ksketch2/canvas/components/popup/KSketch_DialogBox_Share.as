package sg.edu.smu.ksketch2.canvas.components.popup
{
	import flash.events.MouseEvent;
	
	import spark.layouts.HorizontalLayout;
	import spark.layouts.VerticalLayout;
	
	import sg.edu.smu.ksketch2.KSketchAssets;
	import sg.edu.smu.ksketch2.KSketchGlobals;
	import sg.edu.smu.ksketch2.canvas.components.buttons.KSketch_CanvasButton;
	import sg.edu.smu.ksketch2.canvas.components.buttons.KSketch_DialogButton;

	public class KSketch_DialogBox_Share
	{
		private var PADDING:Number = 20 * KSketchGlobals.SCALE;
		
		private var _dialogPopUp:KSketch_DialogBox_Skin;
		private var mailButton:KSketch_CanvasButton;
		private var facebookButton:KSketch_CanvasButton;
		private var twitterButton:KSketch_CanvasButton;
		private var closeButton:KSketch_DialogButton;
		
		public function KSketch_DialogBox_Share(dialogPopUp:KSketch_DialogBox_Skin)
		{
			_dialogPopUp = dialogPopUp;
			_dialogPopUp.header.text = "Sharing Options";
			_dialogPopUp.header.setStyle("fontSize", KSketchGlobals.FONT_SIZE_26);
			
			_initContentComponent();
			_initButtonComponent();
		}
		
		private function _initContentComponent():void
		{
			var horizontalLayout:HorizontalLayout = new HorizontalLayout();
			horizontalLayout.verticalAlign = "middle";
			horizontalLayout.horizontalAlign = "center";
			horizontalLayout.gap = PADDING;
			horizontalLayout.paddingLeft = PADDING;
			horizontalLayout.paddingRight = PADDING;
			_dialogPopUp.contentComponent.layout = horizontalLayout;
			
			mailButton = new KSketch_CanvasButton();
			facebookButton = new KSketch_CanvasButton();
			twitterButton = new KSketch_CanvasButton();
			
			mailButton.init(KSketchAssets.texture_share_mail, KSketchAssets.texture_share_mail_down, false);
			mailButton.initSkin();
			mailButton.addEventListener(MouseEvent.CLICK, _shareMail);
			
			facebookButton.init(KSketchAssets.texture_share_facebook, KSketchAssets.texture_share_facebook_down, false);
			facebookButton.initSkin();
			facebookButton.addEventListener(MouseEvent.CLICK, _shareFacebook);
			
			twitterButton.init(KSketchAssets.texture_share_twitter, KSketchAssets.texture_share_twitter_down, false);
			twitterButton.initSkin();
			twitterButton.addEventListener(MouseEvent.CLICK, _shareTwitter);
			
			_dialogPopUp.contentComponent.addElement(mailButton);
			_dialogPopUp.contentComponent.addElement(facebookButton);
			_dialogPopUp.contentComponent.addElement(twitterButton);
		}
		
		private function _initButtonComponent():void
		{
			_dialogPopUp.buttonComponent.percentWidth = 100;
			var verticalLayout:VerticalLayout = new VerticalLayout();
			verticalLayout.horizontalAlign = "right";
			_dialogPopUp.buttonComponent.layout = verticalLayout;
			
			closeButton = new KSketch_DialogButton();
			closeButton.init("Close");
			closeButton.initSkin();
			closeButton.addEventListener(MouseEvent.CLICK, _close);
			
			_dialogPopUp.buttonComponent.addElement(closeButton);
		}
		
		private function _shareMail(event:MouseEvent):void
		{
			trace("Implement share through mail");
		}
		
		private function _shareFacebook(event:MouseEvent):void
		{
			trace("Implement share through facebook");
		}
		
		private function _shareTwitter(event:MouseEvent):void
		{
			trace("Implement share through twitter");
		}
		
		private function _close(event:MouseEvent):void
		{
			closeButton.removeEventListener(MouseEvent.CLICK, _close);
			_dialogPopUp.close();
		}
	}
}