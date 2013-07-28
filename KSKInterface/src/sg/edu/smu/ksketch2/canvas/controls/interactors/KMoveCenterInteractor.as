package sg.edu.smu.ksketch2.canvas.controls.interactors
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.PanGesture;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.canvas.components.timebar.KSketch_TimeControl;
	import sg.edu.smu.ksketch2.canvas.controls.KInteractionControl;
	import sg.edu.smu.ksketch2.canvas.controls.interactors.draw.KInteractor;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.operators.operations.KChangeCenterOperation;
	
	/**
	 * The KCanvasInteractorManager class serves as the concrete class for
	 * moving the center of focused interface objects in K-Sketch.
	 */
	public class KMoveCenterInteractor extends KInteractor
	{
		public static const CENTER_CHANGE_ENDED:String = "Center Change Ended";
		
		private var _panGesture:PanGesture;
		
		private var _modelSpace:DisplayObject;
		private var _previousPoint:Point;
		private var _oldCenter:Point;
		private var _center:Point;
		
		/**
		 * The main constructor of the KMoveCenterInteractor class.
		 * 
		 * @param KSketchInstance The target ksketch instance that interacts with the mode.
		 * @param interactionControl The target interaction control that oversees mode switching.
		 * @param inputComponent The target input component that dispatches gesture events for the mode.
		 * @param modelDisplay The model display linked to the given ksketch object.
		 */
		public function KMoveCenterInteractor(KSketchInstance:KSketch2, interactionControl:KInteractionControl, inputComponent:DisplayObject, modelSpace:DisplayObject)
		{
			super(KSketchInstance, interactionControl);
			
			_modelSpace = modelSpace;
			_panGesture = new PanGesture(inputComponent);
			_panGesture.maxNumTouchesRequired = 1;
		}
		
		override public function reset():void
		{
			super.reset();
			_panGesture.removeAllEventListeners();
			
			activate();
		}
		
		override public function activate():void
		{
			super.activate();
			_panGesture.addEventListener(GestureEvent.GESTURE_BEGAN, _interaction_begin);
		}
		
		public function deactivate():void
		{
			_panGesture.removeAllEventListeners();
		}
		
		/**
		 * Begins the move center interaction.
		 * 
		 * @param event The gesture event.
		 */
		private function _interaction_begin(event:GestureEvent):void
		{
			_previousPoint = _panGesture.location;
			
			if(_interactionControl.selection.objects.length()==1)
			{
				var object:KObject = _interactionControl.selection.objects.getObjectAt(0);
				_oldCenter = object.center;
			}
			
			_interactionControl.begin_interaction_operation();
			_panGesture.addEventListener(GestureEvent.GESTURE_CHANGED, _update_Move);
			_panGesture.addEventListener(GestureEvent.GESTURE_ENDED, _interaction_end);			
		}
		
		/**
		 * Updates the move center interaction.
		 * 
		 * @param event The gesture event.
		 */
		private function _update_Move(event:GestureEvent):void
		{
			var touchLocation:Point = _panGesture.location;
			var change:Point = touchLocation.clone().subtract(_previousPoint);
			
			if(_interactionControl.selection.objects.length()==1)
			{
				var object:KObject = _interactionControl.selection.objects.getObjectAt(0);
				_KSketch.moveCenter(object, change.x, change.y);
			}
			
			_previousPoint = touchLocation;
		}
		
		/**
		 * Ends the move center interaction.
		 * 
		 * @param event The gesture event.
		 */
		private function _interaction_end(event:GestureEvent):void
		{
			var changeCenterOp:KChangeCenterOperation;
			if(_oldCenter)
			{
				var object:KObject = _interactionControl.selection.objects.getObjectAt(0);
				changeCenterOp = new KChangeCenterOperation(object, _oldCenter,object.center);
			}
			
			_interactionControl.end_interaction_operation(changeCenterOp, _interactionControl.selection);
			
			var log:XML = <op/>;
			var date:Date = new Date();
			
			log.@category = "Widget";
			log.@type = "Move Center";
			log.@elapsedTime = KSketch_TimeControl.toTimeCode(date.time - _KSketch.logStartTime);
			_KSketch.log.appendChild(log);
			
			_interactionControl.dispatchEvent(new Event(CENTER_CHANGE_ENDED));
			
			reset();
		}
	}
}