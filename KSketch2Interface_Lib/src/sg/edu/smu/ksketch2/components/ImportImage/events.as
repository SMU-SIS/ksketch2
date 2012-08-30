/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package sg.edu.smu.ksketch2.components.ImportImage
{
	import sg.edu.smu.ksketch2.components.ImportImage.ImageTrim;	
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	
	public class events
	{
		private var imgTrim:ImageTrim;
		public var myDott:Dott;
		private var array:Array;
		
		public function events(dott:Dott,imgtrm:ImageTrim)
		{
		   this.myDott=dott;
		   this.imgTrim=imgtrm;	
		}
		
		public function onClick(event:MouseEvent) :void
		{				
			myDott.shape.x=event.localX;
			myDott.shape.y=event.localY;			
			setupThePoints()			
			imgTrim.removeEventListener(MouseEvent.MOUSE_MOVE,onMove);														
			lineLoop();																									
		}
		
		
		public function onDown(event:MouseEvent):void
		{		
			myDott.shape.x=event.localX
			myDott.shape.y=event.localY;													
			imgTrim.addEventListener(MouseEvent.MOUSE_MOVE, onMove);				
			lineLoop();												
		}
		
		
		public function onMove(event:MouseEvent):void
		{ 						
			myDott.shape.x=event.localX
			myDott.shape.y=event.localY;								
			myDott.addEventListener(MouseEvent.MOUSE_UP, onClick);								
			setupThePoints()			
		    lineLoop();
		}
		
		
		public function setupThePoints():void
		{
			for(var i:int=0; i<imgTrim.dotsArray.length; i++)
			{
				imgTrim.poinsArray[i]=new Point(imgTrim.dotsArray[i].shape.x, imgTrim.dotsArray[i].shape.y);
			}	
		}
		
		public function lineLoop():void
		{
			imgTrim.lineShape.graphics.clear();						
			imgTrim.lineShape.graphics.lineStyle(1, 0xFF0000);					
			imgTrim.lineShape.graphics.moveTo(imgTrim.poinsArray[0].x, imgTrim.poinsArray[0].y);
			
			for(var j:int=1; j<imgTrim.poinsArray.length; j++)
			{											
				imgTrim.lineShape.graphics.lineTo(imgTrim.poinsArray[j].x, imgTrim.poinsArray[j].y);				
			}	
		}
												
	}
}