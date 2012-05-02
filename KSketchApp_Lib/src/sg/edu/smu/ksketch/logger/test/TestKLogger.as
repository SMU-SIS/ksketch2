/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.logger.test
{
	import flexunit.framework.Assert;
	
	import sg.edu.smu.ksketch.logger.KLogger;
	
	public class TestKLogger
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
		public function testLog():void
		{
			KLogger.flush();
			KLogger.log("testTagName1", "attr1_1", "key1", "attr1_2", 2, "attr1_3", 3.3);
			var log:XML = KLogger.logFile;
			Assert.assertEquals(1, log.children().length());
			var tag:XML = log.children()[0];
			Assert.assertEquals("testTagName1", tag.name().toString());
			Assert.assertEquals("key1", tag.@["attr1_1"].toString());
			Assert.assertEquals(2, tag.@["attr1_2"]);
			Assert.assertEquals(3.3, tag.@["attr1_3"]);
			
			KLogger.log("testTagName2", "attr2_1", "key2", "attr2_2", 22, "attr2_3", 33.3);
			log = KLogger.logFile;
			Assert.assertEquals(2, log.children().length());
			tag = log.children()[1];
			Assert.assertEquals("testTagName2", tag.name().toString());
			Assert.assertEquals("key2", tag.@["attr2_1"].toString());
			Assert.assertEquals(22, tag.@["attr2_2"]);
			Assert.assertEquals(33.3, tag.@["attr2_3"]);
			
			KLogger.flush();
			KLogger.log("testTagName3", "attr3_1", "key3", "attr3_2", 222, "attr3_3", 333.3);
			log = KLogger.logFile;
			Assert.assertEquals(1, log.children().length());
			tag = log.children()[0];
			Assert.assertEquals("testTagName3", tag.name().toString());
			Assert.assertEquals("key3", tag.@["attr3_1"].toString());
			Assert.assertEquals(222, tag.@["attr3_2"]);
			Assert.assertEquals(333.3, tag.@["attr3_3"]);
			
			KLogger.enabled = false;
			log = KLogger.logFile;
			Assert.assertEquals(0, log.children().length());
			KLogger.log("testTagName4", "attr4_1", "key4", "attr4_2", 2222, "attr4_3", 3333.3);
			log = KLogger.logFile;
			Assert.assertEquals(0, log.children().length());
			
			KLogger.enabled = true;
			KLogger.log("testTagName4", "attr4_1", "key4", "attr4_2", 2222, "attr4_3", 3333.3);
			log = KLogger.logFile;
			Assert.assertEquals(1, log.children().length());
			tag = log.children()[0];
			Assert.assertEquals("testTagName4", tag.name().toString());
			Assert.assertEquals("key4", tag.@["attr4_1"].toString());
			Assert.assertEquals(2222, tag.@["attr4_2"]);
			Assert.assertEquals(3333.3, tag.@["attr4_3"]);
		}
	}
}