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
	import flash.geom.Matrix;
	import flash.media.ID3Info;
	
	import sg.edu.smu.ksketch.model.IKeyFrame;
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
		
		override public function lookUp(kskTime:Number):IKeyFrame
		{
			return getAtOrBeforeTime(kskTime);
		}
	}
}