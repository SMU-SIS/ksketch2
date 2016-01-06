/**
 * Copyright 2010-2015 Singapore Management University
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.canvas.controls
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.system.Capabilities;
	
	import mx.collections.ArrayList;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.canvas.KSketch_CanvasView_Preferences;
	import sg.edu.smu.ksketch2.canvas.components.popup.KSketch_InstructionsBox;
	import sg.edu.smu.ksketch2.canvas.components.view.KMotionDisplay;
	import sg.edu.smu.ksketch2.canvas.components.view.KSketch_CanvasView;
	import sg.edu.smu.ksketch2.model.data_structures.KModelObjectList;
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
			
			var objTemplate:KObject;
			var objDrawn:KObject;

			if(activity == "RECALL")
			{
				result = measureQuadrantAttempt(result);
				if(_activityControl.stars == 3) //user tapped at the correct quadrant
				{
					stars += starQuadrantAttempt(result);
					stars += _activityControl.stars;		
				}
				measures = 2; 
			}
			else if(activity == "TRACE")
			{
				objTemplate = _activityControl.getCurrentObject(_instructionsBox.currentObjectID(), true);
				objDrawn = _activityControl.getCurrentObject(_instructionsBox.currentObjectID(), false);
				
				if(objDrawn)
				{
					result = measureTraceAccuracy(result, objDrawn as KStroke, objTemplate as KStroke);
					stars += starShapeDistance(result);
					
					measures = 1;
				}
			}
			else if(activity == "TRACK")
			{
				objTemplate = _activityControl.getCurrentObject(_instructionsBox.currentObjectID(), true);
				objDrawn = _activityControl.getCurrentObject(_instructionsBox.currentObjectID(), false);

				result = measureTrackAccuracy(result, objTemplate as KStroke, objDrawn as KStroke, 0); //translation
				stars += starShapeDistance(result);
				
				result = measureTrackAccuracy(result, objDrawn as KStroke, objTemplate as KStroke, 1); //rotation
				stars += starRotationDifference(result);
				
				measures = 2;
			}
			else if(activity == "RECREATE")
			{				
				stars += measureRecreateRegion();
				
				result = measureRecreateAccuracy(result);
				stars += result.stars;
				
				measures = 2;
			}
			
			if(stars != 0 && measures != 0)
				stars = Math.floor(stars/measures);
			
			result.stars = stars;
			
			if(_resultArr)
				_resultArr.addItem(result);
			
			return stars;
		}
	
		/*
			Get matched template object of the passed in drawn object
		*/
		private function getTemplateForDrawnObject(drawnObject:KStroke):KStroke
		{
			var templateObjects:KModelObjectList = _activityControl.getAllObjects(true);
			for(var i:int = 0; i<templateObjects.length(); i++)
			{
				var templateObject:KStroke = templateObjects.getObjectAt(i) as KStroke;
				if(drawnObject.startRegion == templateObject.startRegion)
				{
					return templateObject;
				}
			}	
			return templateObject;
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
		
		//only for recall
		public function measureQuadrantAttempt(result:KResult):KResult
		{
			var trials:int = _activityControl.recallCounter - 1;
			
			var percentage:int = 100;
			if(trials != 0)
				percentage = Math.floor(100 - ((trials/6)*100));
			
			result.quadrantAttempt = percentage;
			return result;
		}
		
		public function starQuadrantAttempt(result:KResult):int
		{
			var stars:int = 0;
			
			if(result.quadrantAttempt >= 83)
				stars = 3;
			else if(result.quadrantAttempt >=50 && result.quadrantAttempt < 83)
				stars = 2;
			else if(result.quadrantAttempt >= 16 && result.quadrantAttempt < 50)
				stars = 1;
			
			return stars;
		}
		
		//For trace, track and recreate
		public function measureQuadrantAccuracy(objDrawn:KObject, objTemplate:KObject, isStart:Boolean):int
		{
			var drawnRegion:int, templateRegion:int = 0;
			
			if(isStart)
			{
				drawnRegion = objDrawn.startRegion;
				templateRegion = objTemplate.startRegion;
			}
			else
			{
				drawnRegion = objDrawn.endRegion;
				templateRegion = objTemplate.endRegion;
			}
			
			return _activityControl.computeQuadrantAccuracy(drawnRegion, templateRegion);
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
		
		public function measureTraceAccuracy(result:KResult, obj1:KStroke, obj2:KStroke):KResult
		{
			var points1:Vector.<Point> = obj1.points;
			var points2:Vector.<Point> = obj2.points;
			
			result = measureShapeDistance(result, points1, points2);
			return result;
		}
		
		public function measureTrackAccuracy(result:KResult, objTemplate:KStroke, objDrawn:KStroke, mode:int):KResult
		{
			var motionDisplay:KMotionDisplay = _activityControl.motionDisplay;
			
			if(mode == 0) //translate
			{
				var pathTemplate:Vector.<Point> = new Vector.<Point>();
				var pathDrawn:Vector.<Point> = new Vector.<Point>();
				pathTemplate = motionDisplay.trackTranslation(objTemplate);
				pathDrawn = motionDisplay.trackTranslation(objDrawn);
				result = measureShapeDistance(result, pathTemplate, pathDrawn);
			}
			
			if(mode == 1) //rotate
			{
				var count1:int = motionDisplay.trackRotation(objTemplate);
				var count2:int = motionDisplay.trackRotation(objDrawn);
				result.rotationCountDifference = Math.abs(count1-count2);
			}
			
			if(mode == 2) //scale
			{}
			
			return result;
		}

		public function measureRecreateAccuracy(result:KResult):KResult
		{
			var stars:int;
			
			var templateObjects:KModelObjectList = _activityControl.getAllObjects(true);
			var drawnObjects:KModelObjectList = _activityControl.getAllObjects(false);	
			var templateObject:KStroke, drawnObject:KStroke;
			
			for(var i:int = 0; i<templateObjects.length(); i++)
			{
				templateObject = templateObjects.getObjectAt(i) as KStroke;
				
				for(var j:int = 0; j<drawnObjects.length(); j++)
				{
					if((drawnObjects.getObjectAt(j) as KStroke).originalId == templateObject.id)
					{
						drawnObject= drawnObjects.getObjectAt(j) as KStroke;
						break;
					}	
				}
				
				if(drawnObject && templateObject)
				{
					result = measureTrackAccuracy(result, templateObject, drawnObject, 0); //translation
					stars += starShapeDistance(result);
					
					result = measureTrackAccuracy(result, templateObject, drawnObject, 1); //rotation
					stars += starRotationDifference(result);
				}
			}
			
			stars = Math.floor(stars / (templateObjects.length() * 2));
			result.stars = stars;
			
			return result;
		}
		
		public function measureShapeDistance(result:KResult, points1:Vector.<Point>, points2:Vector.<Point>):KResult
		{
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
							minDistance = dist;
					}
					
					if(maxMinDistance == 0)
						maxMinDistance = minDistance;
					else if(maxMinDistance < minDistance)
						maxMinDistance = minDistance;
				}
				minDistanceTot += minDistance;
			}
			
			if(minDistanceTot > 0)
			{
				result.averageDistance = minDistanceTot/points1.length;
				result.maximumDistance = maxMinDistance;
			}
			
			return result;
		}
		
		public function starShapeDistance(result:KResult):int
		{
			var accuracyThresholdValues:Array = _canvasView.starValueArr;
			var stars:int = 0;
			
			var oneStarAvg:Number = accuracyThresholdValues[0];
			var twoStarAvg:Number = accuracyThresholdValues[1];
			var threeStarAvg:Number = accuracyThresholdValues[2];
			
			var oneStarMax:Number = accuracyThresholdValues[3];
			var twoStarMax:Number = accuracyThresholdValues[4];
			var threeStarMax:Number = accuracyThresholdValues[5];
			
			var averageDistanceInCM:Number = result.averageDistance * 2.54 / flash.system.Capabilities.screenDPI;
			var maximumDistanceInCM:Number = result.maximumDistance * 2.54 / flash.system.Capabilities.screenDPI;
			
			if (averageDistanceInCM >=0 && averageDistanceInCM <= threeStarAvg)
				stars = 3;
			if (averageDistanceInCM > threeStarAvg && averageDistanceInCM <= twoStarAvg)
				stars = 2;
			if (averageDistanceInCM > twoStarAvg && averageDistanceInCM <= oneStarAvg)
				stars = 1;
			
			if (maximumDistanceInCM >=0 && maximumDistanceInCM <= threeStarMax)
				stars += 3;
			if (maximumDistanceInCM > threeStarMax && maximumDistanceInCM <= twoStarMax)
				stars += 2;
			if (maximumDistanceInCM > twoStarMax && maximumDistanceInCM <= oneStarMax)
				stars += 1;
			
			stars = stars/2;
			return stars;
		}
		
		public function starRotationDifference(result:KResult):int
		{
			var stars:int = 0;
			
			if(result.rotationCountDifference <= 2)
				stars += 3;
			if(result.rotationCountDifference > 2 && result.rotationCountDifference <= 5)
				stars += 2;
			if(result.rotationCountDifference > 5)
				stars += 1;

			return stars;
		}
		
		public function measureRecreateRegion():int
		{
			var stars: int;
			var templateObjects:KModelObjectList = _activityControl.getAllObjects(true);
			var drawnObjects:KModelObjectList = _activityControl.getAllObjects(false);	
			
			for(var i:int = 0; i<drawnObjects.length(); i++)
			{
				var drawnObject:KStroke = drawnObjects.getObjectAt(i) as KStroke;
				
				//set start region
				var keyTime:Number = drawnObject.transformInterface.firstKeyTime;
				var currentMatrix:Matrix = drawnObject.fullPathMatrix(keyTime);
				var currentPosition:Point = currentMatrix.transformPoint(drawnObject.center);				
				drawnObject.startRegion = _activityControl.getDrawnObjectRegion(currentPosition);				
				
				//set Original ID
				var objectTemplate:KStroke = getTemplateForDrawnObject(drawnObject);	
				drawnObject.originalId = objectTemplate ? objectTemplate.id : 0;				
				
				//set end region
				keyTime = drawnObject.transformInterface.lastKeyTime;
				currentMatrix = drawnObject.fullPathMatrix(keyTime);
				currentPosition = currentMatrix.transformPoint(drawnObject.center);
				drawnObject.endRegion = _activityControl.getDrawnObjectRegion(currentPosition);
				
				if(objectTemplate)
				{
					stars += measureQuadrantAccuracy(drawnObject, objectTemplate, true); // start region
					stars += measureQuadrantAccuracy(drawnObject, objectTemplate, false); // end region
				}
			}	
			
			stars = Math.floor(stars / (drawnObjects.length() * 2));
			
			return stars;
		}
		
		public function get resultArr():ArrayList
		{
			return _resultArr;
		}
	}
}