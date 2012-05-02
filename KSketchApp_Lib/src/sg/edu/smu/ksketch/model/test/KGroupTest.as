/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.model.test
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import flexunit.framework.Assert;
	
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.model.KStroke;
	import sg.edu.smu.ksketch.utilities.IIterator;

	public class KGroupTest
	{
		private var _root:KGroup;
		private var _group:KGroup;
		private var _subGroup:KGroup;
		private var _stroke1:KStroke;
		private var _stroke2:KStroke;
		private var _stroke3:KStroke;
		private var _stroke4:KStroke;
		
		[Before]
		public function setUp():void
		{
			_group = new KGroup(-1, 0, null, new Point(0, 0));
			_subGroup = new KGroup(-1, 0, null, new Point(10, 10));

			_stroke1 = new KStroke(1,0);
			_stroke1.addPoint(-1,-1);
			_stroke1.addPoint(0,0);
			_stroke1.addPoint(1,1);
			
			_stroke2 = new KStroke(2,0);
			_stroke2.addPoint(0,0);
			_stroke2.addPoint(2,0);
			_stroke2.addPoint(2,2);
			
			_stroke3 = new KStroke(3,0);
			_stroke3.addPoint(-1,1);
			_stroke3.addPoint(0,0);
			_stroke3.addPoint(1,-1);
			
			_stroke4 = new KStroke(4,0);
			_stroke4.addPoint(0,0);
			_stroke4.addPoint(0,2);
			_stroke4.addPoint(2,2);
			
			_root = new KGroup(-1, 0, null, new Point(0, 0));
			_root.add(_group);
			_root.add(_subGroup);
			_root.add(_stroke1);
			_root.add(_stroke2);
			_root.add(_stroke3);
			_root.add(_stroke4);

			_group.addParentKey(0,_root);
			_subGroup.addParentKey(0,_root);
			_stroke1.addParentKey(0,_root);
			_stroke2.addParentKey(0,_root);
			_stroke3.addParentKey(0,_root);
			_stroke4.addParentKey(0,_root);
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
		public function testKGroup():void
		{
			Assert.assertEquals(0, _group.length());	
		}

		[Test]
		public function testDirectChildIterator():void
		{
			_group.add(_stroke1);
			_group.add(_stroke2);
			_group.add(_subGroup);
			_subGroup.add(_stroke3);
			_subGroup.add(_stroke4);
			
			_stroke1.addParentKey(1000,_group);
			_stroke2.addParentKey(2000,_group);
			_stroke3.addParentKey(3000,_subGroup);
			_stroke4.addParentKey(4000,_subGroup);
			_subGroup.addParentKey(5000,_group);			

			var objs:Vector.<KObject> = _getObjects(_group.directChildIterator(500));
			Assert.assertEquals(0,objs.length);

			objs = _getObjects(_group.directChildIterator(1000));
			Assert.assertEquals(1,objs.length);
			Assert.assertTrue(objs.indexOf(_stroke1) >= 0);

			objs = _getObjects(_group.directChildIterator(2000));
			Assert.assertEquals(2,objs.length);
			Assert.assertTrue(objs.indexOf(_stroke1) >= 0);
			Assert.assertTrue(objs.indexOf(_stroke2) >= 0);
			Assert.assertObjectEquals(objs,_getObjects(_group.directChildIterator(3000)));
			Assert.assertObjectEquals(objs,_getObjects(_group.directChildIterator(4500)));

			objs = _getObjects(_group.directChildIterator(5000));
			Assert.assertEquals(3,objs.length);
			Assert.assertTrue(objs.indexOf(_stroke1) >= 0);
			Assert.assertTrue(objs.indexOf(_stroke2) >= 0);
			Assert.assertTrue(objs.indexOf(_subGroup) >= 0);
		}
		
		[Test]
		public function testAllChildrenIterator():void
		{
			_group.add(_stroke1);
			_group.add(_stroke2);
			_group.add(_subGroup);
			_subGroup.add(_stroke3);
			_subGroup.add(_stroke4);
			
			_stroke1.addParentKey(1000,_group);
			_stroke2.addParentKey(2000,_group);
			_stroke3.addParentKey(3000,_subGroup);
			_stroke4.addParentKey(4000,_subGroup);
			_subGroup.addParentKey(5000,_group);			

			var objs:Vector.<KObject> = _getObjects(_group.allChildrenIterator(500));
			Assert.assertEquals(0,objs.length);
			
			objs = _getObjects(_group.allChildrenIterator(1000));
			Assert.assertEquals(1,objs.length);
			Assert.assertTrue(objs.indexOf(_stroke1) >= 0);
			
			objs = _getObjects(_group.allChildrenIterator(2000));
			Assert.assertEquals(2,objs.length);
			Assert.assertTrue(objs.indexOf(_stroke1) >= 0);
			Assert.assertTrue(objs.indexOf(_stroke2) >= 0);
			
			Assert.assertObjectEquals(objs,_getObjects(_group.allChildrenIterator(3000)));
			Assert.assertObjectEquals(objs,_getObjects(_group.allChildrenIterator(4500)));
			
			objs = _getObjects(_group.allChildrenIterator(5000));
			Assert.assertEquals(4,objs.length);
			Assert.assertTrue(objs.indexOf(_stroke1) >= 0);
			Assert.assertTrue(objs.indexOf(_stroke2) >= 0);
			Assert.assertTrue(objs.indexOf(_stroke3) >= 0);
			Assert.assertTrue(objs.indexOf(_stroke4) >= 0);
		}
		
		[Test]
		public function testGet_defaultCenter():void
		{
			
			_group.add(_stroke1);
			_stroke1.addParentKey(0,_group);
			Assert.assertObjectEquals(new Point(0,0), _group.defaultCenter);
			
			_group.add(_stroke2);
			_stroke2.addParentKey(0,_group);		
			Assert.assertObjectEquals(new Point(0.5,0.5), _group.defaultCenter);

			_group.add(_subGroup);
			_subGroup.addParentKey(0,_group);
			_subGroup.add(_stroke3);
			_subGroup.add(_stroke4);
			_stroke3.addParentKey(0,_subGroup);
			_stroke4.addParentKey(0,_subGroup);
			Assert.assertObjectEquals(new Point(0.5,0.5), _group.defaultCenter);
			
		}
		
		[Test]
		public function testGetBoundingRect():void
		{
			_group.add(_stroke1);
			_stroke1.addParentKey(0,_group);
			Assert.assertObjectEquals(new Rectangle(-1,-1,2,2), _group.getBoundingRect(0));
			
			_group.add(_stroke2);
			_stroke2.addParentKey(0,_group);
			Assert.assertObjectEquals(new Rectangle(-1,-1,3,3), _group.getBoundingRect(0));
			
			_group.add(_subGroup);
			_subGroup.addParentKey(0,_group);
			_subGroup.add(_stroke3);
			_subGroup.add(_stroke4);
			_stroke3.addParentKey(0,_subGroup);
			_stroke4.addParentKey(0,_subGroup);	
			Assert.assertObjectEquals(new Rectangle(-1,-1,3,3), _group.getBoundingRect(0));
		}
		
		private function _getObjects(it:IIterator):Vector.<KObject>
		{
			var objects:Vector.<KObject> = new Vector.<KObject>();
			while (it.hasNext())
				objects.push(it.next());
			return objects;
		}				
	}
}