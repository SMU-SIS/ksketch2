package sg.edu.smu.ksketch.model
{
	import flash.geom.Matrix;

	public interface IParentKeyFrameList extends IKeyFrameList
	{
		function createParentKey(time:Number, parent:KGroup):IParentKeyFrame;
	}
}