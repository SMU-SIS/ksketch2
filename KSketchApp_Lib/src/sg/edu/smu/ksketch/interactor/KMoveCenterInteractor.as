/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.interactor
{
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.html.script.Package;
	
	import mx.core.Container;
	
	import sg.edu.smu.ksketch.components.IWidget;
	import sg.edu.smu.ksketch.components.KCanvas;
	import sg.edu.smu.ksketch.logger.ILoggable;
	import sg.edu.smu.ksketch.logger.KPlaySketchLogger;
	import sg.edu.smu.ksketch.logger.KWithSelectionLog;
	import sg.edu.smu.ksketch.model.ISpatialKeyframe;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.model.geom.KPathPoint;
	import sg.edu.smu.ksketch.model.implementations.KSpatialKeyFrame;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	import sg.edu.smu.ksketch.operation.KModelFacade;
	import sg.edu.smu.ksketch.operation.KTransformMgr;
	import sg.edu.smu.ksketch.utilities.KAppState;
	import sg.edu.smu.ksketch.utilities.KMathUtil;
	
	import spark.primitives.Graphic;

	public class KMoveCenterInteractor implements IInteractor
	{
		private const SNAP_DISTANCE:Number = 12.5;
		
		private var _appState:KAppState;
		
		private var _startPoint:Point;
		private var _oldOffset:Point;
		private var _defaultCenter:Point;
		private var _invert:Matrix;
		private var _original:Matrix;
		
		private var _widget:IWidget;
		private var _facade:KModelFacade;
		private var _log:KWithSelectionLog;
		
		private var _centers:Vector.<Point>;
		
		//variables to record the current position of the widget
		//Relative to the current selection's true center
		private var _currentCenter:Point;
		private var _widgetOffset:Point;
		
		//Canvas only here for debugging purposes
		public var canvas:KCanvas;
		
		// constructor
		
		public function KMoveCenterInteractor(appState:KAppState, widget:IWidget, facade:KModelFacade)
		{
			_appState = appState;
			_facade = facade;
			_widget = widget;
		}
		
		public function activate():void
		{
			_widget.isMovingCenter = true;
		}
		
		public function deactivate():void
		{
			_widget.isMovingCenter = false;
		}
		
		// override mouse event handlers of KInteractor
		
		public function begin(point:Point):void
		{
			//For one center mode and grouping explicit
			//return since center movement is not allowed
			if(_appState.groupingMode == KAppState.GROUPING_EXPLICIT_DYNAMIC)
			{
				if(_appState.selection.objects.length() > 1)
				{
					return;
				}				
			}
			
			if(_log != null)
			{
				_log.selected = _appState.selection.objects;
				_log.addPoint(new KPathPoint(point.x, point.y, _appState.time));
			}
			
			if(_appState.userSetCenterOffset)
				_oldOffset = _appState.userSetCenterOffset.clone();
			else
				_oldOffset = new Point();
			
			_appState.userSetCenterOffset = null;
			
			//If length of selected objects == 1
			//Selection can be worked on, find the selection's matrix
			//This matrix will be used to transform points later.
			if(_appState.selection.objects.length() == 1)
			{
				_original = _appState.selection.objects.getObjectAt(0).getFullPathMatrix(_appState.time); //original matrix correct
				_invert = _original.clone();
				_invert.invert();
			}
			else
			{
				_original = new Matrix();
				_invert = new Matrix();
			}
			
			_defaultCenter = _appState.selection.objects.getObjectAt(0).defaultCenter;
			_startPoint = point.clone();
			_widgetOffset = point.subtract(_startPoint);
			_prepareSnapToCenter();
			update(point);
		}
		
		public function update(point:Point):void
		{
			//For one center mode and grouping explicit
			//return since center movement is not allowed
			if(_appState.groupingMode == KAppState.GROUPING_EXPLICIT_DYNAMIC)
			{
				if(_appState.selection.objects.length() > 1)
				{
					return;
				}				
			}
			
			if(_log != null)
				_log.addPoint(new KPathPoint(point.x, point.y, _appState.time));
			
			_renderFadedPaths();
			
			var offset:Point = point.subtract(_startPoint);
			
			if(_oldOffset != null)
				offset = offset.add(_oldOffset);
			
			_appState.userSetCenterOffset = offset;
			
			var snapOffset:Point = _snapToCenter(_widget.center).subtract(_widget.center);
			_appState.userSetCenterOffset = offset.add(snapOffset);
		}
		
		public function end(point:Point):void
		{
			//For one center mode and grouping explicit
			//return since center movement is not allowed
			if(_appState.groupingMode == KAppState.GROUPING_EXPLICIT_DYNAMIC)
			{
				if(_appState.selection.objects.length() > 1)
				{
					return;
				}				
			}
			
			if(_log != null)
			{
				_log.addPoint(new KPathPoint(point.x, point.y, _appState.time));
				_log = null;
			}
			
			//var currentPoint:Point = _snapToCenter(_invert.transformPoint(_widget.center));
			var offset:Point = point.subtract(_startPoint);
			
			if(_oldOffset != null)
				offset = offset.add(_oldOffset);
			
			_appState.userSetCenterOffset = offset;
			canvas.gestureLayer.graphics.clear();
		}
		
		/**
		 * Function to prepare for snapping to some given centers
		 */
		private function _prepareSnapToCenter():void
		{
			//If the selected objects have not been grouped,
			//Ignore since the selection itself will not have a previous path
			//No points to snap to
			if(_appState.selection.objects.length() == 1)
			{
				var currentObject:KObject = _appState.selection.objects.getObjectAt(0);
				var rotateKey:ISpatialKeyframe = currentObject.getSpatialKey(_appState.time, KTransformMgr.ROTATION_REF);
				var scaleKey:ISpatialKeyframe = currentObject.getSpatialKey(_appState.time, KTransformMgr.SCALE_REF);
				var displayCenter:Point;
				_centers = new Vector.<Point>();
				
				canvas.gestureLayer.graphics.clear();
				if(rotateKey)
				{
					_centers.push(_original.transformPoint(rotateKey.center));
					displayCenter = _original.transformPoint(rotateKey.center);
					canvas.gestureLayer.graphics.lineStyle(1,0x00FF00);
					canvas.gestureLayer.graphics.drawCircle(displayCenter.x, displayCenter.y, 7.5);
				}
				
				if(scaleKey)
				{
					_centers.push(_original.transformPoint(scaleKey.center));
					displayCenter = _original.transformPoint(scaleKey.center);
					canvas.gestureLayer.graphics.lineStyle(1,0xFF0000);
					canvas.gestureLayer.graphics.drawCircle(displayCenter.x, displayCenter.y, 7.5);
				}
				
				_centers.push(_original.transformPoint(_defaultCenter));
				displayCenter = _original.transformPoint(_defaultCenter);
				canvas.gestureLayer.graphics.lineStyle(1,0x0000FF);
				canvas.gestureLayer.graphics.drawCircle(displayCenter.x, displayCenter.y, 7.5);
				
				displayCenter = displayCenter.add(_oldOffset);
				_centers.push(displayCenter);
				canvas.gestureLayer.graphics.lineStyle(1,0xFF00FF);
				canvas.gestureLayer.graphics.drawCircle(displayCenter.x, displayCenter.y, 7.5);
			}
		}
		
		/**
		 * Function to snap to a given set of center
		 */
		 private function _snapToCenter(currentCenter:Point):Point
		 {
			 if(_centers)
			 {
				var scores:Vector.<Number> = new Vector.<Number>();
				var distance:Number;
				
				for each(var targetCenter:Point in _centers)
				{
					distance = KMathUtil.distanceOf(currentCenter, targetCenter);
					scores.push(distance);					
				}
				
				if(scores.length < 1)
					return currentCenter;
				
				var lowestDistanceIndex:int = 0;

				for(var i:int = 0; i < scores.length; i++)
				{
					if(scores[i] < scores[lowestDistanceIndex])
						lowestDistanceIndex = i;
				}

				if(scores[lowestDistanceIndex] < SNAP_DISTANCE)
					return _centers[lowestDistanceIndex];
			 }

			 return currentCenter;
		 }
		 
		 //Renders washed out paths when move center mode is being activated
		 private function _renderFadedPaths():void
		 {
//			 canvas.gestureLayer.graphics.clear();
/*			
			 if(!((_appState.selection.objects.length() > 1)&&(_appState.selection.objects.length() != 0)))
			 {
				 var currentObject:KObject = _appState.selection.objects.getObjectAt(0);
				 var spatialKeys:KSpatialKeyframe = currentObject.timeline.getKeyframeAt(currentObject.createdTime, KPositionKeyframe.KEYFRAME_POSITION) as KSpatialKeyframe;
				 
				 var colour:uint;
				 
				 //Compile all available centers, including translation centers
				 while(spatialKeys != null)
				 {
					var center:Point;
					
					if(spatialKeys is KCenteredKeyframe)
						center = currentObject.getFullMatrix(spatialKeys.startTime).transformPoint((spatialKeys as KCenteredKeyframe).center.clone());
					else
						center = (currentObject.handleCenter(spatialKeys.startTime));
					
					//invoke path drawing algorithm
					drawCursorPath(spatialKeys.cursorPathClone, center, spatialKeys.type);
					
					spatialKeys = spatialKeys.next as KSpatialKeyframe;
				 } 
			 }
*/			 
		 }
		 
		 //This drawing function is similar to that of path view
		 //The only difference is that path view moves but the gesture layer stays put
		 //So we will have to transform the centers of the rotation and scale keys before rendering them out
		 private function drawCursorPath(points:Vector.<KPathPoint>, origin:Point, type:String):void
		 {
			 var pnts:int = points.length;
			 if(pnts <= 0)
				 return;
			 
			 var color:uint;
			 var thickness:int = 2;
			 var grph:Graphics = canvas.gestureLayer.graphics;
/*			 
			 //Determine the colour of the faded lines
			 switch(type)
			 {
				 case KPositionKeyframe.KEYFRAME_POSITION:
					 color = 0x0000ff;
					 break;
				 case KRotationKeyframe.KEYFRAME_ROTATION:
					 color = 0x00ff00;
					 break;
				 
				 case KScaleKeyframe.KEYFRAME_SCALE:
					 color = 0xff0000;
					 break;
			 }
*/			
			 //With the origin of each key frame as a reference point, draw the cursor paths
			 var p:Point = points[0].add(origin);
			 
			 grph.lineStyle(thickness, color, 0.3);
			 
			 grph.beginFill(color, 0.3);
			 grph.drawCircle(origin.x-2.5, origin.y-2.5, 5);
			 grph.endFill();
			 
			 grph.moveTo(p.x, p.y);
			 
			 for(var i:int = 1; i<pnts; i++)
			 {
				 p = points[i].add(origin);
				 grph.lineTo(p.x, p.y);
				 
				 //Construct a triangular arrow head
				 if(i == (pnts-1) && (points.length > 10))
				 {
					 //Find the direction of the arrow frmo the final line segment of the cursor path
					 var lastPoint:Point = points[i-1];
					 var secondLastPoint:Point = points[i-5];
					 var finalVectorX:Number = lastPoint.x - secondLastPoint.x;
					 var finalVectorY:Number = lastPoint.y - secondLastPoint.y;
					 
					 //Find the vector's unit vector
					 var magnitude:Number = Math.sqrt((finalVectorX*finalVectorX) + (finalVectorY*finalVectorY));
					 var unitFinalVectorX:Number = finalVectorX/magnitude*7; //a
					 var unitFinalVectorY:Number = finalVectorY/magnitude*7; //b
					 
					 //Find the ortogonal vector for the arrow's direction
					 //this vector will form the direction of the triangular arrow head's base
					 //If our given vector is <a,b> then the orthogonal vector will be <-b, a>
					 var orthogonalX:Number = -unitFinalVectorY;
					 var orthogonalY:Number = unitFinalVectorX;
					 
					 //Organise the points into the three vertices that form the triangular arrow head
					 //and draw them
					 var vertex1:Point = new Point(unitFinalVectorX+p.x, unitFinalVectorY+p.y);
					 var vertex2:Point = new Point(-orthogonalX+p.x, -orthogonalY+p.y);
					 var vertex3:Point = new Point(orthogonalX+p.x, orthogonalY+p.y);
					 
					 var triangleVertices:Vector.<Number> = Vector.<Number>([vertex1.x, vertex1.y, vertex2.x, vertex2.y, vertex3.x, vertex3.y]);
					 grph.beginFill(color);
					 grph.drawTriangles(triangleVertices);
					 grph.endFill();
				 }	
			 }
		 }
		
		public function enableLog():ILoggable
		{
			_log = new KWithSelectionLog(new Vector.<KPathPoint>(), 
				KPlaySketchLogger.INTERACTION_MOVE_CENTER, _appState.selection.objects);
			return _log;
		}
	}
}