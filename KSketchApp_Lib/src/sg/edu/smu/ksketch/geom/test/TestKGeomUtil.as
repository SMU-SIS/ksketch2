/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.geom.test
{
	import flash.geom.Point;
	
	import flexunit.framework.Assert;
	
	import sg.edu.smu.ksketch.geom.KGeomUtil;
	import sg.edu.smu.ksketch.model.geom.KPathPoint;

	public class TestKGeomUtil
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
		public function testInterpolateTranslation():void
		{
	//		var translations:Vector.<KPathPoint> = new Vector.<KPathPoint>();
	//		translations.push(new KPathPoint(1, 10, 20));
			
	//		Assert.assertEquals(translations.toString(), KGeomUtil.interpolateTranslation(1,1,new Point(10,20)).toString());
		}		
		
	}
}