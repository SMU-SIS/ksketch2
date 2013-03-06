/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.view
{
	import flash.geom.Matrix;
	import flash.geom.Point;

	import sg.edu.smu.ksketch2.model.data_structures.KSpatialKeyFrame;
	import sg.edu.smu.ksketch2.model.data_structures.KTimedPoint;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.operators.KSingleReferenceFrameOperator;

	public class KSingleCenterPathView extends KPathView
	{
		private static const QUARTER_CIRCLE:Number = 1.5707;
		private static const PATH_RADIUS:Number = 100;
		private var _activeKey:KSpatialKeyFrame;
		
		public function KSingleCenterPathView(object:KObject)
		{
			super(object);
		}
		
		override public function recomputePathPoints(time:int):void
		{
			clearPoints();
			_activeKey = (_object.transformInterface as KSingleReferenceFrameOperator).getActiveKey(time) as KSpatialKeyFrame;
			
			//Compute for translation first.
			//We will do two key frames for translation.
			var currentMatrix:Matrix = _activeKey?_object.fullPathMatrix(_activeKey.startTime):new Matrix();
			var currentPosition:Point = currentMatrix.transformPoint(_object.centroid);
			
			if(_activeKey && _activeKey.duration != 0)
			{
				_translatePoints = createPathPoints(currentPosition, _activeKey?_activeKey.translatePath.points:null, _activeKey);
				_rotatePoints = createPathPoints(_object.centroid, _activeKey?_activeKey.rotatePath.points:null, _activeKey);
				generateRotationMotionPath(_rotatePoints);
				_scalePoints = _activeKey? _activeKey.scalePath.clone().points:null;
				generateScaleMotionPath(_scalePoints);
			}
			
			if(_activeKey && _activeKey.next)
			{
				if((_activeKey.next as KSpatialKeyFrame).duration != 0)
				{
					currentMatrix = _object.fullPathMatrix((_activeKey.next as KSpatialKeyFrame).startTime);
					currentPosition = currentMatrix.transformPoint(_object.centroid);
					_nextTranslatePoints = createPathPoints(currentPosition, (_activeKey.next as KSpatialKeyFrame).translatePath.points,
						_activeKey.next as KSpatialKeyFrame);
				}
			}
		}
		
		private function createPathPoints(origin:Point, transformPoints:Vector.<KTimedPoint>, targetKey:KSpatialKeyFrame):Vector.<KTimedPoint>
		{
			if(!transformPoints || !targetKey ||transformPoints.length == 0)
				return null;
			
			var i:int;
			var length:int = transformPoints.length;
			var currentPoint:KTimedPoint;
			var motionPath:Vector.<KTimedPoint> = new Vector.<KTimedPoint>();

			for(i = 0; i < length; i++)
			{
				currentPoint = transformPoints[i].clone();
				currentPoint.x += origin.x;
				currentPoint.y += origin.y;
				motionPath.push(currentPoint);
			}
			
			return motionPath;
		}
		
		public function generateRotationMotionPath(path:Vector.<KTimedPoint>):void
		{
			if(!path || path.length == 0)
				return;

			var currentTransitionPoint:KTimedPoint;
			var cartesianPoint:Point;
			var firstPoint:KTimedPoint = path[0];
			var duration:Number = path[path.length-1].time - firstPoint.time;
			
			for(var i:int = 0; i<path.length; i++)
			{
				currentTransitionPoint = path[i];
				cartesianPoint = Point.polar(PATH_RADIUS+((currentTransitionPoint.time- firstPoint.time)/duration*PATH_RADIUS),currentTransitionPoint.x);
				currentTransitionPoint.x = cartesianPoint.x;
				currentTransitionPoint.y = cartesianPoint.y;
			}
		}
		
		public function generateScaleMotionPath(path:Vector.<KTimedPoint>):void
		{
			if(!path || path.length == 0)
				return;
			
			var currentTransitionPoint:KTimedPoint;
			var cartesianPoint:Point;
			var firstPoint:KTimedPoint = path[0];
			var duration:Number = path[path.length-1].time - firstPoint.time;
			var maxScaleValue:Number = 0;
			var i:int;
			
			for(i=0 ; i< path.length; i++)
			{
				if(Math.abs(path[i].x) > maxScaleValue)
					maxScaleValue =  Math.abs(path[i].x);
			}
			
			
			var dRadius:Number;
			var currentAngle:Number;
			for(i=0 ; i< path.length; i++)
			{
				currentTransitionPoint = path[i];
				dRadius = PATH_RADIUS * (currentTransitionPoint.x / maxScaleValue);
				currentAngle = (currentTransitionPoint.time - firstPoint.time)/duration*QUARTER_CIRCLE;
				cartesianPoint = Point.polar(PATH_RADIUS+dRadius,currentAngle+Math.PI);
				currentTransitionPoint.x = cartesianPoint.x;
				currentTransitionPoint.y = cartesianPoint.y;
			}
		}

		
		override public function renderPathView(time:int):void
		{
			var currentActiveKey:KSpatialKeyFrame =  (_object.transformInterface as KSingleReferenceFrameOperator).getActiveKey(time) as KSpatialKeyFrame;
			
			if(_activeKey != currentActiveKey)
				recomputePathPoints(time);
			
			super.renderPathView(time);
		}
	}
}