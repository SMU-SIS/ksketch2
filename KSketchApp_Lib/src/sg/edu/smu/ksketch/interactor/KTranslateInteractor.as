package sg.edu.smu.ksketch.interactor
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch.logger.KPlaySketchLogger;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.model.geom.KTranslation;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	import sg.edu.smu.ksketch.operation.KModelFacade;
	import sg.edu.smu.ksketch.operation.implementations.KCompositeOperation;
	import sg.edu.smu.ksketch.utilities.IIterator;
	import sg.edu.smu.ksketch.utilities.KAppState;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;
	
	/**
	 * Subclass of KTransitionInteractor that handles translation 
	 * function (addToPosition) invocation in DefaultKModelFacade.
	 */
	public class KTranslateInteractor extends KTransitionInteractor
	{
		protected var _startPoint:Point;
		protected var _dxdy:Point;
		
		/**
		 * Subclass constructor to initialise KModelFacade and KAppState for KTransitionInteractor.
		 * @param facade DefaultKModelFacade object to manipulate objects. 
		 * @param appState KAppState object to store and track the operation state. 
		 */   
		public function KTranslateInteractor(facade:KModelFacade, appState:KAppState)
		{
			super(facade, appState);
		}
		
		/**
		 * Name of the interaction. Return "translate".
		 */
		public override function get name():String
		{
			return KPlaySketchLogger.INTERACTION_TRANSLATE;
		}
		
		/**
		 * Returns the current displacement as a point.
		 * Returns (0,0) if there is no ongoing translation
		 */
		public function get interactionDisplacement():Point
		{
			if(!_dxdy)
				return new Point();
			
			return _dxdy.clone();
		}
		
		/**
		 * transitionStart initiates the transition operation.
		 */
		protected override function transitionStart(canvasPoint:Point, 
													transitionType:int):IModelOperation
		{
			var op:IModelOperation = performGroupingOp(selection().objects);
			var it:IIterator = selection().objects.iterator;
			
			//Call the begin translation
			_beginTranslation(canvasPoint);
			
			while (it.hasNext())
				_facade.beginTranslation(it.next(), _appState.time, transitionType);
			
			_addToTranslation(canvasPoint);
			return op;
		}
		
		protected override function transitionUpdate(canvasPoint:Point):void
		{
			_addToTranslation(canvasPoint);
		}
		
		protected override function transitionEnd(canvasPoint:Point):IModelOperation
		{
			_addToTranslation(canvasPoint);
			var op:KCompositeOperation = new KCompositeOperation();
			var it:IIterator = selection().objects.iterator;
			while (it.hasNext())
				op.addOperation(_facade.endTranslation(it.next(), _appState.time));
			return op.length > 0 ? op : null;
		}
		
		protected function _beginTranslation(canvasPoint:Point):void
		{
			_startPoint = canvasPoint.clone();
		}
		
		protected function _addToTranslation(canvasPoint:Point):void
		{
			_dxdy = KTranslation.computeTranslate(_startPoint, canvasPoint)
			
			var it:IIterator = selection().objects.iterator;
			while (it.hasNext())
			{
				var obj:KObject = it.next();
				var m:Matrix = obj.getFullPathMatrix(_appState.time);
				var objCenter:Point = m.transformPoint(obj.defaultCenter);
				_facade.addToTranslation(obj, _dxdy.x, _dxdy.y,_appState.time, canvasPoint);
			}
		}
		
		/**
		 * Places all selected objects (including strokes inside groups) into the root
		 * If number of selected objects > 1, form a new group with the selected objects under the root
		 */
		protected override function performGroupingOp(objects:KModelObjectList):IModelOperation
		{
			var mode:String = _appState.groupingMode;
			var type:int = _appState.transitionType;
			var time:Number = _appState.time;
			var length:int = objects.length();
			var zerothObj:KObject = objects.getObjectAt(0);
			var needGroup:Boolean = isImplicitGrouping() && length > 1;
			var needUngroup:Boolean = isImplicitGrouping() && length == 1 &&
				zerothObj.getParent(_appState.time) != _facade.root;

			if (needUngroup)
				return _facade.ungroup(objects,mode,time);
			else if (needGroup)
			{
				var realtimeTransition:Boolean = _transitionType == KAppState.TRANSITION_REALTIME;
				return _facade.regroup(objects, mode, type,time, realtimeTransition);
			}
			else
				return null;
		}
	}
}
