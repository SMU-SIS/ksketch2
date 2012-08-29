package sg.edu.smu.ksketch.interactor
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch.components.KCanvas;
	import sg.edu.smu.ksketch.model.geom.KPathPoint;
	import sg.edu.smu.ksketch.logger.ILoggable;
	import sg.edu.smu.ksketch.logger.KInteractiveLog;
	import sg.edu.smu.ksketch.logger.KPlaySketchLogger;
//	import sg.edu.smu.ksketch.model.KKeyframe;
	import sg.edu.smu.ksketch.model.IKeyFrame;
	import sg.edu.smu.ksketch.model.KObject;
//	import sg.edu.smu.ksketch.model.KRotationKeyframe;
//	import sg.edu.smu.ksketch.model.KScaleKeyframe;
//	import sg.edu.smu.ksketch.model.KSpatialKeyframe;
	import sg.edu.smu.ksketch.model.ISpatialKeyframe;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	import sg.edu.smu.ksketch.operation.KModelFacade;
	import sg.edu.smu.ksketch.utilities.KAppState;
	
	/**
	 * Class that handles changing the motion path by offsetting the path center.
	 */
	public class KPathCenterInteractor implements IInteractor
	{
		private var _startPoint:Point;
		private var _object:KObject;
		private var _keyframe:ISpatialKeyframe;
		private var _facade:KModelFacade;
		private var _appState:KAppState;
		private var _log:KInteractiveLog;
		
		/**
		 * Constructor to initialise KModelFacade and KAppState.
		 * @param facade KModelFacade object to manipulate objects. 
		 * @param appState KAppState object to store and track the operation state. 
		 * @param canvas KAppState object to obtain the cursor point.
		 */	
		public function KPathCenterInteractor(facade:KModelFacade, appState:KAppState)
		{
			_facade = facade;
			_appState = appState;			
		}
		
		public function get object():KObject
		{
			return _object;
		}
		
		public function set object(object:KObject):void
		{
			_object = object;
		}
		
		public function get keyframe():ISpatialKeyframe
		{
			return _keyframe;
		}
		
		public function set keyframe(key:ISpatialKeyframe):void
		{
			_keyframe = key;
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
		
		public function begin(point:Point):void
		{		
			if(_log != null)
				_log.addPoint(new KPathPoint(point.x, point.y, _appState.time));			
//			_facade.beginTransition();
			_startPoint = point;
			var vector:Point = point.subtract(_startPoint);
			_offsetKPath(vector);
		}
		
		public function update(point:Point):void
		{
			if(_log != null)
				_log.addPoint(new KPathPoint(point.x, point.y, _appState.time));
			var vector:Point = point.subtract(_startPoint);
			_offsetKPath(vector);
		}
		
		public function end(point:Point):void
		{
			if(_log != null)
			{
				_log.addPoint(new KPathPoint(point.x, point.y, _appState.time));
				_log = null;
			}
			var vector:Point = point.subtract(_startPoint);
			_offsetKPath(vector);
//			_facade.endTransition();
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

		private function _offsetKPath(vector:Point):void
		{
			/*				
			if (KAppState.isMultiCenterMode() || KAppState.isRefactorCenterMode())
				_facade.offsetKPath(_object,_keyframe,vector,_appState.time);
			else if (KAppState.isOneCenterMode())
			{
		//		_facade.offsetKPath(_object,_keyframe,vector,_appState.time);
				var keytimes:Vector.<int> = _object.timeline.getKeys();
				for (var i:int=0; i < keytimes.length; i++)
				{
					var key:KKeyframe = _object.timeline.getKeyframeAt(
						keytimes[i],KRotationKeyframe.KEYFRAME_ROTATION);
					if (key != null)
						_facade.offsetKPath(_object,key as KSpatialKeyframe,vector,_appState.time);					
					key = _object.timeline.getKeyframeAt(keytimes[i],KScaleKeyframe.KEYFRAME_SCALE);
					if (key != null)
						_facade.offsetKPath(_object,key as KSpatialKeyframe,vector,_appState.time);
				}
			}
			*/				
		}
	}
}