/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

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