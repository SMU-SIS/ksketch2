/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.utilities.test
{
	import flash.geom.Point;
	
	import flexunit.framework.Assert;
	
	import sg.edu.smu.ksketch.model.KModel;
	import sg.edu.smu.ksketch.model.KStroke;
	import sg.edu.smu.ksketch.utilities.KClipBoard;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;
	
	public class KClipBoardTest
	{	
		private var _clipboard:KClipBoard;
		private var _points1:Vector.<Point>;
		private var _points2:Vector.<Point>;
		private var _stroke1:KStroke;
		private var _stroke2:KStroke;
		
		[Before]
		public function setUp():void
		{
			_points1 = _createPoints([new Point(),new Point(100,100),new Point(200,200)]);
			_points2 = _createPoints([new Point(-10,-10),new Point(-5,-5),new Point()]);
			_stroke1 = new KStroke(-1,0,_points1);
			_stroke2 = new KStroke(-1,0,_points2);
			_clipboard = new KClipBoard();
			var list:KModelObjectList = new KModelObjectList();
			list.add(_stroke1);
			list.add(_stroke2);
			_clipboard.put(list,0);
		}
		
		[After]
		public function tearDown():void
		{
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		
		[Test]
		public function testClear():void
		{
			_clipboard.clear();
			var list:KModelObjectList = _clipboard.get(null,0);
			Assert.assertEquals(0,list.length());			
		}		
		
		[Test]
		public function testGet():void
		{
			var offset:int = KClipBoard.OFFSET_INCREMENT;
			var list:KModelObjectList = _clipboard.get(null,0);
			Assert.assertEquals(2,list.length());
			Assert.assertObjectEquals(_shift(_points1,offset),(list.getObjectAt(0) as KStroke).points);
			Assert.assertObjectEquals(_shift(_points2,offset),(list.getObjectAt(1) as KStroke).points);
		}
		
		[Test]
		public function testPut():void
		{
			var offset:int = KClipBoard.OFFSET_INCREMENT;
			var pts:Vector.<Point> = _createPoints([new Point(),new Point(30,0),new Point(0,30)]);
			var stroke:KStroke = new KStroke(-1,0,pts);
			var list:KModelObjectList = new KModelObjectList();
			list.add(stroke);
			_clipboard.put(list,0);
			list = _clipboard.get(null,0);
			Assert.assertEquals(1,list.length());
			Assert.assertObjectEquals(_shift(pts,offset),(list.getObjectAt(0) as KStroke).points);
		}
		
		private function _createPoints(array:Array):Vector.<Point>
		{
			var points:Vector.<Point> = new Vector.<Point>();
			for (var i:int; i < array.length; i++)
				points.push(array[i]);
			return points;
		}
		
		private function _shift(points:Vector.<Point>, amount:int):Vector.<Point>
		{
			var pts:Vector.<Point> = new Vector.<Point>(); 
			for (var i:int; i < points.length; i++)
				pts[i] = points[i].add(new Point(amount,amount));
			return pts;
		}
	}
}