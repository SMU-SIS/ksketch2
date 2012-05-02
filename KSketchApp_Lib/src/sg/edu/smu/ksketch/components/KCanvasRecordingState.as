/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.components
{
	import flash.display.Shape;
	
	import mx.core.Container;
	import mx.core.IBorder;
	
	import sg.edu.smu.ksketch.utilities.KAppState;
	
	import spark.components.BorderContainer;

	public class KCanvasRecordingState implements ICanvasClockState
	{
		private var _appState:KAppState;
		private var _canvas:KCanvas;
		private var _widget:IWidget;
		
		public function KCanvasRecordingState(canvas:KCanvas, appState:KAppState, widget:IWidget)
		{
			_appState = appState;
			_widget = widget;
			_canvas = canvas;
		}
		
		public function entry():void
		{
			var drawingStage:BorderContainer = _canvas.drawingRegion.getChildAt(0) as BorderContainer;
			showWidget(false);
			drawingStage.graphics.lineStyle(10,0xff0000);
			drawingStage.graphics.drawRect(0,0,drawingStage.width,drawingStage.height);			
		}
		
		public function exit():void
		{
			var drawingStage:BorderContainer = _canvas.drawingRegion.getChildAt(0) as BorderContainer;			
			drawingStage.graphics.lineStyle(10,0x748893);
			drawingStage.graphics.drawRect(0,0,drawingStage.width,drawingStage.height);			
			showWidget(true);
		}
		
		private function showWidget(show:Boolean):void
		{
			if(show)
			{
				_widget.visible = true;
				_widget.highlightSelection();
			}
			else
				_widget.visible = false;
		}
	}
}