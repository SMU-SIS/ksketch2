/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.model.test
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import flexunit.framework.Assert;
	
	import sg.edu.smu.ksketch.model.implementations.KParentKeyframe;
	import sg.edu.smu.ksketch.model.implementations.KReferenceFrame;
	import sg.edu.smu.ksketch.model.implementations.KSpatialKeyFrame;
	
	public class KReferenceFrameTest
	{	
		private var _referenceFrame:KReferenceFrame;
		private var _spatialKey:KSpatialKeyFrame;
		
		[Before]
		public function setUp():void
		{
			_referenceFrame = new KReferenceFrame();
			_spatialKey = _referenceFrame.createSpatialKey(1000,10,10) as KSpatialKeyFrame;
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
		
		[Test]
		public function testCreateSpatialKey():void
		{
			Assert.assertObjectEquals(new Point(10,10),_spatialKey.center);
			Assert.assertEquals(1000,_spatialKey.endTime);
			Assert.assertEquals(0,_referenceFrame.numKeys);
		}
		
		[Test]
		public function testGetMatrix():void
		{
			//Assert.assertObjectEquals(new Matrix(), _referenceFrame.getMatrix(0));
			//Assert.assertObjectEquals(new Matrix(), _referenceFrame.getMatrix(1000));
			//Assert.assertObjectEquals(new Matrix(), _referenceFrame.getMatrix(2000));
			
			//_spatialKey.addToTranslation(0,0,0,0);
			//_spatialKey.addToTranslation(100,100,1000,0);
			//_spatialKey.endTime = 1000;
			//_referenceFrame.insertKey(_spatialKey);
			
			//Assert.assertObjectEquals(new Matrix(1,0,0,1,0,0), _referenceFrame.getMatrix(0));
			//Assert.assertObjectEquals(new Matrix(1,0,0,1,100,100), _referenceFrame.getMatrix(1000));
			//Assert.assertObjectEquals(new Matrix(1,0,0,1,100,100), _referenceFrame.getMatrix(2000));
			//Assert.assertObjectEquals(new Matrix(1,0,0,1,50,50), _referenceFrame.getMatrix(500));
		}

	}
}