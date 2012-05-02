/**------------------------------------------------
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 
*-------------------------------------------------*/
package test
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import flexunit.framework.Assert;
	
	import mx.events.FlexEvent;
	
	import org.flexunit.async.Async;
	import org.fluint.uiImpersonation.UIImpersonator;
		
	[RunWith("org.flexunit.runners.Parameterized")]
	public class IntegrationTest
	{		
		private static const _DEBUG:String = "DEBUG"; // only run test files under ITDebug folder
		private static const _RUN:String = "RUN"; // only run test files under IntegrationTestCases folder
		private static const _ALL:String = "ALL"; // run all the files under these two folders
		private static var _mode:String = _ALL;	
		private var _testApp:PlaySketch_Test;
		private var _address:String;
		
		public function IntegrationTest(address:String)
		{
			_address = address;
		}

		[Parameters]
		public static var urls:Array = inital();
		
		private static function inital():Array
		{
			var addresses:Array = new Array();
			switch(_mode)
			{
				case _DEBUG:
					parseFileList(new File(File.applicationDirectory.nativePath+"/../ITDebug"), addresses);
					break;
				case _RUN:
					parseFileList(new File(File.applicationDirectory.nativePath+"/../IntegrationTestCases"), addresses);
					break;
				case _ALL:
					parseFileList(new File(File.applicationDirectory.nativePath+"/../ITDebug"), addresses);
					parseFileList(new File(File.applicationDirectory.nativePath+"/../IntegrationTestCases"), addresses);
					break;
				default:
					throw new Error("unsupported test mode: "+_mode);
			}
			return addresses;
		}
		private static function parseFileList(directory:File, fileAddresses:Array):void
		{
			var list:Array = directory.getDirectoryListing();
			for(var i:int = 0;i<list.length;i++)
			{
				var file:File = list[i];
				if(file.isDirectory)
				{
					if(file.name != ".svn") // ignore files under .svn folder
						parseFileList(file, fileAddresses);
				}
				else if(file.extension == "xml")
					fileAddresses.push(new Array(list[i].nativePath));
			}
		}
		
		[Before(async, ui)]
		public function setUp():void
		{
			_testApp = new PlaySketch_Test();
			Async.proceedOnEvent(this, _testApp, FlexEvent.CREATION_COMPLETE, 3000, _appCreationFailed);
			UIImpersonator.addChild(_testApp);
			_load();
		}
		
		[After]
		public function tearDown():void
		{
			UIImpersonator.removeChild(_testApp);
			_testApp = null;
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
		public function testThis():void
		{
			trace("Executing: "+_address);
			_executeNext();
		}
		
		private function _executeNext(event:Event = null, passThroughData:Object = null):void
		{
			if(_testApp.hasNextCommand())
			{
				Async.handleEvent(this, _testApp, PlaySketch_Test.COMMAND_FINISHED, _executeNext, 1000000);
				_testApp.execute();
			}
		}
		
		private function _load():void
		{
			var file:File = new File(_address);
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.READ);
			var str:String = fileStream.readMultiByte(file.size, File.systemCharset);
			_testApp.parseCommandList(new XML(str));
		}
		private function _appCreationFailed(passThroughData:Object):void
		{
			Assert.fail( "Timeout reached before KSketchApp created");
		}
	}
}