package sg.edu.smu.ksketch.model.implementations
{
	import sg.edu.smu.ksketch.model.IActivityKeyFrame;
	
	public class KActivityKeyFrame extends KKeyFrame implements IActivityKeyFrame
	{
		private var _alpha:Number;
		private var _active:Boolean;
		
		public function KActivityKeyFrame(time:Number,alpha:Number)
		{
			super(time);
			_alpha = alpha;
		}
		
		public function get alpha():Number
		{
			return _alpha;
		}
		
		public function set alpha(value:Number):void
		{
			_alpha = value;
		}
		
		public function get active():Boolean
		{
			return _active;
		}
		
		public function hasTransform():Boolean
		{
			if(_next)
				return true;
			else
				return false;
		}
	}
}