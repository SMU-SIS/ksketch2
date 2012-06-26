/**------------------------------------------------
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 
*-------------------------------------------------*/
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;

import sg.edu.smu.ksketch.event.KModelEvent;
import sg.edu.smu.ksketch.event.KSelectionChangedEvent;
import sg.edu.smu.ksketch.event.KTimeChangedEvent;
import sg.edu.smu.ksketch.operation.KTransformMgr;
import sg.edu.smu.ksketch.utilities.KAppState;
import sg.edu.smu.playsketch.components.timebar.TimeWidget;

private const _thumbOffset:Number = 2.5;
private const _dummyEvent:Event = new Event(Event.COMPLETE);

private var _initialAppWidth:Number;
private var _initialAppHeight:Number;
private var _initialCanvasWidth:Number;
private var _initialCanvasHeight:Number;
private var _windowBoundsOffsetX:Number;
private var _windowBoundsOffsetY:Number;
private var _prevStageBounds:Rectangle;
private var _highDef:Boolean = false;
private var _prevWidth:Number;
private var _prevHeight:Number;


//Zooming variable
private var _zoomIn:Boolean = true;
private var _timeBar_toogled:Boolean = true;

/*
Function to initialise playsketch
*/
public function init_canvas(appWidth:Number, appHeight:Number, windowBoundsOffsetX:Number, windowBoundsOffsetY:Number):void
{
	//Store the initial width and height of the application and "drawing area"
	//for future calculations.
	_initialAppWidth = appWidth;
	_initialAppHeight = appHeight;
	_windowBoundsOffsetX = windowBoundsOffsetX*2;
	_windowBoundsOffsetY = windowBoundsOffsetY*2;
	_prevWidth = 0;
	_prevHeight = 0;
	_initialCanvasWidth = appWidth - drawingArea_Layout.paddingLeft - drawingArea_Layout.paddingRight;
	_initialCanvasHeight = appHeight - topBar.height - timeBar.height - appMainVerticalLayout.gap*2;
	//Set the width, height and scale of the drawing area.
	drawingArea_stage.width = _initialCanvasWidth;
	drawingArea_stage.height = _initialCanvasHeight;
	changeStageAspect(true);

	//Initialize the canvas, activating the interaction to it.
	appCanvas.initialize();
	appCanvas.initKCanvas(_facade, appState);
	appCanvas.drawingRegion = drawingArea;
	slider_key_index.init(appState);
	
	//Add the content container to the main container grouping
	drawingArea_stage.addElement(appCanvas.contentContainer);
	
	//set the contentcontainer to ignore the main container grouping's layout
	appCanvas.contentContainer.includeInLayout = false;
	
	//rearrange the depths of the components
	//smaller numbers means deeper into the view
	drawingArea.depth = 1;
	appCanvas.contentContainer.depth = 2;
	topBar.depth = 2;
	timeBar.depth = 3;
	
	//Initialise keyframe marker operations	
	timeWidget.initTimeWidget(_facade, appState, slider_key_index, TimeWidget.OVERVIEW);
	expandedWidget1.initTimeWidget(_facade, appState, slider_key_index, KTransformMgr.TRANSLATION_REF);
	expandedWidget2.initTimeWidget(_facade, appState, slider_key_index, KTransformMgr.ROTATION_REF);
	expandedWidget3.initTimeWidget(_facade, appState, slider_key_index, KTransformMgr.SCALE_REF);
	_facade.addEventListener(KModelEvent.EVENT_MODEL_UPDATE_COMPLETE, updateTimeWidgets);
	appState.addEventListener(KAppState.EVENT_UNDO_REDO_ENABLED_CHANGED, updateTimeWidgets);
	appState.addEventListener(KSelectionChangedEvent.EVENT_SELECTION_CHANGED, updateTimeWidgets);
	
	//Play button state listener
	appState.addEventListener(KAppState.EVENT_ANIMATION_START, _playToPause);
	appState.addEventListener(KAppState.EVENT_ANIMATION_STOP, _pauseToPlay);
	
	
	_toogle_TimebarExpand();
}	

/**
 * Function to manage the interface as it resizes or moves
 */
