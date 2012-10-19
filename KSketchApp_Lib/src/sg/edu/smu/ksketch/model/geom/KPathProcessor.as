/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package sg.edu.smu.ksketch.model.geom
{
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch.operation.KTransformMgr;
	import sg.edu.smu.ksketch.utilities.KAppState;
	import sg.edu.smu.ksketch.utilities.KMathUtil;

	public class KPathProcessor
	{	
		private static const NO_VALUE:K2DVector = new K2DVector(0,0);
		private static const QUARTER_CIRCLE:Number = 0.785398163;
		private static const FULL_CIRCLE:Number = 6.28318531;
		private static const PATH_RADIUS:Number = 100;
		private static const PATH_DIRECTION:Number = 0.392699; //pi/8
		private static const RESAMPLE_RATE:Number = KAppState.ANIMATION_INTERVAL/1.5;
		
		public static function mergeTranslationMotionPath(path1:KPath,path2:KPath):KPath
		{
			return _mergeXYPath(path1,path2,KTransformMgr.TRANSLATION_REF);		
		}
		
		public static function mergeRotationMotionPath(path1:KPath,path2:KPath):KPath
		{
			return _mergeXYPath(path1,path2,KTransformMgr.ROTATION_REF);		
		}
		
		public static function mergeScaleMotionPath(path1:KPath,path2:KPath):KPath
		{
			return _mergeXYPath(path1,path2,KTransformMgr.SCALE_REF);		
		}
		
		public static function mergeTranslationTransitionPath(path1:K3DPath,path2:K3DPath):K3DPath
		{
			return _mergeK3DPath(path1,path2);		
		}
		
		public static function mergeRotationTransitionPath(path1:K2DPath,path2:K2DPath):K2DPath
		{
			return _mergeK2DPath(path1,path2);
		}
		
		public static function mergeScaleTransitionPath(path1:K2DPath,path2:K2DPath):K2DPath
		{
			return _mergeK2DPath(path1,path2);
		}
		
		public static function interpolateTranslationMotionPath(
			targetPath:Vector.<KPathPoint>, dx:Number, dy:Number, bigToSmall:Boolean=false):void
		{
			var pathLength:int = targetPath.length;
			
			var duration:Number;
			
			if(pathLength == 0)
				duration = 0;
			else
				duration = targetPath[pathLength-1].time;
			
			var i:int = 0;
			var currentPoint:KPathPoint;
			var proportion:Number;
			
			if(bigToSmall)
			{
				for(i = 0; i<pathLength; i++)
				{
					currentPoint = targetPath[i];
					
					if(duration == 0)
						proportion = 1 - (i/(pathLength-1));
					else
						proportion  = 1 - (currentPoint.time/duration);
					
					currentPoint.x += proportion*dx;
					currentPoint.y += proportion*dy;
				}
			}
			else
			{
				for(i = 0; i<pathLength; i++)
				{
					currentPoint = targetPath[i];
					
					if(duration == 0)
						proportion = i/(pathLength-1);
					else
						proportion  = currentPoint.time/duration;
						
					currentPoint.x += proportion*dx;
					currentPoint.y += proportion*dy;
				}
			}
		}
		
		public static function interpolateTranslationTransitionPath(
			targetPath:Vector.<K3DVector>, dx:Number, dy:Number):void
		{
			var pathLength:int = targetPath.length;
			
			var duration:Number;
			
			if(pathLength == 0)
				duration = 0;
			else
				duration = targetPath[pathLength-1].z;
			
			var i:int = 0;
			var currentPoint:K3DVector;
			var proportion:Number;
			
		
			for(i = 0; i<pathLength; i++)
			{
				currentPoint = targetPath[i];
				
				if(duration == 0)
					proportion = i/(pathLength-1);
				else
					proportion  = currentPoint.z/duration;
				
				currentPoint.x += proportion*dx;
				currentPoint.y += proportion*dy;
			}
		}
		
		public static function interpolateRotationTransitionPath(
			targetPath:Vector.<K2DVector>, dTheta:Number):void
		{
			var pathLength:int = targetPath.length;
			
			var duration:Number;
			
			if(pathLength == 0)
				duration = 0;
			else
				duration = targetPath[pathLength-1].y;
			
			var i:int = 0;
			var currentPoint:K2DVector;
			var proportion:Number;
			
			for(i = 0; i<pathLength; i++)
			{
				currentPoint = targetPath[i];
				
				if(duration == 0)
					proportion = i/(pathLength-1);
				else
					proportion  = currentPoint.y/duration;
				
				currentPoint.x += proportion*dTheta;
			}
		}
		
		public static function interpolateScaleMotionPath(
			targetPath:Vector.<KPathPoint>, endScale:Number, center:Point):void
		{
			var pathLength:int = targetPath.length;
			var duration:Number;
			
			if(pathLength == 0)
				duration = 0;
			else
				duration = targetPath[pathLength-1].time;
			
			var i:int = 0;
			var currentPoint:KPathPoint;
			var proportion:Number;
			
			var polarForm:Point;
			var cartesianForm:Point;
			
			if(pathLength ==0)
				return;
			
			for(i = 1; i<pathLength; i++)
			{
				currentPoint = targetPath[i];
				
				if(duration == 0)
					proportion = (i/(pathLength-1));
				else
					proportion  = (currentPoint.time/duration);
				
				polarForm = KMathUtil.cartesianToPolar(currentPoint);
				
				polarForm.x *= (proportion*endScale);
				cartesianForm = Point.polar(polarForm.x, polarForm.y);
				
				currentPoint.x = cartesianForm.x;
				currentPoint.y = cartesianForm.y;
			}
		}
		
		public static function interpolateScaleTransitionPath(
			targetPath:Vector.<K2DVector>, dSigma:Number):void
		{
			var pathLength:int = targetPath.length;
			
			var duration:Number;
			
			if(pathLength == 0)
				duration = 0;
			else
				duration = targetPath[pathLength-1].y;
			
			var i:int = 0;
			var currentPoint:K2DVector;
			var proportion:Number;
			
			for(i = 0; i<pathLength; i++)
			{
				currentPoint = targetPath[i];
				
				if(duration == 0)
					proportion = i/(pathLength-1);
				else
					proportion  = currentPoint.y/duration;
				
				currentPoint.x += proportion*dSigma;
			}
		}
		
		private static function _mergeK3DPath(path1:K3DPath,path2:K3DPath):K3DPath
		{
			if (path1.length == 0)
				return path2;
			if (path2.length == 0)
				return path1;
			var resultPath:K3DPath = new K3DPath();
			var duration2:Number = path2.getPointByIndex(path2.length-1).z;
			for (var i:int = 0; i < path1.length; i++)
			{
				var p1:K3DVector = path1.getPointByIndex(i);
				var p2:K3DVector = path2.getPoint(p1.z/duration2);
				resultPath.push(p1.x+p2.x,p1.y+p2.y,p1.z);
			}
			return resultPath;				
		}
		
		private static function _mergeK2DPath(path1:K2DPath,path2:K2DPath):K2DPath
		{
			if (path1.length == 0)
				return path2;
			if (path2.length == 0)
				return path1;
			var resultPath:K2DPath = new K2DPath();
			var duration2:Number = path2.getPointByIndex(path2.length-1).y;
			for (var i:int = 0; i < path1.length; i++)
			{
				var p1:K2DVector = path1.getPointByIndex(i);
				var p2:K2DVector = path2.getPoint(p1.y/duration2);
				resultPath.push(p1.x+p2.x,p1.y);
			}
			return resultPath;			
		}
		
		private static function _mergeXYPath(path1:KPath,path2:KPath,type:int):KPath
		{
			if (path1.length == 0)
				return path2;
			if (path2.length == 0)
				return path1;
			var resultPath:KPath = new KPath();
			var time2:Number = path2.getPointByIndex(path2.length-1).time;
			for (var i:int = 0; i < path1.length; i++)
			{
				var p1:KPathPoint = path1.getPointByIndex(i);
				var p2:KPathPoint = path2.getPoint(p1.time/time2);
				resultPath.addPoint(p1.x+p2.x,p1.y+p2.y,p1.time,type);
			}
			return resultPath;				
		}
		
		public static function generateTranslationMotionPath(transitionPath:K3DPath):KPath
		{
			var motionPath:KPath = new KPath();
			var points:Vector.<K3DVector> = transitionPath.points;
			for (var i:int = 0; i < points.length; i++)
				motionPath.addPoint(points[i].x,points[i].y,points[i].z);
			return motionPath;
		}
		
		public static function generateRotationMotionPath(transitionPath:K2DPath):KPath
		{
			var motionPath:KPath = new KPath();
			
			if(transitionPath.length <= 0)
				return motionPath;
			
			var currentTransitionPoint:K2DVector;
			var currentMotionPoint:KPathPoint;
			var cartesianPoint:Point;
			
			var duration:Number = transitionPath.points[transitionPath.length-1].y;
			
			for(var i:int = 0; i<transitionPath.length; i++)
			{
				currentTransitionPoint = transitionPath.points[i];
				cartesianPoint = Point.polar(PATH_RADIUS+(currentTransitionPoint.y/duration*PATH_RADIUS),currentTransitionPoint.x);
				motionPath.addPoint(cartesianPoint.x, cartesianPoint.y, currentTransitionPoint.y);
			}
			
			return motionPath;
		}

		// ---> Need to add code to do this ...
		public static function generateScaleMotionPath(transitionPath:K2DPath):KPath
		{
			var motionPath:KPath = new KPath();

			if(transitionPath.length <= 0)
				return motionPath;
			
			var currentTransitionPoint:K2DVector;
			var currentMotionPoint:KPathPoint;
			var cartesianPoint:Point;
			
			var duration:Number = transitionPath.points[transitionPath.length-1].y;
			var maxScaleValue:Number = 0;
			var i:int;
			
			for(i=0 ; i< transitionPath.length; i++)
			{
				if(Math.abs(transitionPath.points[i].x) > maxScaleValue)
					maxScaleValue =  Math.abs(transitionPath.points[i].x);
			}
			

			var dRadius:Number;
			var currentAngle:Number;
			
			for(i=0 ; i< transitionPath.length; i++)
			{
				currentTransitionPoint = transitionPath.points[i];
				dRadius = PATH_RADIUS * (currentTransitionPoint.x / maxScaleValue);
				currentAngle = currentTransitionPoint.y/duration*QUARTER_CIRCLE;
				cartesianPoint = Point.polar(PATH_RADIUS+dRadius,currentAngle+Math.PI);
				motionPath.addPoint(cartesianPoint.x, cartesianPoint.y, currentTransitionPoint.y);
			}
			
			return motionPath;
		}
		
		public static function generatePathPointsFromString(pntsString:String, timeIndex:int=0,
															xIndex:int=1, yIndex:int=2):Vector.<KPathPoint>
		{
			if(pntsString == null)
				return null;
			var points:Vector.<KPathPoint> = new Vector.<KPathPoint>();
			var coordinates:Array = pntsString.split(" ");
			for each(var point:String in coordinates)
			{
				if(point != "")
				{
					var txy:Array = point.split(",");
					if(txy.length==3)
						points.push(new KPathPoint(txy[xIndex], txy[yIndex],txy[timeIndex]));
					else
						throw new Error("Stroke.points: expected 3 parameters " +
							"for each path point, but found \""+point+"\"");
				}
			}
			return points;
		}						

		/**
		 * Compares two vectors in the Value-T domain.
		 * Vectors must have points in the (value, time) format.
		 * time is computed in milliseconds.
		 * Default timeStep is 62.5.
		 * Smaller time steps may give more accurate results, at the cost of more iterations.
		 */
		public static function compare2DPaths(toCompare:Vector.<K2DVector>, pathTemplate:Vector.<K2DVector>, timeStep:Number = 62.5):Number
		{
			var i:int = 0;
			var error:Number = 0;
			var length:int = pathTemplate.length;
			
			var targetPath:K2DPath = new K2DPath();
			targetPath.points = toCompare;
			var templatePath:K2DPath = new K2DPath();
			templatePath.points = pathTemplate;
			var templatePoint:K2DVector;
			var targetPoint:K2DVector;
			
			
			var targetDuration:Number = toCompare[toCompare.length-1].y;
			var templateDuration:Number = pathTemplate[pathTemplate.length - 1].y
			var maxDuration:Number = Math.max(targetDuration, templateDuration);
			
			var currentTime:Number = 0;
			var templateProportion:Number = 0;
			var targetProportion:Number = 0;
			
			while(currentTime <= maxDuration)
			{
				templateProportion = currentTime / templateDuration;
				
				if(templateProportion <= 1)
					templatePoint = templatePath.getPoint(templateProportion);
				else
					templatePoint = NO_VALUE;
				
				targetProportion = currentTime / targetDuration;
				
				if(targetProportion <= 1)
					targetPoint = targetPath.getPoint(targetProportion);
				else
					targetPoint = NO_VALUE;
	
				error += Math.abs(templatePoint.x - targetPoint.x);
				
				currentTime += timeStep;
			}
			
			return error;
		}
		
		public static function cleanUp3DPath(toResample:K3DPath):void
		{
			return;
			var points:Vector.<K3DVector> = toResample.points;
			
			if(points.length == 0)
				return;
			
			var currentTime:Number = points[0].z;
			var endTime:Number = points[points.length - 1].z;
			var resampledPoints:Vector.<K3DVector> = new Vector.<K3DVector>();
			var sampledPoint:K3DVector;
			
			while(currentTime <= endTime)
			{
				sampledPoint = toResample.getPoint(currentTime/endTime);
				resampledPoints.push(sampledPoint);
				currentTime += KPathProcessor.RESAMPLE_RATE;
			}
			
			toResample.points = resampledPoints;
		}
		
		public static function cleanUp2DPath(toResample:K2DPath):void
		{
			var points:Vector.<K2DVector> = toResample.points;
			
			if(points.length == 0)
				return;
			
			var currentTime:Number = points[0].y;
			var endTime:Number = points[points.length - 1].y;
			var resampledPoints:Vector.<K2DVector> = new Vector.<K2DVector>();
			var sampledPoint:K2DVector;
			
			while(currentTime <= endTime)
			{
				sampledPoint = toResample.getPoint(currentTime/endTime);
				resampledPoints.push(sampledPoint);
				currentTime += KPathProcessor.RESAMPLE_RATE;
			}
			
			toResample.points = resampledPoints;
		}
		
		public static function resample3DPath(toResample:K3DPath):void
		{
			var points:Vector.<K3DVector> = toResample.points;
			
			if(points.length == 0)
				return;
			
			var currentTime:Number = points[0].z;
			var endTime:Number = points[points.length - 1].z;
			var resampledPoints:Vector.<K3DVector> = new Vector.<K3DVector>();
			var sampledPoint:K3DVector;
			
			while(currentTime <= endTime)
			{
				sampledPoint = toResample.getPointByProportion(currentTime/endTime);
				sampledPoint.z = currentTime;
				resampledPoints.push(sampledPoint);
				currentTime += KPathProcessor.RESAMPLE_RATE;
				
				if(currentTime > endTime)
				{
					currentTime = endTime;
					sampledPoint = toResample.getPointByProportion(currentTime/endTime);
					sampledPoint.z = currentTime;
					resampledPoints.push(sampledPoint);
					currentTime += KPathProcessor.RESAMPLE_RATE;
				}
			}
			
			toResample.points = resampledPoints
		}
		
		public static function resample2DPath(toResample:K2DPath):void
		{
			var points:Vector.<K2DVector> = toResample.points;
			
			if(points.length == 0)
				return;
			
			var currentTime:Number = points[0].y;
			var endTime:Number = points[points.length - 1].y;
			var resampledPoints:Vector.<K2DVector> = new Vector.<K2DVector>();
			var sampledPoint:K2DVector;
			
			while(currentTime <= endTime)
			{
				sampledPoint = toResample.getPointByProportion(currentTime/endTime);
				sampledPoint.y = currentTime;
				resampledPoints.push(sampledPoint);
				currentTime += KPathProcessor.RESAMPLE_RATE;
				
				if(currentTime > endTime)
				{
					currentTime = endTime;
					sampledPoint = toResample.getPointByProportion(currentTime/endTime);
					sampledPoint.y = currentTime;
					resampledPoints.push(sampledPoint);
					currentTime += KPathProcessor.RESAMPLE_RATE;
				}
			}
			
			toResample.points = resampledPoints
		}
	}
}