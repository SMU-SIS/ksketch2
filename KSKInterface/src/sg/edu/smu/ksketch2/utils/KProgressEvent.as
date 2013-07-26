/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.utils
{
	import flash.events.Event;
	
	/**
	 * The KProgressEvent class serves as the concrete class for handling
	 * progress events in K-Sketch.
	 */
	public class KProgressEvent extends Event
	{
		/**
		 * The progress status.
		 */
		public var progress:Number;
		
		/**
		 * The main constructor for the KProgressEvent class.
		 * 
		 * @param type The target event type.
		 * @param progress The target progress status.
		 */
		public function KProgressEvent(type:String, progress:Number)
		{
			super(type);
			
			this.progress = progress;
		}
	}
}