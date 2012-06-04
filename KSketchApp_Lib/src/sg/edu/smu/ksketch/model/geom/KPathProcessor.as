/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.model.geom
{
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch.operation.KTransformMgr;
	import sg.edu.smu.ksketch.utilities.KMathUtil;

	public class KPathProcessor
	{	
		private static const PATH_RADIUS:Number = 100;
		private static const PATH_DIRECTION:Number = 0.392699; //pi/8
		
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
		
		/*public static function generateTranslateMotionPath(transitionPath:K3DPath):KPath
		{
			var motionPath:KPath = new KPath();
			
			if(transitionPath.length <= 0)
				return motionPath;
			
			var currentTransitionPoint:K3DVector;
			var currentMotionPoint:KPathPoint;
			
			var duration:Number = transitionPath.points[transitionPath.length-1].y;
			
			var i:num
			
			while(
			
			
			for(var i:int = 0; i<transitionPath.length; i+=62.5)
			{
				currentTransitionPoint = transitionPath.points[i];
				motionPath.addPoint(cartesianPoint.x, cartesianPoint.y, currentTransitionPoint.y);
			}
			
			return motionPath;
		}*/
		
		public static function generateRotationMotionpath(transitionPath:K2DPath):KPath
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
	}
}