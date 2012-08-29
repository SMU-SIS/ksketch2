/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package sg.edu.smu.ksketch.operation.implementations
{
	import sg.edu.smu.ksketch.model.geom.KRotation;
	import sg.edu.smu.ksketch.model.geom.KScale;
	import sg.edu.smu.ksketch.model.geom.KTranslation;
	import sg.edu.smu.ksketch.model.implementations.KSpatialKeyFrame;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	
	public class KReplaceTransformOperation implements IModelOperation
	{
		private var _key:KSpatialKeyFrame;
		private var _oldTranslation:KTranslation;
		private var _newTranslation:KTranslation;
		private var _oldRotation:KRotation;
		private var _newRotate:KRotation;
		private var _oldScale:KScale;
		private var _newScale:KScale;
		
		public function KReplaceTransformOperation(
			key:KSpatialKeyFrame, oldTranslate:KTranslation, newTranslate:KTranslation, 
			oldRotate:KRotation, newRotate:KRotation, oldScale:KScale, newScale:KScale)
		{
			_key = key;
			_oldTranslation = oldTranslate;
			_newTranslation = newTranslate;
			_oldRotation = oldRotate;
			_newRotate = newRotate;
			_oldScale = oldScale;
			_newScale = newScale;
		}
		
		public function apply():void
		{
			if(_newTranslation)
				_key.translate = _newTranslation;
			
			if(_newRotate)
				_key.rotate = _newRotate;
			
			if(_newScale)
				_key.scale = _newScale;
	
			_key.dirtyKey();
		}
		
		public function undo():void
		{
			if(_oldTranslation)
				_key.translate = _oldTranslation;

			if(_oldRotation)
				_key.rotate = _oldRotation;
			
			if(_oldScale)
				_key.scale = _oldScale;
	
			_key.dirtyKey();
		}
	}
}