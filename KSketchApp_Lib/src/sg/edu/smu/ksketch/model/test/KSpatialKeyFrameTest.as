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
	
	import sg.edu.smu.ksketch.model.implementations.KSpatialKeyFrame;

	public class KSpatialKeyFrameTest
	{		
		private const _TOL:Number = 0.001;
		
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
		public function testAddToTranslation():void
		{
			var point1:Point = new Point(0,1);
			var point2:Point = new Point(1,0);
			var point3:Point = new Point(1,1);
			var keyframe:KSpatialKeyFrame = new KSpatialKeyFrame(0,new Point(0,0));
			
			keyframe.addToTranslation(point1.x,point1.y,0);
			keyframe.addToTranslation(point2.x,point2.y,1);
			keyframe.addToTranslation(point3.x,point3.y,2);
			keyframe.endTime = 2;
			
			_assertPoint(new Point(0,0),keyframe.getTranslation(0),_TOL);
			_assertPoint(new Point(1,-1),keyframe.getTranslation(1),_TOL);
			_assertPoint(new Point(1,0),keyframe.getTranslation(2),_TOL);
			
		//	var actual:Matrix = keyframe.getFullMatrix(2,new Matrix());
			//var expected:Matrix = new Matrix();
			//expected.translate(1,0);
			//_assertMatrix(expected,actual,_TOL);
		}
		
		[Test]
		public function testAddToRotation():void
		{
			var point1:Point = new Point(0,1);
			var point2:Point = new Point(1,0);
			var point3:Point = new Point(0,-1);
			var point4:Point = new Point(-1,0);
			var keyframe:KSpatialKeyFrame = new KSpatialKeyFrame(0,new Point(0,0));
			
			//keyframe.addToRotation(point1.x,point1.y,0);
			//keyframe.addToRotation(point2.x,point2.y,1);
			//keyframe.addToRotation(point3.x,point3.y,2);
			//keyframe.addToRotation(point4.x,point4.y,3);
			//keyframe.endTime = 3;
			
			_assertNumber(0,keyframe.getRotation(0),_TOL);
			_assertNumber(1.5*Math.PI,keyframe.getRotation(1),_TOL);
			_assertNumber(1*Math.PI,keyframe.getRotation(2),_TOL);
			_assertNumber(0.5*Math.PI,keyframe.getRotation(3),_TOL);

			//var actual:Matrix = keyframe.getFullMatrix(3,new Matrix());
			//var expected:Matrix = new Matrix();
			//expected.rotate(Math.PI/2);
			//_assertMatrix(expected,actual,_TOL);
		}
		
		[Test]
		public function testAddToScale():void
		{
			var point1:Point = new Point(1,0);
			var point2:Point = new Point(2,0);
			var point3:Point = new Point(1,0);
			var point4:Point = new Point(0.5,0);
			var keyframe:KSpatialKeyFrame = new KSpatialKeyFrame(0,new Point(0,0));
			
			//keyframe.addToScale(point1.x,point1.y,0);
			//keyframe.addToScale(point2.x,point2.y,1);
			//keyframe.addToScale(point3.x,point3.y,2);
			//keyframe.addToScale(point4.x,point4.y,3);
			//keyframe.endTime = 3;

			_assertNumber(1,keyframe.getScale(0),_TOL);
			_assertNumber(2,keyframe.getScale(1),_TOL);		
			_assertNumber(1,keyframe.getScale(2),_TOL);		
			_assertNumber(0.5,keyframe.getScale(3),_TOL);		

			//var actual:Matrix = keyframe.getFullMatrix(3,new Matrix());
			//var expected:Matrix = new Matrix();
			//expected.scale(0.5,0.5);
			//_assertMatrix(expected,actual,_TOL);
		}
		
		[Test]
		public function test_AddToTranslate_AddToRotation_AddToScale():void
		{
			var point1:Point = new Point(0,1);
			var point2:Point = new Point(1,0);
			var point3:Point = new Point(1,1);
			var point4:Point = new Point(0,1);
			var point5:Point = new Point(1,0);
			var point6:Point = new Point(0,-1);
			var point7:Point = new Point(-1,0);
			var point8:Point = new Point(1,0);
			var point9:Point = new Point(2,0);
			var point10:Point = new Point(1,0);
			var point11:Point = new Point(0.5,0);

			var keyframe:KSpatialKeyFrame = new KSpatialKeyFrame(0,new Point(0,0));
			//keyframe.addToTranslation(point1.x,point1.y,0);
			//keyframe.addToTranslation(point2.x,point2.y,1);
			//keyframe.addToTranslation(point3.x,point3.y,2);
			//keyframe.addToRotation(point4.x,point4.y,0);
			//keyframe.addToRotation(point5.x,point5.y,1);
			//keyframe.addToRotation(point6.x,point6.y,2);
			//keyframe.addToRotation(point7.x,point7.y,3);
			//keyframe.addToScale(point8.x,point8.y,0);
			//keyframe.addToScale(point9.x,point9.y,1);
			//keyframe.addToScale(point10.x,point10.y,2);
			//keyframe.addToScale(point11.x,point11.y,3);
			//keyframe.endTime = 3;			

			_assertPoint(new Point(1,0),keyframe.getTranslation(2),_TOL);
			_assertNumber(0.5*Math.PI,keyframe.getRotation(3),_TOL);
			_assertNumber(0.5,keyframe.getScale(3),_TOL);
			
			//var actual:Matrix = keyframe.getFullMatrix(3,new Matrix());
			//var expected:Matrix = new Matrix();
			//expected.scale(0.5,0.5);
			//expected.rotate(Math.PI/2);
			//expected.translate(1,0);
			//_assertMatrix(expected,actual,_TOL);
		}
		
		private function _assertMatrix(expected:Matrix,actual:Matrix,tol:Number):void
		{
			var da:Number = Math.abs(expected.a-actual.a);
			var db:Number = Math.abs(expected.b-actual.b);
			var dc:Number = Math.abs(expected.c-actual.c);
			var dd:Number = Math.abs(expected.d-actual.d);
			var dx:Number = Math.abs(expected.tx-actual.tx);
			var dy:Number = Math.abs(expected.ty-actual.ty);
			if (da + db + dc + dd + dx + dy > tol)
				throw new Error(
					"expected: Matrix(" + 
					expected.a + "," + expected.b + "," + expected.c + "," + 
					expected.d + "," + expected.tx + "," + expected.ty + "), " +
					"but was: Matrix(" + 
					actual.a + "," + actual.b + "," + actual.c + "," + 
					actual.d + "," + actual.tx + "," + actual.ty + ")");
		}
		
		private function _assertPoint(expected:Point,actual:Point,tol:Number):void
		{
			var diff:Point = expected.subtract(actual);
			if (Math.sqrt(diff.x*diff.x + diff.y*diff.y) > tol)
				throw new Error("expected: Point(" + expected.x + "," + expected.y + "), " +
					"but was: Point(" + actual.x + "," + actual.y + ")");
		}
		
		private function _assertNumber(expected:Number,actual:Number,tol:Number):void
		{
			if(Math.abs(expected - actual) > tol)
				throw new Error("expected: "+expected+ "+-"+tol+", but was: "+actual);
		}
	}
}