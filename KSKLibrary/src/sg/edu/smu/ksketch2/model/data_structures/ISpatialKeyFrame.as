/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.model.data_structures
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	public interface ISpatialKeyFrame extends IKeyFrame
	{
		/**
		 * Dirtys this key and all future keys, forcing recomputation of its matrix when it is required
		 */
		function dirtyKey():void;
		
		/**
		 * Returns a clone of this key's transformation center
		 */
		function get center():Point;
		
		/**
		 * Returns this Spatial Key's matrix, concatenated with matrices of previous keys at time
		 */
		function fullMatrix(time:int):Matrix;
		
		/**
		 * Returns this spatial key's own matrix at time 
		 */
		function partialMatrix(time:int):Matrix;
	}
}