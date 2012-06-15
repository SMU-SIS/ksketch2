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
		protected static function _isRunningInAIR():Boolean
		{
			return Capabilities.playerType == "Desktop";
		}
		
		protected static function _getImageTypeFilter():FileFilter
		{
			return new FileFilter("Images (*.jpg, *.jpeg, *.gif, *.png)", "*.jpg;*.jpeg;*.gif;*.png");
		}
		
		protected static function _getKMVTypeFilter():FileFilter
		{
			return new FileFilter("KSketch Movie File (*.kmv)", "*.kmv");
		}
		
		protected static function _getLogTypeFilter():FileFilter
		{
			return new FileFilter("KSketch Log File (*.klg)", "*.klg");
		}		
	}
}