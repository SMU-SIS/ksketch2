/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

import sg.edu.smu.ksketch2.components.Audio.MicrophoneFunctions;

import sg.edu.smu.ksketch2.components.ImportImage.ImageTrim;
import sg.edu.smu.ksketch2.components.ImportImage.ImgResizingWindow;
import sg.edu.smu.ksketch2.components.ImportImage.ImgWindowSkin;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.GraphicsPath;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.media.Camera;
import flash.net.FileFilter;
import flash.net.FileReference;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.setTimeout;

import mx.binding.utils.BindingUtils;
import mx.collections.ArrayCollection;
import mx.collections.ArrayList;
import mx.containers.TitleWindow;
import mx.controls.Alert;
import mx.controls.Image;
import mx.controls.ProgressBar;
import mx.core.UIComponent;
import mx.events.CloseEvent;
import mx.flash.UIMovieClip;
import mx.graphics.codec.PNGEncoder;
import mx.managers.PopUpManager;

import sg.edu.smu.ksketch.interactor.KCommandExecutor;
import sg.edu.smu.ksketch.logger.KLogger;
import sg.edu.smu.ksketch.logger.KPlaySketchLogger;
import sg.edu.smu.ksketch2.exportTools.SimpleFlvWriter;

import spark.components.Button;
import spark.components.DropDownList;
import spark.components.Group;
import spark.components.Label;
import spark.events.IndexChangeEvent;


private static var FLVresolution:Number=0.1;
private static var FLVstep:Number=0.1;
private var flagForFLV:Boolean=false;
private var flagForSaveFLV:Boolean=false;
public var flvTestWindow:mx.containers.TitleWindow;
private static var stagePointerForFlv:int=1;
private var pbBar:ProgressBar;
private var btnCanclFlvWnd:Button
private var btnNextlFlvWnd:Button;	
private var btnPrevFlvWnd:Button;
private var btnNext2FlvWnd:Button;
private var dropDownFlvWnd:DropDownList
private var uiArrayforFlv:Array;
private var myXFlv:Number=1;
private var myYFlv:Number=1;
private var imageSizeFlv:Rectangle;
private var timeInSeconds:int;
private var numberOfFrames:int;										 	
private var myWriter:SimpleFlvWriter;	
private var fps:Number;
private var contentCanvas:MovieClip;;
private var bmpData:BitmapData;
private var transformMartixFlv:Matrix;
public var imgTitleWindow:ImgResizingWindow;
private var ImageTr:sg.edu.smu.ksketch2.components.ImportImage.ImageTrim;
private var camera:Camera;
private var liveOrSnapped:Boolean=false;	
public var bitmapDataBeforeIrregular:BitmapData;
private var bitmapDataAfterIrregular:BitmapData;
private var onLoadBtn:Boolean=false;
private var bytes1:ByteArray = new ByteArray();
private var loader:Loader;
private var _buttonMapping:Dictionary;
private var _commandExecutor:KCommandExecutor;
private var _savedModel:XML = null;
public var isRegionDrawn:Boolean=false;
private var _fileRef : FileReference;
private var arrListforCam:ArrayList;

public function get commandExecutor():KCommandExecutor
{
	return _commandExecutor;
}

public function needSave():Boolean
{
	return _savedModel != facade.saveFile();
}

public function promptForSave(postFunction:Function):void
{
	var f:Function = function(e:CloseEvent):void
	{
		switch(e.detail)
		{
			case Alert.YES:
				_commandExecutor.saveWithListener(function(e:Event):void 
				{
					postFunction();
					_savedModel = facade.saveFile();
				});
				break;
			case Alert.NO:
				postFunction();
				_savedModel = facade.saveFile();
				break;
			case Alert.CANCEL:
				break;
		}
	};
	Alert.show("Do you want to save the changes to this file?","Warning",
		Alert.YES|Alert.NO|Alert.CANCEL,this,f);
}

public function initButtonFunctions():void
{
	_savedModel = facade.saveFile();
	_initLoggableButtons();
	_buttonMapping = _getButtonMappings();
	_commandExecutor = new KCommandExecutor(appState,appCanvas,facade);
	
	imageSizeFlv=drawingArea_Layout.getElementBounds(0);
	initButtonsToFlv();
	uiArrayforFlv=new Array(pbBar,btnCanclFlvWnd,btnNextlFlvWnd,
		btnPrevFlvWnd,btnNext2FlvWnd,dropDownFlvWnd);
}

