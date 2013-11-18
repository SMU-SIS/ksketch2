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

	/**
	 * The KReplacePathOperation class serves as the concrete class for
	 * handling replace path operations in K-Sketch.
	 */
	public class KReplacePathOperation implements IModelOperation
	{
		private var _key:KSpatialKeyFrame		// the current spatial key frame
		private var _newPath:KPath;				// the new key frames path
		private var _oldPath:KPath;				// the old key frames path
		private var _type:int;					// the transform type
		
		/**
		 * The main constructor for the KReplacePathOperation class.
		 * 
		 * @param affectedKey The target spatial key frame.
		 * @param newPath The new key frames path.
		 * @param oldPath The old key frames path.
		 * @param type The transform type.
		 */
		public function KReplacePathOperation(affectedKey:ISpatialKeyFrame, newPath:KPath, oldPath:KPath, type:int)
		{
			_key = affectedKey as KSpatialKeyFrame;		// set the target key frame
			_newPath = newPath.clone();					// set the new key frames path
			_oldPath = oldPath.clone();					// set the old key frames path
			_type = type;								// set the transform type
			
			// case: the replace path operation is invalid
			// return an error
			if(!isValid())
				throw new Error(errorMessage);
		}
		
		/**
		 * Gets the error message for the replace path operation.
		 * 
		 * @return The error message for the replace path operation.
		 */
		public function get errorMessage():String
		{
			return "KReplacePathOperation requires all of its 4 inputs to be not null";
		}
		
		/**
		 * Checks whether the replace path operation is valid. If not, it should
		 * fail on construction and not be added to the operation stack.
		 * 
		 * @return Whether the replace path operation is valid.
		 */
		public function isValid():Boolean
		{
			return 	_key &&				// check for non-null key frame
					_newPath &&			// check for non-null new key frames path
					_oldPath &&			// check for non-null old key frames path
					!isNaN(_type);		// check for valid number
		}
		
		/**
		 * Undoes the replace path operation by reverting the state of the
		 * operation to immediately before the operation was performed.
		 */
		public function undo():void
		{
			// handle the different transform types
			switch(_type)
			{
				// case: translation transformation
				case KSketch2.TRANSFORM_TRANSLATION:
					_key.translatePath = _oldPath;
					break;
				
				// case: rotation transformation
				case KSketch2.TRANSFORM_ROTATION:
					_key.rotatePath = _oldPath;
					break;
				
				// case: scale transformation
				case KSketch2.TRANSFORM_SCALE:
					_key.scalePath = _oldPath;
			}
		}
		
		/**
		 * Redoes the replace path operation by reverting the state of the
		 * operation to immediately before the operation was performed.
		 */
		public function redo():void
		{
			// handle the different transform types
			switch(_type)
			{
				// case: translation transformation
				case KSketch2.TRANSFORM_TRANSLATION:
					_key.translatePath = _newPath;
					break;
				
				// case: rotation transformation
				case KSketch2.TRANSFORM_ROTATION:
					_key.rotatePath = _newPath;
					break;
				
				// case: scale transformation
				case KSketch2.TRANSFORM_SCALE:
					_key.scalePath = _newPath;
			}
		}
		
		/**
		 * Debugs the replace path operation by showing what is inside the
		 * operation.
		 */
		public function debug():void
		{
			trace(this);
		}
	}
}