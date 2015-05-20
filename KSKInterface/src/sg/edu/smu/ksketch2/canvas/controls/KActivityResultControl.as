package sg.edu.smu.ksketch2.canvas.controls
{
	import mx.collections.ArrayList;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.canvas.components.popup.KSketch_InstructionsBox;
	import sg.edu.smu.ksketch2.canvas.components.view.KSketch_CanvasView;
	import sg.edu.smu.ksketch2.model.objects.KResult;

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
				//result = measureTime(result);
				//TO DO: implement shape accuracy
				
				//measures = 3;
				//stars += starTime(result);
				//stars += starStartRegion(result);
				//stars += starShapeAccuracy(result);
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
			result.time = _instructionsBox.timeTaken;
			return result;
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
		
		public function measurePercentageScore(result:KResult):KResult
		{
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
		
		public function get resultArr():ArrayList
		{
			return _resultArr;
		}
		
	}
}