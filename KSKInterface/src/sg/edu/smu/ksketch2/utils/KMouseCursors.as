/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.ui.MouseCursorData;

	public class KMouseCursors
	{
		public static const CUSOR_DEFAULT:String = MouseCursor.AUTO;
		public static const CURSOR_SELECT:String = "SELECT";
		public static const CUSOR_DEMO:String = "DEMO";
		public static const CURSOR_INTERPOLATE:String = MouseCursor.HAND;
		
		[Embed (source="assets/Demo_Cursor_Frame_1.png" )]
		private var DemoFrame1:Class;
		[Embed (source="assets/Demo_Cursor_Frame_2.png" )]
		private var DemoFrame2:Class;
		[Embed (source="assets/Selection_Cursor.png" )]
		private var SelectIcon:Class;
		
		private var _demoCursor:MouseCursorData;
		private var _selectCursor:MouseCursorData
		private var _previousCursor:String;
		
		public function KMouseCursors()
		{
			// Create a MouseCursorData object
			_demoCursor = new MouseCursorData();
			
			var bitmapDatas:Vector.<BitmapData> = new Vector.<BitmapData>();
			var frame1:Bitmap = new DemoFrame1();
			var frame2:Bitmap = new DemoFrame2();
			bitmapDatas.push(frame1.bitmapData);
			bitmapDatas.push(frame2.bitmapData);
			_demoCursor.data = bitmapDatas;
			_demoCursor.frameRate = 4;
			Mouse.registerCursor(CUSOR_DEMO, _demoCursor);
			
			_selectCursor = new MouseCursorData();
			bitmapDatas = new Vector.<BitmapData>();
			frame1 = new SelectIcon();
			bitmapDatas.push(frame1.bitmapData);
			_selectCursor.data = bitmapDatas;
			_selectCursor.frameRate = 4;
			Mouse.registerCursor(CURSOR_SELECT, _selectCursor);
			
			setMouseCursor(CURSOR_INTERPOLATE);
		}
		
		public function setMouseCursor(type:String):void
		{
			if(_previousCursor != type)
				_previousCursor = Mouse.cursor;
			//Mouse.cursor = type;	
		}
		
		public function previousCursor():void
		{
			setMouseCursor(_previousCursor);
			Mouse.show();
		}
	}
}