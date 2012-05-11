/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.interactor
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch.logger.KLogger;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.model.KStroke;
	import sg.edu.smu.ksketch.model.geom.KTranslation;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	import sg.edu.smu.ksketch.operation.KModelFacade;
	import sg.edu.smu.ksketch.operation.KUngroupUtil;
	import sg.edu.smu.ksketch.operation.implementations.KCompositeOperation;
	import sg.edu.smu.ksketch.operation.implementations.KInteractionOperation;
	import sg.edu.smu.ksketch.utilities.IIterator;
	import sg.edu.smu.ksketch.utilities.KAppState;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;
	
	/**
	 * Subclass of KTransitionInteractor that handles translation 
	 * function (addToPosition) invocation in DefaultKModelFacade.
	 */
	public class KTranslateInteractor extends KTransitionInteractor
	{
		private var _startPoint:Point;
		private var _dxdy:Point;
		
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
			return KLogger.INTERACTION_TRANSLATE;
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
		
		private function _beginTranslation(canvasPoint:Point):void
		{
			_startPoint = canvasPoint.clone();
		}
		
		private function _addToTranslation(canvasPoint:Point):void
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
		
		protected override function performGroupingOp(objects:KModelObjectList):IModelOperation
		{
			var length:int = objects.length();
			var zerothObj:KObject = objects.getObjectAt(0);
			var needGroup:Boolean = isImplicitGrouping() && length > 1;
			var needUngroup:Boolean = isImplicitGrouping() && length == 1 && 
				zerothObj is KStroke && zerothObj.getParent(_appState.time) != _facade.root;
			var ops:KCompositeOperation = new KCompositeOperation();
			var unGpOp:IModelOperation;
			var gpOp:IModelOperation;
			if (needUngroup)
				unGpOp = _facade.ungroup(objects);
			else if (needGroup)
			{
				unGpOp = _facade.ungroup(objects);
				gpOp = _facade.group(objects);
			}
			if (unGpOp != null)		
				ops.addOperation(unGpOp);
			if (gpOp != null)		
				ops.addOperation(gpOp);
			return ops.length == 0 ? null : ops;
		}
	}
}
