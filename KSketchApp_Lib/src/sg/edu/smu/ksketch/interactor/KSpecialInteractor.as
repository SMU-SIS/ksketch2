/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.interactor
{
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch.model.geom.KPathPoint;
	import sg.edu.smu.ksketch.logger.ILoggable;
	import sg.edu.smu.ksketch.logger.KLogger;
	import sg.edu.smu.ksketch.logger.KInteractiveLog;
	import sg.edu.smu.ksketch.logger.KPlaySketchLogger;
	import sg.edu.smu.ksketch.logger.KWithSelectionLog;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	import sg.edu.smu.ksketch.utilities.KAppState;
	
	/**
	 * Handles special case interactions that are too simple to require a separate class
	 * (E.g. Deselection and hiding popups).
	 */
	public class KSpecialInteractor implements IInteractor
	{
		public static const MODE_DESELECT:String = "DESELECT";
		public static const MODE_HIDE_POPUP:String = "NOTHING";
		
		private var _appState:KAppState;
		
		private var _log:KInteractiveLog;
		
		private var _mode:String;
		
		public function KSpecialInteractor(appState:KAppState)
		{
			_appState = appState;
		}
		
		public function set mode(value:String):void
		{
			_mode = value;
		}
		
		public function get mode():String
		{
			return _mode;
		}

		public function enableLog():ILoggable
		{
			switch(_mode)
			{
				case MODE_DESELECT:
					_log = new KWithSelectionLog(new Vector.<KPathPoint>(), 
						KPlaySketchLogger.INTERACTION_DESELECT, _appState.selection.objects);
					break;
				case MODE_HIDE_POPUP:
					_log = new KInteractiveLog(new Vector.<KPathPoint>(), KPlaySketchLogger.INTERACTION_HIDE_POPUP);
					break;
				default:
					throw new Error("invalid mode: "+_mode);
			}
			return _log;
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
			
			if(_mode == MODE_DESELECT)
			{
				if(_log != null)
				{
					KLogger.logDeselect(_appState.selection.objects.toIDs());
					(_log as KWithSelectionLog).selected = _appState.selection.objects;
				}
				_appState.selection = null;
			}
		}
		
		public function update(point:Point):void
		{
			if(_log != null)
				_log.addPoint(new KPathPoint(point.x, point.y, _appState.time));
		}
		
		public function end(point:Point):void
		{
			if(_log != null)
			{
				_log.addPoint(new KPathPoint(point.x, point.y, _appState.time));
				_log = null;
			}
		}
	}
}