private function _initLoggableButtons():void
{
	btn_firstFrame.addEventListener(MouseEvent.CLICK, _handleButton);
	btn_previous.addEventListener(MouseEvent.CLICK, _handleButton);
	btn_next.addEventListener(MouseEvent.CLICK, _handleButton);
	btn_play.addEventListener(MouseEvent.CLICK, _handleButton);
	group_fileOps.btn_new.addEventListener(MouseEvent.CLICK, _handleButton);
	group_fileOps.btn_load.addEventListener(MouseEvent.CLICK, _handleButton);
	group_fileOps.btn_save.addEventListener(MouseEvent.CLICK, _handleButton);
	group_fileOps.btn_FLV.addEventListener(MouseEvent.CLICK, function fx(event:MouseEvent):void{flvWizardWindow()});
	group_fileOps.btn_IMG.addEventListener(MouseEvent.CLICK, function fx(event:MouseEvent):void{imgWizardWindow()});
	group_editOps.btn_cut.addEventListener(MouseEvent.CLICK, _handleButton);
	group_editOps.btn_copy.addEventListener(MouseEvent.CLICK, _handleButton);
	group_editOps.btn_paste.addEventListener(MouseEvent.CLICK, _handleButton);
	group_viewOps.btn_undo.addEventListener(MouseEvent.CLICK, _handleButton);
	group_viewOps.btn_redo.addEventListener(MouseEvent.CLICK, _handleButton);	
	group_groupOps.btn_group.addEventListener(MouseEvent.CLICK, _handleButton);
	group_groupOps.btn_ungroup.addEventListener(MouseEvent.CLICK, _handleButton);
	group_pen.black.addEventListener(MouseEvent.CLICK, function fx(event:MouseEvent):void{_switchPen(0)});
	group_pen.blue.addEventListener(MouseEvent.CLICK, function fx(event:MouseEvent):void{_switchPen(3)});
	group_pen.red.addEventListener(MouseEvent.CLICK, function fx(event:MouseEvent):void{_switchPen(1)});
	group_pen.green.addEventListener(MouseEvent.CLICK, function fx(event:MouseEvent):void{_switchPen(2)});
	group_pen.eraser.addEventListener(MouseEvent.CLICK, function fx(event:MouseEvent):void{_switchPen(4)});
	group_zoom.btn_zoomIn.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void{setZoomMode(true);});
	group_zoom.btn_zoomOut.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void{setZoomMode(false);});

	_bindComponent(group_fileOps.btn_save, appState, "undoEnabled");	
	_bindComponent(group_editOps.btn_cut, appState, "copyEnabled");
	_bindComponent(group_editOps.btn_copy, appState, "copyEnabled");
	_bindComponent(group_editOps.btn_paste, appState, "pasteEnabled");
	_bindComponent(group_viewOps.btn_undo, appState, "undoEnabled");
	_bindComponent(group_viewOps.btn_redo, appState, "redoEnabled");
	_bindComponent(group_groupOps.btn_group, appState, "groupEnabled");
	_bindComponent(group_groupOps.btn_ungroup, appState, "ungroupEnabled");
	btn_toogle.addEventListener(MouseEvent.CLICK, function (event:MouseEvent):void
	{
		KLogger.log(KPlaySketchLogger.BTN_TOGGLE_TIMEBAR_EXPAND);
		_toogle_TimebarExpand();
	});
}

private function _getButtonMappings():Dictionary
{
	var mapping:Dictionary = new Dictionary();
	mapping[group_fileOps.btn_new] = KPlaySketchLogger.BTN_NEW;
	mapping[group_fileOps.btn_load] = KPlaySketchLogger.BTN_LOAD;
	mapping[group_fileOps.btn_save] = KPlaySketchLogger.BTN_SAVE;
	mapping[group_editOps.btn_cut] = KPlaySketchLogger.BTN_CUT;
	mapping[group_editOps.btn_copy] = KPlaySketchLogger.BTN_COPY;
	mapping[group_editOps.btn_paste] = KPlaySketchLogger.BTN_PASTE;
	mapping[group_viewOps.btn_undo] = KPlaySketchLogger.BTN_UNDO;
	mapping[group_viewOps.btn_redo] = KPlaySketchLogger.BTN_REDO;
	mapping[group_groupOps.btn_group] = KPlaySketchLogger.BTN_GROUP;
	mapping[group_groupOps.btn_ungroup] = KPlaySketchLogger.BTN_UNGROUP;
	mapping[group_configOps.btn_settings] = KPlaySketchLogger.BTN_SETTING;
	mapping[group_configOps.btn_debug] = KPlaySketchLogger.BTN_DEBUG;
	mapping[btn_firstFrame] = KPlaySketchLogger.BTN_FIRST;
	mapping[btn_previous] = KPlaySketchLogger.BTN_PREVIOUS;
	mapping[btn_next] = KPlaySketchLogger.BTN_NEXT;
	mapping[btn_play] = KPlaySketchLogger.BTN_PLAY;
	return mapping;
}

private function _handleButton(event:MouseEvent):void
{	
	if (event.currentTarget is UIComponent || event.currentTarget is UIMovieClip)
	{
		var command:String = _buttonMapping[event.currentTarget];
		if (command == KPlaySketchLogger.BTN_SAVE)
		{
			_commandExecutor.saveWithListener(function(e:Event):void
			{
				_savedModel = facade.saveFile();
			});
		}
		else if ((command == KPlaySketchLogger.BTN_NEW || command == KPlaySketchLogger.BTN_LOAD) && needSave())
			promptForSave(function ():void{_commandExecutor.doButtonCommand(command);});
		else
			_commandExecutor.doButtonCommand(command);
	}
}

