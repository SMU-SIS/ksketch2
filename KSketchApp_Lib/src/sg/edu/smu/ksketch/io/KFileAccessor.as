/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package sg.edu.smu.ksketch.io
{
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.net.FileReference;
	import flash.net.FileFilter;
	import flash.system.Capabilities;

	import sg.edu.smu.ksketch.logger.KLogger;

	public class KFileAccessor extends EventDispatcher
	{
		public static function resolvePath(filename:String,location:String):FileReference
		{
			if (_isRunningInAIR())
			{
				switch(location)
				{
					case KLogger.FILE_USER_DIR:
						return File.userDirectory.resolvePath(filename);
					case KLogger.FILE_DESKTOP_DIR:
						return File.desktopDirectory.resolvePath(filename);
					case KLogger.FILE_DOCUMENT_DIR:
						return File.documentsDirectory.resolvePath(filename);
					case KLogger.FILE_STORAGE_DIR:
						return File.applicationStorageDirectory.resolvePath(filename);
				}
				return new File(null);
			}
			return null;
		}
		
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