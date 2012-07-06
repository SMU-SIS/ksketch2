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
	 * Subclass of KTransitionInteractor that handles rotation 
	 * function (addToRotation) invocation in DefaultKModelFacade.
	 */
	public class KRotateInteractor extends KTransitionInteractor
	{
		protected var _ghost:KGhostMarker;
		protected var _previousPoint:Point;
		protected var _currentAngle:Number;
		protected var _activeCenter:Point
		protected var _offsetCopy:Point;
		
		/**
		 * Subclass constructor to initialise KModelFacade and KAppState for KTransitionInteractor.
		 * @param facade DefaultKModelFacade object to manipulate objects. 
		 * @param appState KAppState object to store and track the operation state. 
		 */	
		public function KRotateInteractor(facade:KModelFacade, appState:KAppState, 
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
		 * Name of the interaction. Return "rotate".
		 */
		public override function get name():String
		{
			return KPlaySketchLogger.INTERACTION_ROTATE;
		}            
		
		protected override function transitionStart(canvasPoint:Point, 
													transitionType:int):IModelOperation
		{
			var obj:KObject;
			var time:Number = _appState.time;
			_activeCenter = center(_appState);
			var op:IModelOperation = performGroupingOp(selection().objects);
			
			if(_appState.userSetCenterOffset)
				_offsetCopy = _appState.userSetCenterOffset.clone();
			else
				_offsetCopy = new Point();
			
			_appState.userSetCenterOffset = null;
			
			if(selection().objects.length() < 2)
			{
				obj = selection().objects.getObjectAt(0);
				_beginRotation(obj, _activeCenter.clone(), time, transitionType, canvasPoint);
				selection().interactionCenter = _activeCenter.clone();
			}
			else
			{
				var it:IIterator = selection().objects.iterator;
				while (it.hasNext())
				{
					obj = it.next();
					var matrix:Matrix = obj.getFullPathMatrix(time);
					var objCenter:Point = matrix.transformPoint(obj.defaultCenter);
					_beginRotation(obj, objCenter, time, transitionType,canvasPoint);
				}
			}
			_addToRotation(canvasPoint);
			return op;
		}
		
		protected override function transitionUpdate(canvasPoint:Point):void
		{
			_addToRotation(canvasPoint);
		}
		
		protected override function transitionEnd(canvasPoint:Point):IModelOperation
		{
			_addToRotation(canvasPoint);
			selection().interactionCenter = null;
			var op:KCompositeOperation = new KCompositeOperation();
			var it:IIterator = selection().objects.iterator;
			
			while (it.hasNext())
			{
				var obj:KObject = it.next();
				op.addOperation(_facade.endRotation(obj, _appState.time));
				KLogger.logEndRotation(_appState.time);
				_ghost.remove(obj);
			}		
			
			return op.length > 0 ? op : null;
		}
		
		protected function _beginRotation(object:KObject, center:Point, time:Number,
										transitionType:int, canvasPoint:Point):void
		{
			_ghost.add(object, center, time);

			_facade.beginRotation(object, center, time, transitionType);
			KLogger.logBeginRotation(object.id,center,time,transitionType);

			_previousPoint = canvasPoint.clone().subtract(center);
			_currentAngle = 0;
		}
		
		protected function _addToRotation(canvasPoint:Point):void
		{
			var defaultOffset:Point = new Point();
			var length:int = selection().objects.length();
			var it:IIterator = selection().objects.iterator;
			
			var currentPoint:Point = canvasPoint.subtract(_activeCenter.clone());
			var angle:Number = Math.min(KMathUtil.angleOf(_previousPoint,currentPoint),
				KMathUtil.angleOf(currentPoint,_previousPoint));
			var direction:int = KMathUtil.segcross(_previousPoint, currentPoint, _previousPoint);
			
			if(direction <0)
				angle *= -1;
			
			_currentAngle += angle;
			
			while (it.hasNext())
			{
				var obj:KObject = it.next();
				var m:Matrix = obj.getFullPathMatrix(_appState.time);
				var objCenter:Point = m.transformPoint(obj.defaultCenter);
				var dydx:Point = length == 1 ? defaultOffset : objCenter.subtract(_activeCenter.clone());
				var cursorPoint:Point = canvasPoint.add(dydx);

				_facade.addToRotation(obj, _currentAngle, cursorPoint, _appState.time);
				KLogger.logAddToRotation(_currentAngle,cursorPoint,_appState.time);

				_ghost.update(obj,_appState.time);
			}
			
			_previousPoint = currentPoint.clone();			
		}
	}
}