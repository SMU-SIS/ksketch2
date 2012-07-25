/**------------------------------------------------
 * Copyright 2012 Singapore Management University
 * All Rights Reserved
 *
 *-------------------------------------------------*/

package sg.edu.smu.ksketch.interactor
{
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch.components.KCanvas;
	import sg.edu.smu.ksketch.logger.ILoggable;
	import sg.edu.smu.ksketch.logger.KInteractiveLog;
	import sg.edu.smu.ksketch.logger.KPlaySketchLogger;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.model.geom.KPathPoint;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	import sg.edu.smu.ksketch.operation.KModelFacade;
	import sg.edu.smu.ksketch.operation.implementations.KCompositeOperation;
	import sg.edu.smu.ksketch.operation.implementations.KInteractionOperation;
	import sg.edu.smu.ksketch.utilities.KAppState;
	
	/**
	 * Class that handles Erasing stroke (detectKStroke) operation in KModelFacade.
	 */
	public class KEraseInteractor implements IInteractor
	{
		private var _currentOperation:KCompositeOperation;
		private var _hit_detector:KHitDetector;
		private var _facade:KModelFacade;
		private var _appState:KAppState;
		private var _canvas:KCanvas;
		private var _log:KInteractiveLog;
		
		/**
		 * Constructor to initialise KModelFacade and KAppState.
		 * @param facade KModelFacade object to manipulate objects. 
		 * @param appState KAppState object to store and track the operation state. 
		 * @param canvas KAppState object to obtain the cursor point.
		 */	
		public function KEraseInteractor(facade:KModelFacade, appState:KAppState, canvas:KCanvas)
		{
			_hit_detector = new KHitDetector(canvas);
			_facade = facade;
			_appState = appState;			
			_canvas = canvas;
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
		 * Begin the Erase interaction.
		 * If interactive log is enabled, record the cursor point on the log.
		 */
		public function begin(point:Point):void
		{		
			if(_log != null)
				_log.addPoint(new KPathPoint(point.x, point.y, _appState.time));
			_hit_detector.reset(point);
			_appState.selection = null;
			_currentOperation = new KCompositeOperation();
		}
		
		/**
		 * Update intermediate cursor point during erase interaction. 
		 * If interactive log is enabled, record the cursor point on the log.
		 */		
		public function update(point:Point):void
		{
			var time:Number = _appState.time;
			if(_log != null)
				_log.addPoint(new KPathPoint(point.x, point.y, _appState.time));
			var pt:Point = KInteractorManager.getInverseCoordinate(point,_canvas);
			var object:KObject = _hit_detector.detect(pt);
			var op:IModelOperation = object ? _erase(object,time) : null;
			if (op != null)
				_currentOperation.addOperation(
					new KInteractionOperation(_appState,time,time,null,null,op));
		}
		
		/**
		 * End the Erase interaction.
		 * If interactive log is enabled, record the cursor point on the log.
		 */
		public function end(point:Point):void
		{
			if(_log != null)
				_log.addPoint(new KPathPoint(point.x, point.y, _appState.time));
			_log = null;
			if (_currentOperation.length > 0)
				_appState.addOperation(_currentOperation);
		}
		
		/**
		 * Enable interactive log.
		 * @return interactive log. 
		 */
		public function enableLog():ILoggable
		{
			_log = new KInteractiveLog(new Vector.<KPathPoint>(), 
				KPlaySketchLogger.INTERACTION_ERASE);
			return _log;
		}
		
		private function _inverseEventCoordinate(p:Point):Point
		{			
			var pt:Point = new Point();
			pt.x = p.x*_canvas.contentScale + _canvas.mouseOffsetX;
			pt.y = p.y*_canvas.contentScale + _canvas.mouseOffsetY;
			return pt;
		}
		
		private function _erase(object:KObject,time:Number):IModelOperation
		{
			return _facade.erase(object,time);
		}
	}
}