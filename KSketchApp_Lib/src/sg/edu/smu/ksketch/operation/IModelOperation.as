/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.operation
{
	public interface IModelOperation
	{
		function apply():void;
		function undo():void;
	}
}