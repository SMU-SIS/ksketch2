package sg.edu.smu.ksketch2.canvas.controls
{
	import flash.display.DisplayObject;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.canvas.components.popup.KSketch_InstructionsBox;
	import sg.edu.smu.ksketch2.canvas.components.view.KModelDisplay;
	import sg.edu.smu.ksketch2.canvas.components.view.KSketch_CanvasView;
	import sg.edu.smu.ksketch2.canvas.components.view.objects.IObjectView;
	import sg.edu.smu.ksketch2.canvas.components.view.objects.KStrokeView;
	import sg.edu.smu.ksketch2.events.KSketchEvent;
	import sg.edu.smu.ksketch2.model.data_structures.KModelObjectList;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.model.objects.KStroke;
	import sg.edu.smu.ksketch2.utils.KSelection;

	public class KActivityControl
	{
		private var _instructionsBox:KSketch_InstructionsBox;
		private var _canvasView:KSketch_CanvasView;
		private var _KSketch:KSketch2;
		private var _interactionControl:KInteractionControl;
		
		private var _currentObjectID:int;
		private var _currentObject:KObject;
		private var _activityType:String = "SKETCH";
		private var _isAnimationPlaying:Boolean;
		private var _isNewSketch:Boolean;
		private var _recallCounter:int;
		
		public function KActivityControl(instructionsBox:KSketch_InstructionsBox, canvas:KSketch_CanvasView, ksketch:KSketch2, interaction:KInteractionControl)
		{
			_instructionsBox = instructionsBox;
			_canvasView = canvas;
			_KSketch = ksketch;
			_interactionControl = interaction;
		}
		
		public function startActivity(activity:String):void
		{
			var currentInstruction:int = _instructionsBox.currentInstruction();
			_currentObjectID = _instructionsBox.currentObjectID();
			
			var currObj:KObject = null;
			for(var i:int=0; i<_KSketch.root.children.length(); i++)
			{
				currObj = _KSketch.root.children.getObjectAt(i) as KObject;
				if(currObj is KStroke && currObj.originalId == _currentObjectID)
					break;
			}
			
			if(currObj)
				_currentObject = currObj;
			
			//Reset settings
			if(currentInstruction == 0)
			{
				_canvasView.setRegionVisibility(false);
				_setObjectProperties(false, false, false);
			}
			_canvasView.resetTimeControl();
			_interactionControl.selection = null;
			
			if(activity == "INTRO")
			{
				_activityType = "INTRO";
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
				_activityType = "TRACE";
				_discardSketchedObjects();
				_setObjectProperties(false, true, false);
			}
			else if(activity == "TRACK")
			{ 
				_activityType = "TRACK";
				_currentObject = _getCurrentObjectToTrack(false);
				_setObjectProperties(false, false, true);
				_hideObjects(true);
				processTrack(_currentObject as KStroke);
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
						if(currObj.id == _currentObject.id)
							(view as KStrokeView).changeActivityHighlight(_KSketch.time, false);
						else
							(view as KStrokeView).changeActivityHighlight(_KSketch.time, true);
					}
					else if(isTrack)
					{
						currObj.template = true;
						(view as KStrokeView).changeActivityHighlight(_KSketch.time, false);
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
		}
		
		public function processRecall(correctRecall:Boolean):void
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
				
				_instructionsBox.open(_canvasView, false);
				_instructionsBox.startStopActivity();
			}
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
		}

		public function processTrack(currObj:KStroke):void
		{
			if(currObj)	//if there is a sketched object
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
			else //make a duplicate of the template object and use it
			{
				/*This portion creates a duplicate object
				_interactionControl.begin_interaction_operation();
				
				var op:KCompositeOperation = new KCompositeOperation();
				var newStroke:KStroke = _KSketch.object_Add_Stroke(currObj.points, _KSketch.time, currObj.color, currObj.thickness, op);
				
				//do a hit test objects between regions and this view
				var view:KStrokeView = modelDisplay.viewsTable[newStroke];
				var region:int = initRegion(view, regions);
				newStroke.initRegion(region, region);
				
				// create a new list of model objects
				var newObjects:KModelObjectList = new KModelObjectList();
				
				// add the new stroke to the list of model objects
				newObjects.add(newStroke);
				
				// end the interaction
				_interactionControl.end_interaction_operation(op, new KSelection(newObjects));*/
			}
		}
		
		private function _getCurrentObjectToTrack(useTemplate:Boolean):KObject
		{
			var currObj:KObject = null;
			for(var i:int=0; i<_KSketch.root.children.length(); i++)
			{
				currObj = _KSketch.root.children.getObjectAt(i) as KObject;
				
				if(!useTemplate)
				{
					if(currObj is KStroke && currObj.id != currObj.originalId && currObj.originalId == _currentObjectID)
						break;
				}
				else
				{
					if(currObj is KStroke && currObj.id == currObj.originalId && currObj.originalId == _currentObjectID)
						break;
				}
			}
			
			return currObj;
		}
		
		public function autoSelectObjectToAnimate():void
		{
			if(_currentObject)
			{
				var selectedList:KModelObjectList = new KModelObjectList();
				selectedList.add(_currentObject);
				_interactionControl.selection = new KSelection(selectedList);
			}
		}
		
		private function _discardSketchedObjects():void
		{
			var tempArr:Array = new Array(_KSketch.root.children.length());
			var i:int;
			var currObj:KObject;
			
			for(i=0; i<_KSketch.root.children.length(); i++)
			{
				currObj = _KSketch.root.children.getObjectAt(i) as KObject;
				if(currObj is KStroke)
				{
					if(currObj.id != currObj.originalId && currObj.originalId == _currentObjectID)
					{
						_removeAnimationFromObject(currObj);
						tempArr[i] = currObj;
					}
				}	
			}
			
			for(i=0; i<tempArr.length; i++)
			{
				if(tempArr[i] as KStroke)
				{
					currObj = tempArr[i];
					
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
					
					trace("hide this view and obj " + currObj.id);
					/*This portion will delete the stroke/view
					var view:IObjectView = _canvasView.modelDisplay.viewsTable[currObj];
					var op:KCompositeOperation = new KCompositeOperation();
					(view as KStrokeView).hardErase(_KSketch.time, _interactionControl.currentInteraction);*/
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
		
		public function getCurrentObject():IObjectView
		{
			return _canvasView.getCurrentObject();
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
			_instructionsBox.initNextInstruction();
		}
		
		public function retryActivity():void
		{
			startActivity(_activityType);
			_instructionsBox.openInstructions();
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
	}
}