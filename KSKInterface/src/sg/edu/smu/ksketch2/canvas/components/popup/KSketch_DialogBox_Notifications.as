package sg.edu.smu.ksketch2.canvas.components.popup
{
	import flash.events.MouseEvent;
	
	import spark.components.Label;
	import spark.layouts.HorizontalLayout;
	
	import sg.edu.smu.ksketch2.KSketchGlobals;
	import sg.edu.smu.ksketch2.KSketch_Config;
	import sg.edu.smu.ksketch2.canvas.components.buttons.KSketch_DialogButton;
	import sg.edu.smu.ksketch2.canvas.components.view.KSketch_HomeView;

	public class KSketch_DialogBox_Notifications
	{
		public static const CANVASNOTICE_FAILED_SKETCH:String = "FAILEDSKETCH";
		public static const CANVASNOTICE_FAILED_LOGIN:String = "FAILEDLOGIN";
		public static const CANVASNOTICE_EXPIRED_SESSION:String = "EXPIREDSESSION";
		
		private var PADDINGLEFT:Number = 10 * KSketchGlobals.SCALE;
		
		private var _homeView:KSketch_HomeView;
		private var _dialogPopUp:KSketch_DialogBox_Skin;
		private var _failedMessage:String;
		private var _label:Label;
		private var _yesButton:KSketch_DialogButton;
		private var _okButton:KSketch_DialogButton;
		
		public function KSketch_DialogBox_Notifications(dialogPopUp:KSketch_DialogBox_Skin, homeView:KSketch_HomeView, message:String)
		{
			_dialogPopUp = dialogPopUp;
			_dialogPopUp.header.setStyle("fontSize", KSketchGlobals.FONT_SIZE_26);
			
			_homeView = homeView;
			
			_failedMessage = message;
			if(_failedMessage == CANVASNOTICE_FAILED_SKETCH)
			{
				_failedMessage = "Unable to display sketch. Check your network connection or\ncontact the K-Sketch team at " + KSketch_Config.email;
				_dialogPopUp.header.text = "Network Error";
			}
			else if(_failedMessage == CANVASNOTICE_FAILED_LOGIN)
			{
				_failedMessage = "Unable to login. Check your network connection or\ncontact the K-Sketch team at " + KSketch_Config.email;
				_dialogPopUp.header.text = "Login Error";
			}
			else if(_failedMessage == CANVASNOTICE_EXPIRED_SESSION)
			{
				_failedMessage = "Your K-Sketch session has expired. Please login to retrieve your sketches. Do you want to login now?";
				_dialogPopUp.header.text = "Session Expired";
				
			}
			
			_initContentComponent();
			_initButtonComponent();
		}
		
		private function _initContentComponent():void
		{
			var horizontalLayout:HorizontalLayout = new HorizontalLayout();
			horizontalLayout.verticalAlign = "middle";
			_dialogPopUp.contentComponent.layout = horizontalLayout;
			
			_label = new Label();
			
			if(_failedMessage == CANVASNOTICE_FAILED_SKETCH)
				_label.text = "Unable to display sketch. Check your network connection or\ncontact the K-Sketch team at " + KSketch_Config.email;
			else if(_failedMessage == CANVASNOTICE_FAILED_LOGIN)
				_label.text = "Unable to login. Check your network connection or\ncontact the K-Sketch team at " + KSketch_Config.email;
			else if(_failedMessage == CANVASNOTICE_EXPIRED_SESSION)
				_label.text = "Your K-Sketch session has expired. Please login to retrieve your sketches. Do you want to login now?";
			
			_dialogPopUp.contentComponent.addElement(_label);
		}
		
		private function _initButtonComponent():void
		{
			_dialogPopUp.buttonComponent.percentWidth = 100;
			var horizontalLayout:HorizontalLayout = new HorizontalLayout();
			horizontalLayout.horizontalAlign = "right";
			horizontalLayout.paddingLeft = PADDINGLEFT;
			_dialogPopUp.buttonComponent.layout = horizontalLayout;
			
			_yesButton = new KSketch_DialogButton();
			_yesButton.init("Yes");
			_yesButton.initSkin();
			_yesButton.addEventListener(MouseEvent.CLICK, _login);
			
			_okButton = new KSketch_DialogButton();
			if(_failedMessage == CANVASNOTICE_EXPIRED_SESSION)
			{
				_okButton.init("NO");
				_yesButton.setVisible(true);
			}
			else
			{
				_okButton.init("OK");
				_yesButton.setVisible(false);
			}
			_okButton.initSkin();
			_okButton.addEventListener(MouseEvent.CLICK, _close);
			
			_dialogPopUp.buttonComponent.addElement(_yesButton);
			_dialogPopUp.buttonComponent.addElement(_okButton);
		}
		
		private function _login(event:MouseEvent):void
		{
			_yesButton.removeEventListener(MouseEvent.CLICK, _login);
			_homeView.navigateToScreen('RELOGIN');
			
			_okButton.removeEventListener(MouseEvent.CLICK, _close);
			_dialogPopUp.close();
		}
		
		private function _close(event:MouseEvent):void
		{
			_okButton.removeEventListener(MouseEvent.CLICK, _close);
			_dialogPopUp.close();
		}
	}
}