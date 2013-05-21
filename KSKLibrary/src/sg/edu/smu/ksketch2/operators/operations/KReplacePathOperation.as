/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.operators.operations
{
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.model.data_structures.ISpatialKeyFrame;
	import sg.edu.smu.ksketch2.model.data_structures.KPath;
	import sg.edu.smu.ksketch2.model.data_structures.KSpatialKeyFrame;

	public class KReplacePathOperation implements IModelOperation
	{
		private var _key:KSpatialKeyFrame
		private var _newPath:KPath;
		private var _oldPath:KPath;
		private var _type:int;
		
		public function KReplacePathOperation(affectedKey:ISpatialKeyFrame, newPath:KPath, oldPath:KPath, type:int)
		{
			_key = affectedKey as KSpatialKeyFrame;
			_newPath = newPath.clone();
			_oldPath = oldPath.clone();
			_type = type;	
			if(!isValid())
				throw new Error(errorMessage);
		}
		
		public function get errorMessage():String
		{
			return "KReplacePathOperation requires all of its 4 inputs to be not null";
		}
		
		public function isValid():Boolean
		{
			return _key && _newPath && _oldPath && !isNaN(_type);
		}
		
		public function undo():void
		{
			switch(_type)
			{
				case KSketch2.TRANSFORM_TRANSLATION:
					_key.translatePath = _oldPath;
					break;
				case KSketch2.TRANSFORM_ROTATION:
					_key.rotatePath = _oldPath;
					break;
				case KSketch2.TRANSFORM_SCALE:
					_key.scalePath = _oldPath;
			}
		}
		
		public function redo():void
		{
			switch(_type)
			{
				case KSketch2.TRANSFORM_TRANSLATION:
					_key.translatePath = _newPath;
					break;
				case KSketch2.TRANSFORM_ROTATION:
					_key.rotatePath = _newPath;
					break;
				case KSketch2.TRANSFORM_SCALE:
					_key.scalePath = _newPath;
			}
		}
		
		public function debug():void
		{
			trace(this);
		}
	}
}