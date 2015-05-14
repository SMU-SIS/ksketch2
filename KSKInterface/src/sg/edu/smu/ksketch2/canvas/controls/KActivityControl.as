package sg.edu.smu.ksketch2.canvas.controls
{
	import flash.display.DisplayObject;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.canvas.components.popup.KSketch_InstructionsBox;
	import sg.edu.smu.ksketch2.canvas.components.view.KModelDisplay;
	import sg.edu.smu.ksketch2.canvas.components.view.KSketch_CanvasView;
	import sg.edu.smu.ksketch2.canvas.components.view.objects.IObjectView;
	import sg.edu.smu.ksketch2.canvas.components.view.objects.KStrokeView;
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
			
			if(currentInstruction == 0 && activity != "INTRO")
				resetAllActivities();
			
			_canvasView.resetTimeControl();
			
			if(activity == "INTRO")
			{
				_activityType = "INTRO";
				this.startIntroductionAnimation();
				_isAnimationPlaying = true;
			}
			else if(activity == "RECALL")
			{
				_activityType = "RECALL";
				
				if(currentInstruction == 0)
					setObjectProperties(true, false, false);	
				
				_canvasView.setRegionVisibility(true);
			}
			else if(activity == "TRACE")
			{ 
				_activityType = "TRACE";
				
				if(currentInstruction == 0)
					setObjectProperties(true, false, true);
			}
			else if(activity == "TRACK")
			{ 
				var currObj:KObject = null;
			
				for(var i:int=0; i<_KSketch.root.children.length(); i++)
				{
					currObj = _KSketch.root.children.getObjectAt(i) as KObject;
					if(currObj is KStroke && currObj.id != currObj.originalId && currObj.originalId == _currentObjectID)
						break;
				}
				
				if(currObj)
				{
					_currentObject = currObj;
					setObjectProperties(true, false, true);
					processTrack(_currentObject as KStroke);
				}
			}
			else if(activity == "RECREATE")
			{ 
				trace("*********Implement RECREATE function*********"); 
			}
		}
		
		public function setObjectProperties(template:Boolean, visible:Boolean, isTraceTrack:Boolean):void
		{
			for(var i:int=0; i<_KSketch.root.children.length(); i++)
			{
				var currObj:KObject = _KSketch.root.children.getObjectAt(i) as KObject;
				if(currObj is KStroke)
				{
					currObj.template = template;
					
					var view:IObjectView = _canvasView.modelDisplay.viewsTable[currObj];
					
					if(isTraceTrack && template)
						(view as KStrokeView).changeActivityHighlight(_KSketch.time);	
					else
					{
						(view as KStrokeView).resetActivityHighlight(_KSketch.time);
						(view as DisplayObject).visible = visible;
					}
				}	
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

		public function processIntro(correctRecall:Boolean):void
		{
			if(correctRecall)
			{
				_instructionsBox.startStopActivity();
				
				setObjectProperties(true, false, false);	
				_canvasView.setRegionVisibility(true);	
			}
		}
		
		public function processTrack(currObj:KStroke):void
		{
			//unhide current object and disable it as a template
			var tempArr:Array = new Array(_KSketch.root.children.length());
			var view:IObjectView;
			
			var currOriginalID:int = currObj.originalId;
			currObj.template = false;
			view = _canvasView.modelDisplay.viewsTable[currObj];
			(view as KStrokeView).resetActivityHighlight(_KSketch.time);
			
			for(var i:int=0; i<_KSketch.root.children.length(); i++)
			{
				var testObj:KObject;
				testObj = _KSketch.root.children.getObjectAt(i) as KObject;
				if(testObj is KStroke && testObj.originalId != currOriginalID)
				{
					if(testObj.id == testObj.originalId)
						tempArr[i] = currObj;
				}
			}
			
			_interactionControl.begin_interaction_operation();
			for(i=0; i<tempArr.length; i++)
			{
				if(tempArr[i] is KStroke)
				{
					currObj = tempArr[i];
					view = _canvasView.modelDisplay.viewsTable[testObj];
					(view as KStrokeView).hardErase(_KSketch.time, _interactionControl.currentInteraction);
				}
			}
			_interactionControl.end_interaction_operation();
			
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
		
		public function autoSelectObjectToAnimate():void
		{
			//select the currObj - turn on the manipulator
			if(_currentObject)
			{
				var selectedList:KModelObjectList = new KModelObjectList();
				selectedList.add(_currentObject);
				_interactionControl.selection = new KSelection(selectedList);
			}
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
		
		public function hideAllNewlyCreatedObjects():void
		{
			//CAM: for now discard object that has originalId != id
			//later implement accuracy measure to detect either use template or use new objects
			_interactionControl.begin_interaction_operation();
			
			var tempArr:Array = new Array(_KSketch.root.children.length());
			var i:int;
			var currObj:KObject
			
			for(i=0; i<_KSketch.root.children.length(); i++)
			{
				currObj = _KSketch.root.children.getObjectAt(i) as KObject;
				if(currObj is KStroke && !currObj.template && currObj.id != currObj.originalId)
				{
					tempArr[i] = currObj;
				}	
			}
			
			for(i=0; i<tempArr.length; i++)
			{
				if(tempArr[i] is KStroke)
				{
					currObj = tempArr[i];
					
					//This portion will hide the stroke/view
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
		
		public function resetAllActivities():void
		{
			hideAllNewlyCreatedObjects();
			_canvasView.setRegionVisibility(false);
			setObjectProperties(false, true, false);
		}
		
		public function get modelDisplay():KModelDisplay
		{
			return _canvasView.modelDisplay;
		}
		
		public function get regions():Array
		{
			return _canvasView.regions;
		}
		
		public function getRegionByIndex(index:int):DisplayObject
		{
			var regionsArr:Array = regions;
			return regionsArr[index-1];
		}
		
		public function get activityType():String
		{
			return _activityType;
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
		
		public function getCurrentObject():IObjectView{
			return _canvasView.getCurrentObject();
		}
	}
}