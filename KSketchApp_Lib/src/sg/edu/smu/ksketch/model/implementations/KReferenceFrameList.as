package sg.edu.smu.ksketch.model.implementations
{
	import flash.geom.Matrix;
	
	import mx.controls.Label;
	
	import sg.edu.smu.ksketch.model.IReferenceFrame;
	import sg.edu.smu.ksketch.model.IReferenceFrameList;
	
	/**
	 * KReferenceFrameList will work like this.
	 * 1. If you want the latest reference frame, it will be the end of the list.
	 * 2. Currently, the matrices are concatenated from the tail, towards the head of the list
	 */
	
	public class KReferenceFrameList implements IReferenceFrameList
	{
		private var _referenceFrames:KReferenceFrame;
		
		public function KReferenceFrameList()
		{
	
		}
		
		public function earliestTime():Number
		{
			var ref:KReferenceFrame = _referenceFrames;
			var minTime:Number = NaN;
			var i:int = 0;
			
			while(ref)
			{
				if(!isNaN(ref.earliestTime()))
				{	
					if(isNaN(minTime))
						minTime = ref.earliestTime();
					else if(ref.earliestTime() < minTime)
					{
						minTime = ref.earliestTime();
					}
				}
				ref = ref.next as KReferenceFrame;
			}
			
			return minTime;		
		}
		
		public function latestTime():Number
		{
			var ref:KReferenceFrame = _referenceFrames;
			var maxTime:Number = NaN;

			while(ref)
			{
				if(!isNaN(ref.latestTime()))
				{	
					if(isNaN(maxTime))
						maxTime = ref.latestTime();
					else if(ref.latestTime() > maxTime)
					{
						maxTime = ref.latestTime();
					}
				}
				ref = ref.next as KReferenceFrame;
			}
			
			return maxTime;
		}
		
		/**
		 * Returns the number of reference frames in this reference frame list
		 */
		public function get numReferenceFrames():int
		{
			var frames:KReferenceFrame = _referenceFrames;
			var count:int = 0;
			
			if(frames)
			{
				count = 1;
				
				while(frames.next)
				{
					frames = frames.next as KReferenceFrame;
					count++;
				}
			}
			return count;
		}
		
		/**
		 * Creates and returns a new reference frame
		 * This reference frame will not be inserted into the list
		 */
		public function newReferenceFrame():IReferenceFrame
		{
			var newRef:KReferenceFrame = new KReferenceFrame();
			newRef.debugName = numReferenceFrames.toString();
			return newRef;
		}
		
		/**
		 * Returns the matrix of this reference frame list at kskTime
		 */
		public function getMatrix(kskTime:Number):Matrix
		{
			var frames:KReferenceFrame = _getLastReferenceFrame();
			var matrix:Matrix = new Matrix();
			
			while(frames)
			{
				var myMat:Matrix = frames.getMatrix(kskTime);
				matrix.concat(myMat);
				frames = frames.previous as KReferenceFrame;
			}
			return matrix;
		}
		
		/**
		 * Returns the reference frame at index
		 * if index <0, it will return the frame at 0
		 * if numFrames < index, it will return the last frame
		 */
		public function getReferenceFrameAt(index:int):IReferenceFrame
		{
			if(index <0)
				return _referenceFrames;
			
			if(numReferenceFrames <= index)
				return _getLastReferenceFrame();
			
			var frames:KReferenceFrame = _referenceFrames;
			
			for(var i:int = 0; i<index; i++)
			{
				frames = frames.next as KReferenceFrame;
			}
		
			return frames;
		}
		
		/**
		 *Inserts a new reference frame at index and returns it.
		 *If the given index is greater than this list's length, it will append it to the end
		 *If the given index is smaller than 0, it will append it to the front
		 */
		public function insert(index:int):IReferenceFrame
		{
			if(!_referenceFrames)
			{
				_referenceFrames = newReferenceFrame() as KReferenceFrame;
				return _referenceFrames;
			}
			
			var newFrame:KReferenceFrame = newReferenceFrame() as KReferenceFrame;
			
			//Attach to the front
			if(index <=0)
			{
				_referenceFrames.previous = newFrame;
				newFrame.next = _referenceFrames;
				_referenceFrames = newFrame;
				return _referenceFrames;
			}
			
			//Attach to back
			if(numReferenceFrames <= index)
			{
				var lastFrame:KReferenceFrame = _getLastReferenceFrame();
				lastFrame.next = newFrame;
				newFrame.previous = lastFrame;
				
				return newFrame;
			}

			var frames:KReferenceFrame = _referenceFrames;
			
			for(var i:int = 0; i<index; i++)
			{
				frames = frames.next as KReferenceFrame;
			}
			
			var previousFrame:KReferenceFrame = frames.previous as KReferenceFrame;
			
			if(previousFrame)
			{
				previousFrame.next = newFrame;
				newFrame.previous = previousFrame;
			}
			
			if(frames)
			{
				frames.previous = newFrame;
				newFrame.next = frames;
			}
		
			return newFrame;
		}
		
		/**
		 * Moves the given IReferenceFrame to after the ReferenceFrame at destination index
		 * If the given index is greater than this list's length, it will move it to the end
		 * If the given index is smaller than 0, it will move it to the front
		 * Returns the reference frame moved
		 * Not tested properly yet
		 */
		public function move(frame:IReferenceFrame, destinationIndex:int):IReferenceFrame
		{
			//If there is only 1 reference frame return;
			if(numReferenceFrames <=1)
				return frame;
			
			//dont move if they are the same reference frames
			if(frame == getReferenceFrameAt(destinationIndex))
				return frame;
			
			//find the frames before and after given
			var fromFrame:KReferenceFrame = frame as KReferenceFrame;
			var toFrame:KReferenceFrame = getReferenceFrameAt(destinationIndex) as KReferenceFrame;
			
			//find the frames before and after the frame at the destination index
			var fromPrevious:KReferenceFrame = fromFrame.previous as KReferenceFrame;
			var fromNext:KReferenceFrame = fromFrame.next as KReferenceFrame;
			
			//check if the head is the frame being moved, and assign the new head if needed.
			if(fromFrame == _referenceFrames)
			{
				_referenceFrames = fromNext;
			}
			
			//find the next frame at the destination
			var toNext:KReferenceFrame = toFrame.next as KReferenceFrame;
			
			//Hook up the previous frame at origin
			fromFrame.previous = null;
			if(fromPrevious)
			{
				fromPrevious.next = fromNext;
			}
			
			//hook up the next frame at origin
			fromFrame.next = null;
			if(fromNext)
			{
				fromNext.previous = fromPrevious;
			}
			
			//set the next frame at the destination to be the given frame
			fromFrame.previous = toFrame;
			toFrame.next = fromFrame;
				
			if(toNext)
			{
				fromFrame.next = toNext;
				toNext.previous = fromFrame;
			}
			
			return fromFrame;
		}
		
		/**
		 * Moves the given IReferenceFrame to after the ReferenceFrame at destination index
		 * If the given index is greater than this list's length, it will move it to the end
		 * If the given index is smaller than 0, it will move it to the front
		 * Returns the reference frame moved
		 */
		public function moveFrame(from:int, to:int):IReferenceFrame
		{
			var fromFrame:KReferenceFrame = getReferenceFrameAt(from) as KReferenceFrame;
			
			return move(fromFrame, to);
		}
		
		/**
		 * Takes in an IReferenceFrame and finds its position in this list
		 */
		public function indexOf(frame:IReferenceFrame):int
		{
			var frames:KReferenceFrame = _referenceFrames;
			var count:int = 0;
			
			while(frames)
			{
				if(frames == frame)
					break;
				
				frames = frames.next as KReferenceFrame;
				count++;
			}
			
			return count;
		}
		
		/**
		 * Removes the given reference frame from this reference frame list
		 */
		public function removeReferenceFrame(referenceFrame:IReferenceFrame):IReferenceFrame
		{
			var refFrame:KReferenceFrame = referenceFrame as KReferenceFrame;
			var previousFrame:KReferenceFrame = refFrame.previous as KReferenceFrame;
			var nextFrame:KReferenceFrame = refFrame.next as KReferenceFrame;
			
			if(previousFrame)
				previousFrame.next = nextFrame;
			
			if(nextFrame)
				nextFrame.previous = previousFrame;
			
			refFrame.previous = null;
			refFrame.next = null;
			
			if(refFrame == _referenceFrames)
				_referenceFrames = nextFrame;
			
			return refFrame;
		}
		
		/**
		 * Removes the reference frame at index
		 */
		public function removeReferenceFrameAt(index:int):IReferenceFrame
		{
			var frame:KReferenceFrame = getReferenceFrameAt(index) as KReferenceFrame;
			
			return removeReferenceFrame(frame);
		}
		
		
		/**
		 * Removes all reference frames after index
		 * Returns the immediate reference frame at given index
		 * Returns null if no reference frame(s) are removed
		 * Removes everything and returns first reference frame if index < 0
		 * Returns null if numReferenceFrames < index 
		 */
		public function removeAllAfter(index:int):IReferenceFrame
		{
			var frame:KReferenceFrame;
			
			if(index < 0)
			{
				frame = _referenceFrames
				_referenceFrames = null;
				return frame;
			}
			
			
			frame = getReferenceFrameAt(index) as KReferenceFrame;
			
			if(!frame)
				return null;
			
			var toRemoveFrom:KReferenceFrame = frame.next as KReferenceFrame;
			
			if(toRemoveFrom)
			{
				toRemoveFrom.previous = null;
				frame.next = null;
			}
			
			return toRemoveFrom;
		}
		
		/**
		 * Returns the last reference frame in the list
		 */
		private function _getLastReferenceFrame():KReferenceFrame
		{
			var frames:KReferenceFrame = _referenceFrames;
			while(frames.next)
			{
				if(frames.next)
					frames = frames.next as KReferenceFrame;
			}
			
			return frames;
		}
	}
}