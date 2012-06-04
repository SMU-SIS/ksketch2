/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.interactor
{
	public interface IComplexInteractor extends IInteractor
	{
		function get decorated():IInteractor;
	}
}