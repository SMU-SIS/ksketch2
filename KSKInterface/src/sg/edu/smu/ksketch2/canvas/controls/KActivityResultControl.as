package sg.edu.smu.ksketch2.canvas.controls
{
	import flash.geom.Point;
	import flash.system.Capabilities;
	
	import mx.collections.ArrayList;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.canvas.KSketch_CanvasView_Preferences;
	import sg.edu.smu.ksketch2.canvas.components.popup.KSketch_InstructionsBox;
	import sg.edu.smu.ksketch2.canvas.components.view.KSketch_CanvasView;
	import sg.edu.smu.ksketch2.model.data_structures.KPath;
	import sg.edu.smu.ksketch2.model.data_structures.KTimedPoint;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.model.objects.KResult;
	import sg.edu.smu.ksketch2.model.objects.KStroke;

	public class KActivityResultControl
	{
		private var _resultArr:ArrayList;
		
		private var _instructionsBox:KSketch_InstructionsBox;
		private var _canvasView:KSketch_CanvasView;
		private var _KSketch:KSketch2;
		private var _interactionControl:KInteractionControl;
		private var _activityControl:KActivityControl;
		
		public function KActivityResultControl(instructions:KSketch_InstructionsBox, canvas:KSketch_CanvasView, 
											   kSketch:KSketch2, interactionControl:KInteractionControl, activity:KActivityControl)
		{
			_resultArr = new ArrayList();
			_instructionsBox = instructions;
			_canvasView = canvas;
			_KSketch = kSketch;
			_interactionControl = interactionControl;
			_activityControl = activity;
		}
		
		public function computeResult(activity:String, instruction:int, id:int):int
		{
			var stars:int = 0;
			var measures:int = 0;
			var result:KResult = new KResult(activity, instruction, id);
			
			if(activity == "RECALL")
			{
				result = measureQuadrant(result);
				//result = measureTime(result);
				
				measures = 1; 
				stars += starQuadrant(result);
				//stars += starTime(result);
			}
			else if(activity == "TRACE")
			{
				var objTemplate:KObject = _activityControl.getCurrentObject(_instructionsBox.currentObjectID(), true);
				var objDrawn:KObject = _activityControl.getCurrentObject(_instructionsBox.currentObjectID(), false);
				
				if(objDrawn)
				{
					result.shapeDistance = calculateShapeDistance(objDrawn as KStroke, objTemplate as KStroke);
					result.shapeDistanceInCm = Math.round(result.shapeDistance* 2.54 / flash.system.Capabilities.screenDPI);
					var strokeLengthProportion:Number = totalDistance(objDrawn as KStroke)/totalDistance(objTemplate as KStroke);
					
					result = measureTime(result);
					
					measures = 1;
					
					//stars += starTime(result);
					
					//not sure
					if(strokeLengthProportion > 0.002)
						stars += starShapeDistance(result);
					
					//stars += starRegion(objDrawn, objTemplate);
				}
			}
			else if(activity == "TRACK")
			{
				//result = measureTime(result);
				//TO DO: implement shape accuracy
				//TO DO: implement motion accuracy (shape of motion path)
				
				//measures = 4;
				//stars += starTime(result);
				//stars += starStartRegion(result);
				//stars += starEndRegion(result);
				//stars += starShapeAccuracy(result);
			}
			
			if(stars != 0 && measures != 0)
				stars = Math.floor(stars/measures);
			
			result.stars = stars;
			
			if(_resultArr)
				_resultArr.addItem(result);
			
			return stars;
		}
		
		public function measureTime(result:KResult):KResult
		{
			var timeGiven:int = KSketch_CanvasView_Preferences.duration *1000;
			var timeTaken:int = _canvasView.timeTaken;
			
			result.timeGiven = timeGiven;
			result.timeTaken = timeTaken;
			
			return result;
		}
		
		public function starTime(result:KResult):int
		{
			var stars:int = 0;
			var ratio:Number = (result.timeTaken/result.timeGiven) * 100;
			
			if(ratio >= 0 && ratio <= 50)
				stars = 3;
			else if(ratio > 50 && ratio <=75)
				stars = 2;
			else if(ratio > 75 && ratio <= 100)
				stars = 1;
			
			return stars;
		}
		
		public function measureQuadrant(result:KResult):KResult
		{
			var trials:int = _activityControl.recallCounter - 1;
			
			var percentage:int = 100;
			if(trials != 0)
				percentage = Math.floor(100 - ((trials/6)*100));
			
			result.percentageQuadrant = percentage;
			return result;
		}
		
		public function starQuadrant(result:KResult):int
		{
			var stars:int = 0;
			
			if(result.percentageQuadrant >= 83)
				stars = 3;
			else if(result.percentageQuadrant >=50 && result.percentageQuadrant < 83)
				stars = 2;
			else if(result.percentageQuadrant >= 16 && result.percentageQuadrant < 50)
				stars = 1;
			
			return stars;
		}
		
		public function maxDistance(object:KStroke):Number 
		{
			var _points:Vector.<Point> = object.points;
			var maxDist:Number = Point.distance(_points[0],_points[1]);
			for(var i:int = 0; i<_points.length; i++)
			{
				for(var j:int = 0; j<_points.length; j++){
					var distance:Number = Point.distance(_points[i],_points[j]);
					if(distance > maxDist) {
						maxDist = distance;
					}
				}
			}
			
			var distInCm:Number = maxDist * 2.54 / flash.system.Capabilities.screenDPI;
			return distInCm;
		}
		
		public function totalDistance(object:KStroke):Number 
		{
			var _points:Vector.<Point> = object.points;
			var totDist:Number = 0;
			for(var i:int = 0; i<_points.length; i++)
			{
				for(var j:int = 0; j<_points.length; j++){
					totDist += Point.distance(_points[i],_points[j]);
				}
			}
			
			return totDist;
		}

		public function calculateShapeDistance(obj1:KStroke, obj2:KStroke):int
		{
			var points1:Vector.<Point> = obj1.points;
			var points2:Vector.<Point> = obj2.points;
			
			var minDistanceTot:Number = 0;
			var maxMinDistance:Number = 0;
			var dist:Number = 0;
			
			for(var i:int = 0; i<points1.length; i++)
			{
				var minDistance:Number = Point.distance(points1[i],points2[0]) ;
				if(minDistance > 0)
				{
					for(var j:int = 1; j<points2.length; j++) 
					{
						dist = Point.distance(points1[i],points2[j]);
						if(dist<minDistance)
						{
							minDistance = dist;
							
							if(maxMinDistance == 0)
								maxMinDistance = dist;
							else if(maxMinDistance < dist)
								maxMinDistance = dist;
						}
					}
				}
				minDistanceTot += minDistance;
			}
			
			if(minDistanceTot > 0)
				minDistanceTot = Math.round((minDistanceTot/points1.length) + maxMinDistance);
			
			return minDistanceTot;
		}
		
		public function starShapeDistance(result:KResult):int
		{
			var maximumStarValues:Array = _canvasView.starValueArr;
			var stars:int = 0;
			
			var maxDistance:int = maximumStarValues[0];
			var oneStarDiff:int = maximumStarValues[1];
			var twoStarDiff:int = maximumStarValues[2];
			var threeStarDiff:int = maximumStarValues[3];
			var diffDistance:int = Math.abs(maxDistance - result.shapeDistanceInCm);
			
			if (diffDistance >=0 && diffDistance <= threeStarDiff)
				stars = 3;
			if (diffDistance > threeStarDiff && diffDistance <= (threeStarDiff + twoStarDiff))
				stars = 2;
			if (diffDistance > (threeStarDiff + twoStarDiff) && diffDistance <= (threeStarDiff + twoStarDiff + oneStarDiff))
				stars = 1;
			
			trace("star shape distance:************************");
			trace("maxDistance: " + maxDistance);
			trace("ACTUAL dist: " + result.shapeDistanceInCm);
			trace("diffDistance: " + diffDistance);
			trace("star values --> " + threeStarDiff + " , " + twoStarDiff + " , " + oneStarDiff);
			trace("STARS EARNED --> " + stars);
			
			return stars;
		}
		
		public function starRegion(objDrawn:KObject, objTemplate:KObject):int
		{
			var stars:int = 0;
			
			if(objDrawn.startRegion == objTemplate.startRegion)
				stars = 3;
			else
			{
				if(objTemplate.startRegion == 1)
				{
					if(objDrawn.startRegion == 2 || objDrawn.startRegion == 4 || objDrawn.startRegion == 5)
						stars = 2;
					else
						stars = 1;
				}
				else if(objTemplate.startRegion == 2)
				{
					if(objDrawn.startRegion == 1 || objDrawn.startRegion == 3 || objDrawn.startRegion == 5)
						stars = 2;
					else
						stars = 1;
				}
				else if(objTemplate.startRegion == 3)
				{
					if(objDrawn.startRegion == 2 || objDrawn.startRegion == 5 || objDrawn.startRegion == 6)
						stars = 2;
					else
						stars = 1;
				}
				else if(objTemplate.startRegion == 4)
				{
					if(objDrawn.startRegion == 1 || objDrawn.startRegion == 2 || objDrawn.startRegion == 5)
						stars = 2;
					else
						stars = 1;
				}
				else if(objTemplate.startRegion == 5)
				{
					if(objDrawn.startRegion == 2 || objDrawn.startRegion == 4 || objDrawn.startRegion == 6)
						stars = 2;
					else
						stars = 1;
				}
				else if(objTemplate.startRegion == 6)
				{
					if(objDrawn.startRegion == 2 || objDrawn.startRegion == 3 || objDrawn.startRegion == 5)
						stars = 2;
					else
						stars = 1;
				}
			}
			
			trace("star region: " + stars + ", objDrawn: " + objDrawn.startRegion + ", objTemplate: " + objTemplate.startRegion);
			return stars;
		}
		
		
		
		
		
		
		
		
		
		
		
		
		public function measureTransformation(object1:KPath, object2:KPath):Number
		{
			var points1:Vector.<KTimedPoint> = object1.points;
			var points2:Vector.<KTimedPoint> = object2.points;
			var minDistanceTot:Number = 0;
			for(var i:int = 0; i<points1.length; i++)
			{
				var minDistance:Number = KTimedPoint.distance(points1[i],points2[0]) ;
				for(var j:int = 1; j<points2.length; j++) {
					var dist:Number = KTimedPoint.distance(points1[i],points2[j]);
					if(dist<minDistance) {
						minDistance = dist;
					}
					minDistanceTot += minDistance;
				}
			}
			return minDistanceTot;
		}
	
		public function get resultArr():ArrayList
		{
			return _resultArr;
		}
	}
}