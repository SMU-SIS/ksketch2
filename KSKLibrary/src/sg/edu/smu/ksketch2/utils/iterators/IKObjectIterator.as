package sg.edu.smu.ksketch2.utils.iterators
{
	import sg.edu.smu.ksketch2.model.objects.KObject;

	public interface IKObjectIterator
	{
		/**
		 * Reset the iterator to point to the first element.
		 */
		function reset():void;
		
		/**
		 * Return the next element.
		 * 
		 * @return The next element.
		 */
		function next():KObject;
		
		/**
		 * Check if there are more elements to iterate over.
		 * 
		 * @return True iff there are more elements.
		 */
		function hasNext():Boolean;
		
	}
}