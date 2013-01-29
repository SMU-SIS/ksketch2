package views.imageimport.nativeapps
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MediaEvent;
	import flash.events.MouseEvent;
	import flash.media.CameraRoll;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class CamRoll extends Sprite
	{		
		private var _roll:CameraRoll;
		private var _imgPath:String;
		
		public function CamRoll()
		{
			super();
			
			addEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
		}
		
		public function get imgPath():String
		{
			return _imgPath;
		}
		
		private function _onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			_launchCameraRoll();
		}
		
		private function _draw():void
		{
			graphics.clear();
			graphics.beginFill(0xFFFFFF,1);
			graphics.drawRect(0, 0, stage.width, stage.height);
			graphics.endFill();
		}
		
		private function _launchCameraRoll():void
		{
			if(CameraRoll.supportsBrowseForImage)
			{
				_roll = new CameraRoll();
				_addRollListeners();
				_roll.browseForImage();
			}
			else
			{				
				showError("CameraRoll/Gallery not supported by your mobile device. " +
					"Touch anywhere on screen to go back to Menu.");
			}
		}
		
		private function showError(newMsg:String):void
		{
			var msg:TextField = new TextField();
			var tf:TextFormat = new TextFormat();
			
			_draw();
			
			tf.align = "center";
			tf.size = 24;
			msg.width = stage.stageWidth;
			msg.height = stage.stageHeight;
			msg.x = 0;
			msg.y = 0;
			msg.multiline = true;
			msg.wordWrap = true;
			msg.defaultTextFormat = tf;
			addChild(msg);
			msg.text = newMsg;

			stage.addEventListener(MouseEvent.CLICK, _exitErrorHandler);
		}
		
		private function _exitErrorHandler(e:MouseEvent): void
		{
			stage.removeEventListener(MouseEvent.CLICK, _exitErrorHandler);
			_removeRollListeners();
		}
		
		private function _onCancel(event:Event):void
		{
			_removeRollListeners();
		}
		
		private function _onSelect(event:MediaEvent):void
		{
			try
			{
				_imgPath = event.data.file.url;
				dispatchEvent(new Event("cfmImgApp", true));
				_removeRollListeners();
			}
			catch(e:Error)
			{
				showError("Image not found. " +
					"Touch anywhere on screen to go back to Menu.");
			}
		}		
		
		private function _addRollListeners():void
		{
			if(_roll)
			{
				_roll.addEventListener(MediaEvent.SELECT, _onSelect);
				_roll.addEventListener(Event.CANCEL, _onCancel);
			}
		}
		
		private function _removeRollListeners():void
		{
			if(_roll)
			{
				_roll.removeEventListener(MediaEvent.SELECT, _onSelect);
				_roll.removeEventListener(Event.CANCEL, _onCancel);
			}
			
			dispatchEvent(new Event("exitImgApp", true));
		}
	}
}