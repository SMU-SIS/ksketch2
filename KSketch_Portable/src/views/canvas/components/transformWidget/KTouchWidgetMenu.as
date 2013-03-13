package views.canvas.components.transformWidget
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	
	import mx.events.FlexEvent;
	
	import spark.components.Button;
	import spark.components.SkinnablePopUpContainer;
	import spark.components.VGroup;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.events.KSketchEvent;
	
	import views.canvas.components.timeBar.KTouchTimeControl;
	import views.canvas.interactioncontrol.KMobileInteractionControl;
	import views.canvas.interactors.widget.KWidgetInteractorManager;
	import views.document.previewer.KTouchPreviewerButtonSkin;
	
	public class KTouchWidgetMenu extends SkinnablePopUpContainer
	{		
		public const MAX_WIDGET_WIDTH:Number = 600;
		public const MAX_WIDGET_HEIGHT:Number = 600;
		public const MAX_WIDGET_RADIUS:Number = 300;
		public const BASE_BUTTON_RADIUS:Number = 220;
		
		private var _KSketch:KSketch2;
		private var _interactionControl:KMobileInteractionControl;
		private var _transitionHelper:KWidgetInteractorManager;
		private var _widget:KTouchWidgetBase;
		
		private var _buttonContainer:VGroup;
		private var _insertKeyButton:Button;
		private var _clearMotionButton:Button;
		private var blocker:Button;
		private var _initiated:Boolean = false;
		
		//Need to find a way to display this radially
		public function KTouchWidgetMenu(KSketchInstance:KSketch2,
										 interactionControl:KMobileInteractionControl,
										 widget:KTouchWidgetBase, transitionHelper:KWidgetInteractorManager)
		{
			_KSketch = KSketchInstance;
			_interactionControl = interactionControl;
			_transitionHelper = transitionHelper;
			_widget = widget;
			
			super();
			setStyle("skinClass", KWidgetMenuSkin);
			
			blocker = new Button();
			blocker.setStyle("skinClass", Class(KTouchPreviewerButtonSkin));
			blocker.width = Capabilities.screenResolutionX > Capabilities.screenResolutionY?Capabilities.screenResolutionX:Capabilities.screenResolutionY;
			blocker.height= Capabilities.screenResolutionX > Capabilities.screenResolutionY?Capabilities.screenResolutionY:Capabilities.screenResolutionX;
			blocker.addEventListener(MouseEvent.CLICK , _handleClose);
			blocker.alpha = 0;
			
			_buttonContainer = new VGroup();
			_buttonContainer.setStyle("gap", 3);
			
			_insertKeyButton = new Button();
			
			_insertKeyButton.percentWidth = 100;
			_insertKeyButton.setStyle("skinClass", Class(KTouchWidgetMenuButtonSkin));
			_insertKeyButton.addEventListener(MouseEvent.CLICK, _insertKey); 

			_clearMotionButton = new Button();
			_clearMotionButton.percentWidth = 100;
			_clearMotionButton.setStyle("skinClass", Class(KTouchWidgetMenuButtonSkin));
			_clearMotionButton.addEventListener(MouseEvent.CLICK, _clearMotion); 
			
			addElement(blocker);
			addElement(_buttonContainer);
			_buttonContainer.addElement(_insertKeyButton);
			_buttonContainer.addElement(_clearMotionButton);

			addEventListener(FlexEvent.CREATION_COMPLETE, _initiateMenu);
		}
		
		private function _initiateMenu(event:Event):void
		{
			_initiated = true;
			_updateMenu();
			removeEventListener(FlexEvent.CREATION_COMPLETE, _initiateMenu);
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
			blocker.x = -x;
			blocker.y = -y;
			
			if(KSketch2.studyMode == KSketch2.STUDY_P)
			{
				_insertKeyButton.label = "Break motion at "+ KTouchTimeControl.toTimeCode(_KSketch.time);
				_clearMotionButton.label = "Delete motions after "+ KTouchTimeControl.toTimeCode(_KSketch.time)
			}
			else
			{
				_insertKeyButton.label = "Insert key at "+ KTouchTimeControl.toTimeCode(_KSketch.time);
				_clearMotionButton.label = "Clear keys after "+ KTouchTimeControl.toTimeCode(_KSketch.time);
			}
			
			super.open(owner, modal);
			_updateMenu();
		}
		
		private function _updateMenu():void
		{
			_canInsertKey();
			
			if(!_initiated)
				return;
			
			_layoutButtons();
		}
		
		private function _layoutButtons():void
		{
			_widget.boundary.graphics.clear();
			_widget.boundary.graphics.beginFill(0x000000);
			_widget.boundary.graphics.drawCircle(-25,-25,MAX_WIDGET_RADIUS);
			_widget.boundary.graphics.endFill();
			
			var bounds:Rectangle = _widget.getRect(stage);
			
			_widget.boundary.graphics.clear();
			
			var maxX:Number = Capabilities.screenResolutionX;
			var maxY:Number = Capabilities.screenResolutionY;
			
			var allowedX:Number = maxX - bounds.right;
			var allowedY:Number = maxY - bounds.bottom;
			var point:Point;
			
			//Right
			if(bounds.left  < allowedX)
			{
				_buttonContainer.setStyle("horizontalAlign","right");
				
				//Bottom
				if(bounds.top < allowedY)
				{
					point = Point.polar(BASE_BUTTON_RADIUS, 15/180*Math.PI)
					_buttonContainer.x = point.x;
					_buttonContainer.y = point.y;
				}
				else
				{
					point = Point.polar(BASE_BUTTON_RADIUS, -15/180*Math.PI)
					_buttonContainer.x = point.x;
					_buttonContainer.y = point.y - _buttonContainer.height;
				}
				
			}
			else//Left
			{
				_buttonContainer.setStyle("horizontalAlign","left");
				//Bottom
				if(bounds.top < allowedY)
				{
					point = Point.polar(BASE_BUTTON_RADIUS, 165/180*Math.PI)
					_buttonContainer.x = point.x - _buttonContainer.width;
					_buttonContainer.y = point.y;
				}
				else
				{
					point = Point.polar(BASE_BUTTON_RADIUS, -165/180*Math.PI)
					_buttonContainer.x = point.x - _buttonContainer.width;
					_buttonContainer.y = point.y - _buttonContainer.height;
				}
			}
		}
		
		private function _handleClose(event:MouseEvent):void
		{
			close();
		}
		
		private function _canInsertKey():void
		{
			if(!_interactionControl.selection)
			{	
				_insertKeyButton.enabled = false;
				return;
			}
			
			if(_interactionControl.selection.objects.length() != 1)
			{
				_insertKeyButton.enabled = false;
				return;
			}
			
			if(_interactionControl.selection.objects.getObjectAt(0).transformInterface.canInsertKey(_KSketch.time))
			{
				_insertKeyButton.enabled = true;
				return;
			}
			
			_insertKeyButton.enabled = false;
		}
		
		private function _insertKey(event:MouseEvent = null):void
		{
			_interactionControl.begin_interaction_operation();
			_interactionControl.selection.objects.getObjectAt(0).transformInterface.insertBlankKeyFrame(_KSketch.time, _interactionControl.currentInteraction);
			_interactionControl.end_interaction_operation(null,_interactionControl.selection);
			
			var log:XML = <op/>;
			var date:Date = new Date();
			
			log.@category = "Context";
			log.@type = "Insert Key";
			log.@triggeredTime = KTouchTimeControl.toTimeCode(_KSketch.time);
			log.@elapsedTime = KTouchTimeControl.toTimeCode(date.time - _KSketch.logStartTime);
			_KSketch.log.appendChild(log);
			
			_KSketch.dispatchEvent(new KSketchEvent(KSketchEvent.EVENT_MODEL_UPDATED));
			
			_canInsertKey();
			close();
		}
		
		private function _clearMotion(event:MouseEvent = null):void
		{
			_interactionControl.begin_interaction_operation();
			_interactionControl.selection.objects.getObjectAt(0).transformInterface.clearAllMotionsAfterTime(_KSketch.time, _interactionControl.currentInteraction);
			_interactionControl.end_interaction_operation(null, _interactionControl.selection);
			
			var log:XML = <op/>;
			var date:Date = new Date();
			
			log.@category = "Context";
			log.@type = "Clear Future Keys";
			log.@triggeredTime = KTouchTimeControl.toTimeCode(_KSketch.time);
			log.@elapsedTime = KTouchTimeControl.toTimeCode(date.time - _KSketch.logStartTime);
			_KSketch.log.appendChild(log);
			
			_KSketch.dispatchEvent(new KSketchEvent(KSketchEvent.EVENT_MODEL_UPDATED));
			close();
		}
		
	}
}