/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.model.test
{
	import flexunit.framework.Assert;
	
	import sg.edu.smu.ksketch.model.implementations.KReferenceFrameList;
	import sg.edu.smu.ksketch.model.IReferenceFrame;
	
	public class KReferenceFrameListTest
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
		public function testInsertRefFramesWithIndex():void
		{
			var referenceFrameList:KReferenceFrameList  = new KReferenceFrameList();
			
			//Test insert when empty
			var ref1:IReferenceFrame = referenceFrameList.insert(0);
			Assert.assertEquals(ref1,referenceFrameList.getReferenceFrameAt(0));

			//Test insert in front
			var ref2:IReferenceFrame = referenceFrameList.insert(-1);
			Assert.assertEquals(ref2,referenceFrameList.getReferenceFrameAt(0));
			
			//Test insert at back
			var ref3:IReferenceFrame = referenceFrameList.insert(3);
			Assert.assertEquals(ref2,referenceFrameList.getReferenceFrameAt(0));
			
			//Test insert into the frame list
			var ref4:IReferenceFrame = referenceFrameList.insert(1);
			Assert.assertEquals(ref4,referenceFrameList.getReferenceFrameAt(1));
			
			//check the order of the keys
			Assert.assertEquals(ref2,referenceFrameList.getReferenceFrameAt(0));
			Assert.assertEquals(ref4,referenceFrameList.getReferenceFrameAt(1));
			Assert.assertEquals(ref1,referenceFrameList.getReferenceFrameAt(2));
			Assert.assertEquals(ref3,referenceFrameList.getReferenceFrameAt(3));
		}
		
		[Test]
		public function testRemoveAllRefFramesAfter():void
		{
			var referenceFrameList:KReferenceFrameList  = new KReferenceFrameList();
			var ref1:IReferenceFrame = referenceFrameList.insert(0);
			var ref2:IReferenceFrame = referenceFrameList.insert(1);
			var ref3:IReferenceFrame = referenceFrameList.insert(2);
			var ref4:IReferenceFrame = referenceFrameList.insert(3);
			
			//Test Remove reference frames using index greater than numReferenceFrames
			referenceFrameList.removeAllAfter(referenceFrameList.numReferenceFrames+1);
			Assert.assertEquals(ref1,referenceFrameList.getReferenceFrameAt(0));
			Assert.assertEquals(ref2,referenceFrameList.getReferenceFrameAt(1));
			Assert.assertEquals(ref3,referenceFrameList.getReferenceFrameAt(2));
			Assert.assertEquals(ref4,referenceFrameList.getReferenceFrameAt(3));
			Assert.assertEquals(4,referenceFrameList.numReferenceFrames);

			//Test Remove reference frames using index equal to numReferenceFrames
			referenceFrameList.removeAllAfter(referenceFrameList.numReferenceFrames);
			Assert.assertEquals(ref1,referenceFrameList.getReferenceFrameAt(0));
			Assert.assertEquals(ref2,referenceFrameList.getReferenceFrameAt(1));
			Assert.assertEquals(ref3,referenceFrameList.getReferenceFrameAt(2));
			Assert.assertEquals(ref4,referenceFrameList.getReferenceFrameAt(3));
			Assert.assertEquals(4,referenceFrameList.numReferenceFrames);

			//Test Remove reference frames using last index
			referenceFrameList.removeAllAfter(referenceFrameList.numReferenceFrames-1);
			Assert.assertEquals(ref1,referenceFrameList.getReferenceFrameAt(0));
			Assert.assertEquals(ref2,referenceFrameList.getReferenceFrameAt(1));
			Assert.assertEquals(ref3,referenceFrameList.getReferenceFrameAt(2));
			Assert.assertEquals(ref4,referenceFrameList.getReferenceFrameAt(3));
			Assert.assertEquals(4,referenceFrameList.numReferenceFrames);
			
			//Test Remove reference frames using last second index
			referenceFrameList.removeAllAfter(referenceFrameList.numReferenceFrames-2);
			Assert.assertEquals(ref1,referenceFrameList.getReferenceFrameAt(0));
			Assert.assertEquals(ref2,referenceFrameList.getReferenceFrameAt(1));
			Assert.assertEquals(ref3,referenceFrameList.getReferenceFrameAt(2));
			Assert.assertEquals(ref3,referenceFrameList.getReferenceFrameAt(3)); // Need to check !!
			Assert.assertEquals(3,referenceFrameList.numReferenceFrames);
			
			//Test remove all reference frames after first index
			referenceFrameList.removeAllAfter(0);
			Assert.assertEquals(ref1,referenceFrameList.getReferenceFrameAt(0));
			Assert.assertEquals(ref1,referenceFrameList.getReferenceFrameAt(1)); // Need to check !!
			Assert.assertEquals(ref1,referenceFrameList.getReferenceFrameAt(2)); // Need to check !!
			Assert.assertEquals(ref1,referenceFrameList.getReferenceFrameAt(3)); // Need to check !!
			Assert.assertEquals(1,referenceFrameList.numReferenceFrames);

			//Test remove all reference frames using negative index
			referenceFrameList = new KReferenceFrameList();
			ref1 = referenceFrameList.insert(0);
			ref2 = referenceFrameList.insert(1);
			ref3 = referenceFrameList.insert(2);
			ref4 = referenceFrameList.insert(3);
			referenceFrameList.removeAllAfter(-1);
			Assert.assertEquals(0,referenceFrameList.numReferenceFrames);
		}
		
		[Test]		
		public function testRemoveRefFrameAtIndex():void
		{
			// Test Remove at index using index < 0 //
			var referenceFrameList:KReferenceFrameList  = new KReferenceFrameList();
			var ref1:IReferenceFrame = referenceFrameList.insert(0);
			var ref2:IReferenceFrame = referenceFrameList.insert(1);
			var ref3:IReferenceFrame = referenceFrameList.insert(2);
			var ref4:IReferenceFrame = referenceFrameList.insert(3);
			var removed:IReferenceFrame = referenceFrameList.removeReferenceFrameAt(-1);
			Assert.assertEquals(ref1,removed);
			Assert.assertEquals(ref2,referenceFrameList.getReferenceFrameAt(0));
			Assert.assertEquals(ref3,referenceFrameList.getReferenceFrameAt(1));
			Assert.assertEquals(ref4,referenceFrameList.getReferenceFrameAt(2));
			Assert.assertEquals(3,referenceFrameList.numReferenceFrames);
			
			//Test Remove at index using index == 0 //
			referenceFrameList = new KReferenceFrameList();
			ref1 = referenceFrameList.insert(0);
			ref2 = referenceFrameList.insert(1);
			ref3 = referenceFrameList.insert(2);
			ref4 = referenceFrameList.insert(3);			
			removed = referenceFrameList.removeReferenceFrameAt(0);
			Assert.assertEquals(ref1,removed);
			Assert.assertEquals(ref2,referenceFrameList.getReferenceFrameAt(0));
			Assert.assertEquals(ref3,referenceFrameList.getReferenceFrameAt(1));
			Assert.assertEquals(ref4,referenceFrameList.getReferenceFrameAt(2));
			Assert.assertEquals(3,referenceFrameList.numReferenceFrames);
			
			//Test Remove at index using index == 1
			referenceFrameList = new KReferenceFrameList();
			ref1 = referenceFrameList.insert(0);
			ref2 = referenceFrameList.insert(1);
			ref3 = referenceFrameList.insert(2);
			ref4 = referenceFrameList.insert(3);
			removed = referenceFrameList.removeReferenceFrameAt(1);
			Assert.assertEquals(ref2,removed);
			Assert.assertEquals(ref1,referenceFrameList.getReferenceFrameAt(0));
			Assert.assertEquals(ref3,referenceFrameList.getReferenceFrameAt(1));
			Assert.assertEquals(ref4,referenceFrameList.getReferenceFrameAt(2));
			Assert.assertEquals(3,referenceFrameList.numReferenceFrames);
			
			//Test remove at last using index == 3
			referenceFrameList = new KReferenceFrameList();
			ref1 = referenceFrameList.insert(0);
			ref2 = referenceFrameList.insert(1);
			ref3 = referenceFrameList.insert(2);
			ref4 = referenceFrameList.insert(3);
			removed = referenceFrameList.removeReferenceFrameAt(3);
			Assert.assertEquals(ref4,removed);
			Assert.assertEquals(ref1,referenceFrameList.getReferenceFrameAt(0));
			Assert.assertEquals(ref2,referenceFrameList.getReferenceFrameAt(1));
			Assert.assertEquals(ref3,referenceFrameList.getReferenceFrameAt(2));
			Assert.assertFalse(ref4 == referenceFrameList.getReferenceFrameAt(3));
			Assert.assertEquals(3,referenceFrameList.numReferenceFrames);
			
			//Test remove at last using index > 3
			referenceFrameList = new KReferenceFrameList();
			ref1 = referenceFrameList.insert(0);
			ref2 = referenceFrameList.insert(1);
			ref3 = referenceFrameList.insert(2);
			ref4 = referenceFrameList.insert(3);
			removed = referenceFrameList.removeReferenceFrameAt(4);
			Assert.assertEquals(ref4,removed);
			Assert.assertEquals(ref1,referenceFrameList.getReferenceFrameAt(0));
			Assert.assertEquals(ref2 ,referenceFrameList.getReferenceFrameAt(1));
			Assert.assertEquals(ref3,referenceFrameList.getReferenceFrameAt(2));
			Assert.assertFalse(ref4 == referenceFrameList.getReferenceFrameAt(3));
			Assert.assertEquals(3,referenceFrameList.numReferenceFrames);
		}	

		[Test]		
		public function testMoveRefFramesWithSameIndex():void
		{
			var referenceFrameList:KReferenceFrameList = new KReferenceFrameList();				
			var ref0:IReferenceFrame = referenceFrameList.insert(0);
			var ref1:IReferenceFrame = referenceFrameList.insert(1);
			var ref2:IReferenceFrame = referenceFrameList.insert(2);
			var ref3:IReferenceFrame = referenceFrameList.insert(3);
			
			referenceFrameList.moveFrame(0,0);		
			Assert.assertEquals(ref0,referenceFrameList.getReferenceFrameAt(0));
			Assert.assertEquals(ref1,referenceFrameList.getReferenceFrameAt(1));
			Assert.assertEquals(ref2,referenceFrameList.getReferenceFrameAt(2));
			Assert.assertEquals(ref3,referenceFrameList.getReferenceFrameAt(3));
			Assert.assertEquals(4,referenceFrameList.numReferenceFrames);
			
			referenceFrameList.moveFrame(1,1);				
			Assert.assertEquals(ref0,referenceFrameList.getReferenceFrameAt(0));
			Assert.assertEquals(ref1,referenceFrameList.getReferenceFrameAt(1));
			Assert.assertEquals(ref2,referenceFrameList.getReferenceFrameAt(2));
			Assert.assertEquals(ref3,referenceFrameList.getReferenceFrameAt(3));
			Assert.assertEquals(4,referenceFrameList.numReferenceFrames);
			
			referenceFrameList.moveFrame(-1,-1);				
			Assert.assertEquals(ref0,referenceFrameList.getReferenceFrameAt(0));
			Assert.assertEquals(ref1,referenceFrameList.getReferenceFrameAt(1));
			Assert.assertEquals(ref2,referenceFrameList.getReferenceFrameAt(2));
			Assert.assertEquals(ref3,referenceFrameList.getReferenceFrameAt(3));
			Assert.assertEquals(4,referenceFrameList.numReferenceFrames);
			
			referenceFrameList.moveFrame(3,3);
			Assert.assertEquals(ref0,referenceFrameList.getReferenceFrameAt(0));
			Assert.assertEquals(ref1,referenceFrameList.getReferenceFrameAt(1));
			Assert.assertEquals(ref2,referenceFrameList.getReferenceFrameAt(2));
			Assert.assertEquals(ref3,referenceFrameList.getReferenceFrameAt(3));
			Assert.assertEquals(4,referenceFrameList.numReferenceFrames);
			
			referenceFrameList.moveFrame(4,4);
			Assert.assertEquals(ref0,referenceFrameList.getReferenceFrameAt(0));
			Assert.assertEquals(ref1,referenceFrameList.getReferenceFrameAt(1));
			Assert.assertEquals(ref2,referenceFrameList.getReferenceFrameAt(2));
			Assert.assertEquals(ref3,referenceFrameList.getReferenceFrameAt(3));
			Assert.assertEquals(4,referenceFrameList.numReferenceFrames);			
		}

		[Test]		
		public function testMoveRefFramesWithDifferentIndex():void
		{
			// Test move from 0 to 1
			var referenceFrameList:KReferenceFrameList = new KReferenceFrameList();				
			var ref0:IReferenceFrame = referenceFrameList.insert(0);
			var ref1:IReferenceFrame = referenceFrameList.insert(1);
			var ref2:IReferenceFrame = referenceFrameList.insert(2);
			var ref3:IReferenceFrame = referenceFrameList.insert(3);
			referenceFrameList.moveFrame(0,1);
			Assert.assertEquals(ref1,referenceFrameList.getReferenceFrameAt(0));
			Assert.assertEquals(ref0,referenceFrameList.getReferenceFrameAt(1));
			Assert.assertEquals(ref2,referenceFrameList.getReferenceFrameAt(2));
			Assert.assertEquals(ref3,referenceFrameList.getReferenceFrameAt(3));
			Assert.assertEquals(4,referenceFrameList.numReferenceFrames);
			
		}

	}
}