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
	
	import sg.edu.smu.ksketch.model.geom.KPathPoint;
	import sg.edu.smu.ksketch.logger.ILoggable;
	import sg.edu.smu.ksketch.logger.KInteractiveLog;
	import sg.edu.smu.ksketch.logger.KPlaySketchLogger;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	import sg.edu.smu.ksketch.operation.KModelFacade;
	import sg.edu.smu.ksketch.operation.implementations.KInteractionOperation;
	import sg.edu.smu.ksketch.utilities.KAppState;
	
	/**
	 * Class that handles drawing stroke function invocation in KModelFacade.
	 */
	public class KDrawInteractor implements IInteractor
	{
		private var _facade:KModelFacade;
		private var _appState:KAppState;
		private var _log:KInteractiveLog;
		
		/**
		 * Constructor to initialise KModelFacade and KAppState.
		 * @param facade DefaultKModelFacade object to manipulate objects. 
		 * @param appState KAppState object to store and track the operation state. 
		 */	
		public function KDrawInteractor(facade:KModelFacade, appState:KAppState)
		{
			_facade = facade;
			_appState = appState;
		}
		
		/**
		 * Do nothing.
		 */
		public function activate():void
		{
		}
		
		/**
		 * Do nothing.
		 */
		public function deactivate():void
		{
		}
		
		/**
		 * Begin the draw interaction by invoking beginInteracting() function and add the first 
		 * cursor point on the canvas by invoking addKStrokePoint() function of the facade.
		 * If interactive log is enabled, record the cursor point on the log.
		 * @param point Coordinate of the first cursor point at start of the draw interaction.
		 */
		public function begin(point:Point):void
		{
			if(_log != null)
				_log.addPoint(new KPathPoint(point.x, point.y, _appState.time));
			
			_facade.beginKStrokePoint(_appState.penColor,_appState.penThickness,_appState.time);
			_facade.addKStrokePoint(point.x, point.y);
		}
		
		/**
		 * Update intermediate cursor point during draw interaction.
		 * If interactive log is enabled, record the cursor point on the log.
		 * @param point Coordinate of the intermediate cursor point during draw interaction.
		 */		
		public function update(point:Point):void
		{
			if(_log != null)
				_log.addPoint(new KPathPoint(point.x, point.y, _appState.time));
			
			_facade.addKStrokePoint(point.x, point.y);
		}
		
		/**
		 * Begin the draw interaction by invoking facade addKStrokePoint() function on the 
		 * last cursor point on the canvas and return the facade endInteracting() operation.
		 * If interactive log is enabled, record the cursor point on the log.
		 * @param point Coordinate of the last cursor point before end of the draw interaction.
		 */		
		public function end(point:Point):void
		{
			if(_log != null)
			{
				_log.addPoint(new KPathPoint(point.x, point.y, _appState.time));
				_log = null;
			}
			_facade.addKStrokePoint(point.x, point.y);			
			_appState.addOperation(new KInteractionOperation(
				_appState,_appState.time,_appState.time,null,null,_facade.endKStrokePoint()));
		}
		
		/**
		 * Enable interactive log.
		 * @return interactive log. 
		 */
		public function enableLog():ILoggable
		{
			_log = new KInteractiveLog(new Vector.<KPathPoint>(), KPlaySketchLogger.INTERACTION_DRAW);
			return _log;
		}
	}
}