package sg.edu.smu.ksketch2.model.objects
{
	public class KResult
	{
		private var _activityType:String;
		private var _instructionNo:int;
		private var _objectID:int;
		private var _time_taken:int;
		private var _time_given:int;
		private var _percentageQuadrant:int;
		private var _averageDistance:Number;
		private var _maximumDistance:Number;
		private var _stars:int;
		
		public function KResult(activityType:String, instruction:int, id:int)
		{
			_activityType = activityType;
			_instructionNo = instruction;
			_objectID = id;
			_time_taken = 0;
			_time_given = 0;
			_percentageQuadrant = 0;
			_averageDistance = 0;
			_maximumDistance = 0;
			_stars = 0;
		}
		
		/**
		 * Get/Set methods for all attributes
		 */
		public function get timeTaken():int
		{
			return _time_taken;
		}
		
		public function set timeTaken(t:int):void
		{
			_time_taken = t;
		}
		
		public function get timeGiven():int
		{
			return _time_given;
		}
		
		public function set timeGiven(t:int):void
		{
			_time_given = t;
		}
		
		
		public function get percentageQuadrant():int
		{
			return _percentageQuadrant;
		}
		
		public function set percentageQuadrant(percentage:int):void
		{
			_percentageQuadrant = percentage;
		}
		
		public function get averageDistance():Number
		{
			return _averageDistance;
		}
		
		public function set averageDistance(distance:Number):void
		{
			_averageDistance = distance;
		}
		
		public function get maximumDistance():Number
		{
			return _maximumDistance;
		}
		
		public function set maximumDistance(distance:Number):void
		{
			_maximumDistance = distance;
		}
		
		public function get stars():int
		{
			return _stars;
		}
		
		public function set stars(stars:int):void
		{
			_stars = stars;
		}
	}
}