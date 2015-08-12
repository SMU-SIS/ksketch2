package sg.edu.smu.ksketch2.canvas.components.popup
{
	import flash.events.MouseEvent;
	
	import spark.components.Label;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.VerticalLayout;
	
	import sg.edu.smu.ksketch2.KSketchGlobals;
	import sg.edu.smu.ksketch2.canvas.components.buttons.KSketch_DialogButton;
	import sg.edu.smu.ksketch2.canvas.components.view.KSketch_HomeView;

	public class KSketch_DialogBox_Logout
	{
		private var GAP:Number = 10 * KSketchGlobals.SCALE;
		private var PADDING:Number = 5 * KSketchGlobals.SCALE;
		
		private var _homeView:KSketch_HomeView;
		private var _dialogPopUp:KSketch_DialogBox_Skin;
		private var _label1:Label;
		private var _label2:Label;
		private var _cancelButton:KSketch_DialogButton;
		private var _logoutButton:KSketch_DialogButton;
		
		public function KSketch_DialogBox_Logout(dialogPopUp:KSketch_DialogBox_Skin, homeView:KSketch_HomeView)
		{
			_dialogPopUp = dialogPopUp;
			
			_homeView = homeView;
			
			_initContentComponent();
			_initButtonComponent();
		}
		
		private function _initContentComponent():void
		{
			var verticalLayout:VerticalLayout = new VerticalLayout();
			verticalLayout.horizontalAlign = "right";
			verticalLayout.gap = GAP;
			verticalLayout.paddingLeft = PADDING;
			verticalLayout.paddingRight = PADDING;
			verticalLayout.paddingTop = PADDING;
			verticalLayout.paddingBottom = PADDING;
			_dialogPopUp.contentComponent.layout = verticalLayout;
			
			_label1 = new Label();
			_label1.text = "You are currently disconnected.";
			
			_label2 = new Label();
			_label2.text = "Logging out will discard all unsaved changes.";
			
			_dialogPopUp.contentComponent.addElement(_label1);
			_dialogPopUp.contentComponent.addElement(_label2);
		}
		
		private function _initButtonComponent():void
		{
			_dialogPopUp.buttonComponent.percentWidth = 100;
			var horizontalLayout:HorizontalLayout = new HorizontalLayout();
			horizontalLayout.horizontalAlign = "right";
			horizontalLayout.paddingLeft = GAP;
			_dialogPopUp.buttonComponent.layout = horizontalLayout;
			
			_cancelButton = new KSketch_DialogButton();
			_cancelButton.init("Cancel");
			_cancelButton.initSkin();
			_cancelButton.addEventListener(MouseEvent.CLICK, _cancel);
			
			_logoutButton = new KSketch_DialogButton();
			_logoutButton.init("Logout");
			_logoutButton.initSkin();
			_logoutButton.addEventListener(MouseEvent.CLICK, _logout);
			
			_dialogPopUp.buttonComponent.addElement(_cancelButton);
			_dialogPopUp.buttonComponent.addElement(_logoutButton);
		}
		
		private function _cancel(event:MouseEvent):void
		{
			_cancelButton.removeEventListener(MouseEvent.CLICK, _cancel);
			_dialogPopUp.close();
		}
		
		private function _logout(event:MouseEvent):void
		{
			_logoutButton.removeEventListener(MouseEvent.CLICK, _logout);
			_homeView.navigateToScreen("LOGIN");
			
			_cancelButton.removeEventListener(MouseEvent.CLICK, _cancel);
			_dialogPopUp.close();
		}
	}
}