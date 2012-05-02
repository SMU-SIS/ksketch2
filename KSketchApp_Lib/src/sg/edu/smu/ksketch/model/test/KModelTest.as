/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.model.test
{
	import flexunit.framework.Assert;

	import org.flexunit.async.Async;

	import sg.edu.smu.ksketch.event.KModelEvent;
	import sg.edu.smu.ksketch.event.KObjectEvent;
	import sg.edu.smu.ksketch.model.KModel;
	import sg.edu.smu.ksketch.model.KStroke;
	import sg.edu.smu.ksketch.utilities.ErrorMessage;
	
	public class KModelTest
	{		
		private var _model:KModel;
		private var _stroke:KStroke;

		[Before]
		public function setUp():void
		{
			_model = new KModel();
			_stroke = new KStroke(-1, -1);
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
		
		[Test(async)]
		public function testAdd():void
		{
			Async.handleEvent(this, _model, KObjectEvent.EVENT_OBJECT_ADDED, 
				_objectEventHandler, 500, _stroke);
			_model.add(_stroke);		
			try
			{
				Async.failOnEvent(this, _model, KObjectEvent.EVENT_OBJECT_ADDED, 500);
				_model.add(_stroke);	
				Assert.fail("Expected error not catched!");
			}
			catch(e:Error)
			{
				Assert.assertTrue(e is Error);
				Assert.assertEquals(ErrorMessage.OBJECT_EXISTS, e.message);
			}
		}
		
		[Test]
		public function testGetObjectAt():void
		{
			_model.add(_stroke);
			Assert.assertEquals(_stroke,_model.getObjectAt(0));
		}
				
		[Test]
		public function testLength():void
		{
			Assert.assertEquals(0,_model.length());
			_model.add(_stroke);
			Assert.assertEquals(1,_model.length());
			_model.remove(_stroke);
			Assert.assertEquals(0,_model.length());
		}

		[Test(async)]
		public function testRemove():void
		{
			_model.add(_stroke);
			Async.handleEvent(this, _model, KObjectEvent.EVENT_OBJECT_REMOVED, 
				_objectEventHandler, 500, _stroke);
			_model.remove(_stroke);		
			
			try
			{
				Async.failOnEvent(this, _model, KObjectEvent.EVENT_OBJECT_REMOVED, 500);
				_model.remove(_stroke);
				Assert.fail("Expected error not catched!");
			}
			catch(e:Error)
			{
				Assert.assertTrue(e is Error);
				Assert.assertEquals(ErrorMessage.OBJECT_NOT_EXIST, e.message);
			}
		}
		
		[Test]
		public function testResetModel():void
		{
			_model.add(_stroke);
			Assert.assertEquals(1,_model.length());
			_model.resetModel();
			Assert.assertEquals(0,_model.length());
		}				

		private function _objectEventHandler(event:KObjectEvent, passThroughData:Object):void
		{
			var stroke:KStroke = passThroughData as KStroke;
			Assert.assertEquals(stroke, event.object);
		}
		
	}
}