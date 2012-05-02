/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.io
{
	import flash.events.EventDispatcher;
	import flash.net.FileFilter;
	import flash.system.Capabilities;

	public class KFileAccessor extends EventDispatcher
	{
		
		protected function _isRunningInAIR():Boolean
		{
			return Capabilities.playerType == "Desktop";
		}
		
		protected function _getImageTypeFilter():FileFilter
		{
			return new FileFilter("Images (*.jpg, *.jpeg, *.gif, *.png)", "*.jpg;*.jpeg;*.gif;*.png");
		}
		
		protected function _getKMVTypeFilter():FileFilter
		{
			return new FileFilter("KSketch Movie File (*.kmv)", "*.kmv");
		}
		
		protected function _getLogTypeFilter():FileFilter
		{
			return new FileFilter("KSketch Log File (*.klg)", "*.klg");
		}
		
		// Generate time string in YYYY-MM-DD-HH-MN format
		protected function _generateTimeString():String
		{
			var date:Date = new Date();
			return date.fullYear+"-"+(date.month+1)+"-"+date.date+"-"+date.hours+"-"+date.minutes;
		}
	}
}