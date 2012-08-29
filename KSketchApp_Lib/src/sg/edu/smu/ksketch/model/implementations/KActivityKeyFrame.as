/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

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