private function _bindComponent(component:UIMovieClip,object:Object,property:String):void
{
	var fn:Function = function(enable:Boolean):void
	{
		component.enabled = enable;
		component.mouseEnabled = enable;
		component.mouseChildren = enable;
		component.alpha = enable ? 1.0 : 0.2;
	}
	BindingUtils.bindSetter(fn ,object, property);
}

private function _playToPause(event:Event):void
{
	btn_play.clickPlay();
}

private function _pauseToPlay(event:Event):void
{
	btn_play.clickPause();
}

private function onCompleteforFLV():void
{							
	timeInSeconds=(this.appState.maxPlayTime/62.5)/16;
	numberOfFrames=this.appState.maxPlayTime/62.5;										 	
	myWriter= SimpleFlvWriter.getInstance();	
	fps;
	contentCanvas=this.appCanvas.objectRoot;
	transformMartixFlv=new Matrix();
	transformMartixFlv.scale(myXFlv,myYFlv);
	transformMartixFlv.invert();
	pbBar.label="Saved"+" "+"%3%";
	pbBar.labelPlacement="center";
	
	if(flagForFLV==false)
	{	
		btnCanclFlvWnd.enabled=false;
		this.appState.selection = null;	
		myWriter.createFile(imageSizeFlv.width, imageSizeFlv.height, fps,timeInSeconds);
		flagForFLV=true;
		setTimeout(onCompleteforFLV,10)	 	
	} 
	else
	{		
		if(numberOfFrames==0)
		{	
			for(var i1:int=0; i1<=1; i1++)
			{
				this.appState.time =i1*62.5;							
				drawImageFlv();
			}
			whenWinishedFlv();
		}	
			
		else
			
		{
			for(var i:int=numberOfFrames*FLVresolution; i<=numberOfFrames*(FLVresolution+FLVstep); i++)
			{ 
				this.appState.time =i*62.5;							
				drawImageFlv()	
			}	
			
			pbBar.setProgress(Math.round(FLVresolution*100),100);
			
			if(FLVresolution<=1)	
			{setTimeout(onCompleteforFLV,10);}
			
			if(pbBar.value==100)
			{ whenWinishedFlv();}
			
			this.appState.time = 0;	
			this.appState.selection = null;
			FLVresolution+=0.1;
		}				
	}		
	flagForFLV=true;	
}

private function drawImageFlv():void
{
	bmpData = new BitmapData(imageSizeFlv.width, imageSizeFlv.height);		  
	bmpData.draw(drawingArea_stage,transformMartixFlv,null,null,
		new Rectangle(0,0,imageSizeFlv.width, imageSizeFlv.height));
	myWriter.saveFrame(bmpData);	
}

private function whenWinishedFlv():void
{
	pbBar.setProgress(100,100);				
	pbBar.visible=true;
	btnNext2FlvWnd.enabled=true;		
	btnCanclFlvWnd.enabled=true;
	btnPrevFlvWnd.enabled=true;
	this.appState.time = 0;	
}

private function flvWizardWindow():void
{				
	if(stagePointerForFlv==1)
	{
		var flvDropdownItems:ArrayCollection=new ArrayCollection();   
		
		flvTestWindow = new TitleWindow();	
		flvTestWindow.width= 268, flvTestWindow.height= 175;		
		pbBar.mode="manual";
		flvTestWindow.title="FLV Export";
		flvTestWindow.layout="absolute";
		flvTestWindow.x=(appCanvas.width/2)-100;
		flvTestWindow.y=(appCanvas.height/2)-100;
		dropDownFlvWnd.enabled=true;	
		dropDownFlvWnd.visible=true;
		pbBar.visible=true;	
		btnCanclFlvWnd.visible=true;		
		btnCanclFlvWnd.move(10,100);	
		btnCanclFlvWnd.label="Close";
		btnNext2FlvWnd.visible=false;		
		btnPrevFlvWnd.enabled=false;
		btnPrevFlvWnd.label="Previous";
		btnPrevFlvWnd.move(110,100);
		btnPrevFlvWnd.visible=true;
		pbBar.y=50,pbBar.x=10;		
		dropDownFlvWnd.y=5,dropDownFlvWnd.x=10;			
		flvDropdownItems.addItem("Video Height"), flvDropdownItems.addItem("960 px"), 
			flvDropdownItems.addItem("720 px"), flvDropdownItems.addItem("540 px"),
			flvDropdownItems.addItem("480 px"),flvDropdownItems.addItem("240 px");
		dropDownFlvWnd.width=110;
		dropDownFlvWnd.dataProvider=flvDropdownItems;			
		dropDownFlvWnd.selectedIndex=0;		
		pbBar.width=250;
		btnNextlFlvWnd.move(190,100);
		btnNextlFlvWnd.label="Next";
		btnNextlFlvWnd.visible=true;
		btnNextlFlvWnd.enabled=false;
		pbBar.setProgress(0,100);
		pbBar.label="Saved"+" "+"%3%";
		pbBar.labelPlacement="center";		
		PopUpManager.addPopUp(flvTestWindow, this, true);	
		dropDownFlvWnd.addEventListener(IndexChangeEvent.CHANGE,flvDropDown_changeHandler);
	}	
	addButtonsToFlv();			 
	addListenersFlv();
}

