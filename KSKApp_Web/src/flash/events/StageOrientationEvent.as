/**
 * Copyright 2010-2015 Singapore Management University
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package flash.events
{
	public class StageOrientationEvent extends Event
	{
		static public const ORIENTATION_CHANGE:String = "orientationChange";
		static public const ORIENTATION_CHANGING:String = "orientationChanging";
		
		public function StageOrientationEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}