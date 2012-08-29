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
	
	import sg.edu.smu.ksketch.model.IParentKeyFrame;
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.model.KObject;

	public class KParentKeyframe extends KKeyFrame implements IParentKeyFrame
	{
		public static const KEYFRAME_PARENT:String = "PARENT";
		
		private var _parent:KGroup;
		private var _positionMatrix:Matrix;
		public var debugID:int;
		
		/**
		 * Constructor.
		 * @param kskTime KSketch Time.
		 * @param previous The previous parent keyframe.
		 * @param next The next parent keyframe.
		 * @param parent The parent group of this keyframe.
		 */
		public function KParentKeyframe(kskTime:Number, parent:KGroup)
		{
			super(kskTime);
			_parent = parent;
		}
		
		/**
		 * Get the parent group at the provided K-Sketch time. 
		 * If the provided time is earlier than the time of this keyframe and 
		 * there is a previous parent keyframe, return the parent group of the 
		 * previous parent keyframe; else return the parent group of this keyframe. 
		 * @return The parent group with respect to this keyframe.
		 */		
		public function getParent(kskTime:Number):KGroup
		{
			if(kskTime < this.endTime && previous != null)
				return (previous as KParentKeyframe).parent;
			else
				return parent;
		}
		
		/**
		 * Get the group of this keyframe. 
		 * @return The parent group of this keyframe.
		 */		
		public function get parent():KGroup
		{			
			return _parent;
		}
		
		public function get positionMatrix():Matrix
		{
			if(_positionMatrix)
				return _positionMatrix.clone();
			else
				return new Matrix();
		}

		public function set positionMatrix(value:Matrix):void
		{
			_positionMatrix = value.clone();
		}			
	}
}