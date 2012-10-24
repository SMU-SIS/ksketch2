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
	import flash.errors.IllegalOperationError;
	import flash.geom.Point;
	import flash.utils.getQualifiedClassName;
	
	import sg.edu.smu.ksketch.logger.ILoggable;
	import sg.edu.smu.ksketch.logger.KTransitionLog;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.model.geom.KPathPoint;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	import sg.edu.smu.ksketch.operation.KModelFacade;
	import sg.edu.smu.ksketch.operation.implementations.KCompositeOperation;
	import sg.edu.smu.ksketch.operation.implementations.KInteractionOperation;
	import sg.edu.smu.ksketch.utilities.ErrorMessage;
	import sg.edu.smu.ksketch.utilities.KAppState;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;
	
	/**
	 * Class for invoking transition operations in KModelFacade. It cannot be instantiated 
	 * directly, calling new KTransitionInteractor() constructor throws an IllegalOperationError. 
	 * KTranslateInteractor, KRotateInteractor and KScaleInteractor are its subclasses.
	 */	
	public class KTransitionInteractor implements IInteractor
	{
		public static const BREAK_OUT:Boolean = false;
		protected var _facade:KModelFacade;
		protected var _appState:KAppState;
		protected var _transitionType:int;
		private var _startTime:Number;
		private var _oldSelection:KSelection;
		private var _currentOperation:KCompositeOperation;
		private var _log:KTransitionLog;
		
		/**
		 * Constructor to initialise KModelFacade and KAppState. Should be called from the subclass.
		 * Calling the new KModelFacade() constructor throws an IllegalOperationError. 
		 * @param facade DefaultKModelFacade object to manipulate objects. 
		 * @param appState KAppState object to store and track the operation state. 
		 */	
		public function KTransitionInteractor(facade:KModelFacade, appState:KAppState)
		{
			if (getQualifiedClassName(this) == "sg.edu.smu.ksketch.interactor::KTransitionInteractor")
				throw new IllegalOperationError(ErrorMessage.ABSTRACT_CLASS_INSTANTIATED);
			
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
		 * Begin the transition and invoke transitionStart (implement by subclass) function at point if
		 * KAppState is not in user test mode. If transition log is enabled, record the point on the log.
		 * @param point The coordinate of the first point at the start of transition interaction.
		 */		
		public function begin(point:Point):void
		{
			if(_appState.selection == null || _appState.selection.objects.length() <= 0)
				throw new Error("selection is null or contains 0 object!");
			
			if(_log != null)
				_log.addPoint(new KPathPoint(point.x, point.y, _appState.time));
			
			_transitionType = _appState.transitionType;

			if(!_appState.isUserTest)
			{
				_startTime = _appState.time;
				_oldSelection = _appState.selection;
				_currentOperation = new KCompositeOperation();
				var op:IModelOperation = transitionStart(point, _transitionType);
				if (op != null)
					_currentOperation.addOperation(op);
			}
		}

		/**
		 * Update the transition for the intermediate point as the pen dragged on the canvas and invoke 
		 * transitionUpdate (implement by subclass) function at point KAppState is not in user test mode.
		 * If transition log is enabled, record the point on the log and disable the log.
		 * @param point The coordinate of the intermediate point during the transition interaction.
		 */		
		public function update(point:Point):void
		{
			if(_log != null)
				_log.addPoint(new KPathPoint(point.x, point.y, _appState.time));
			
			if(!_appState.isUserTest)
				transitionUpdate(point);
		}
		
		/**
		 * End the transition at point and return transitionEnd (implement by subclass) operation.
		 * If transition log is enabled, record the point on the log and disable the log.
		 * @param point The coordinate of the last point before the end of the transition interaction.
		 */		
		public function end(point:Point):void
		{
			_currentOperation.addOperation(transitionEnd(point));
			if (_currentOperation.length > 0)
				_appState.addOperation(new KInteractionOperation(_appState,_startTime,
					_appState.time,_oldSelection,_appState.selection,_currentOperation));

			_transitionType = KAppState.TRANSITION_DEFAULT;
			
			if(_log != null)
			{
				_log.addPoint(new KPathPoint(point.x, point.y, _appState.time));
				_log = null;
			}
		}

		/**
		 * Enable transition log.
		 * @return transition log. 
		 */
		public function enableLog():ILoggable
		{
			_log = new KTransitionLog(name, _appState.transitionType, new Vector.<KPathPoint>());
			return _log;
		}

		/**
		 * Name of the interactor. For subclass to implement.
		 */
		public function get name():String
		{
			return null;
		}

		// ----- functions for subclasses to implement ----- //
		protected function transitionStart(canvasPoint:Point, transitionType:int):IModelOperation
		{
			throw new IllegalOperationError(ErrorMessage.ABSTRACT_METHODS_NOT_IMPLEMENTED);
		}
		protected function transitionUpdate(canvasPoint:Point):void
		{
			throw new IllegalOperationError(ErrorMessage.ABSTRACT_METHODS_NOT_IMPLEMENTED);
		}
		protected function transitionEnd(canvasPoint:Point):IModelOperation
		{
			throw new IllegalOperationError(ErrorMessage.ABSTRACT_METHODS_NOT_IMPLEMENTED);
		}
		// ------------------------------------------------- //
		
		// Obtain the center of appState at appState time.
		protected function center(appState:KAppState):Point
		{
			return appState.selection.centerAt(appState.time).clone();
		}
		
		// Obtain the selected object of appState at index.
		protected function objectAt(appState:KAppState,index:int):KObject
		{
			return appState.selection.objects.getObjectAt(index);
		}
		
		// Determine if the current appState is in Implicit Dynamic Grouping mode.
		protected function isImplicitGrouping():Boolean
		{
			return _appState.groupingMode == KAppState.GROUPING_IMPLICIT_STATIC;
		}
		
		/**
		 * Will force a group if > 1 object
		 * If all objects of a group is selected, nObject = 1 for those selected objects
		 */
		protected function performGroupingOp(objects:KModelObjectList):IModelOperation
		{
			if(objects.length() > 1)
			{
				var groupOp:KCompositeOperation = new KCompositeOperation();
				var groupedObjects:KModelObjectList = _facade.group(objects,_appState.time, BREAK_OUT, groupOp);
				_appState.selection = new KSelection(groupedObjects, _appState.time);
				
				if(groupOp.length > 1)
					return groupOp;
			}
			return null;
		}
		protected function selection():KSelection
		{
			return _appState.selection ? _appState.selection : _oldSelection;
		}
	}
}