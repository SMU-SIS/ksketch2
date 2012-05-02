/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.model.test
{
	import flexunit.framework.Assert;
	
	import sg.edu.smu.ksketch.model.IKeyFrame;
	import sg.edu.smu.ksketch.model.implementations.KKeyFrame;
	import sg.edu.smu.ksketch.model.implementations.KKeyFrameList;
	
	public class KKeyFrameListTest
	{		
		private var _key0:KKeyFrame;
		private var _key1:KKeyFrame;
		private var _key3:KKeyFrame;
		private var _list:KKeyFrameList;
		
		[Before]
		public function setUp():void
		{
			_list = new KKeyFrameList();
			_key0 = _list.insertKey(new KKeyFrame(0)) as KKeyFrame;
			_key1 = _list.insertKey(new KKeyFrame(1000)) as KKeyFrame;
			_key3 = _list.insertKey(new KKeyFrame(3000)) as KKeyFrame;
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
		public function testGetAtOrAfter():void
		{
			Assert.assertEquals(_key0,_list.getAtOrAfter(-1000));
			Assert.assertEquals(_key0,_list.getAtOrAfter(0));
			Assert.assertEquals(_key3,_list.getAtOrAfter(2000));
			Assert.assertEquals(_key3,_list.getAtOrAfter(3000));
			Assert.assertNull(_list.getAtOrAfter(4000));			
		}
		
		[Test]
		public function testGetAtOrBeforeTime():void
		{
			Assert.assertEquals(_key0,_list.getAtOrBeforeTime(0));
			Assert.assertEquals(_key1,_list.getAtOrBeforeTime(2000));
			Assert.assertEquals(_key3,_list.getAtOrBeforeTime(3000));
			Assert.assertEquals(_key3,_list.getAtOrBeforeTime(4000));
			Assert.assertNull(_list.getAtOrBeforeTime(-1000));
		}
		
		[Test]
		public function testGetAtTime():void
		{
			Assert.assertEquals(_key0,_list.getAtTime(0));
			Assert.assertEquals(_key1,_list.getAtTime(1000));
			Assert.assertEquals(null,_list.getAtTime(2000));
			Assert.assertEquals(_key3,_list.getAtTime(3000));
			Assert.assertEquals(null,_list.getAtTime(4000));
		}
		
		[Test]
		public function testInsert():void
		{			
			//Ready for testing
		}
		
		[Test]
		public function testInsertKey():void
		{
			var key2:KKeyFrame = _list.insertKey(new KKeyFrame(2000)) as KKeyFrame;
			Assert.assertEquals(4,_list.numKeys);
			Assert.assertEquals(_key1,key2.previous);
			Assert.assertEquals(_key3,key2.next);
			
			Assert.assertEquals(key2,_list.getAtTime(2000));
			Assert.assertEquals(_key1,_list.getAtTime(1000));
			Assert.assertEquals(_key3,_list.getAtTime(3000));
		
			var key4:KKeyFrame = _list.insertKey(new KKeyFrame(4000)) as KKeyFrame
			Assert.assertEquals(5,_list.numKeys);
			Assert.assertEquals(_key0,_list.getAtTime(0));
			Assert.assertEquals(_key1,_list.getAtTime(1000));
			Assert.assertEquals(key2,_list.getAtTime(2000));
			Assert.assertEquals(_key3,_list.getAtTime(3000));
			Assert.assertEquals(key4,_list.getAtTime(4000));
			Assert.assertEquals(_key3,key4.previous);
			Assert.assertEquals(null,key4.next);
		}
		
		[Test]
		public function testKeyExists():void
		{
			var key:KKeyFrame = new KKeyFrame(5000);
			Assert.assertFalse(_list.keyExists(key));
			Assert.assertFalse(_list.keyExists(null));
			Assert.assertTrue(_list.keyExists(_key0));
			Assert.assertTrue(_list.keyExists(_key1));
			Assert.assertTrue(_list.keyExists(_key3));
		}
		
		[Test]
		public function testLookUp():void
		{
			Assert.assertEquals(_key0,_list.lookUp(-1000));
			Assert.assertEquals(_key0,_list.lookUp(0));
			Assert.assertEquals(_key1,_list.lookUp(1000));
			Assert.assertEquals(_key3,_list.lookUp(3000));
			Assert.assertEquals(_key3,_list.lookUp(4000));
		}
		
		[Test]
		public function testGet_numKeys():void
		{
			Assert.assertEquals(3,_list.numKeys);
		}
		
		[Test]
		public function testRemove():void
		{
			var beforeEndTime:Number = _key3.endTime;
			
			//Test remove list head
			_list.remove(_key0);
			Assert.assertEquals(null,_key0.previous);
			Assert.assertEquals(null,_key0.next);
			Assert.assertEquals(2, _list.numKeys);
	
			//Test remove key in the middle of a list
			setUp();
			_list.remove(_key1);
			Assert.assertEquals(null,_key1.previous);
			Assert.assertEquals(null,_key1.next);
			Assert.assertEquals(_key3, _key0.next);
			Assert.assertEquals(_key0, _key3.previous);
			Assert.assertEquals(2, _list.numKeys);
			
			//Test remove last key
			setUp();
			_list.remove(_key3);
			Assert.assertEquals(null,_key3.previous);
			Assert.assertEquals(null,_key3.next);
			Assert.assertEquals(null, _key1.next);
			Assert.assertEquals(2, _list.numKeys);
			
			//Test remove keys not in list
			setUp();
			var assertion:int = 0;
			try
			{
				_list.remove(new KKeyFrame(4000));
			}catch(error:Error)
			{
				//Should throw an error
				assertion = 1;
			}
			Assert.assertEquals(1,assertion);
		}
		
		[Test]
		public function testRemoveAllAfter():void
		{
			//Test Remove all keys from before first key
			var removedKeys:Vector.<IKeyFrame> = _list.removeAllAfter(-1);
			Assert.assertEquals(3, removedKeys.length);
			Assert.assertEquals(0, _list.numKeys);
			Assert.assertEquals(0, removedKeys[0].endTime);
			Assert.assertEquals(1000, removedKeys[1].endTime);
			Assert.assertEquals(3000, removedKeys[2].endTime);
			
			//Test Remove all keys after last time
			setUp();
			removedKeys = _list.removeAllAfter(4000);
			Assert.assertEquals(0,removedKeys.length);
			Assert.assertEquals(3,_list.numKeys);
			
			//Test Remove all keys at first end time
			setUp();
			removedKeys = _list.removeAllAfter(0);
			Assert.assertEquals(2, removedKeys.length);
			Assert.assertEquals(1, _list.numKeys);
			Assert.assertEquals(1000, removedKeys[0].endTime);
			Assert.assertEquals(3000, removedKeys[1].endTime);
			
			//Test Remove all keys at last end time
			setUp();
			removedKeys = _list.removeAllAfter(3000);
			Assert.assertEquals(0, removedKeys.length);
			Assert.assertEquals(3, _list.numKeys);
			
			//Test Remove all keys after given time, where time is between 2 keys
			setUp();
			removedKeys = _list.removeAllAfter(500);
			Assert.assertEquals(2, removedKeys.length);
			Assert.assertEquals(1, _list.numKeys);
			Assert.assertEquals(1000, removedKeys[0].endTime);
			Assert.assertEquals(3000, removedKeys[1].endTime);
		}
		
		[Test]
		public function testShiftKeys():void
		{
			_list.shiftKeys(2500,0);
			Assert.assertEquals(0,_key0.endTime);
			Assert.assertEquals(1000,_key1.endTime);
			Assert.assertEquals(3000,_key3.endTime);
			
			_list.shiftKeys(2500,500);
			Assert.assertEquals(0,_key0.endTime);
			Assert.assertEquals(1000,_key1.endTime);
			Assert.assertEquals(3500,_key3.endTime);
			
			_list.shiftKeys(1000,500);
			Assert.assertEquals(0,_key0.endTime);
			Assert.assertEquals(1500,_key1.endTime);
			Assert.assertEquals(4000,_key3.endTime);

			_list.shiftKeys(-1000,500);
			Assert.assertEquals(500,_key0.endTime);
			Assert.assertEquals(2000,_key1.endTime);
			Assert.assertEquals(4500,_key3.endTime);
		}
	}
}