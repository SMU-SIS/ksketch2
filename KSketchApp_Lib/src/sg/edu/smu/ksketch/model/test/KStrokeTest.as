/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.model.test
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import flexunit.framework.Assert;
	
	import org.flexunit.async.Async;
	
	import sg.edu.smu.ksketch.event.KObjectEvent;
	import sg.edu.smu.ksketch.model.KStroke;
	
	import spark.primitives.Rect;
	
	public class KStrokeTest
	{		
		private var _stroke:KStroke;

		[Before]
		public function setUp():void
		{
			_stroke = new KStroke(-1,0);
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
		public function testKStroke():void
		{
			Assert.assertNotNull(_stroke.points);
			Assert.assertEquals(0, _stroke.points.length);
			Assert.assertEquals(1, _stroke.thickness);
			Assert.assertEquals(0, _stroke.color);
			Assert.assertObjectEquals(new Matrix(), _stroke.getFullMatrix(0));
		}
		
		[Test(async)]
		public function testAddPoint():void
		{
			Async.proceedOnEvent(this, _stroke, KObjectEvent.EVENT_POINTS_CHANGED, 500);
			_stroke.addPoint(100, 200);
			Assert.assertEquals(1, _stroke.points.length);
			Assert.assertEquals(100, _stroke.points[0].x);
			Assert.assertEquals(200, _stroke.points[0].y);
			
			Async.proceedOnEvent(this, _stroke, KObjectEvent.EVENT_POINTS_CHANGED, 500);
			_stroke.addPoint(300, 400);
			Async.proceedOnEvent(this, _stroke, KObjectEvent.EVENT_POINTS_CHANGED, 500);
			_stroke.addPoint(-2.45, -43.12);
			Assert.assertEquals(3, _stroke.points.length);
			Assert.assertObjectEquals(new Point(300,400), _stroke.points[1]);
			Assert.assertObjectEquals(new Point(-2.45,-43.12), _stroke.points[2]);
			_stroke.endAddingPoint();
			var expected_center:Point = new Point((300-2.45)/2,(400-43.12)/2); 
			Assert.assertObjectEquals(expected_center, _stroke.handleCenter(10));
		}
		
		[Test]
		public function testGetBoundingRect():void
		{
			_stroke.addPoint(10, 10);
			_stroke.addPoint(0, 0);
			_stroke.addPoint(-10, -10);
			_stroke.endAddingPoint();
			Assert.assertObjectEquals(new Rectangle(-10,-10,20,20),_stroke.getBoundingRect(0));
		}
	}
}