private  function flvDropDown_changeHandler(event:spark.events.IndexChangeEvent):void
{		
	if(dropDownFlvWnd.selectedIndex!=0)
	 {btnNextlFlvWnd.enabled=true;}	
	if(dropDownFlvWnd.selectedIndex==0)
	 {btnNextlFlvWnd.enabled=false;}	
}

private function addListenersFlv():void
{
	var funcArray:Array=new Array(onFlv1,onFlv2,onFlv5,onFlv6,onFlv3);
	
	for(var i:int=1; i<uiArrayforFlv.length-1; i++)
	  {uiArrayforFlv[i].addEventListener(MouseEvent.CLICK,funcArray[i-1]);}
}

private function onFlv1(event:MouseEvent):void
{
	stagePointerForFlv=1;
	flagForFLV=false;
	PopUpManager.removePopUp(flvTestWindow);
	flagForSaveFLV=false;	
}

private function initButtonsToFlv():void
{			
	pbBar=new ProgressBar();		
	btnCanclFlvWnd=new Button();
	btnNextlFlvWnd=new Button();
	btnPrevFlvWnd=new Button();
	btnNext2FlvWnd=new Button();		
	dropDownFlvWnd=new DropDownList();	
}	

private function addButtonsToFlv():void
{	
	for(var i:int=0; i<uiArrayforFlv.length; i++)
	  {flvTestWindow.addElement(uiArrayforFlv[i]);}			
}

private function onFlv3(event:MouseEvent):void
{	
	stagePointerForFlv=3;
	pbBar.visible=true;	
	flagForFLV=false;	
	flagForSaveFLV=true;
	onCompleteforFLV();	
	FLVresolution=0.1;		
	pbBar.setProgress(0,100);
	flvWizardWindow();
}

private function onSavePressedFlv(event:Event):void
{
	PopUpManager.removePopUp(flvTestWindow);
	stagePointerForFlv=1;
	flagForSaveFLV=false;
}

private function onFlv5(event:MouseEvent):void
{		
	dropDownFlvWnd.enabled=true;
	dropDownFlvWnd.visible=true;
	btnNext2FlvWnd.visible=false;
	btnCanclFlvWnd.visible=true;
	btnNextlFlvWnd.visible=true;
	btnPrevFlvWnd.visible=true;
	pbBar.visible=true;
	pbBar.setProgress(0,100);
	btnPrevFlvWnd.enabled=false;	
}

private function convertFlvToResolution(resBig:Number, resSmall:Number):void
{
	var propotionW:Number;	
	var propotionH:Number;	
	var widthFinal:Number;
	var heightFinal:Number;
	
	if(!this.stageAspectRatio)		  
	 {propotionW = (drawingArea_stage.width/resBig);}
	else
	 {propotionW = (drawingArea_stage.width/(resBig*(4/3)));}
	
	propotionH= drawingArea_stage.height/resSmall;	
	
	widthFinal = drawingArea_stage.width/propotionW;
	heightFinal = drawingArea_stage.height/propotionH;		  		 	
	
	imageSizeFlv.height=heightFinal;		  		 
	imageSizeFlv.width=widthFinal;	
	
	myXFlv= propotionW;
	myYFlv=propotionH;	
}

private function onFlv2(event:MouseEvent):void
{	
	imageSizeFlv = drawingArea_Layout.getElementBounds(0);	
	btnNextlFlvWnd.enabled=true;
	
	if(dropDownFlvWnd.selectedIndex==1)
	 {convertFlvToResolution(1280, 960);}
	
	if(dropDownFlvWnd.selectedIndex==2)
	 {convertFlvToResolution(960, 720);}
	
	if(dropDownFlvWnd.selectedIndex==3)
	 {convertFlvToResolution(720, 540);} 
	
	if(dropDownFlvWnd.selectedIndex==4)
	 {convertFlvToResolution(640, 480);}
	
	if(dropDownFlvWnd.selectedIndex==5)
	 {convertFlvToResolution(320, 240);}
	
	stagePointerForFlv=3;
	pbBar.visible=true;	
	flagForFLV=false;	
	flagForSaveFLV=true;
	onCompleteforFLV();	
	FLVresolution=0.1;		
	pbBar.setProgress(0,100);
	flvWizardWindow();		
	dropDownFlvWnd.visible=true;
	dropDownFlvWnd.enabled=false;
	btnCanclFlvWnd.visible=true;
	btnNextlFlvWnd.visible=false;
	btnNext2FlvWnd.visible=true;
	btnNext2FlvWnd.enabled=false;		
	btnNext2FlvWnd.move(190,100);
	btnNext2FlvWnd.label="Save"; 
	btnPrevFlvWnd.enabled=false;		
}

