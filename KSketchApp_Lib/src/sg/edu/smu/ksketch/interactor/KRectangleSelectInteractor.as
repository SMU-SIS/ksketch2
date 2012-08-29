package sg.edu.smu.ksketch.interactor
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.Container;
	
	import sg.edu.smu.ksketch.components.KCanvas;
	import sg.edu.smu.ksketch.logger.KLogger;
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.model.KStroke;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	import sg.edu.smu.ksketch.operation.KModelFacade;
	import sg.edu.smu.ksketch.utilities.IIterator;
	import sg.edu.smu.ksketch.utilities.KAppState;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;
	
	public class KRectangleSelectInteractor extends KSelectInteractor
	{
		public static const MODE:String = "RECT";
		
		private static const THICKNESS:Number = 2;
		private static const COLOR:uint = 0xf38400;
		
		private var _facade:KModelFacade;
		
		private var _startPoint:Point;
		private var _selectArea:Rectangle;
		
		private var _areaShape:Shape;
		
		public function KRectangleSelectInteractor(facade:KModelFacade, appState:KAppState, canvas:KCanvas)
		{
			super(canvas, appState);
			
			_facade = facade;
			_appState = appState;
			
			_areaShape = new Shape();
		}
		
		protected override function get areaShape():DisplayObject
		{
			return _areaShape;
		}
		
		public override function begin(point:Point):void
		{
			updateLog(point);
			_appState.selection = null;
			update(point);
		}
		
		public override function end(point:Point):void
		{
			update(point);
			
			_appState.selection = _appState.selection;
			
			_startPoint = null;
			_selectArea = null;
			
			_areaShape.graphics.clear();
			
			endLog();
		}
		
		public override function update(point:Point):void
		{
			updateLog(point);
			var areaChanged:Boolean = false;
			if(_startPoint == null)
			{
				_startPoint = new Point(point.x, point.y);
				_selectArea = new Rectangle(_startPoint.x, _startPoint.y, 0, 0);
				areaChanged = true;
			}
			else
			{
				var oldX:Number = _selectArea.x;
				var oldY:Number = _selectArea.y;
				var oldW:Number = _selectArea.width;
				var oldH:Number = _selectArea.height;
				_selectArea.x = point.x<_startPoint.x?point.x:_startPoint.x;
				_selectArea.y = point.y<_startPoint.y?point.y:_startPoint.y;
				_selectArea.width = Math.abs(point.x - _startPoint.x);
				_selectArea.height = Math.abs(point.y - _startPoint.y);
				if(_selectArea.width != oldW || _selectArea.height != oldH || _selectArea.x != oldX || _selectArea.y != oldY )
				{
					_areaShape.graphics.clear();
					_areaShape.graphics.lineStyle(THICKNESS, COLOR);
					_areaShape.graphics.drawRect(_selectArea.x, _selectArea.y, _selectArea.width, _selectArea.height);
					areaChanged = true;
				}
			}
			if(areaChanged)
			{
				var list:KModelObjectList = new KModelObjectList();
				updateSelection(_facade.root, list);
				if(list.length() > 0)
					_appState.interactingSelection = new KSelection(list, _appState.time);
			}
		}
		
		private function updateSelection(root:KGroup, addTo:KModelObjectList):void
		{
			var i:IIterator = root.directChildIterator(_appState.time);
			var obj:KObject;
			while(i.hasNext())
			{
				obj = i.next();
				if(hitTest(obj, _appState.time))
					addTo.add(obj);
				else if(obj is KGroup)
					updateSelection(obj as KGroup, addTo);
			}
		}
		
		private function hitTest(target:KObject, kskTime:Number):Boolean
		{
			var inside:Boolean = true;
			var matrix:Matrix;
			var transformedPoint:Point;
			if(target is KStroke)
			{
				var stroke:KStroke = target as KStroke;
				var points:Vector.<Point> = stroke.points;
				var length:int = points.length;
				matrix= stroke.getFullPathMatrix(kskTime);
				for (var j:int = 0;j<length;j++)
				{
					transformedPoint = matrix.transformPoint(points[j]);
					if(transformedPoint.x > _selectArea.x + _selectArea.width
						|| transformedPoint.x < _selectArea.x
						|| transformedPoint.y > _selectArea.y + _selectArea.height
						|| transformedPoint.y < _selectArea.y)
					{
						inside = false;
						break;
					}
				}
			}
			else if(target is KGroup)
			{
				inside = true;
				var i:IIterator = (target as KGroup).allChildrenIterator(kskTime);
				while(i.hasNext())
				{
					inside = hitTest(i.next(), kskTime) > 0;
					if(!inside)
						break;
				}
			}
			else throw new Error("not supported kobject!"); 
			return inside;
		}
		
		public override function get name():String
		{
		//	return KLogger.INTERACTION_SELECT_RECT;
			return "";
		}
	}
}