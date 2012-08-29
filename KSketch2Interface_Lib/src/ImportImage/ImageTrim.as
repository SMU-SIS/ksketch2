/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package ImportImage
{
	import ImportImage.events;	
	import flash.display.*;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;	
	import mx.core.*;
	import mx.graphics.IFill;
	import mx.graphics.IStroke;
	import mx.graphics.SolidColor;
	import mx.graphics.Stroke;	
	import spark.primitives.Line;

	
	public class ImageTrim extends UIComponent
	{
		public static var LOADED:String = "imagecrop.loaded";		
		public var imageLoader:Loader = new Loader();
		public var loadFileRef:FileReference;
		public var image:Bitmap;
		public var poinsArray:Array;
		public var dotsArray:Array;
		public var lineShape:Shape;
		private var imgResWindow:ImgResizingWindow;
		private var psCanvas:KSketch2Canvas;
		
		public function ImageTrim(irw:ImgResizingWindow,btnFunct:KSketch2Canvas)
		{
			imgResWindow=irw;
			psCanvas=btnFunct;
		}
   		
		
		public function loadImage():void 
		{
			loadFileRef=new FileReference();		
			loadFileRef.browse();
			loadFileRef.addEventListener(Event.SELECT, onFileSelect);
		}
	
		private function onFileSelect(e:Event):void
		{		
			loadFileRef.addEventListener(Event.COMPLETE, onFileLoadComplete);
			loadFileRef.load();		
		}
		
		private function onFileLoadComplete(e:Event):void 
		{			
			imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadImageComplete);
			imageLoader.loadBytes(loadFileRef.data);		
			loadFileRef = null;
		}
				
		public function loadImageComplete1(bmpdata:Bitmap):void
		{
			image = Bitmap(bmpdata);
			setupForImageComplete();			
		} 
		
		private function loadImageComplete(e:Event):void
		{
			image = Bitmap(e.target.loader.content);
			imageLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadImageComplete); 
			setupForImageComplete();	
		}
					
						
		private function setupForImageComplete():void
		{
			this.width = image.width;
			this.height = image.height;				
			this.addChild(image);																			
		    this.doubleClickEnabled=true;			
			poinsArray=new Array();
			dotsArray=new Array();
			lineShape=new Shape();		
		    this.addEventListener(MouseEvent.MOUSE_DOWN, onCallTheDott);								
		}
		
								
		public function onCallTheDott(event:MouseEvent):void
		{		
			
			if(event.target is Dott)
			  {return;}
			
		    var dotEvents:events;
			var mydot:Dott = new Dott();				
					
			mydot.shape.x=event.localX;
			mydot.shape.y=event.localY;							
			dotsArray.push(mydot);		
			dotEvents=new events(mydot,this);
									
			for(var i:int=0; i<dotsArray.length; i++)
			  {poinsArray[i]=new Point(dotsArray[i].shape.x, dotsArray[i].shape.y);}
			
			mydot.addEventListener(MouseEvent.MOUSE_DOWN,dotEvents.onDown,false, 10);	
						
			dotEvents.lineLoop()						
			this.addChild(lineShape);
			this.addChild(mydot);	
			setChildIndex(lineShape, 1);	
			
			if(poinsArray.length==3)
			  {psCanvas.isRegionDrawn=true;}
			
			imgResWindow.btnLoad.enabled=true;
		}
									
	}
}