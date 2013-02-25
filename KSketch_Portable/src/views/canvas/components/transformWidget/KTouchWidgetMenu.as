package views.canvas.components.transformWidget
{
	import flash.display.DisplayObjectContainer;
	
	import mx.events.FlexMouseEvent;
	
	import spark.components.SkinnablePopUpContainer;
	
	import sg.edu.smu.ksketch2.KSketch2;
	
	import views.canvas.interactioncontrol.KMobileInteractionControl;
	
	public class KTouchWidgetMenu extends SkinnablePopUpContainer
	{		
		
		private var _KSketch:KSketch2;
		private var _interactionControl:KMobileInteractionControl;
		private var _widget:KTouchWidgetBase;
		
		//Need to find a way to display this radially
		public function KTouchWidgetMenu(KSketchInstance:KSketch2,
										 interactionControl:KMobileInteractionControl,
										 widget:KTouchWidgetBase)
		{
			
			_KSketch = KSketchInstance;
			_interactionControl = interactionControl;
			_widget = widget;
			
			super();
			setStyle("skinClass", KWidgetMenuSkin);
			addEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE, _handleClose);
		}
		
		/**
		 * Displays the context menu about xPos and yPos
		 * xPos abd yPos should be global coordinates
		 */
		public function showMenu(owner:DisplayObjectContainer, modal:Boolean=false,
									  xPos:Number = 0, yPos:Number = 0):void
		{
			x = xPos;
			y = yPos;

			
			super.open(owner, modal);

			//Align the menu here!
			graphics.clear();
			graphics.beginFill(0xFF0000);
			graphics.drawCircle(0,0,20);
			graphics.endFill();
		}
		
		private function _handleClose(event:FlexMouseEvent):void
		{
			close();
		}
	}
}