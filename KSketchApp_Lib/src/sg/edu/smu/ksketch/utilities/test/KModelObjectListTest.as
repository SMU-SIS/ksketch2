/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.utilities.test
{
	import flexunit.framework.Assert;
	
	import sg.edu.smu.ksketch.utilities.ErrorMessage;
	import sg.edu.smu.ksketch.utilities.IModelObjectList;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;
	import sg.edu.smu.ksketch.model.KStroke;
	
	public class KModelObjectListTest
	{		
		private var objectList:KModelObjectList;
		
		[Before]
		public function setUp():void
		{
			objectList = new KModelObjectList();
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
		public function testKModelObjectList():void
		{
			Assert.assertEquals(0, objectList.length());
		}
		
		[Test]
		public function testAdd():void
		{
			var stroke1:KStroke = new KStroke(0, 0);
			objectList.add(stroke1);			
			Assert.assertEquals(1,objectList.length());
			Assert.assertEquals(stroke1,objectList.getObjectAt(0));
			
			var stroke2:KStroke = new KStroke(1, 0);
			objectList.add(stroke2);			
			Assert.assertEquals(2,objectList.length());
			Assert.assertEquals(stroke1,objectList.getObjectAt(0));
			Assert.assertEquals(stroke2,objectList.getObjectAt(1));
			
			var stroke3:KStroke = new KStroke(2, 0);
			objectList.add(stroke3);			
			Assert.assertEquals(3,objectList.length());
			Assert.assertEquals(stroke1,objectList.getObjectAt(0));
			Assert.assertEquals(stroke2,objectList.getObjectAt(1));
			Assert.assertEquals(stroke3,objectList.getObjectAt(2));
			
			try
			{
				objectList.add(stroke1);	
				Assert.fail("Expected error not catched!");
			}
			catch(e:Error)
			{
				Assert.assertTrue(e is Error);
				Assert.assertEquals(ErrorMessage.OBJECT_EXISTS, e.message);
			}
			
			try
			{
				objectList.add(stroke2);	
				Assert.fail("Expected error not catched!");
			}
			catch(e:Error)
			{
				Assert.assertTrue(e is Error);
				Assert.assertEquals(ErrorMessage.OBJECT_EXISTS, e.message);
			}
		}
		
		[Test]
		public function testRemove():void
		{
			var stroke1:KStroke = new KStroke(0, 0);//:Object_KStroke_Public = new Object_KStroke_Public(null, 0, 0);
			objectList.add(stroke1);	
			var stroke2:KStroke = new KStroke(1, 0);//:Object_KStroke_Public = new Object_KStroke_Public(null, 0, 0);
			objectList.add(stroke2);	
			var stroke3:KStroke = new KStroke(2, 0);//:Object_KStroke_Public = new Object_KStroke_Public(null, 0, 0);
			objectList.add(stroke3);	
			var stroke4:KStroke = new KStroke(3, 0);//:Object_KStroke_Public = new Object_KStroke_Public(null, 0, 0);
			objectList.add(stroke4);
			
			objectList.remove(stroke4);
			Assert.assertEquals(3,objectList.length());
			Assert.assertEquals(stroke1,objectList.getObjectAt(0));
			Assert.assertEquals(stroke2,objectList.getObjectAt(1));
			Assert.assertEquals(stroke3,objectList.getObjectAt(2));
			
			try
			{
				objectList.remove(stroke4);
				Assert.fail("Expected error not catched!");
			}
			catch(e:Error)
			{
				Assert.assertTrue(e is Error);
				Assert.assertEquals(ErrorMessage.OBJECT_NOT_EXIST, e.message);
			}
			
			objectList.remove(stroke2);
			Assert.assertEquals(2,objectList.length());
			Assert.assertEquals(stroke1,objectList.getObjectAt(0));
			Assert.assertEquals(stroke3,objectList.getObjectAt(1));
			
			try
			{
				objectList.remove(stroke2);
				Assert.fail("Expected error not catched!");
			}
			catch(e:Error)
			{
				Assert.assertTrue(e is Error);
				Assert.assertEquals(ErrorMessage.OBJECT_NOT_EXIST, e.message);
			}
			
			objectList.remove(stroke1);
			Assert.assertEquals(1,objectList.length());
			Assert.assertEquals(stroke3,objectList.getObjectAt(0));
			
			objectList.remove(stroke3);
			Assert.assertEquals(0,objectList.length());
		}
		
	}
}