private function onFlv6(event:MouseEvent):void
{
	var myWriter1:SimpleFlvWriter = SimpleFlvWriter.getInstance();
	var myBytes:ByteArray = myWriter1.getByteArray();				 
	var myRef:FileReference=new FileReference();
	stagePointerForFlv=4;
	flvWizardWindow();		
	myRef.save(myWriter1.bytes, "YourFileName.flv");
	myRef.addEventListener(Event.COMPLETE,onSavePressedFlv);
	myRef.addEventListener(IOErrorEvent.IO_ERROR, flvFileError);
	flagForSaveFLV=true;			
}

private function flvFileError(error:IOErrorEvent):void
{
	Alert.show("FLV Writing Error! The Exporting File Is Used By Other Applications, " +
		"Please Close That Application");
	error.target.removeEventListener(IOErrorEvent.IO_ERROR, flvFileError);
}

private function onFlv7(event:MouseEvent):void
{
	btnNext2FlvWnd.visible=false;
	btnNextlFlvWnd.visible=true;
	btnNext2FlvWnd.enabled=true;
}

private var micr:MicrophoneFunctions;

public function soundRecord():void
{
	///UNDER CONSTRUCTION- Ready to use window
	
	micr=new MicrophoneFunctions();	
    var btcl:Button=new Button();
	var strec:Button=new Button();
	var endrec:Button=new Button();
	var playbeck:Button=new Button();
	var lab:Label=new Label();
	var savexml:Button=new Button();
	var loadxml:Button=new Button();
	
	lab.text="UNDER CONSTRUCTION";
	lab.x=100;
	lab.y=100;
	
	imgTitleWindow= new ImgResizingWindow(this);	
	imgTitleWindow.height = 270, imgTitleWindow.width = 360;
	imgTitleWindow.x = (appCanvas.width/2)-100;;
	imgTitleWindow.y = (appCanvas.height/2)-100;
		
	btcl.label="Close";
	btcl.x=10;
	btcl.y=200;
	imgTitleWindow.addElement(btcl);
	
	playbeck.label="Playback";
	playbeck.x=250;
	playbeck.y=200;
	imgTitleWindow.addElement(playbeck);
	imgTitleWindow.addElement(lab);
	
	strec.x=80;
	strec.y=200;
	
	endrec.x=150;
	endrec.y=200;
	
	strec.label="Start";
	endrec.label="Stop";
	imgTitleWindow.addElement(strec);
	imgTitleWindow.addElement(endrec);
	
	savexml.x=150;
	savexml.y=150;	
	savexml.label="To XML";
	imgTitleWindow.addElement(savexml);
	
	loadxml.x=250;
	loadxml.y=150;	
	loadxml.label="From XML";
	imgTitleWindow.addElement(loadxml);
	
	PopUpManager.addPopUp(imgTitleWindow, this, true)
	btcl.addEventListener("click", closeHandlerImg);
	strec.addEventListener("click", onstrec);
	endrec.addEventListener("click", onendrec);
	playbeck.addEventListener("click", playbeckss);
	savexml.addEventListener("click", onsavexml);
	loadxml.addEventListener("click",onloadxml);
}

private function onstrec(event:Event):void
{	
	micr.startMicRecording();
}

private function onendrec(event:Event):void
{
	micr.stopMicRecording();
}

private function playbeckss(event:Event):void
{
	micr.playbackData();
}

private function onsavexml(event:Event):void
{	
	micr.onbtnSaveSound(event);
}

private function onloadxml(event:Event):void
{	
	micr.onSaveSelected(event);
}

