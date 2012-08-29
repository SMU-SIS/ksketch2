package sg.edu.smu.ksketch.utilities
{
	import sg.edu.smu.ksketch.model.KObject;

	public interface IIterator
	{
		function hasNext():Boolean;
		function next():KObject;
		function top():KObject;
	}
}