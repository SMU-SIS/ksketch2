/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.interactor
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import sg.edu.smu.ksketch.logger.KLogger;
	import sg.edu.smu.ksketch.logger.KPlaySketchLogger;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	import sg.edu.smu.ksketch.operation.KModelFacade;
	import sg.edu.smu.ksketch.operation.implementations.KCompositeOperation;
	import sg.edu.smu.ksketch.operation.implementations.KInteractionOperation;
	import sg.edu.smu.ksketch.utilities.IIterator;
	import sg.edu.smu.ksketch.utilities.KAppState;
	import sg.edu.smu.ksketch.utilities.KMathUtil;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;
	
	/**
	 * Subclass of KTransitionInteractor that handles scale 
	 * function (addToScale) invocation in DefaultKModelFacade.
	 */
	public class KScaleInteractor extends KTransitionInteractor
	{
		protected var _ghost:KGhostMarker;
		protected var _startPoint:Point;
		protected var _currentScale:Number;
		protected var _activeCenter:Point;
		protected var _scaleDenominator:Number;
		
		/**
		 * Subclass constructor to initialise KModelFacade and KAppState for KTransitionInteractor.
		 * @param facade DefaultKModelFacade object to manipulate objects. 
		 * @param appState KAppState object to store and track the operation state. 
		 */	
		public function KScaleInteractor(facade:KModelFacade, appState:KAppState, 
										 ghost:KGhostMarker)
		{
			super(facade, appState);
			_ghost = ghost;
		}
		
		/**
		 * Do nothing.
		 */
		public override function activate():void
		{
		}
		
		/**
		 * Do nothing.
		 */
		public override function deactivate():void
		{
		}
		
		/**
		 * Name of the interaction. Return "scale".
		 */
		public override function get name():String
		{
			return KPlaySketchLogger.INTERACTION_SCALE;
		}
		
		protected override function transitionStart(canvasPoint:Point, 
													transitionType:int):IModelOperation
		{
			var obj:KObject;
			var time:Number = _appState.time;
			_activeCenter = center(_appState);
			var op:IModelOperation = performGroupingOp(selection().objects);
			_appState.userSetCenterOffset = null;
			
			if(selection().objects.length() < 2)
			{
				obj = selection().objects.getObjectAt(0);
				selection().interactionCenter = _activeCenter.clone();
				_beginScale(obj, _activeCenter.clone(), _appState.time, transitionType, canvasPoint);
			}
			else
			{
				var it:IIterator = selection().objects.iterator;
				while (it.hasNext())
				{
					obj = it.next();
					var matrix:Matrix = obj.getFullPathMatrix(_appState.time);
					var objCenter:Point = matrix.transformPoint(obj.defaultCenter);
					_beginScale(obj, objCenter, _appState.time, transitionType, canvasPoint);
				}
			}
			_addToScale(canvasPoint);
			return op;
		}
		
		protected override function transitionUpdate(canvasPoint:Point):void
		{
			_addToScale(canvasPoint);
		}
		
		protected override function transitionEnd(canvasPoint:Point):IModelOperation
		{
			_addToScale(canvasPoint);
			selection().interactionCenter = null;
			var op:KCompositeOperation = new KCompositeOperation();
			var it:IIterator = selection().objects.iterator;
			while (it.hasNext())
			{
				var obj:KObject = it.next();

				op.addOperation(_facade.endScale(obj, _appState.time));
				KLogger.logEndScale(_appState.time);

				_ghost.remove(obj);
			}
			_appState.userSetCenterOffset = null;
			return op.length > 0 ? op : null;
		}
		
		protected function _beginScale(object:KObject, center:Point, time:Number,
									 transitionType:int, canvasPoint:Point):void
		{
			_ghost.add(object, center, time);

			_facade.beginScale(object, center, time, transitionType);
			KLogger.logBeginScale(object.id,center,time,transitionType);

			_startPoint = canvasPoint.clone();
			_currentScale = 1;
			_scaleDenominator = KMathUtil.distanceOf(_activeCenter, _startPoint);
		}
		
		protected function _addToScale(canvasPoint:Point):void
		{
			var defaultOffset:Point = new Point();
			var length:int = selection().objects.length();
			var it:IIterator = selection().objects.iterator;
		
			var scaleNumerator:Number = KMathUtil.distanceOf(_activeCenter, canvasPoint);
			var scale:Number = (scaleNumerator/_scaleDenominator) - 1;
			
			while (it.hasNext())
			{
				var obj:KObject = it.next();
				var m:Matrix = obj.getFullPathMatrix(_appState.time);
				var objCenter:Point = m.transformPoint(obj.defaultCenter);
				var dydx:Point = length == 1 ? defaultOffset : objCenter.subtract(_activeCenter.clone());
				var cursorPoint:Point = canvasPoint.add(dydx);
				
				_facade.addToScale(obj, scale, cursorPoint, _appState.time);
				KLogger.logAddToScale(scale, cursorPoint, _appState.time);

				_ghost.update(obj,_appState.time);
			}
		}
	}
}