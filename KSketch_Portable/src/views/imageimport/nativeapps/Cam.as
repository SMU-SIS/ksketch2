package views.imageimport.nativeapps
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MediaEvent;
	import flash.events.MouseEvent;
	import flash.media.CameraUI;
	import flash.media.MediaType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class Cam extends Sprite
	{		
		private var _cam:CameraUI;
		private var _imgPath:String;
		
		public function Cam()
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
			
			_launchCamera();
		}
		
		private function _draw():void
		{
			graphics.clear();
			graphics.beginFill(0xFFFFFF,1);
			graphics.drawRect(0, 0, stage.width, stage.height);
			graphics.endFill();
		}
		
		private function _launchCamera():void
		{
			if(CameraUI.isSupported)
			{
				_cam = new CameraUI();
				_addCamListeners();
				_cam.launch(MediaType.IMAGE);				
			}
			else
			{
				showError("Camera not supported by your mobile device. " +
					"Touch anywhere on screen to go back to Menu.");
			}			
		}
		
		private function _addCamListeners():void
		{
			if(_cam)
			{
				_cam.addEventListener(MediaEvent.COMPLETE, _onCamCompleteHandler);
				_cam.addEventListener(Event.CANCEL, _onCamCancelHandler);
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
			
			addEventListener(MouseEvent.CLICK, _exitErrorHandler);
		}
		
		private function _exitErrorHandler(e:MouseEvent): void
		{
			stage.removeEventListener(MouseEvent.CLICK, _exitErrorHandler);
			_removeCamListeners()
		}
		
		private function _onCamCompleteHandler(event:MediaEvent):void
		{
			try
			{
				_imgPath = event.data.file.url;
				dispatchEvent(new Event("cfmImgApp", true));
				_removeCamListeners();
			}
			catch(e:Error)
			{
				showError("Image not found. " +
					"Touch anywhere on screen to go back to Menu.");
			}
		}
		
		private function _onCamCancelHandler(event:Event):void
		{
			_removeCamListeners();
		}		
		
		private function _removeCamListeners():void
		{
			if(_cam)
			{
				_cam.removeEventListener(MediaEvent.COMPLETE, _onCamCompleteHandler);
				_cam.removeEventListener(Event.CANCEL, _onCamCancelHandler);
			}
			
			dispatchEvent(new Event("exitImgApp", true));
		}
	}
}