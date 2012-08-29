/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package sg.edu.smu.ksketch.model
{
	import flash.geom.Matrix;

	public interface IParentKeyFrame extends IKeyFrame
	{
		function getParent(kskTime:Number):KGroup;
		function get parent():KGroup;
		function get positionMatrix():Matrix;
		function set positionMatrix(value:Matrix):void;
	}
}