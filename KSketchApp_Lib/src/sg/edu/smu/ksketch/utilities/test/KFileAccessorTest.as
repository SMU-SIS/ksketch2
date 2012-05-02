/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.utilities.test
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import flexunit.framework.Assert;
	
	import org.flexunit.async.Async;
	
	import sg.edu.smu.ksketch.io.KFileLoader;
	import sg.edu.smu.ksketch.io.KFileSaver;
	import sg.edu.smu.ksketch.event.KFileLoadedEvent;
	import sg.edu.smu.ksketch.event.KFileSavedEvent;
	
	public class KFileAccessorTest
	{		
		private var _loader:KFileLoader;
		private var _saver:KFileSaver;
		
		[Before]
		public function setUp():void
		{
			_loader = new KFileLoader();
			_saver = new KFileSaver();
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
		
		private function verifyLoad(event:KFileLoadedEvent, result:Object):void
		{
			Assert.assertEquals(result.filePath as String, event.filePath);
			Assert.assertTrue(byteArrayEquals(result.content as ByteArray, event.content));
		}
		
		[Test(async)]
		public function testLoadImage():void
		{
			trace("select file 'Koala.jpg'");
			var imageFile:File = new File(File.applicationDirectory.nativePath+"/../testFiles/Koala.jpg");
			var fileStream:FileStream = new FileStream();
			fileStream.open(imageFile, FileMode.READ);
			var content:ByteArray = new ByteArray();
			fileStream.readBytes(content, 0, imageFile.size);
			
			var result:Object = new Object();
			result.filePath = imageFile.nativePath;
			result.content = content;
			Async.handleEvent(this, _loader, KFileLoadedEvent.EVENT_FILE_LOADED, verifyLoad, 20000, result);
			_loader.loadImage();
		}
		
		[Test(async)]
		public function testLoadKMV():void
		{
			trace("select file 'testLoadKMV.kmv'");
			var result:Object = new Object();
			result.filePath = new File(File.applicationDirectory.nativePath+"/../testFiles/testLoadKMV.kmv").nativePath;
			var content:ByteArray = new ByteArray();
			content.writeUTFBytes("<testLoadKMV/>");
			result.content = content;
			Async.handleEvent(this, _loader, KFileLoadedEvent.EVENT_FILE_LOADED, verifyLoad, 20000, result);
			_loader.loadKMV();
		}
		
		[Test(async)]
		public function testLoadLog():void
		{
			trace("select file 'testLoadLog.klg'");
			var result:Object = new Object();
			result.filePath = new File(File.applicationDirectory.nativePath+"/../testFiles/testLoadLog.klg").nativePath;
			var content:ByteArray = new ByteArray();
			content.writeUTFBytes("<testLoadLog/>");
			result.content = content;
			Async.handleEvent(this, _loader, KFileLoadedEvent.EVENT_FILE_LOADED, verifyLoad, 20000, result);
			_loader.loadLog();
		}
		
		private function verifySave(event:KFileSavedEvent, result:Object):void
		{
			Assert.assertEquals(result.filePath as String, event.filePath);
			
			var file:File = new File(event.filePath);
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.READ);
			var content:ByteArray = new ByteArray();
			fileStream.readBytes(content, 0, file.size); 
			
			Assert.assertTrue(byteArrayEquals(result.content as ByteArray, content));
		}
		
		[Test(async)]
		public function testSaveKMV():void
		{
			trace("select file 'testSaveKMV.kmv'");
			var kmvFile:XML = <testSaveKMV/>;
			var content:ByteArray = new ByteArray();
			content.writeUTFBytes("<testSaveKMV/>");
			
			var result:Object = new Object();
			result.filePath = new File(File.applicationDirectory.nativePath+"/../testFiles/testSaveKMV.kmv").nativePath;
			result.content = content;
			
			Async.handleEvent(this, _saver, KFileSavedEvent.EVENT_FILE_SAVED, verifySave, 20000, result);
			_saver.saveKMV(kmvFile);
		}
		
		[Test(async)]
		public function testSaveLog():void
		{
			trace("select file 'testSaveLog.klg'");
			var logFile:XML = <testSaveLog/>;
			var content:ByteArray = new ByteArray();
			content.writeUTFBytes("<testSaveLog/>");
			
			var result:Object = new Object();
			result.filePath = new File(File.applicationDirectory.nativePath+"/../testFiles/testSaveLog.klg").nativePath;
			result.content = content;
			
			Async.handleEvent(this, _saver, KFileSavedEvent.EVENT_FILE_SAVED, verifySave, 20000, result);
			_saver.saveLog(logFile);
		}
		
		private function byteArrayEquals(bytes1:ByteArray, bytes2:ByteArray):Boolean
		{
			if(bytes1.length != bytes2.length)
				return false;
			for(var i:int = 0;i<bytes1.length;i++)
				if(bytes1[i] != bytes2[i])
					return false;
			return true;
		}
	}
}