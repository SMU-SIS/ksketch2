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
	import flash.utils.getTimer;
	
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
			if(!_activeKey)
			{
				_translatePoints = null;
				_rotatePoints = null;
				_scalePoints = null;
				_nextTranslatePoints = null;
				return;
			}
			
			_translatePoints = generateTranslatePath(_activeKey, _translatePoints);
			_nextTranslatePoints = generateTranslatePath(_activeKey.next as KSpatialKeyFrame, _nextTranslatePoints);
		}
		
		/**
		 * Generates a translation path for the given key
		 */
		private function generateTranslatePath(key:KSpatialKeyFrame, transformPoints:Vector.<KTimedPoint>):Vector.<KTimedPoint>
		{
			if(key)
			{
				var targetPoints:Vector.<KTimedPoint> = key.translatePath.points;
				var length:int = targetPoints.length;
				if(length != 0)
				{
					var currentMatrix:Matrix = _activeKey?_object.fullPathMatrix(_activeKey.startTime):new Matrix();
					var currentPosition:Point = currentMatrix.transformPoint(_object.centroid);
					
					if(!transformPoints)
						transformPoints = new Vector.<KTimedPoint>();
					
					if(transformPoints.length < length)
					{
						while(transformPoints.length < length)
							transformPoints.push(new KTimedPoint());
					}
					else if(transformPoints.length > length)
					{
						while(transformPoints.length > length)
							transformPoints.shift();
					}
					
					var i:int;
					var currentPoint:KTimedPoint;
					var targetPoint:KTimedPoint;
					
					for(i = 0; i < length; i++)
					{
						currentPoint = transformPoints[i];
						targetPoint = targetPoints[i];
						currentPoint.x = currentPosition.x + targetPoint.x;
						currentPoint.y = currentPosition.y + targetPoint.y;
						currentPoint.time = targetPoint.time;
					}
			
					return transformPoints;
				}
			}
			
			//Set points to null if there are no points at all
			//No need to render everything
			return null;
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
			_activeKey =  (_object.transformInterface as KSingleReferenceFrameOperator).getActiveKey(time) as KSpatialKeyFrame;
			recomputePathPoints(time);
			super.renderPathView(time);
		}
	}
}