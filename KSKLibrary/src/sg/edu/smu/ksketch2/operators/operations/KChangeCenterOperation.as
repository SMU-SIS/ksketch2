package sg.edu.smu.ksketch2.operators.operations
{
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch2.model.objects.KObject;

	public class KChangeCenterOperation implements IModelOperation
	{
		private var _object:KObject;
		private var _oldCenter:Point;
		private var _newCenter:Point;
		
		public function KChangeCenterOperation(object:KObject, oldCenter:Point, newCenter:Point)
		{
			_object = object;
			_oldCenter = oldCenter;
			_newCenter = newCenter;
		}
		
		public function get errorMessage():String
		{
			if(!_object)
				return "The target object wasn't specified";
			
			if(!_oldCenter)
				return "The old center wasn't specified";
			
			if(!_newCenter)
				return "The new center wasn't specified";
			
			return "There is an error with change center operation";
		}
		
		public function isValid():Boolean
		{
			return (_object != null)&&(_oldCenter != null)&&(_newCenter != null);
		}
		
		public function undo():void
		{
			_object.center = _oldCenter;
		}
		
		public function redo():void
		{
			_object.center = _newCenter;
		}
		
		public function debug():void
		{
		}
	}
}