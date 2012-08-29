/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

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