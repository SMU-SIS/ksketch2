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
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.net.SharedObject;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	
	import spark.components.Image;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.KSketchAssets;
	import sg.edu.smu.ksketch2.KSketchGlobals;
	import sg.edu.smu.ksketch2.canvas.components.popup.KSketch_InstructionsBox;
	import sg.edu.smu.ksketch2.canvas.components.view.KModelDisplay;
	import sg.edu.smu.ksketch2.canvas.components.view.KMotionDisplay;
	import sg.edu.smu.ksketch2.canvas.components.view.KSketch_CanvasView;
	import sg.edu.smu.ksketch2.canvas.components.view.objects.IObjectView;
	import sg.edu.smu.ksketch2.canvas.components.view.objects.KStrokeView;
	import sg.edu.smu.ksketch2.events.KSketchEvent;
	import sg.edu.smu.ksketch2.events.KTimeChangedEvent;
	import sg.edu.smu.ksketch2.model.data_structures.KModelObjectList;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.model.objects.KStroke;
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;
	import sg.edu.smu.ksketch2.utils.KSelection;
	import sg.edu.smu.ksketch2.utils.KSketch_Avatar;
	
	import starling.utils.Color;
	
	public class KActivityControl
	{
		private var _instructionsBox:KSketch_InstructionsBox;
		private var _canvasView:KSketch_CanvasView;
		private var _KSketch:KSketch2;
		private var _interactionControl:KInteractionControl;
		
		private var _currentObjectID:int;
		private var _currentManipulateObject:KObject;
		private var _currentTemplateObject:KObject;
		private var _activityType:String = "SKETCH";
		private var _isAnimationPlaying:Boolean;
		private var _isNewSketch:Boolean;
		private var _recallCounter:int;
		private var _stars:int;
		private var _isRetry:Boolean = false;
		public var recogniseDraw:Boolean;
		
		
		private var _textfield:TextField;
		private var _currentPosition:int=0;		
		
		public function KActivityControl(instructionsBox:KSketch_InstructionsBox, canvas:KSketch_CanvasView, ksketch:KSketch2, interaction:KInteractionControl)
		{
			_instructionsBox = instructionsBox;
			_canvasView = canvas;
			_KSketch = ksketch;
			_interactionControl = interaction;
			recogniseDraw = true;
		}
		
		public function startActivity(activity:String):void
		{
			var currentInstruction:int = _instructionsBox.currentInstruction();
			_currentObjectID = _instructionsBox.currentObjectID();
			_currentManipulateObject = getCurrentObject(_currentObjectID, false);
			_currentTemplateObject = getCurrentObject(_currentObjectID, true);
			
			trace("CURRENT TEMPLATE OBJECT ID: " + _currentTemplateObject.id);
			//Disable pens in INTRO, RECALL and TRACK mode
			if(activity == "INTRO" || activity == "RECALL" || activity == "TRACK")
				_canvasView.setPenAccessibility(false);
			else
				_canvasView.setPenAccessibility(true);
			
			if(activity == "TRACK")
				_canvasView.setRedoUndoAccessibility(true);
			
			//Reset settings
			if(currentInstruction == 0)
			{
				_canvasView.setRegionVisibility(false);
				_setObjectProperties(false, false, false);
			}
			_canvasView.resetTimeControl();
			
			if(activity == "INTRO")
			{
				_activityType = "INTRO";
				discardSketchedObjects();
				_hideObjects(true);
				startIntroductionAnimation();
				_isAnimationPlaying = true;
			}
			else if(activity == "RECALL")
			{
				_activityType = "RECALL";
				_recallCounter = 0;
				_setObjectProperties(true, false, false);
				_hideObjects(true);
				_canvasView.setRegionVisibility(true);
			}
			else if(activity == "TRACE")
			{ 
				removeSelectObjectToAnimate();
				_activityType = "TRACE";
				//only discard sketch objects after the Start button is clicked.
				//_discardSketchedObjects();
				_setObjectProperties(false, true, false);
			}
			else if(activity == "TRACK")
			{ 
				removeSelectObjectToAnimate();
				_activityType = "TRACK";
				_currentManipulateObject = _getCurrentObjectToTrack(false);
				
				//If there is no sketched object to track, then duplicate copy of the original
				if(!_currentManipulateObject)
				{
					_currentManipulateObject = _duplicateObject(_currentTemplateObject as KStroke);
					trace("Implement duplicate object for track without trace");	
				}
				_setObjectProperties(false, false, true);
				_hideObjects(true);
				processTrack(_currentManipulateObject as KStroke);
				autoSelectObjectToAnimate();
				_canvasView.updateTrackWidget();
			}
			else if(activity == "RECREATE")
			{ 
				_interactionControl.selection = null;
				_activityType = "RECREATE";
				//only discard sketch objects after the Start button is clicked.
				//_discardSketchedObjects(); 
				_currentManipulateObject = null; 
				_setObjectProperties(false, false, false);
				_hideObjects(false);
				//processTrack(_currentManipulateObject as KStroke);
			}
		}
		
		private function _setObjectProperties(isRecall:Boolean, isTrace:Boolean, isTrack:Boolean):void
		{
			for(var i:int=0; i<_KSketch.root.children.length(); i++)
			{
				var currObj:KObject = _KSketch.root.children.getObjectAt(i) as KObject;
				if(currObj is KStroke)
				{
					var view:IObjectView = _canvasView.modelDisplay.viewsTable[currObj];
					
					//reset
					currObj.template = false;
					(view as KStrokeView).resetActivityHighlight(_KSketch.time);
					(view as DisplayObject).visible = true;
					
					if(isRecall)
					{
						(view as DisplayObject).visible = false;
					}
					else if(isTrace)
					{
						currObj.template = true;
						if(currObj.id == _currentTemplateObject.id)
						{
							(view as KStrokeView).changeActivityHighlight(_KSketch.time, false);
							(view as KStrokeView).visible = true;
						}
						else
						{
							(view as KStrokeView).changeActivityHighlight(_KSketch.time, true);
							(view as KStrokeView).visible = false;
						}
					}
					else if(isTrack)
					{
						currObj.template = true;
						(view as KStrokeView).changeActivityHighlight(_KSketch.time, false);
						(view as KStrokeView).visible = true;
						
						var translationDict:Dictionary = _instructionsBox.getTranslateDirectionDictionary(_canvasView.getTherapyTemplateXML(), _currentTemplateObject.id);
						if(translationDict != null)
						{
							_createLabel(_currentTemplateObject.transformMatrix(_KSketch.time).transformPoint(_currentTemplateObject.center));
							_KSketch.addEventListener(KTimeChangedEvent.EVENT_TIME_CHANGED, function(e:KTimeChangedEvent):void
							{
								if(_currentTemplateObject)
									_addLabelToTranslationObject(_currentTemplateObject as KStroke, translationDict);											
							});
						}
					}					
				}	
			}
		}
		
		public function processIntro(successIntro:Boolean):void
		{
			if(successIntro)
			{
				_instructionsBox.startStopActivity();
				
				_setObjectProperties(false, false, false);	
				_canvasView.setRegionVisibility(true);	
				_hideObjects(false);
			}
			_interactionControl.selection = null;
		}
		
		public function processRecall(correctRecall:Boolean, tapPoint:Point, templateRegion:int):void
		{
			if(correctRecall)
			{
				//unhide the object view
				for(var i:int=0; i<_KSketch.root.children.length(); i++)
				{
					var currObj:KObject = _KSketch.root.children.getObjectAt(i) as KObject;
					if(currObj.id == _currentObjectID)
					{
						var view:IObjectView = _canvasView.modelDisplay.viewsTable[currObj];
						(view as DisplayObject).visible = true;
					}
				}
				stars = 3;			
				_instructionsBox.open(_canvasView, false);
				_instructionsBox.startStopActivity();
			}
			else
			{
				var tapRegion:int = getDrawnObjectRegion(tapPoint);
				stars = computeQuadrantAccuracy(tapRegion,templateRegion);
				showWrongResultForRecall(tapRegion);
			}
			
			_interactionControl.selection = null;
		}
		
		public function computeQuadrantAccuracy(drawnRegion:int, templateRegion:int):int
		{
			var stars:int = 0;
			if(drawnRegion == templateRegion)
				stars = 3;
			else
			{
				if(templateRegion == 1)
				{
					if(drawnRegion == 2 || drawnRegion == 4 || drawnRegion == 5)
						stars = 2;
					else
						stars = 1;
				}
				else if(templateRegion == 2)
				{
					if(drawnRegion == 1 || drawnRegion == 3 || drawnRegion == 5)
						stars = 2;
					else
						stars = 1;
				}
				else if(templateRegion == 3)
				{
					if(drawnRegion == 2 || drawnRegion == 5 || drawnRegion == 6)
						stars = 2;
					else
						stars = 1;
				}
				else if(templateRegion == 4)
				{
					if(drawnRegion == 1 || drawnRegion == 2 || drawnRegion == 5)
						stars = 2;
					else
						stars = 1;
				}
				else if(templateRegion == 5)
				{
					if(drawnRegion == 2 || drawnRegion == 4 || drawnRegion == 6)
						stars = 2;
					else
						stars = 1;
				}
				else if(templateRegion == 6)
				{
					if(drawnRegion == 2 || drawnRegion == 3 || drawnRegion == 5)
						stars = 2;
					else
						stars = 1;
				}
			}
			return stars;
		}
		
		public function incrementRecallCounter():void
		{
			_recallCounter++;
		}
		
		public function processTrace():void
		{
			
			for(var i:int=0; i<_KSketch.root.children.length(); i++)
			{
				var currObj:KObject = _KSketch.root.children.getObjectAt(i) as KObject;
				if(currObj is KStroke && !currObj.template && currObj.id == currObj.originalId)
				{
					currObj.originalId = _currentObjectID;
				}	
			}
			
			_interactionControl.selection = null;
		}
		
		public function processTrack(currObj:KStroke):void
		{
			if(currObj)
			{
				//unhide current object and disable it as a template
				var tempArr:Array = new Array(_KSketch.root.children.length());
				var view:IObjectView;
				
				var currOriginalID:int = currObj.originalId;
				currObj.template = false;
				view = _canvasView.modelDisplay.viewsTable[currObj];
				(view as KStrokeView).resetActivityHighlight(_KSketch.time);
				(view as DisplayObject).visible = true;
				
				//remove the animation if the object is previously animated
				_removeAnimationFromObject(currObj);
			}
		}
		
		private function _getCurrentObjectToTrack(useTemplate:Boolean):KObject
		{
			var currObj:KObject = null;
			var newestObj:KObject = null;
			
			for(var i:int=0; i<_KSketch.root.children.length(); i++)
			{
				currObj = _KSketch.root.children.getObjectAt(i) as KObject;
				
				if(!useTemplate)
				{
					if(currObj is KStroke && currObj.id != currObj.originalId && currObj.originalId == _currentObjectID)
						newestObj = currObj;
					else
						currObj = null;
				}
				else
				{
					if(currObj is KStroke && currObj.id == currObj.originalId && currObj.originalId == _currentObjectID)
					{ 
						newestObj = currObj;
						break;
					}
					else 
						currObj = null;
				}
			}
			
			return newestObj;
		}
		
		public function autoSelectObjectToAnimate():void
		{
			if(_currentManipulateObject)
			{
				var selectedList:KModelObjectList = new KModelObjectList();
				selectedList.add(_currentManipulateObject);
				_interactionControl.selection = new KSelection(selectedList);
			}
		}
		
		public function removeSelectObjectToAnimate():void
		{
			if(_interactionControl.selection)
			{
				_interactionControl.selection = null;				
			}
		}
		
		public function discardSketchedObjects():void
		{
			var tempArr:Array = new Array(_KSketch.root.children.length());
			var i:int;
			var currObj:KObject;
			var retainSketchObject:KObject;
			
			for(i=0; i<_KSketch.root.children.length(); i++)
			{
				currObj = _KSketch.root.children.getObjectAt(i) as KObject;
				if(currObj is KStroke)
				{
					if((currObj.id != currObj.originalId && currObj.originalId == _currentObjectID) ||
						(_activityType == "RECREATE" && !currObj.template && currObj.id == currObj.originalId))
					{
						_removeAnimationFromObject(currObj);
						tempArr[i] = currObj;
						if(currObj.id != currObj.originalId && currObj.originalId == _currentObjectID)
							retainSketchObject = currObj;
					}
				}	
			}

			for(i=0; i<tempArr.length; i++)
			{
				if(tempArr[i] as KStroke)
				{
					currObj = tempArr[i];
					
					//RECREATE: retain the latest sketch object which matches the template region
					if(_activityType == "RECREATE" && retainSketchObject && currObj.id == retainSketchObject.id)
						continue;
					
					_interactionControl.begin_interaction_operation();
					
					var view:IObjectView = _canvasView.modelDisplay.viewsTable[currObj];
					(view as KStrokeView).hardErase(_KSketch.time, _interactionControl.currentInteraction);	
					
					_interactionControl.end_interaction_operation(null, _interactionControl.selection);
					_KSketch.dispatchEvent(new KSketchEvent(KSketchEvent.EVENT_MODEL_UPDATED));
				}
			}
		}	
		
		private function _hideObjects(sketched:Boolean):void
		{
			_interactionControl.begin_interaction_operation();
			
			var tempArr:Array = new Array(_KSketch.root.children.length());
			var i:int;
			var currObj:KObject
			
			for(i=0; i<_KSketch.root.children.length(); i++)
			{
				currObj = _KSketch.root.children.getObjectAt(i) as KObject;
				if(sketched)
				{
					if(currObj is KStroke && currObj.id != currObj.originalId)
						tempArr[i] = currObj;
				}
				else
					tempArr[i] = currObj;
			}
			
			for(i=0; i<tempArr.length; i++)
			{
				if(tempArr[i] is KStroke)
				{
					currObj = tempArr[i];
					
					currObj.template = true;
					currObj.hide = true;
					var view:IObjectView = _canvasView.modelDisplay.viewsTable[currObj];
					(view as DisplayObject).visible = false;
					
					//trace("hide this view and obj " + currObj.id);
					/*This portion will delete the stroke/view
					var view:IObjectView = _canvasView.modelDisplay.viewsTable[currObj];
					var op:KCompositeOperation = new KCompositeOperation();
					(view as KStrokeView).hardErase(_KSketch.time, _interactionControl.currentInteraction);
					*/
				}
			}
		
			_interactionControl.end_interaction_operation();
			tempArr = null;
		}
		
		private function _removeAnimationFromObject(object:KObject):void
		{
			_interactionControl.begin_interaction_operation();
			
			if(object.transformInterface.canClearKeys(_KSketch.time))
			{
				object.visibilityControl.setVisibility(true, _KSketch.time, _interactionControl.currentInteraction, true);
				object.transformInterface.clearAllMotionsAfterTime(_KSketch.time, _interactionControl.currentInteraction);
			}
			
			_interactionControl.end_interaction_operation(null, _interactionControl.selection);
			_KSketch.dispatchEvent(new KSketchEvent(KSketchEvent.EVENT_MODEL_UPDATED));
		}
		
		private function _duplicateObject(currObj:KStroke):KObject
		{
			_interactionControl.begin_interaction_operation();
			
			var op:KCompositeOperation = new KCompositeOperation();
			var newStroke:KStroke = _KSketch.object_Add_Stroke(currObj.points, _KSketch.time, currObj.color, currObj.thickness, op);
			(newStroke as KObject).originalId = (currObj as KObject).id;
			
			_interactionControl.end_interaction_operation();
			
			return (newStroke as KObject);
		}
		
		public function getCurrentTemplateObjectView():IObjectView
		{
			return _canvasView.getCurrentTemplateObjectView();
		}
		
		public function getCurrentObject(objID:int, template:Boolean):KObject
		{
			var object:KObject = null;
			
			for(var i:int=0; i<_KSketch.root.children.length(); i++)
			{
				var currObj:KObject = _KSketch.root.children.getObjectAt(i) as KObject;
				
				if(!template)
				{
					//grab the sketched object 
					if(currObj is KStroke && currObj.originalId == objID && currObj.id != currObj.originalId)
					{
						object = currObj;
						break;
					}
				}
				else
				{
					//grab the original template object
					if(currObj is KStroke && currObj.originalId == objID && currObj.id == currObj.originalId)
					{
						object = currObj;
						break;
					}
				}
				
			}
			
			return object;
		}
		
		public function getAllObjects(template:Boolean):KModelObjectList
		{
			var allRelatedObjects:KModelObjectList = new KModelObjectList();
			
			for(var i:int=0; i<_KSketch.root.children.length(); i++)
			{
				var currObj:KObject = _KSketch.root.children.getObjectAt(i) as KObject;
				
				if(currObj.template == template)
					allRelatedObjects.add(currObj);
				
			}
			return allRelatedObjects;
		}
		
		public function initRegion(object:DisplayObject, regionsArr:Array):int
		{
			var region:int = 0;
			
			if((regionsArr[0] as DisplayObject).hitTestObject(object))
				region = 1;
			else if((regionsArr[1] as DisplayObject).hitTestObject(object))
				region = 2;
			else if((regionsArr[2] as DisplayObject).hitTestObject(object))
				region = 3;
			else if((regionsArr[3] as DisplayObject).hitTestObject(object))
				region = 4;
			else if((regionsArr[4] as DisplayObject).hitTestObject(object))
				region = 5;
			else if((regionsArr[5] as DisplayObject).hitTestObject(object))
				region = 6;
			
			return region;
		}
		
		public function startIntroductionAnimation():void
		{
			_canvasView.timeControl.playRepeat = true;
			_canvasView.timeControl.play(true);
		}
		
		public function stopIntroductionAnimation():void
		{
			_canvasView.timeControl.playRepeat = false;
			_canvasView.timeControl.stop();
		}
		
		public function continueActivity():void
		{
			_isRetry = false;
			_instructionsBox.initNextInstruction();
			_canvasView.isEnabledInstructionsButton(true);
		}
		
		public function retryActivity():void
		{
			_isRetry = true;
			
			//only keep the latest sketch object drawn by user
			if(_activityType == "RECREATE")
				discardSketchedObjects();
			
			startActivity(_activityType);
			_instructionsBox.openInstructions();
			_canvasView.isEnabledInstructionsButton(true);
			_canvasView.setPenAccessibility(false);
			_canvasView.setControlAccessibility(false);
		}
		
		public function completeActivity():void
		{
			_canvasView.setTherapyCompletion();
		}
		
		public function getRegionByIndex(index:int):DisplayObject
		{
			var regionsArr:Array = regions;
			return regionsArr[index-1];
		}
		
		public function get regions():Array
		{
			return _canvasView.regions;
		}
		
		public function get modelDisplay():KModelDisplay
		{
			return _canvasView.modelDisplay;
		}
		
		public function get motionDisplay():KMotionDisplay
		{
			return _canvasView.motionDisplay;
		}
		
		public function get activityType():String
		{
			return _activityType;
		}
		
		public function get recallCounter():int
		{
			return _recallCounter;
		}
		
		public function get isAnimationPlaying():Boolean
		{
			return _isAnimationPlaying;
		}
		
		public function set isAnimationPlaying(value:Boolean):void
		{
			_isAnimationPlaying = value;
		}
		
		public function get currentObjectID():int
		{
			return _currentObjectID;		
		}
		
		public function get isNewSketch():Boolean
		{
			return _isNewSketch;
		}
		
		public function set isNewSketch(value:Boolean):void
		{
			_isNewSketch = value;
		}
		
		public function get stars():int
		{
			return _stars;
		}
		
		public function set stars(value:int):void
		{
			_stars = value;
		}
		
		public function get isRetry():Boolean
		{
			return _isRetry;
		}
		
		public function set isRetry(value:Boolean):void
		{
			_isRetry = value;
		}
		
		public function get currentIntruction():String
		{
			return _instructionsBox.currentInstructionMessage();
		}
		
		public function get time():Number
		{
			return _KSketch.time;
		}
		
		public function resetCanvas():void
		{
			_currentObjectID = _instructionsBox.currentObjectID();
			_currentManipulateObject = getCurrentObject(_currentObjectID, false);
			_currentTemplateObject = getCurrentObject(_currentObjectID, true);
			
			removeSelectObjectToAnimate();
			if(_activityType == "TRACE")
			{
				discardSketchedObjects();
				_setObjectProperties(false, true, false);
			}
		}
		
		public function closeCountDown():void
		{
			_instructionsBox.closeCountDown();
		}
		
		/*
		Get the canvas region where the center point of drawn object belongs to
		*/
		public function getDrawnObjectRegion(point:Point):int
		{
			var selectionArea:Sprite = new Sprite();
			selectionArea.graphics.clear();
			selectionArea.graphics.beginFill(0xFFFF22, 1);
			selectionArea.graphics.drawCircle(point.x, point.y, 2);
			selectionArea.graphics.endFill();
			_canvasView.modelDisplay.addChild(selectionArea);
			
			var regions:Array = _canvasView.regions;
			for(var i:int=0;i<regions.length;i++)
			{
				var index:int = i+1;
				var regionDisplay:DisplayObject = getRegionByIndex(index);
				if (regionDisplay){
					if(regionDisplay.hitTestObject(selectionArea)) 
					{
						_canvasView.modelDisplay.removeChild(selectionArea);
						return index;
					}
				}
			}			
			_canvasView.modelDisplay.removeChild(selectionArea);
			return 0;
		}

		private function showWrongResultForRecall(tapRegion:int):void
		{
			var so:SharedObject = SharedObject.getLocal("avatar");	
			var imgContainerArr:Array = [_canvasView.region_1_image, _canvasView.region_2_image, _canvasView.region_3_image, _canvasView.region_4_image, _canvasView.region_5_image, _canvasView.region_6_image];
			var img:Image = imgContainerArr[tapRegion-1];
			img.source = KSketch_Avatar.AVATAR_NEGATIVE[so.data.imageClass] as Class;
			img.visible = true;
			setTimeout(function():void{ img.visible = false; }, 1000);			
		}		
		
		/**
		 * Create and attach a text field to Therapy template object which is currently animated.
		 * 
		 * @param the target animation object
		 */
		private function _addLabelToTranslationObject(obj:KStroke, dictTranslate:Dictionary):void
		{
			if(dictTranslate != null)
				_updateLabel(dictTranslate[_KSketch.time], obj.transformMatrix(_KSketch.time).transformPoint(obj.center));				
		}
		
		private function _createLabel(point:Point):void{
			removeAnimationLabel();		
			_textfield = new TextField();
			_canvasView.modelDisplay.addChild(_textfield);
		}
		
		private function _updateLabel(content:int, point:Point):void{
			_textfield.text = String.fromCharCode(content);
			var textFormat:TextFormat = new TextFormat();
			textFormat.size = 50;
			textFormat.bold = true;
			_textfield.textColor = Color.RED;			
			_textfield.setTextFormat(textFormat);
			_textfield.x = point.x;
			_textfield.y = point.y;
		}
		
		public function removeAnimationLabel():void{
			if(_textfield  && _canvasView.modelDisplay.contains(_textfield))
				_canvasView.modelDisplay.removeChild(_textfield);	
		}
	}
}