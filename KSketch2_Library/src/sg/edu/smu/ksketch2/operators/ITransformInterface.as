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

	public interface ITransformInterface
	{
		function set dirty(value:Boolean):void;
		function matrix(time:int):Matrix;
		function get firstKeyTime():int;
		function get lastKeyTime():int;
		function getActiveKey(time:int):IKeyFrame;
		function get transitionType():int;
		function canInterpolate(time:int):Boolean;
		function canInsertKey(time:int):Boolean;
		
		function beginTransition(time:int, transitionType:int, op:KCompositeOperation):void;
		function updateTransition(time:int, dx:Number, dy:Number, dTheta:Number, dScale:Number):void;
		function endTransition(time:int, op:KCompositeOperation):void;
		
		function insertBlankKeyFrame(time:int, op:KCompositeOperation):void;
		function clearAllMotionsAfterTime(time:int, op:KCompositeOperation):void;
		
		/**
		 * Returns all key frames that this object has as a vector
		 */
		function getAllKeyFrames():Vector.<IKeyFrame>;
		
		/**
		 * Merge sourceObject's transform (up till time) into this interface's owner
		 * SourceObject should be part of the hierachy for this to work
		 */
		function mergeTransform(sourceObject:KObject, stopMergeTime:int, op:KCompositeOperation):void;
		
		/**
		 * Serializes the transform for this interface's owner
		 */
		function clone():ITransformInterface
		function serializeTransform():XML;
		function deserializeTransform(xml:XML):void;
	}
}