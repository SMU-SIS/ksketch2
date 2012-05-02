/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.logger
{
	public interface ILoggable
	{
		function get tagName():String;
		function toXML():XML;
	}
}