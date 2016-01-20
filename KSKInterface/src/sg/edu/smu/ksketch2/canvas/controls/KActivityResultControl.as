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
	import flash.net.SharedObject;
	import flash.system.Capabilities;
	
	import mx.collections.ArrayList;
	
	import data.KSketch_DataListItem;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.canvas.KSketch_CanvasView_Preferences;
	import sg.edu.smu.ksketch2.canvas.components.popup.KSketch_InstructionsBox;
	import sg.edu.smu.ksketch2.canvas.components.view.KMotionDisplay;
	import sg.edu.smu.ksketch2.canvas.components.view.KSketch_CanvasView;
	import sg.edu.smu.ksketch2.model.data_structures.KModelObjectList;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.model.objects.KResult;
	import sg.edu.smu.ksketch2.model.objects.KStroke;
	import sg.edu.smu.ksketch2.utils.KTherapyResult;
	import sg.edu.smu.ksketch2.utils.iterators.INumberIterator;

	
	public class KActivityResultControl
	{			
		public var allResultSO:SharedObject = SharedObject.getLocal(KTherapyResult.THERAPY_RESULT_NAME);
		public var resultSO:SharedObject;
		private var resultSO_List:ArrayList = allResultSO.data.result;
		
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
			_initTherapyResult();
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
				result = measureQuadrantPercentage(result);
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
			result.retry = _activityControl.isRetry;
			result = measureTime(result);
			
			if(_resultArr)
				_resultArr.addItem(result);
			
			_storeResult(activity, result);
			
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
				if(templateObject.template && drawnObject.startRegion == templateObject.startRegion && drawnObject.color == templateObject.color)
				{
					return templateObject;
				}
			}	
			return null;
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
		public function measureQuadrantPercentage(result:KResult):KResult
		{
			var trials:int = _activityControl.recallCounter - 1;
			
			var percentage:int = 100;
			if(trials != 0)
				percentage = Math.floor(100 - ((trials/6)*100));
			
			result.quadrantAttempt = trials + 1;
			result.quadrantPercentage = percentage;
			return result;
		}
		
		public function starQuadrantAttempt(result:KResult):int
		{
			var stars:int = 0;
			
			if(result.quadrantPercentage >= 83)
				stars = 3;
			else if(result.quadrantPercentage >=50 && result.quadrantPercentage < 83)
				stars = 2;
			else if(result.quadrantPercentage >= 16 && result.quadrantPercentage < 50)
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
			if(mode == 0) //translate
			{
				var pathTemplate:Vector.<Point> = new Vector.<Point>();
				var pathDrawn:Vector.<Point> = new Vector.<Point>();
				pathTemplate = _trackTranslation(objTemplate);
				pathDrawn = _trackTranslation(objDrawn);
				result = measureShapeDistance(result, pathTemplate, pathDrawn);
			}
			
			if(mode == 1) //rotate
			{
				var count1:int = _trackRotationCount(objTemplate);
				var count2:int = _trackRotationCount(objDrawn);
				result.rotationCountDifference = Math.abs(count1-count2);
			}
			
			if(mode == 2) //scale
			{}
			
			return result;
		}
		
		private function _trackTranslation(obj:KObject):Vector.<Point>
		{
			var _vectorPoints:Vector.<Point> = new Vector.<Point>();
			var numIter:INumberIterator = null;
			var t1:Number = -1;
			var p1:Point = null;
			
			var centroid:Point = obj.center;
			numIter = obj.translateTimeIterator();
			numIter.reset();
			
			while (numIter.hasNext()) 
			{ 
				t1 = numIter.next(); 
				p1 = obj.fullPathMatrix(t1).transformPoint(centroid);
				_vectorPoints.push(new Point(p1.x, p1.y));
			}
			
			return _vectorPoints;
		}
		
		private function _trackRotationCount(obj:KObject):int
		{
			var numIter:INumberIterator = null;
			var t1:Number = -1;
			var p1:Point = null;
			var totalRotation = 0;
			var theta0:Number, theta1:Number;
			
			numIter = obj.rotateTimeIterator();
			numIter.reset();
			t1 = numIter.empty ? 0 : numIter.next();
			theta1 = numIter.empty ? 0 : _getObjectRotation(obj, t1, 0);
			
			while (numIter.hasNext())
			{
				t1 = numIter.next();
				theta0 = theta1;
				theta1 = _getObjectRotation(obj, t1, theta0);
				totalRotation += Math.abs(theta1 - theta0);
			}
			return totalRotation;
		}

		private function _getObjectRotation(obj:KObject, t:Number, rPrev:Number):Number
		{
			var transformer:Sprite = new Sprite();
			transformer.transform.matrix = obj.fullPathMatrix(t);
			var r:Number = (transformer.rotation / 180) * Math.PI;			
			
			var turns:int = Math.round(rPrev/(2*Math.PI));
			var rScaled:Number = r + (turns * 2 * Math.PI);
			var diff:Number = rScaled - rPrev;
			
			if (Math.PI < diff)
			{
				rScaled -= 2 * Math.PI;
			}
			else if (diff < -Math.PI)
			{
				rScaled += 2 * Math.PI;				
			}
			
			return rScaled;
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
				if(objectTemplate)
				{
					drawnObject.originalId = objectTemplate ? objectTemplate.id : 0;
					
					//set end region
					keyTime = drawnObject.transformInterface.lastKeyTime;
					currentMatrix = drawnObject.fullPathMatrix(keyTime);
					currentPosition = currentMatrix.transformPoint(drawnObject.center);
					drawnObject.endRegion = _activityControl.getDrawnObjectRegion(currentPosition);
				
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
		
		private function _initTherapyResult():void
		{
			var cacheName:String = KTherapyResult.getTherapyCacheName(_canvasView.getTherapyTemplateName(), _canvasView.getCurrentUserName());
			resultSO = SharedObject.getLocal(cacheName);
			if(!resultSO.data.resultRecall && !resultSO.data.resultTrace && !resultSO.data.resultTrack && !resultSO.data.resultRecreate)
			{
				resultSO.data.resultRecall = "";
				resultSO.data.resultTrace = "";
				resultSO.data.resultTrack = "";
				resultSO.data.resultRecreate = "";	
			}			
			if(!resultSO_List)
			{
				resultSO_List = new ArrayList();
			}
			if(resultSO_List.getItemIndex(resultSO) == -1)
			{
				resultSO.data.userName = _canvasView.getCurrentUserName();
				resultSO.data.templateName = _canvasView.getTherapyTemplateName();
				resultSO.data.resultDate = KTherapyResult.getCurrentDate();
				resultSO.data.id=cacheName;
				resultSO_List.addItem(resultSO);
			}
			allResultSO.data.result = resultSO_List;
		}
		
		/*
			Store therapy results for sending to datastore
		*/
		private function _storeResult(activityName:String, result:KResult):void
		{			
			if(activityName == "RECALL")
				resultSO.data.resultRecall += KTherapyResult.deserializeResult(_activityControl.currentObjectID.toString(), result);	
			else if(activityName == "TRACE")
				resultSO.data.resultTrace += KTherapyResult.deserializeResult(_activityControl.currentObjectID.toString(), result);
			else if(activityName == "TRACK")
				resultSO.data.resultTrack += KTherapyResult.deserializeResult(_activityControl.currentObjectID.toString(), result);
			else if(activityName == "RECREATE")
				resultSO.data.resultRecreate += KTherapyResult.deserializeResult(_activityControl.currentObjectID.toString(), result);
			resultSO.flush();
			allResultSO.flush();
		}
		
		public function getCurrentResultObject():Object
		{
			return KTherapyResult.getResultObject(resultSO);
		}
		
	}
}