public function update_interface():void
{	
	var xScale:Number;
	var yScale:Number;
	var finalScale:Number;
	var scaleXOffset:Number = 1;
	var scaleYOffset:Number = 1;
	
	//Calculate the scale relative to the initial width and height
	xScale = (appCanvas.width-_windowBoundsOffsetX)/_initialAppWidth;
	yScale = (appCanvas.height-_windowBoundsOffsetY)/_initialAppHeight;
	finalScale = Math.min(xScale, yScale);
	
	var toScaleX:Number = 0;
	var toScaleY:Number = 0;
	
	//find the current max stage width and height
	var maxCanvasWidth:Number = appCanvas.width - drawingArea_Layout.paddingLeft - drawingArea_Layout.paddingRight;
	var maxCanvasHeight:Number = appCanvas.height - topBar.height - timeBar.height - appMainVerticalLayout.gap*2;
		
	//if zoom mode is on
	if(_zoomIn){
		
		toScaleX = 1-((drawingArea_stage.width*xScale)/maxCanvasWidth);
		toScaleY = 1-((drawingArea_stage.height*yScale)/maxCanvasHeight);
		group_zoom.setButton(group_zoom.btn_zoomIn);
	}
	else
	{
		//The bigger the multiplied constant, the thinner the margin area
		var idealContentWidth:Number = appState.zoomedOutProportion*maxCanvasWidth; 
		var idealContentHeight:Number = appState.zoomedOutProportion*maxCanvasHeight;
		
		var widthConcerned:Number = Math.max(appCanvas.objectRoot.width, drawingArea_stage.width);
		var heightConcerned:Number = Math.max(appCanvas.objectRoot.height, drawingArea_stage.height);
		
		toScaleX = (idealContentWidth/widthConcerned)-xScale;
		toScaleY = (idealContentHeight/heightConcerned)-yScale;
		group_zoom.setButton(group_zoom.btn_zoomOut);
	}
	
	finalScale = Math.min(xScale+toScaleX, yScale+toScaleY);
	
	appCanvas.contentScale = finalScale;
	drawingArea_stage.scaleX = finalScale;
	drawingArea_stage.scaleY = finalScale;
	appCanvas.unscaleWidget(finalScale, finalScale);
	
	var stageBounds:Rectangle = drawingArea_Layout.getElementBounds(0);
	var stageYPos:Number = stageBounds.y+topBar.height+appMainVerticalLayout.gap;
	
	appCanvas.mouseOffsetX = stageBounds.x;
	appCanvas.mouseOffsetY = stageYPos;
	
	//var positioningRect:Rectangle = appCanvas.getBounds(slider_key_index);
	//extension_layout.paddingLeft = -positioningRect.x + markerPadding.paddingLeft-1;
	
	if(Math.abs(appCanvas.width-_windowBoundsOffsetX -_prevWidth) > 0 ||
		Math.abs(appCanvas.height-_windowBoundsOffsetY-_prevHeight) > 0)
	{
		rescaleTimeWidgets();
		updateTimeWidgets(_dummyEvent);
	}
	
	_prevWidth = appCanvas.width-_windowBoundsOffsetX;
	_prevHeight = appCanvas.height-_windowBoundsOffsetY;
	
	if(flvTestWindow)
	{
		flvTestWindow.x=(appCanvas.width/2)-100;
		flvTestWindow.y=(appCanvas.height/2)-100;
	}
	if(imgTitleWindow)
    {
	    imgTitleWindow.x=(appCanvas.width/2)-150-(imgTitleWindow.width/4);
	    imgTitleWindow.y=(appCanvas.height/2)-100-(imgTitleWindow.height/4);
    }
	
	computeTrackPositions();
}


public function setZoomMode(zoomBoolean:Boolean):void
{
	_zoomIn = zoomBoolean;
	update_interface();
}

/*
Function to change the aspect ratio of the stage to fit video requirements
youtube's common aspect ratios are
4:3 - Normal
16:9 - HD

Changing the aspect ratio of the stage will not cause scaling of the content drawn on the stage

This function does not determine the final output swf size, just the aspect ratio.
Video size should be handled in the output function.
*/
public function changeStageAspect(highDef:Boolean):void
{
	var aspectRatio:Number;
	
	if(highDef)
	{
		aspectRatio = 16/9;
	}
	else
	{
		aspectRatio = 4/3;
	}
	
	drawingArea_stage.width = drawingArea_stage.height*(aspectRatio);
}

public function get stageAspectRatio():Boolean
{
	return _highDef
}

public function set stageAspectRatio(value:Boolean):void
{
	_highDef = value;
	changeStageAspect(_highDef);
	update_interface();
}

public function computeTrackPositions():void
{
	var sliderTrackBox:Rectangle = slider_key_index.getBounds(this.stage);
	var overViewTrackBox:Rectangle =  timeWidget.getBounds(this.stage);
	appState.overViewTrackBox = new Rectangle(overViewTrackBox.x, sliderTrackBox.y,
											sliderTrackBox.width, overViewTrackBox.bottom - sliderTrackBox.y);
	appState.translateTrackBox = expandedWidget1.getBounds(this.stage);
	appState.rotateTrackBox = expandedWidget2.getBounds(this.stage);
	appState.scaleTrackBox = expandedWidget3.getBounds(this.stage);
}