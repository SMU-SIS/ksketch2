/**
 * Copyright 2010-2015 Singapore Management University
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.canvas.components.popup
{
	import flash.events.MouseEvent;
	
	import spark.components.Image;
	import spark.layouts.HorizontalAlign;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.VerticalAlign;
	
	import sg.edu.smu.ksketch2.KSketchAssets;
	import sg.edu.smu.ksketch2.canvas.components.buttons.KSketch_CanvasButton;
	import sg.edu.smu.ksketch2.canvas.controls.KActivityControl;

	public class KSketch_DialogBox_Result
	{
		private var _activityControl:KActivityControl;
		private var _dialogPopUp:KSketch_DialogBox_Skin;
		
		private var _retryButton:KSketch_CanvasButton;
		private var _closeButton:KSketch_CanvasButton;
		private var _image:Image;
		
		public function KSketch_DialogBox_Result(dialogPopUp:KSketch_DialogBox_Skin, activityControl:KActivityControl)
		{		
			_dialogPopUp = dialogPopUp;
			_activityControl = activityControl;		
			_dialogPopUp.transparentBackground();
			_initContentComponent();
		}
		
		private function _initContentComponent():void
		{
			_dialogPopUp.contentComponent.width = _dialogPopUp.width;
			var horizontalLayout:HorizontalLayout = new HorizontalLayout();
			horizontalLayout.horizontalAlign = HorizontalAlign.CENTER;
			horizontalLayout.verticalAlign = VerticalAlign.BOTTOM;
			_dialogPopUp.contentComponent.layout = horizontalLayout;
			
			_retryButton = new KSketch_CanvasButton();
			_retryButton.init(KSketchAssets.texture_therapy_refresh, KSketchAssets.texture_therapy_refresh_down, false);
			_retryButton.initSkin();
			_retryButton.addEventListener(MouseEvent.CLICK, _retry);
			_dialogPopUp.contentComponent.addElement(_retryButton);
			
			_image = _initImageControl("stars", KSketchAssets.therapy_0star);			
			_dialogPopUp.contentComponent.addElement(_image);
			
			_closeButton = new KSketch_CanvasButton();
			_closeButton.init(KSketchAssets.texture_therapy_next, KSketchAssets.texture_therapy_next_down, false);
			_closeButton.initSkin();
			_closeButton.addEventListener(MouseEvent.CLICK, _continue);
			_dialogPopUp.contentComponent.addElement(_closeButton);
		}		
		
		private function _retry(event:MouseEvent):void
		{
			_activityControl.retryActivity();
			_dialogPopUp.close();
			_retryButton.removeEventListener(MouseEvent.CLICK, _retry);
		}
		
		private function _continue(event:MouseEvent):void
		{
			if(_activityControl.activityType == "RECREATE")
			{
				_activityControl.completeActivity();
			}
			else
			{
				_activityControl.continueActivity();				
			}
			_dialogPopUp.close();
			_closeButton.removeEventListener(MouseEvent.CLICK, _continue);
		}
		
		public function initStars(stars:int):void
		{
			if(stars == 0)
				_image.source = KSketchAssets.therapy_0star;
			else if(stars == 1)
				_image.source = KSketchAssets.therapy_1star;
			else if(stars == 2)
				_image.source = KSketchAssets.therapy_2stars;
			else if(stars == 3)
				_image.source = KSketchAssets.therapy_3stars;
		}		
		
		private function _initImageControl(id:String, imageClass:Class):Image
		{
			var targetImage:Image = new Image();
			targetImage = new Image();
			targetImage.id = id;
			targetImage.source = imageClass;
			targetImage.height = 0.8 * _dialogPopUp.height;
			targetImage.verticalAlign = VerticalAlign.TOP;
			return targetImage;
		}
	}
}