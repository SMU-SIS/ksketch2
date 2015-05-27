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
		private var _shapeDistance:int;
		private var _shapeDistanceInCm:int;
		private var _stars:int;
		
		public function KResult(activityType:String, instruction:int, id:int)
		{
			_activityType = activityType;
			_instructionNo = instruction;
			_objectID = id;
			_time_taken = 0;
			_time_given = 0;
			_percentageQuadrant = 0;
			_shapeDistance = 0;
			_shapeDistanceInCm = 0;
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
		
		public function get shapeDistance():int
		{
			return _shapeDistance;
		}
		
		public function set shapeDistance(distance:int):void
		{
			_shapeDistance = distance;
		}
		
		public function get shapeDistanceInCm():int
		{
			return _shapeDistanceInCm;
		}
		
		public function set shapeDistanceInCm(distance:int):void
		{
			_shapeDistanceInCm = distance;
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