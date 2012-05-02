/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.components.test
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import flexunit.framework.Assert;
	
	import sg.edu.smu.ksketch.components.KCanvas;
	import sg.edu.smu.ksketch.event.KObjectEvent;
	import sg.edu.smu.ksketch.event.KSelectionChangedEvent;
	import sg.edu.smu.ksketch.event.KTimeChangedEvent;
	import sg.edu.smu.ksketch.model.KStroke;
	import sg.edu.smu.ksketch.operation.KModelFacade;
	import sg.edu.smu.ksketch.utilities.KAppState;
	
	public class KCanvasTest
	{		
		private var _canvas:KCanvas;
		private var _facade:KModelFacade;
		private var _appState:KAppState;
		
		[Before]
		public function setUp():void
		{
			_appState = new KAppState();
			_facade = new KModelFacade(_appState);
			_canvas = new KCanvas();
			_canvas.initKCanvas(_facade, _appState);
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
		public function testKCanvas():void
		{
			Assert.assertTrue(_facade.hasEventListener(KObjectEvent.EVENT_OBJECT_ADDED));
			Assert.assertTrue(_facade.hasEventListener(KObjectEvent.EVENT_OBJECT_REMOVED));
			Assert.assertTrue(_appState.hasEventListener(KSelectionChangedEvent.EVENT_SELECTION_CHANGED));
			Assert.assertTrue(_appState.hasEventListener(KTimeChangedEvent.TIME_CHANGED));
		}
		
		[Test]
		public function testObjectAddedAndRemovedEventHandler():void
		{
			var stroke:KStroke = new KStroke(-1, 0);
			_facade.dispatchEvent(new KObjectEvent(stroke, KObjectEvent.EVENT_OBJECT_ADDED));
			Assert.assertTrue(stroke.hasEventListener(KObjectEvent.EVENT_POINTS_CHANGED));
			Assert.assertTrue(stroke.hasEventListener(KObjectEvent.EVENT_TRANSFORM_CHANGED));
			
			_facade.dispatchEvent(new KObjectEvent(stroke, KObjectEvent.EVENT_OBJECT_REMOVED));
			Assert.assertFalse(stroke.hasEventListener(KObjectEvent.EVENT_POINTS_CHANGED));
			Assert.assertFalse(stroke.hasEventListener(KObjectEvent.EVENT_TRANSFORM_CHANGED));
		}
		
	}
}