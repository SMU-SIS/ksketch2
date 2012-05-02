/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.geom.test
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import flexunit.framework.Assert;
	
	import sg.edu.smu.ksketch.utilities.KMathUtil;
	
	public class TestKMathUtil
	{		
		[Before]
		public function setUp():void
		{
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
		public function testDistanceBetweenPoints():void
		{
			var p1:Point = new Point(0,0);
			var p2:Point = new Point(3,4);
			
			Assert.assertEquals(5, KMathUtil.distanceOf(p1,p2));
		}
		
		[Test]
		public function testAngleOf():void
		{
			var p1:Point = new Point(0, -100);
			var p2:Point = new Point(100, 0);
			
			Assert.assertEquals(Math.PI / 2, KMathUtil.angleOf(p1, p2));
			
			p1 = new Point(100, 100);
			p2 = new Point(0, 100);
			
			Assert.assertEquals(Math.PI / 4, KMathUtil.angleOf(p1, p2));
			
			p1 = new Point(100, 100);
			p2 = new Point(100, -100);
			
			Assert.assertEquals(Math.PI / 2 * 3, KMathUtil.angleOf(p1, p2));
		}
		[Test]
		public function testLineSegmentCross():void
		{
			Assert.assertTrue(KMathUtil.lineSegmentCross(new Point(0, 0), new Point(100, 100), new Point(0, 100), new Point(100, 0)));
			var intersection:Point = KMathUtil.segmentIntersection(new Point(0, 0), new Point(100, 100), new Point(0, 100), new Point(100, 0));
			Assert.assertEquals(50, intersection.x);
			Assert.assertEquals(50, intersection.y);
			
			Assert.assertTrue(KMathUtil.lineSegmentCross(new Point(0, 0), new Point(100, 0), new Point(50, -50), new Point(50, 50)));
			intersection = KMathUtil.segmentIntersection(new Point(0, 0), new Point(100, 0), new Point(50, -50), new Point(50, 50));
			Assert.assertEquals(50, intersection.x);
			Assert.assertEquals(0, intersection.y);
			
			Assert.assertTrue(KMathUtil.lineSegmentCross(new Point(0, 0), new Point(100, 100), new Point(50, 50), new Point(100, 0)));			
			intersection = KMathUtil.segmentIntersection(new Point(0, 0), new Point(100, 100), new Point(50, 50), new Point(100, 0));
			Assert.assertEquals(50, intersection.x);
			Assert.assertEquals(50, intersection.y);
			
			Assert.assertFalse(KMathUtil.lineSegmentCross(new Point(0, 0), new Point(100, 100), new Point(50, 50), new Point(60, 60)));
			
			Assert.assertFalse(KMathUtil.lineSegmentCross(new Point(695, 242), new Point(695, 240.1234567789), new Point(695, 229), new Point(695, 227)));
			
			Assert.assertFalse(KMathUtil.lineSegmentCross(new Point(0, 0), new Point(2, 0), new Point(3, 0), new Point(4, 0)));
			Assert.assertFalse(KMathUtil.lineSegmentCross(new Point(0, 0), new Point(2, 0), new Point(1, 0), new Point(4, 0)));
			Assert.assertFalse(KMathUtil.lineSegmentCross(new Point(0, 0), new Point(2, 0), new Point(1, 1), new Point(4, 1)));
			
			Assert.assertFalse(KMathUtil.lineSegmentCross(new Point(0, 0), new Point(0, 2), new Point(0, 3), new Point(0, 4)));
			Assert.assertFalse(KMathUtil.lineSegmentCross(new Point(0, 0), new Point(0, 2), new Point(0, 1), new Point(0, 4)));
			Assert.assertFalse(KMathUtil.lineSegmentCross(new Point(0, 0), new Point(0, 2), new Point(1, 1), new Point(1, 4)));
		}
		
		[Test]
		public function testAreaAndPerimeter():void
		{
			var polygon:Vector.<Point> = new Vector.<Point>();
			polygon.push(new Point(0, 0), new Point(50, 0), new Point(50, 20), new Point(25, 40), new Point(0, 20));
			
			Assert.assertEquals(1500, KMathUtil.area(polygon));
			Assert.assertEquals(90+2*Math.sqrt(25*25+20*20), KMathUtil.perimeter(polygon));
			
		}
		
	}
}