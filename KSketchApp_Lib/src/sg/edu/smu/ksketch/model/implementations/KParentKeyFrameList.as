package sg.edu.smu.ksketch.model.implementations
{
	import flash.geom.Matrix;
	import flash.media.ID3Info;
	
	import sg.edu.smu.ksketch.model.IParentKeyFrame;
	import sg.edu.smu.ksketch.model.IParentKeyFrameList;
	import sg.edu.smu.ksketch.model.KGroup;
	
	public class KParentKeyFrameList extends KKeyFrameList implements IParentKeyFrameList
	{
		public var debugID:int;
		
		public function KParentKeyFrameList()
		{
			super();
		}
		
		public function createParentKey(time:Number, parent:KGroup):IParentKeyFrame
		{
			return new KParentKeyframe(time, parent);
		}
	}
}