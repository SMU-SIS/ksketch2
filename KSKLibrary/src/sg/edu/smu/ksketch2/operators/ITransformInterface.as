/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.operators
{
	import flash.geom.Matrix;
	
	import sg.edu.smu.ksketch2.model.data_structures.IKeyFrame;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;

	/**
	 * The ITransformInterface class serves as the interface class
	 * for transform operations in K-Sketch.
	 */
	public interface ITransformInterface
	{
		// ##########################
		// # Accessors and Mutators #
		// ##########################
		
		/**
		 * Sets the value of the dirty state flag.
		 * 
		 * @param The dirty state value.
		 */
		function set dirty(value:Boolean):void;
		
		/**
		 * Gets the transform matrix of the reference frame that the interface
		 * provides access to. If the matrix is in transition, the transition
		 * matrix is returned. If the matrix is cached, then the cached matrix
		 * is returned. Otherwise, the matrix is calculated from scratch and
		 * then returned.
		 * 
		 * @param time The queried time.
		 * @return The transform matrix of the reference frame.
		 */
		function matrix(time:int):Matrix;
		
		/**
		 * Gets the time value of the first key frame in the reference frame
		 * that the transform operator handles.
		 * 
		 * @return The time value of the first key frame in the reference frame
		 * that the transform operator handles.
		 */
		function get firstKeyTime():int;
		
		/**
		 * Gets the time value of the last key frame in the reference frame
		 * that the transform operator handles.
		 * 
		 * @return The time value of the first key frame in the reference frame
		 * that the transform operator handles.
		 */
		function get lastKeyTime():int;
		
		/**
		 * Gets the active key frame in effect at the given time.
		 * 
		 * @param The target time.
		 * @return The active key frame at the given time.
		 */
		function getActiveKey(time:int):IKeyFrame;
		
		/**
		 * Gets the type of the transition operator.
		 * 
		 * @return The type of the transition operator.
		 */
		function get transitionType():int;
		
		
		
		// ##############
		// # Permitters #
		// ##############
		
		/**
		 * Checks whether the object has active transform operations at the given
		 * time. True if there is an active transform operation, false otheriwse.
		 * 
		 * @param time The target time.
		 * @return Whether there is an active transform operations at the given
		 * time.
		 */
		function canInterpolate(time:int):Boolean;
		
		/**
		 * Checks whether it is possible to insert a key frame into the 
		 * transform operator's key frame list. True if there exists a
		 * key frame at the given time, false otherwise.
		 * 
		 * @param time The target time.
		 * @return Whether it is possible to insert a key frame into
		 * the transform operator's key frame list.
		 */
		function canInsertKey(time:int):Boolean;
		
		/**
		 * Checks whether it is possible to remove a key frame from the 
		 * transform operator's key frame list. True if there exists a
		 * key frame at the given time, has a next key frame, and is not
		 * the head key frame; false otherwise.
		 * 
		 * @param The target time.
		 * @return Whether it is possible to remove a key frame from
		 * the transform operator's key frame list.
		 */
		function canRemoveKey(time:int):Boolean;
		
		/**
		 * Checks whether it is possible to clear key frames from the 
		 * transform operator's key frame list. True if there exists a
		 * key frame after the given time; false otherwise.
		 * 
		 * @param The target time.
		 * @return Whether it is possible to clear key frames from the 
		 * transform operator's key frame list.
		 */
		function canClearKeys(time:int):Boolean;
		
		
		
		// ###############
		// # Transitions #
		// ###############
		
		/**
		 * Preps the object for transition by checking for errors and
		 * inconsistencies, and complains if the object is not in the magical
		 * state. Note: the previous operation did not clean up the object.
		 * 
		 * @param time The target time.
		 * @param transitionType The transition type.
		 * @param The corresponding composite operation.
		 */
		function beginTransition(time:int, transitionType:int, op:KCompositeOperation):void;
		
		/**
		 * Updates the object during the transition.
		 * 
		 * @param time The target time.
		 * @param dx The target x-position.
		 * @param dy The target y-position.
		 * @param dTheta The target rotation value.
		 * @param dScale The target scaling value.
		 */
		function updateTransition(time:int, dx:Number, dy:Number, dTheta:Number, dScale:Number):void;
		
		/**
		 * Finalizes the object's transition.
		 * 
		 * @param time The target time.
		 * @param op The corresponding composite operation.
		 */
		function endTransition(time:int, op:KCompositeOperation):void;
		
		
		
		// ############
		// # Modifers #
		// ############
		
		/**
		 * Moves the center of the object.
		 * 
		 * @param dx The target x-position.
		 * @param dy The target y-position.
		 * @param time The target time.
		 */
		function moveCenter(dx:Number, dy:Number, time:int):void;
		
		/**
		 * Inserts a blank key frame into the key frame list under the following
		 * two conditions: 1) there exists a key frame after the given time, and
		 * 2) the existing subsequent key frame has transitions in it.
		 * 
		 * @param time The target time.
		 * @param op The corresponding target composite operation.
		 */
		function insertBlankKeyFrame(time:int, op:KCompositeOperation):void;
		
		/**
		 * Removes the key frame from the key frame list. Any transitions
		 * happening at the time will become non-keyed. Also keeps the object's
		 * transform operation consistent (i.e., as compared to before removal)
		 * both before and after the given time.
		 * 
		 * @param time The target time.
		 * @param op The corresponding composite operation.
		 */
		function removeKeyFrame(time:int, op:KCompositeOperation):void;
		
		/**
		 * Clears all the motions after the given time. If there is no active
		 * key at time, motions won't be cleared since there are no keys after
		 * that point in time. If there is an active key at time, a key frame will
		 * be inserted at the given time time (if there is no key frame).
		 * 
		 * @param time The target time.
		 * @param op The corresponding composite operation.
		 */
		function clearAllMotionsAfterTime(time:int, op:KCompositeOperation):void;
		
		
		
		// #################
		// # Miscellaneous #
		// #################
		
		/**
		 * Gets a list of all the key frames of the transform operator.
		 * 
		 * @return A list of all the key frames of the transform operator.
		 */
		function getAllKeyFrames():Vector.<IKeyFrame>;
		
		/**
		 * Merges the given object's transform operator into this transform
		 * operator until the given time to stop the merge. The given source
		 * object should be part of the hierarchy of this transform operator
		 * for the merge to work successfully.
		 * 
		 * @param sourceObject The target source object.
		 * @param stopMergeTime The time to stop the merge.
		 * @param op The corresponding composite operation.
		 */
		function mergeTransform(sourceObject:KObject, stopMergeTime:int, op:KCompositeOperation):void;
		
		/**
		 * Gets a copy of the transform operator.
		 * 
		 * @return A copy of the transform operator.
		 */
		function clone():ITransformInterface;
		
		/**
		 * Serializes the transform operator to an XML object.
		 * 
		 * @return The serialized XML object of the transform operator.
		 */
		function serializeTransform():XML;
		
		/**
		 * Deserializes the XML object to a transform operator.
		 * 
		 * @param The target XML object of a transform operator.
		 */
		function deserializeTransform(xml:XML):void;
	}
}