public function imgWizardWindow():void
{		
	arrListforCam=new ArrayList();	
		
	imgTitleWindow= new ImgResizingWindow(this);	
	imgTitleWindow.title="Image Import";
		
	imgTitleWindow.x = (appCanvas.width/2)-100;
	imgTitleWindow.y = (appCanvas.height/2)-100;
	
	imgTitleWindow.btnClose.label="Cancel";
	imgTitleWindow.btnClose.x=imgTitleWindow.width-90;
	imgTitleWindow.btnClose.y=imgTitleWindow.height-60;
	imgTitleWindow.addElement(imgTitleWindow.btnClose);	
	
	imgTitleWindow.btnLoad.label="Done";
	imgTitleWindow.btnLoad.x=imgTitleWindow.width-165;
	imgTitleWindow.btnLoad.y=imgTitleWindow.height-60;
	imgTitleWindow.addElement(imgTitleWindow.btnLoad);
	
	imgTitleWindow.btnCamera.label="Camera";
	imgTitleWindow.btnCamera.x=imgTitleWindow.width-240;
	imgTitleWindow.btnCamera.y=imgTitleWindow.height-60;
	imgTitleWindow.addElement(imgTitleWindow.btnCamera);
	
	imgTitleWindow.btnCameraSnap.label="Snap";
	imgTitleWindow.btnCameraSnap.x=imgTitleWindow.width-315;
	imgTitleWindow.btnCameraSnap.y=imgTitleWindow.height-60;
	imgTitleWindow.addElement(imgTitleWindow.btnCameraSnap);
	
	imgTitleWindow.btnSav.label="Load From Disk";	
	imgTitleWindow.btnSav.x=imgTitleWindow.width-425;
	imgTitleWindow.btnSav.y=imgTitleWindow.height-60;
	imgTitleWindow.addElement(imgTitleWindow.btnSav);
			
	imgTitleWindow.setStyle("skinClass", ImgWindowSkin);
		
	imgTitleWindow.chooseCamBox.x=imgTitleWindow.width-165;
	imgTitleWindow.chooseCamBox.y=imgTitleWindow.height-83;
	imgTitleWindow.chooseCamBox.width=145;
	imgTitleWindow.addElement(imgTitleWindow.chooseCamBox);
			
	 for each(var camerasNames:String in Camera.names)
	     {arrListforCam.addItem(camerasNames);}
			 
	imgTitleWindow.chooseCamBox.dataProvider=arrListforCam;
	imgTitleWindow.chooseCamBox.selectedIndex=arrListforCam.length-1;
			
	imgTitleWindow.btnClose.addEventListener("click", closeHandlerImg);
	imgTitleWindow.btnLoad.addEventListener("click", onbtnSaveImage);
	imgTitleWindow.btnLoad.addEventListener("click", closeHandlerImg);
	
	imgTitleWindow.btnCamera.addEventListener("click",function():void{onbtnLoadCamera();});
	imgTitleWindow.btnCameraSnap.addEventListener("click", onbtnLoadCameraSnap);
	imgTitleWindow.btnSav.addEventListener("click", onSaveSelected);
				
	imgTitleWindow.btnLoad.enabled=true;
	imgTitleWindow.btnCameraSnap.enabled=false;
	imgTitleWindow.btnLoad.enabled=false;
	imgTitleWindow.chooseCamBox.enabled=false;
	
	PopUpManager.addPopUp(imgTitleWindow, this, true);	
	imgTitleWindow.chooseCamBox.addEventListener("close", function():void{onbtnLoadCamera();});	
	onbtnLoadCamera();
}

private function onSaveSelected(event:Event):void
{
	var imageTypes:FileFilter = new FileFilter(
		"Images (*.jpg, *.jpeg, *.gif, *.png)", "*.jpg; *.jpeg; *.gif; *.png");
	var imageTypesArray:Array = new Array(imageTypes);
	_fileRef = new FileReference();
	_fileRef.browse(imageTypesArray);	
	_fileRef.addEventListener(Event.SELECT, selectImageHandler);	
}

private function selectImageHandler( evt : Event ) : void
{		
	_fileRef.addEventListener(Event.COMPLETE, loadCompleteHandler);	
	_fileRef.load();	
}

private function loadCompleteHandler(event:Event):void
{	
	var loader:Loader = new Loader();
	loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadBytesHandlerforFullImage);
	loader.contentLoaderInfo.addEventListener("ioError", ldrError); 
	loader.loadBytes(_fileRef.data);	
}

private function loadBytesHandlerforFullImage(event:Event):void
{
	var loaderInfo:LoaderInfo= (event.target as LoaderInfo);
	var snapBmp:Bitmap =Bitmap(loaderInfo.content);		
		
	var bmpDta:BitmapData=new BitmapData(100,100,true,0);	
	bmpDta=snapBmp.bitmapData;		
	var bytes:ByteArray = new ByteArray();
	bytes.writeUnsignedInt(snapBmp.bitmapData.width);
	bytes.writeBytes(snapBmp.bitmapData.getPixels(snapBmp.bitmapData.rect));	
		
	var pngEncoder:PNGEncoder= new PNGEncoder();
	var byteArray:ByteArray = pngEncoder.encodeByteArray(bytes, 
		snapBmp.bitmapData.width, snapBmp.bitmapData.height, true);
    var rect:Rectangle=new Rectangle();
   	
	var byteArr:ByteArray=new ByteArray();										
	loader = new Loader();
	loader.contentLoaderInfo.addEventListener(Event.COMPLETE, 
		function mytest(event:Event):void{onPNG(loader,event)});				
	
	loader.loadBytes(byteArray);							
		
	if(imgTitleWindow.hBox.numChildren > 0)
	  {imgTitleWindow.hBox.removeAllChildren();}
	
	if(imgTitleWindow.videoDisplay.parent)
		(imgTitleWindow.videoDisplay.parent as Group).removeElement(imgTitleWindow.videoDisplay);
	
	ImageTr=new ImageTrim(imgTitleWindow,this);			
	ImageTr.loadImageComplete1(snapBmp);
	imgTitleWindow.addElement(imgTitleWindow.hBox);
	imgTitleWindow.hBox.addElement(ImageTr);
	setUpForTheBox();
	
	imgTitleWindow.btnCamera.enabled=true;
	imgTitleWindow.btnCameraSnap.enabled=false;
	
	imgTitleWindow.btnLoad.enabled=true;
	isRegionDrawn=false;
}

