/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.interactor
{
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch.logger.ILoggable;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	
	public interface IInteractor
	{
		function enableLog():ILoggable;
		function activate():void;
		function deactivate():void;
		function begin(point:Point):void;
		function update(point:Point):void;
		function end(point:Point):void;
	}
}