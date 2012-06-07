/**------------------------------------------------
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 
*-------------------------------------------------*/
package ImportImage
{  
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    
    import mx.containers.HBox;
    import mx.controls.Button;
    import mx.controls.VideoDisplay;
    import mx.core.UIComponent;
    import mx.events.SandboxMouseEvent;
    
    import spark.components.ComboBox;
    import spark.components.DropDownList;
    import spark.components.TitleWindow;
    import spark.components.VideoDisplay;

	
    public class ImgResizingWindow extends TitleWindow
    {		
		public var btnClose:Button=new Button();
		public var btnSav:Button=new Button();
		public var btnLoad:Button=new Button();
		public var btnCamera:Button=new Button();
		public var btnCameraSnap:Button=new Button();
		public var chooseCamBox:DropDownList=new DropDownList();
		public var hBox:HBox=new HBox();
		public var videoDisplay:mx.controls.VideoDisplay=new mx.controls.VideoDisplay();
		public var clickOffset:Point;
		public var windowWidth:int=430;
		public var windowHeight:int=330;
		public var offsetForDisplayWidth:int=30;
		public var offsetForDisplayHeight:int=95;
		public var XForDisplay:int=10;
		public var YForDisplay:int=10;
		public var playSketchCanv:PlaySketchCanvas;
		private var prevWidth:Number;
		private var prevHeight:Number;
				
        public function ImgResizingWindow(psk:PlaySketchCanvas)
        {
            super();				
			this.height = windowHeight;
			this.width = windowWidth;	
			playSketchCanv=psk;
			hBox.width=windowWidth-offsetForDisplayWidth;
			hBox.height=windowHeight-offsetForDisplayHeight;			
			videoDisplay.width=windowWidth-offsetForDisplayWidth;
			videoDisplay.height=windowHeight-offsetForDisplayHeight;
			videoDisplay.x=XForDisplay;
			videoDisplay.y=YForDisplay;
			hBox.x=XForDisplay;
			hBox.y=YForDisplay;		
		
        }
                     
        [SkinPart(required="false")]         
        public var resizeHandle:UIComponent;
        
   
        override protected function partAdded(partName:String, instance:Object) : void
        {
            super.partAdded(partName, instance);
            
            if (instance == resizeHandle)
              {resizeHandle.addEventListener(MouseEvent.MOUSE_DOWN, resizeHandle_mouseDownHandler);}								
        }
        
    
        override protected function partRemoved(partName:String, instance:Object):void
        {
            if (instance == resizeHandle)
            {
                resizeHandle.removeEventListener(MouseEvent.MOUSE_DOWN, resizeHandle_mouseDownHandler);
            }
            
            super.partRemoved(partName, instance);
        }
              
        
        public function resizeHandle_mouseDownHandler(event:MouseEvent):void
        {
            if (enabled && isPopUp && !clickOffset)
            {        
                clickOffset = new Point(event.stageX, event.stageY);
                prevWidth = width;
                prevHeight = height;
                
                var sbRoot:DisplayObject = systemManager.getSandboxRoot();
                
                sbRoot.addEventListener(
                    MouseEvent.MOUSE_MOVE, resizeHandle_mouseMoveHandler, true);
                sbRoot.addEventListener(
                    MouseEvent.MOUSE_UP, resizeHandle_mouseUpHandler, true);
                sbRoot.addEventListener(
                    SandboxMouseEvent.MOUSE_UP_SOMEWHERE, resizeHandle_mouseUpHandler)
            }
        }
        
		
      
        protected function resizeHandle_mouseMoveHandler(event:MouseEvent):void
        {
		 if(playSketchCanv.bitmapDataBeforeIrregular)
		  {
            event.stopImmediatePropagation();
            
            if (!clickOffset)
               {return;}
           			
            width = prevWidth + (event.stageX - clickOffset.x);
            height = prevHeight + (event.stageY - clickOffset.y);
										
						
			if(width>=playSketchCanv.bitmapDataBeforeIrregular.width)
			  {width=playSketchCanv.bitmapDataBeforeIrregular.width+offsetForDisplayWidth;}
			if(height>=playSketchCanv.bitmapDataBeforeIrregular.height)
			  {height=playSketchCanv.bitmapDataBeforeIrregular.height+offsetForDisplayHeight;}	
				
			if(width<=windowWidth)
			 {width=windowWidth;}
			if(height<=windowHeight)
			 {height=windowHeight;}
			
						    	
			setButtons();			
			videoDisplay.width=width-offsetForDisplayWidth;	
			videoDisplay.height=height-offsetForDisplayHeight;				
			hBox.width=width-offsetForDisplayWidth;	
			hBox.height=height-offsetForDisplayHeight;							
            event.updateAfterEvent();
		 }
        }
		
		public function setButtons():void
		{
			btnClose.x=width-90;
			btnClose.y=height-60;			
			btnLoad.x=width-165;	
			btnLoad.y=height-60					
			btnCamera.x=width-240;
			btnCamera.y=height-60				
			btnCameraSnap.x=width-315;
			btnCameraSnap.y=height-60;
			btnSav.x=width-425;
			btnSav.y=height-60;
			chooseCamBox.x=width-165;
			chooseCamBox.y=height-83;
		}
        
     
        protected function resizeHandle_mouseUpHandler(event:Event):void
        {
            clickOffset = null;
            prevWidth = 200;
            prevHeight = NaN;
			
            var sbRoot:DisplayObject = systemManager.getSandboxRoot();
            
            sbRoot.removeEventListener(
                MouseEvent.MOUSE_MOVE, resizeHandle_mouseMoveHandler, true);
            sbRoot.removeEventListener(
                MouseEvent.MOUSE_UP, resizeHandle_mouseUpHandler, true);
            sbRoot.removeEventListener(
                SandboxMouseEvent.MOUSE_UP_SOMEWHERE, resizeHandle_mouseUpHandler);
        }
    }
}