private function ldrError(evt:*):void 
{    
	Alert.show("Wrong Image Type");
}

private function onPNG(loader:Loader, ev:Event):void
{		
	var bitmapData:BitmapData = new BitmapData(loader.content.width, loader.content.height,true,0);
	bitmapData.draw(loader);
	var bitmap:Bitmap = new Bitmap(bitmapData);	
	bitmapDataBeforeIrregular=bitmap.bitmapData;
}

private function closeHandlerImg(event:Event):void
{
	imgTitleWindow.videoDisplay.attachCamera(null);
	event.target.removeEventListener("close", closeHandlerImg);
	PopUpManager.removePopUp(imgTitleWindow);
	isRegionDrawn=false;
}

public function onbtnSaveImage(event:Event):void
{		 
   if(isRegionDrawn)
	{trimmingIrregularShape();}
   else
	{bitmapDataAfterIrregular=bitmapDataBeforeIrregular;}
					 	 
	 var bytes:ByteArray = new ByteArray();
	 bytes.writeUnsignedInt(bitmapDataAfterIrregular.width);
	 bytes.writeBytes(bitmapDataAfterIrregular.getPixels(bitmapDataAfterIrregular.rect));		  	 
	 var pngEncoder:PNGEncoder= new PNGEncoder();
	 var byteArray:ByteArray = pngEncoder.encodeByteArray(bytes, 
		 bitmapDataAfterIrregular.width, bitmapDataAfterIrregular.height, true);
	 bytes1=byteArray;		 
	 loadBytesHandler();	 	 	 		 			
}	

private function on_fileLoadError(event:IOErrorEvent):void
{
	Alert.show("File Error");
}

private function loadBytesHandler():void
{
	var byteArr:ByteArray=new ByteArray();										
	loader = new Loader();
	loader.contentLoaderInfo.addEventListener(Event.COMPLETE, 
		function mytest(event:Event):void{onAddPNG(loader,event)});				
    loader.loadBytes(bytes1);							
}

private function onAddPNG(loader:Loader, ev:Event):void
{			
	var bitmapData:BitmapData = new BitmapData(loader.content.width, loader.content.height,true,0);
	bitmapData.draw(loader);
	var bitmap:Bitmap = new Bitmap(bitmapData);	
	var image:Image = new Image();
	image.source = bitmap;
	appState.addOperation(facade.addKImage(bitmapData,appState.time,100,100));	
}

private function trimmingIrregularShape():void
{
	var offset:int=0;
	var maskPath:GraphicsPath=new GraphicsPath();
	var maskShape:Shape = new Shape();
	var coordArrayX:Array=new Array();
	var coordArrayY:Array=new Array();
	var maxValueX:Number;
	var maxValueY:Number;	 
	var minValueX:Number;
	var minValueY:Number;
	var bmd:BitmapData;
	var region:Rectangle;
	var RegionHeight:int;
	var RegionWidth:int;
	
	
	maskPath.moveTo(ImageTr.poinsArray[0].x, ImageTr.poinsArray[0].y);
	
	for(var l:int=1; l<ImageTr.poinsArray.length; l++)
	  {maskPath.lineTo(ImageTr.poinsArray[l].x,ImageTr.poinsArray[l].y);}
	
	maskPath.lineTo(ImageTr.poinsArray[0].x, ImageTr.poinsArray[0].y);
		
	maskShape.graphics.beginFill(0,0); 
	maskShape.graphics.drawRect(0, 0, bitmapDataBeforeIrregular.width, bitmapDataBeforeIrregular.height);
	maskShape.graphics.endFill();
	
	maskShape.graphics.beginFill(0xFF8400);
	maskShape.graphics.drawPath(maskPath.commands, maskPath.data, maskPath.winding);
	maskShape.graphics.endFill();
	
	bitmapDataAfterIrregular= bitmapDataBeforeIrregular.clone();
	bitmapDataAfterIrregular.draw(maskShape, null, null,BlendMode.ALPHA);
		
	for (var j:int = 0; j<bitmapDataAfterIrregular.height; j++) 
	{
		for (var i:int = 0; i<bitmapDataAfterIrregular.width; i++)
		{				
			if(bitmapDataAfterIrregular.getPixel32(i,j)==0xFF8400)
			   {bitmapDataAfterIrregular.setPixel32(i, j, 0x00ffffff);}	  	  
		}
	}
	
	for(var k:int=0; k<maskPath.data.length; k++)
	{	 		 
		if(k%2)
		 {coordArrayY.push(maskPath.data[k]);} 
		else
		 {coordArrayX.push(maskPath.data[k]);}
	}
	
	maxValueX = Math.max.apply(null,coordArrayX);
	maxValueY = Math.max.apply(null,coordArrayY);	 
	minValueX = Math.min.apply(null,coordArrayX);
	minValueY = Math.min.apply(null,coordArrayY);
	
	RegionHeight=maxValueY-minValueY;
	RegionWidth=maxValueX-minValueX;
	
	bmd = new BitmapData(RegionWidth,RegionHeight,true,0);
	region= new Rectangle(minValueX+2,minValueY,RegionWidth,RegionHeight);	
	bmd.copyPixels(bitmapDataAfterIrregular,region,new Point());
	bitmapDataAfterIrregular=bmd;			
}

