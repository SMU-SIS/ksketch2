/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.components.test
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import flexunit.framework.Assert;
	
	import sg.edu.smu.ksketch.components.KGroupView;
	import sg.edu.smu.ksketch.event.KObjectEvent;
	import sg.edu.smu.ksketch.event.KTimeChangedEvent;
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.model.KStroke;
	import sg.edu.smu.ksketch.operation.KModelFacade;
	import sg.edu.smu.ksketch.utilities.KAppState;
	
	public class KGroupViewTest
	{
		private const _EPSILON:Number = 0.1;

		private var _view:KGroupView;
		private var _group:KGroup;
		
		private var _appState:KAppState;
		private var _facade:KModelFacade;
		
		[Before]
		public function setUp():void
		{
			_appState = new KAppState();
			_facade = new KModelFacade(_appState);
			_group = new KGroup(0, 0, null, new Point(0, 0));			
			_view = new KGroupView(_appState, _group);
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
		public function testRemoveListeners():void
		{
			Assert.assertTrue(_group.hasEventListener(KObjectEvent.EVENT_TRANSFORM_CHANGED));
			Assert.assertTrue(_group.hasEventListener(KObjectEvent.EVENT_VISIBILITY_CHANGED));
			
			_view.removeListeners();
			
			Assert.assertFalse(_group.hasEventListener(KObjectEvent.EVENT_TRANSFORM_CHANGED));
			Assert.assertFalse(_group.hasEventListener(KObjectEvent.EVENT_VISIBILITY_CHANGED));
			Assert.assertFalse(_appState.hasEventListener(KTimeChangedEvent.TIME_CHANGED));
		}
		
		[Test]
		public function testTranslateGroup():void
		{
			//_facade.beginTranslation(_group,0, KAppState.TRANSITION_REALTIME);
			//_facade.addToTranslation(_group, new Point(), 0);
			//_facade.addToTranslation(_group, new Point(50, 60), 1000);
			//_facade.endTranslation(_group, _appState.time = 1000);
			
			Assert.assertEquals(50, _view.transform.matrix.tx);
			Assert.assertEquals(60, _view.transform.matrix.ty);
		}
		
		[Test]
		public function testRotateGroup():void
		{
			//_facade.beginRotation(_group,new Point(100,200),0,KAppState.TRANSITION_REALTIME);
			//_facade.addToRotation(_group, new Point(100, 0), 0);
			//_facade.addToRotation(_group, new Point(200, 200), 1000);
			//_facade.endRotation(_group, _appState.time = 1000);
			
			var result:Matrix = new Matrix();
			result.translate(-100, -200);
			result.rotate(Math.PI/2);
			result.translate(100, 200);
			
			Assert.assertEquals(result.a, _view.transform.matrix.a);
			Assert.assertEquals(result.b, _view.transform.matrix.b);
			Assert.assertEquals(result.c, _view.transform.matrix.c);
			Assert.assertEquals(result.d, _view.transform.matrix.d);
			Assert.assertTrue(_assertionTolerance(result.tx, _view.transform.matrix.tx));
			Assert.assertTrue(_assertionTolerance(result.ty, _view.transform.matrix.ty));
		}
		
		[Test]
		public function testScaleGroup():void
		{
			//_facade.beginScale(_group,new Point(100,200),0,KAppState.TRANSITION_REALTIME);
			//_facade.addToScale(_group, new Point(100, 300), 0);
			//_facade.addToScale(_group, new Point(100, 400), 1000);
			//_facade.endScale(_group, _appState.time = 1000);
			
			var result:Matrix = new Matrix();
			result.translate(-100, -200);
			result.scale(2, 2);
			result.translate(100, 200);
			
			Assert.assertEquals(result.a, _view.transform.matrix.a);
			Assert.assertEquals(result.b, _view.transform.matrix.b);
			Assert.assertEquals(result.c, _view.transform.matrix.c);
			Assert.assertEquals(result.d, _view.transform.matrix.d);
			Assert.assertEquals(result.tx, _view.transform.matrix.tx);
			Assert.assertEquals(result.ty, _view.transform.matrix.ty);
		}

		private function _assertionTolerance(trueValue:Number, testValue:Number):Boolean
		{
			if(Math.abs(trueValue - testValue)<_EPSILON)
				return true;
			else
				return false;
		}		
	}
}