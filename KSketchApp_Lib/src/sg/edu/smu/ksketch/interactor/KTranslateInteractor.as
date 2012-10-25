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
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch.logger.KPlaySketchLogger;
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.model.geom.KTranslation;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	import sg.edu.smu.ksketch.operation.KGroupUtil;
	import sg.edu.smu.ksketch.operation.KModelFacade;
	import sg.edu.smu.ksketch.operation.implementations.KCompositeOperation;
	import sg.edu.smu.ksketch.utilities.IIterator;
	import sg.edu.smu.ksketch.utilities.IModelObjectList;
	import sg.edu.smu.ksketch.utilities.KAppState;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;
	
	/**
	 * Subclass of KTransitionInteractor that handles translation 
	 * function (addToPosition) invocation in DefaultKModelFacade.
	 */
	public class KTranslateInteractor extends KTransitionInteractor
	{
		public static const BREAK_OUT:Boolean = true;
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
			var thisSelection:KSelection = selection();
			var op:IModelOperation = performGroupingOp(selection().objects);
			var thatSelection:KSelection = selection();
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
				_facade.addToTranslation(obj, _dxdy.x, _dxdy.y,_appState.time, canvasPoint);
			}
		}
		
		/**
		 * Places all selected objects (including strokes inside groups) into the root
		 * If number of selected objects > 1, form a new group with the selected objects under the root
		 */
		protected override function performGroupingOp(objects:IModelObjectList):IModelOperation
		{
			if(_appState.groupingMode != KAppState.GROUPING_IMPLICIT_STATIC)
				return null;
			
			var groupOp:KCompositeOperation = new KCompositeOperation();
			var groupedObjects:IModelObjectList = _facade.group(objects,_appState.time, BREAK_OUT, groupOp);
			_appState.selection = new KSelection(groupedObjects, _appState.time);
			
			if(groupOp.length > 1)
				return groupOp;
			else
				return null;
		}
	}
}