public function onbtnLoadCamera():void
{		
	this.camera= Camera.getCamera(imgTitleWindow.chooseCamBox.selectedIndex.toString());	
	var snap:BitmapData = new BitmapData(imgTitleWindow.windowWidth-imgTitleWindow.offsetForDisplayWidth, 
		imgTitleWindow.windowHeight-imgTitleWindow.offsetForDisplayHeight, true);
	var snapBmp:Bitmap = new Bitmap(snap);	
	
	imgTitleWindow.addElement(imgTitleWindow.videoDisplay);	
		
	if(imgTitleWindow.hBox.numChildren > 0)
	  {
		//imgTitleWindow.removeElement(imgTitleWindow.hBox);
	  }
			
	if (this.camera){
		bitmapDataBeforeIrregular=snap;
		imgTitleWindow.videoDisplay.visible=true;
		imgTitleWindow.videoDisplay.attachCamera(this.camera);
		imgTitleWindow.btnCameraSnap.enabled=true;
		imgTitleWindow.btnCamera.enabled=true;//
		imgTitleWindow.btnLoad.enabled=false;
		imgTitleWindow.chooseCamBox.enabled=true;
		liveOrSnapped=true;	
		
		imgTitleWindow.width=imgTitleWindow.windowWidth;
		imgTitleWindow.height=imgTitleWindow.windowHeight;
		imgTitleWindow.videoDisplay.width=imgTitleWindow.windowWidth-imgTitleWindow.offsetForDisplayWidth;
		imgTitleWindow.videoDisplay.height=imgTitleWindow.windowHeight-imgTitleWindow.offsetForDisplayHeight;
		imgTitleWindow.hBox.width=imgTitleWindow.windowWidth-imgTitleWindow.offsetForDisplayWidth;
		imgTitleWindow.hBox.height=imgTitleWindow.windowHeight-imgTitleWindow.offsetForDisplayHeight;
		imgTitleWindow.setButtons();		
	} 
	else{
		imgTitleWindow.videoDisplay.attachCamera(null);
		imgTitleWindow.videoDisplay.visible=false;
		imgTitleWindow.btnLoad.enabled=false;
		imgTitleWindow.btnCamera.enabled=false;
		Alert.show("Problem With Finding Your Web Camera !!!");
	}					
}

public function onbtnLoadCameraSnap(event:Event):void
{							
	var snap:BitmapData = new BitmapData(imgTitleWindow.windowWidth-imgTitleWindow.offsetForDisplayWidth, 
		imgTitleWindow.windowHeight-imgTitleWindow.offsetForDisplayHeight, true);
	var snapBmp:Bitmap = new Bitmap(snap);	
	
	if(imgTitleWindow.hBox.numChildren > 0)
		imgTitleWindow.hBox.removeChildAt(0);
	
	imgTitleWindow.addElement(imgTitleWindow.hBox);
	imgTitleWindow.removeElement(imgTitleWindow.videoDisplay);	
	
	snap.draw(imgTitleWindow.videoDisplay);	 
	ImageTr=new ImageTrim(imgTitleWindow,this);
	ImageTr.loadImageComplete1(snapBmp)
	imgTitleWindow.hBox.addChild(ImageTr);
				
	setUpForTheBox();
	liveOrSnapped=false;
	bitmapDataBeforeIrregular=snap;	 	
	imgTitleWindow.btnCameraSnap.enabled=false;
	imgTitleWindow.btnLoad.enabled=true;
	imgTitleWindow.btnCamera.enabled=true;
	isRegionDrawn=false;
	
	imgTitleWindow.width=imgTitleWindow.windowWidth;
	imgTitleWindow.height=imgTitleWindow.windowHeight;
	imgTitleWindow.hBox.width=imgTitleWindow.windowWidth-imgTitleWindow.offsetForDisplayWidth;
	imgTitleWindow.hBox.height=imgTitleWindow.windowHeight-imgTitleWindow.offsetForDisplayHeight;		
	imgTitleWindow.setButtons();
}

private function setUpForTheBox():void
{
	ImageTr.imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadImageComplete1);	
}

private function loadImageComplete1(event:Event):void
{
	
}

