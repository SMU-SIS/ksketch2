/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.interactor
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import mx.core.Container;
	
	import sg.edu.smu.ksketch.components.KCanvas;
	import sg.edu.smu.ksketch.components.KFilteredLoopView;
	import sg.edu.smu.ksketch.logger.KPlaySketchLogger;
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.model.KImage;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.model.KStroke;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	import sg.edu.smu.ksketch.operation.KModelFacade;
	import sg.edu.smu.ksketch.utilities.IIterator;
	import sg.edu.smu.ksketch.utilities.KAppState;
	import sg.edu.smu.ksketch.utilities.KMathUtil;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;
	
	import spark.components.BorderContainer;
	
	public class KLoopSelectInteractor extends KSelectInteractor
	{
		public static const MODE:String = "INTEL";
		
		private static const RADIUS:Number = 1;
		private static const COLOR:uint = 0xf38400;
		
		private static const THRESHOLD_DISTANCE:int = 10;
		
		private var _facade:KModelFacade;
		
		private var _loopStart:Point;
		private var _secondToLast:Point;
		private var _loopEnd:Point;
		
		private var _lastChecked:int;
		private var _all:ByteArray;
		private var _last:ByteArray;
		
		private var _portions:Dictionary;
		
		private var _loopView:KFilteredLoopView;
		
		private var _arbiter:ISelectionArbiter;
		
		public function KLoopSelectInteractor(facade:KModelFacade, appState:KAppState, canvas:KCanvas, arbiter:ISelectionArbiter = null)
		{
			super(canvas, appState);
			
			_facade = facade;
			_appState = appState;
			
			_arbiter = arbiter;
			if(_arbiter == null)
				_arbiter = new KSimpleArbiter(facade.root);
			
			_loopView = new KFilteredLoopView();
			
			_lastChecked = -1;
			_all = new ByteArray();
			_last = new ByteArray();
		}
		
		public function set arbiter(value:ISelectionArbiter):void
		{
			_arbiter = value;
		}

		public function get portions():Dictionary
		{
			return _portions;
		}
		
		protected override function get areaShape():DisplayObject
		{
			return _loopView;
		}
		
		public override function begin(point:Point):void
		{
			updateLog(point);
			_appState.selection = null;
			_portions = new Dictionary();
			
			_loopEnd = point;
			_loopStart = point;
			_secondToLast = point;
			
			_loopView.add(point);
		}
		
		public override function end(point:Point):void
		{
			update(point);
			
			_appState.selection = _appState.selection;
			
			_loopEnd = null;
			_loopStart = null;
			_secondToLast = null;
			
			_lastChecked = -1;
			_all = new ByteArray();
			_last = new ByteArray();
			
			_loopView.clear();
			
			_portions = null;
			
			endLog();
		}
		
		public override function update(point:Point):void
		{
			updateLog(point);
			_lastChecked = -1;
			
			var p:Point = _loopView.add(point);
			
			if(p == null)
				return;
			
			_secondToLast = _loopEnd;
			_loopEnd = p;
			
			checkAllObjects();
			
			var selection:KModelObjectList;
			
			if(_appState.groupSelectMode == KAppState.SELECTION_GROUP)
			{
				//Select top level group only for group selection mode
				if(_arbiter is KSimpleArbiter)
				{
					selection = (_arbiter as KSimpleArbiter).selectTopGroups(_portions, _appState.time);
				}
			}
			else if(_appState.groupSelectMode == KAppState.SELECTION_GROUP_AND_STROKE)
			{
				selection = _arbiter.bestGuess(_portions, _appState.time);
			}
			else if(_appState.groupSelectMode == KAppState.SELECTION_STROKE)
			{
				//Select top level group only for group selection mode
				if(_arbiter is KSimpleArbiter)
				{
					selection = (_arbiter as KSimpleArbiter).selectStrokes(_portions, _appState.time);
				}
			}
			
			if(selection == null || selection.length() == 0)
				_appState.interactingSelection = null;
			else
			{
				_appState.interactingSelection = new KSelection(selection, _appState.time);
				_appState._fireFacadeUndoRedoModelChangedEvent();
			}
		}
		
		private function checkAllObjects():void
		{
			var it:IIterator = _facade.root.allChildrenIterator(_appState.time);
			var object:KObject;
			var selectedPnts:uint;
			var totalPnts:uint;
			while(it.hasNext())
			{
				object = it.next();
				selectedPnts = hitTest(object, _appState.time);
				totalPnts = testPointsCount(object);
				
				if(selectedPnts > 0)
					_portions[object] = new KPortion(totalPnts, selectedPnts);
				else if(_portions[object] != null)
					delete _portions[object];
			}
		}
		
		private function hitTest(target:KObject, kskTime:Number):uint
		{
			if(target is KStroke)
				return updateByteArray(scaledBoundingBox(target), target.getFullPathMatrix(kskTime), _loopStart, _secondToLast, _loopEnd);
			else if (target is KImage)
			{
				var imagePoints:Vector.<Point> = new Vector.<Point>();
				imagePoints.push(target.defaultCenter);
				/*var bounds:Rectangle = (target as KImage).image.rect;
				imagePoints.push(new Point(bounds.x,bounds.y));
				imagePoints.push(new Point(bounds.x,bounds.bottom));
				imagePoints.push(new Point(bounds.right,bounds.y));
				imagePoints.push(new Point(bounds.right,bounds.bottom));*/
				return updateByteArray(imagePoints, target.getFullPathMatrix(kskTime), _loopStart, _secondToLast, _loopEnd);
			}
			else throw new Error("not supported kobject!");
		}
		
		private function updateByteArray(points:Vector.<Point>, transform:Matrix, startPoint:Point, oldEnd:Point, newEnd:Point):uint
		{
			var i:int = 0, j:int;
			var check:int;
			var newLast:int, newAll:int;
			var insideCount:uint;
			var p:Point;
			var pnts:int = points.length;
			var arrayLength:int = _all.length;
			while( i < pnts)
			{
				_lastChecked ++;
				check = 1;
				newLast = 0;
				if(_lastChecked < arrayLength)
					newAll = _all[_lastChecked] ^ _last[_lastChecked];
				else
					newAll = 0;
				for(j = 0; j < 8; j++, i++)
				{
					if(i > pnts - 1)
						break;
					p = transform.transformPoint(points[i]);
					if(KMathUtil.hasIntersection(p, startPoint, newEnd))
					{
						newLast ^= check;
						newAll ^= check;
					}
					if(KMathUtil.hasIntersection(p, oldEnd, newEnd))
						newAll ^= check;
					
					if((newAll & check) != 0)
						insideCount ++ ;
					
					check <<= 1;
				}
				_all[_lastChecked] = newAll;
				_last[_lastChecked] = newLast;
			}
			return insideCount;
		}
		public override function get name():String
		{
			return KPlaySketchLogger.INTERACTION_SELECT_LOOP;
		}
		
	}
}