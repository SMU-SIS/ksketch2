/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.interactor
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch.model.geom.KPathPoint;
	import sg.edu.smu.ksketch.gestures.GestureDefs;
	import sg.edu.smu.ksketch.gestures.Library;
	import sg.edu.smu.ksketch.gestures.Recognizer;
	import sg.edu.smu.ksketch.logger.ILoggable;
	import sg.edu.smu.ksketch.logger.KDragCenterLog;
	import sg.edu.smu.ksketch.logger.KInteractiveLog;
	import sg.edu.smu.ksketch.logger.KLogger;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	import sg.edu.smu.ksketch.utilities.KAppState;

	public class KDragCenterInteractor extends EventDispatcher implements IComplexInteractor
	{
		public static const EVENT_TAP_RECOGNIZED:String = "TAP_RECOGNIZED";
		public static const EVENT_TAP_NOT_RECOGNIZED:String = "TAP_NOT_RECOGNIZED";
		
		private var _points:Vector.<Point>;
		
		private var _translateInteractor:KTranslateInteractor;
		
		private var _appState:KAppState;
		private var _oldOffset:Point;
		
		private var _log:KDragCenterLog;
		
		public function KDragCenterInteractor(appState:KAppState, translateInteractor:KTranslateInteractor)
		{
			super();
			_appState = appState;
			_translateInteractor = translateInteractor;
		}
		public function activate():void
		{
			
		}
		
		public function deactivate():void
		{
			
		}
		
		public function begin(point:Point):void
		{
			if(_log != null)
				_log.addPoint(new KPathPoint(point.x, point.y, _appState.time));
			
			_oldOffset = _appState.userSetCenterOffset;
			//decorated.begin(point);
			_points = new Vector.<Point>();
			_points.push(point);
		}
		
		public function update(point:Point):void
		{
			if(_log != null)
				_log.addPoint(new KPathPoint(point.x, point.y, _appState.time));
			
			//decorated.update(point);
			_points.push(point);
		}
		
		public function end(point:Point):void
		{
//			var operation:IModelOperation = decorated.end(point);
			//decorated.end(point);
			_points.push(point);
			
			// if is tap
			var isTap:Boolean = Recognizer.isTap(_points);
			if(isTap)
			{
//				if(operation != null)
//					operation.undo();
//				operation = null;
				_appState.userSetCenterOffset = _oldOffset;
				dispatchEvent(new Event(EVENT_TAP_RECOGNIZED));
			}
			else
				dispatchEvent(new Event(EVENT_TAP_NOT_RECOGNIZED));
			
			_points = null;
			_oldOffset = null;
			
			if(_log != null)
			{
				_log.addPoint(new KPathPoint(point.x, point.y, _appState.time));
				_log.isTap = isTap;
				_log = null;
			}
			
		//	return operation;
		}
		
		public function get decorated():IInteractor
		{
			return _translateInteractor;
		}
		
		public function get name():String
		{
			return KLogger.INTERACTION_DRAG_CENTER;
		}
		public function enableLog():ILoggable
		{
			_log = new KDragCenterLog(new Vector.<KPathPoint>());
			return _log;
		}
	}
}