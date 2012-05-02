/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.gestures.test
{
	import flexunit.framework.Assert;
	
	import sg.edu.smu.ksketch.geom.KTimestampPoint;
	import sg.edu.smu.ksketch.gestures.PigtailDetector;
	
	public class PigtailDetectorTest
	{		
		private var _detector:PigtailDetector;
		
		[Before]
		public function setUp():void
		{
			_detector = new PigtailDetector();
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
		public function testHasSelfIntersection():void
		{
			var polyline:Vector.<KTimestampPoint> = new Vector.<KTimestampPoint>();
			polyline.push(new KTimestampPoint(0, 100, 100), new KTimestampPoint(0, 100, 50), 
				new KTimestampPoint(0, 100, 30), new KTimestampPoint(0, 100, -10),
				new KTimestampPoint(0, 100, -100), new KTimestampPoint(0, 0, 0), 
				new KTimestampPoint(0, 200, 0));
			var index:int = _detector.hasSelfIntersection(polyline);
			Assert.assertEquals(2, index);
		}
	}
}