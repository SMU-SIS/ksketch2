/**
 * Copyright 2010-2015 Singapore Management University
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.utils
{
	import mx.core.ILayoutElement;
	
	import spark.components.supportClasses.GroupBase;
	import spark.layouts.supportClasses.LayoutBase;	
	import org.osmf.layout.HorizontalAlign;
	import sg.edu.smu.ksketch2.KSketchGlobals;
	
	public class KCustomLayout extends LayoutBase {
		private var columnCount:int = 3;		
		private var bigTileWidth:Number = 300 * KSketchGlobals.SCALE;
		private var bigTileHeight:Number = 220 * KSketchGlobals.SCALE;
		private var smallTileWidth:Number = 300 * KSketchGlobals.SCALE;
		private var smallTileHeight:Number = 200 * KSketchGlobals.SCALE;
		
		override public function updateDisplayList(width:Number, height:Number):void {
			var layoutTarget:GroupBase = target;
			if (!layoutTarget) return;
			
			var numElements:int = layoutTarget.numElements;
			if (!numElements) return;
			
			var el:ILayoutElement;
			var margin:int = (layoutTarget.width - bigTileWidth * 3)/2;
			
			for (var i:int=0; i<numElements; i++) {
				var x:Number = (i%columnCount == 0) ? margin : bigTileWidth  * ((i-1) % columnCount)  + bigTileWidth + margin;
				var y:Number = bigTileHeight * Math.floor(i/columnCount);
				
				el = useVirtualLayout ? 
					layoutTarget.getVirtualElementAt(i) : 
					layoutTarget.getElementAt(i);
				el.setLayoutBoundsSize(bigTileWidth, bigTileHeight);
				el.setLayoutBoundsPosition(x, y);
				el.horizontalCenter = HorizontalAlign.CENTER;
				el.top = 10;
			}
			
			layoutTarget.top = 10;
			layoutTarget.setContentSize(bigTileWidth, bigTileHeight);
			layoutTarget.horizontalCenter = HorizontalAlign.CENTER;
		}
		
		override public function measure():void {
			var layoutTarget:GroupBase = target;
			if (!layoutTarget) return;
			
			var rowCount:int = Math.ceil((layoutTarget.numElements - 1) / columnCount);
			
			//measure the total width and height
			layoutTarget.measuredWidth = layoutTarget.measuredMinWidth = 
				Math.max(smallTileWidth * columnCount, bigTileWidth);
			layoutTarget.measuredHeight = layoutTarget.measuredMinHeight = 
				smallTileHeight + smallTileHeight * rowCount;
			layoutTarget.horizontalCenter = HorizontalAlign.CENTER;
		}
		
	}
}