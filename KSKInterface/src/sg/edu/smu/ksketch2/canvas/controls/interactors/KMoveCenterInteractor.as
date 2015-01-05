package sg.edu.smu.ksketch2.canvas.controls.interactors
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.PanGesture;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.canvas.components.transformWidget.KSketch_Widget_Component;
	import sg.edu.smu.ksketch2.canvas.controls.KInteractionControl;
	import sg.edu.smu.ksketch2.canvas.controls.interactors.draw.KInteractor;
	import sg.edu.smu.ksketch2.model.data_structures.KModelObjectList;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.operators.operations.KChangeCenterOperation;
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;
	import sg.edu.smu.ksketch2.utils.KSelection;
	
	/**
	 * The KCanvasInteractorManager class serves as the concrete class for
	 * moving the center of focused interface objects in K-Sketch.
	 */
	public class KMoveCenterInteractor extends KInteractor
	{
		public static const CENTER_CHANGE_ENDED:String = "Center Change Ended";
		
		private var _panGesture:PanGesture;
		private var _widget:DisplayObject;
		private var _modelSpace:DisplayObject;
		private var _previousPoint:Point;
		private var _oldCenter:Point;
		private var _center:Point;
		
		private var op:KCompositeOperation;
		
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
			
			_widget = inputComponent;
			_modelSpace = modelSpace;
			_panGesture = new PanGesture(inputComponent);
			_panGesture.maxNumTouchesRequired = 1;
		}
		
		override public function reset():void
		{
			super.reset();
			_panGesture.removeAllEventListeners();
		}
		
		override public function activate():void
		{
			super.activate();
			
			_enlargeSelectArea();
			
			_panGesture.addEventListener(GestureEvent.GESTURE_BEGAN, _interaction_begin);
		}
		
		public function deactivate():void
		{
			_resetSelectArea();
			_panGesture.removeAllEventListeners();
		}
		
		/**
		 * Begins the move center interaction.
		 * 
		 * @param event The gesture event.
		 */
		private function _interaction_begin(event:GestureEvent):void
		{
			var object:KObject;
			op = new KCompositeOperation();
			
			_previousPoint = _panGesture.location;
			_interactionControl.begin_interaction_operation();
			
			if(_interactionControl.selection.objects.length()>1)
			{
				var newObjectList:KModelObjectList = _KSketch.hierarchy_Group(_interactionControl.selection.objects, _KSketch.time, false, op);	
				_interactionControl.selection = new KSelection(newObjectList);
			}
			
			object = _interactionControl.selection.objects.getObjectAt(0);
				
			_oldCenter = object.center;
			
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
				op.addOperation(changeCenterOp);
			}
			
			_interactionControl.end_interaction_operation(op, _interactionControl.selection);
			
			_interactionControl.dispatchEvent(new Event(CENTER_CHANGE_ENDED));
			
			_resetSelectArea();
			
			reset();
			
			//LOG
			_KSketch.logCounter ++;
			var log:XML = <Action/>;
			var date:Date = new Date();
			log.@category = "Move Center";
			log.@type = "Perform Rotate";
			//trace("ACTION " + _KSketch.logCounter + ": Move Center of Object");
			KSketch2.log.appendChild(log);
		}
		
		private function _enlargeSelectArea():void
		{
			(_widget as KSketch_Widget_Component).centroidMove.graphics.beginFill(0x000000, 0);
			(_widget as KSketch_Widget_Component).centroidMove.graphics.drawRect(-125,-125,250,250);
			(_widget as KSketch_Widget_Component).centroidMove.graphics.endFill();
		}
		
		private function _resetSelectArea():void
		{
			(_widget as KSketch_Widget_Component).centroidMove.graphics.clear();
		}
	}
}