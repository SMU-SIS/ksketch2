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
	import sg.edu.smu.ksketch2.model.data_structures.IKeyFrame;
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;

	public interface IVisibilityControl
	{
		function get earliestVisibleTime():int;
		function setVisibility(visible:Boolean, time:int, op:KCompositeOperation):void;
		function get visibilityKeyHeader():IKeyFrame;
		function serializeVisibility():XML;
		function deserializeVisibility(xml:XML):void;
		function alpha(time:int):Number;
	}
}