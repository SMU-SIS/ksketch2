package sg.edu.smu.ksketch.model.implementations
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch.model.IKeyFrame;
	import sg.edu.smu.ksketch.model.IReferenceFrame;
	import sg.edu.smu.ksketch.model.ISpatialKeyframe;
	import sg.edu.smu.ksketch.model.KGroup;
	
	public class KReferenceFrame extends KKeyFrameList implements IReferenceFrame
	{
		private var _previous:KReferenceFrame;
		private var _next:KReferenceFrame;
		public var debugName:String;
		
		public function KReferenceFrame()
		{
			super();
		}
		
		/**
		 *The previous reference frame
		 */
		public function get previous():IReferenceFrame
		{
			return _previous;
		}
		
		public function set previous(refFrame:IReferenceFrame):void
		{
			_previous = refFrame as KReferenceFrame;
		}
		
		/**
		 *The next reference frame
		 */
		public function get next():IReferenceFrame
		{
			return _next;
		}
		
		public function set next(refFrame:IReferenceFrame):void
		{
			_next = refFrame as KReferenceFrame;
		}
		
		/**
		 *Creates and returns a new spatial key.
		 *This key will not be inserted automatically
		 * Center is defined in reference frame coordinates
		 */
		public function createSpatialKey(time:Number, centerX:Number=NaN, centerY:Number=NaN):ISpatialKeyframe
		{
			return new KSpatialKeyFrame(time, new Point(centerX, centerY));
		}
		
		/**
		 * Returns the matrix of this reference frame list at kskTime
		 */
		public function getMatrix(kskTime:Number):Matrix
		{
			var activeKey:KSpatialKeyFrame = lookUp(kskTime) as KSpatialKeyFrame;
			
			if(activeKey)
			{
				return activeKey.getFullMatrix(kskTime, new Matrix());
			}
			else
			{
				return new Matrix();
			}
		}
	}
}