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
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;
	import sg.edu.smu.ksketch2.utils.KSelection;

	public class KActivityControl
	{
		private var _instructionsBox:KSketch_InstructionsBox;
		private var _canvasView:KSketch_CanvasView;
		private var _KSketch:KSketch2;
		private var _interactionControl:KInteractionControl;
		
		private var _currentObjectID:int;
		private var _activityType:String;
		private var _isAnimationPlaying:Boolean;
		
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
			
			if(currentInstruction == 0)
				resetAllActivities();
			
			if(activity == "RECALL")
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
					if(currObj is KStroke && currObj.id == _currentObjectID)
						break;
				}
				
				if(currObj)
				{
					//set object properties - template and isTraceTrack to true
					setObjectProperties(true, false, true);
					
					//create a duplicate for the object that matches the instruction
					processTrack(currObj as KStroke);
					
					//set _interactionControl.selection to the duplicated object
					//set widget to demonstration mode
					//play animation	
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
		
		public function processTrack(currObj:KStroke):void
		{
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
			_interactionControl.end_interaction_operation(op, new KSelection(newObjects));
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
		
		public function discardNewlyCreatedObjects():void
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
					var view:IObjectView = _canvasView.modelDisplay.viewsTable[currObj];
					var op:KCompositeOperation = new KCompositeOperation();
					(view as KStrokeView).hardErase(_KSketch.time, _interactionControl.currentInteraction);
				}
			}
			
			_interactionControl.end_interaction_operation();
			tempArr = null;
		}
		
		public function stopIntroductionAnimation():void
		{
			_canvasView.timeControl.playRepeat = false;
			_canvasView.timeControl.stop();
		}
		
		public function resetAllActivities():void
		{
			discardNewlyCreatedObjects();
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
	}
}