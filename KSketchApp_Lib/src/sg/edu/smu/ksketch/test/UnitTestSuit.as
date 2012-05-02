/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.test
{
	import sg.edu.smu.ksketch.components.test.*;
	import sg.edu.smu.ksketch.gestures.test.*;
	import sg.edu.smu.ksketch.model.test.*;
	import sg.edu.smu.ksketch.utilities.test.*;
	
	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class UnitTestSuit
	{
		public var test1:KReferenceFrameListTest;
		public var test2:KSpatialKeyFrameTest;
		public var test3:KKeyFrameListTest;
		public var test4:KReferenceFrameTest;
		public var test5:KModelTest;
		public var test6:KStrokeTest;
		public var test7:KGroupTest;
		public var test8:KStrokeViewTest;
		public var test9:KGroupViewTest;
		public var test10:KCanvasTest;
		public var test11:PigtailDetectorTest;
		public var test12:KClipBoardTest;
		public var test13:KFileAccessorTest;
		public var test14:KModelObjectListTest;
	}
}