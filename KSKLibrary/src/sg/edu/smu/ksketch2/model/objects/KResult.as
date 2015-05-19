package sg.edu.smu.ksketch2.model.objects
{
	public class KResult
	{
		private var _activityType:String;
		private var _instructionNo:int;
		private var _objectID:int;
		private var _time:int;
		private var _percentageQuadrant:int;
		private var _accuracyShape:Number;
		private var _accuracyMotion:Number;
		
		public function KResult(activityType:String, instruction:int, id:int)
		{
			_activityType = activityType;
			_instructionNo = instruction;
			_objectID = id;
			_time = 0;
			_percentageQuadrant = 0;
			_accuracyShape = 0;
			_accuracyMotion = 0;
		}
		
		/**
		 * Get/Set methods for all attributes
		 */
		public function get time():int
		{
			return _time;
		}
		
		public function set time(t:int):void
		{
			_time = t;
		}
		
		public function get percentageQuadrant():int
		{
			return _percentageQuadrant;
		}
		
		public function set percentageQuadrant(percentage:int):void
		{
			_percentageQuadrant = percentage;
		}
		
		public function get accuracyShape():Number
		{
			return _accuracyShape;
		}
		
		public function set accuracyShape(accuracy:Number):void
		{
			_accuracyShape = accuracy;
		}
		
		public function get accuracyMotion():Number
		{
			return _accuracyMotion;
		}
		
		public function set accuracyMotion(accuracy:Number):void
		{
			_accuracyMotion = accuracy;
		}
	}
}