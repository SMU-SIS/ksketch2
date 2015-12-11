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
	import spark.layouts.HorizontalLayout;
	
	import sg.edu.smu.ksketch2.KSketchAssets;
	import sg.edu.smu.ksketch2.KSketchGlobals;
	import sg.edu.smu.ksketch2.canvas.components.buttons.KSketch_DialogButton;
	import sg.edu.smu.ksketch2.canvas.controls.KActivityControl;

	public class KSketch_DialogBox_Result
	{
		private var PADDINGLEFT:Number = 10 * KSketchGlobals.SCALE;
		
		private var _activityControl:KActivityControl;
		private var _dialogPopUp:KSketch_DialogBox_Skin;
		private var _retryButton:KSketch_DialogButton;
		private var _closeButton:KSketch_DialogButton;
		private var _image1:Image;
		private var _image2:Image;
		private var _image3:Image;
		
		public function KSketch_DialogBox_Result(dialogPopUp:KSketch_DialogBox_Skin, activityControl:KActivityControl)
		{
			PADDINGLEFT = PADDINGLEFT;
			
			_dialogPopUp = dialogPopUp;
			_dialogPopUp.header.text = "Results";
			_dialogPopUp.header.setStyle("fontSize", KSketchGlobals.FONT_SIZE_26);
			
			_activityControl = activityControl;
			
			_initContentComponent();
			_initButtonComponent();
		}
		
		private function _initContentComponent():void
		{
			_dialogPopUp.contentComponent.percentWidth = 100;
			var horizontalLayout:HorizontalLayout = new HorizontalLayout();
			_dialogPopUp.contentComponent.layout = horizontalLayout;
			
			_image1 = new Image();
			_image1.id = "star1";
			_image1.source = KSketchAssets.star_empty;
			
			_image2 = new Image();
			_image2.id = "star2";
			_image2.source = KSketchAssets.star_empty;
			
			_image3 = new Image();
			_image3.id = "star3";
			_image3.source = KSketchAssets.star_empty;
			
			_dialogPopUp.contentComponent.addElement(_image1);
			_dialogPopUp.contentComponent.addElement(_image2);
			_dialogPopUp.contentComponent.addElement(_image3);
		}
	
		private function _initButtonComponent():void
		{
			_dialogPopUp.buttonComponent.percentWidth = 100;
			var horizontalLayout:HorizontalLayout = new HorizontalLayout();
			horizontalLayout.horizontalAlign = "center";
			horizontalLayout.paddingLeft = PADDINGLEFT;
			_dialogPopUp.buttonComponent.layout = horizontalLayout;
			
			_retryButton = new KSketch_DialogButton();
			_retryButton.init("Retry");
			_retryButton.initSkin();
			_retryButton.addEventListener(MouseEvent.CLICK, _retry);
			
			_closeButton = new KSketch_DialogButton();
			if(_activityControl.activityType == "RECREATE" && _activityControl.currentIntruction == "Animate")
				_closeButton.init("Finish");
			else
				_closeButton.init("Continue");
			_closeButton.initSkin();
			_closeButton.addEventListener(MouseEvent.CLICK, _continue);
			
			_dialogPopUp.buttonComponent.addElement(_retryButton);
			_dialogPopUp.buttonComponent.addElement(_closeButton);
		}
		
		private function _retry(event:MouseEvent):void
		{
			_activityControl.retryActivity();
			_dialogPopUp.close();
			_retryButton.removeEventListener(MouseEvent.CLICK, _retry);
		}
		
		private function _continue(event:MouseEvent):void
		{
			if(_activityControl.activityType == "RECREATE" && _activityControl.currentIntruction == "Animate")
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
			if(stars == 1)
			{
				_image1.source = KSketchAssets.star_fill;
			}
			else if(stars == 2)
			{
				_image1.source = KSketchAssets.star_fill;
				_image2.source = KSketchAssets.star_fill;
			}
			else if(stars == 3)
			{
				_image1.source = KSketchAssets.star_fill;
				_image2.source = KSketchAssets.star_fill;
				_image3.source = KSketchAssets.star_fill;
			}
		}
	}
}