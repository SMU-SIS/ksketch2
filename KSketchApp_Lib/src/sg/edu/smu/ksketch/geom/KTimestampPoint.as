package sg.edu.smu.ksketch.geom
{
	import flash.geom.Point;

	/**
	 * The extension of Point class with a time dimension. 
	 * The time dimension is represented using the type Number
	 */
	public class KTimestampPoint extends Point
	{
		private var _timeStamp:Number;
		
		/**
		 * Constructor.
		 * @param timeStamp TimeStamp of the KTimeStampPoint.
		 * @param x X coordinate of the KTimeStampPoint.
		 * @param y Y coordinate of the KTimeStampPoint.
		 */		
		public function KTimestampPoint(timeStamp:Number, x:Number, y:Number)
		{
			super(x, y);
			_timeStamp = timeStamp;
		}

		/**
		 * The time of the KTimedStampPoint.
		 */		
		public function get timeStamp():Number
		{
			return _timeStamp;
		}
		public function set timeStamp(value:Number):void
		{
			_timeStamp = value;
		}
	}
}