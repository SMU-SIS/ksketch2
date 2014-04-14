package sg.edu.smu.ksketch2.canvas.controls.interactors
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.TransformGesture;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.KSketchStyles;
	import sg.edu.smu.ksketch2.canvas.components.timebar.KSketch_TimeControl;
	import sg.edu.smu.ksketch2.canvas.components.transformWidget.KSketch_Widget_Component;
	import sg.edu.smu.ksketch2.canvas.controls.KInteractionControl;
	import sg.edu.smu.ksketch2.canvas.controls.interactors.draw.KInteractor;
	import sg.edu.smu.ksketch2.model.data_structures.KModelObjectList;
	import sg.edu.smu.ksketch2.model.objects.KGroup;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.operators.operations.KChangeCenterOperation;
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;
	import sg.edu.smu.ksketch2.utils.KMathUtil;
	import sg.edu.smu.ksketch2.utils.KSelection;
	
	/**
	 * The KCanvasInteractorManager class serves as the concrete class for
	 * moving the center of focused interface objects in K-Sketch.
	 */
	public class KMoveCenterInteractor extends KInteractor
	{
		public static const CENTER_CHANGE_ENDED:String = "Center Change Ended";
		
		private var _panGesture:TransformGesture;
		
		private var _widget:DisplayObject;
		private var _modelSpace:DisplayObject;
		private var _previousPoint:Point;
		private var _oldCenter:Point;
		private var _center:Point;
		
		private var op:KCompositeOperation;
		
		public var isMoving:Boolean = false;
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
			_panGesture = new TransformGesture(_widget);
			trace("Constructor: " + (_panGesture.target as DisplayObject).transform.matrix.toString());
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
			
			if(object is KGroup)
				(object as KGroup).moveCenter = true;
			
			_oldCenter = object.center;
			_KSketch.beginMoveCenter(object);
			
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
			const gesture:TransformGesture = event.target as TransformGesture;
			
			var touchLocation:Point = _panGesture.location;
			//var change:Point = touchLocation.clone().subtract(_previousPoint);
			
			if(_interactionControl.selection.objects.length()==1)
			{
				var object:KObject = _interactionControl.selection.objects.getObjectAt(0);
				
				//if there is a rotation in object's fullpathmatrix
				if(object.fullPathMatrix(_KSketch.time).b != 0 && object.fullPathMatrix(_KSketch.time).c != 0)
				{
					//get angle of rotation
					var rot:Number = KMathUtil.getRotation(object.fullPathMatrix(_KSketch.time));
					
					//set widget's transform matrix to rotate same angle
					var testMatrix:Matrix = (_panGesture.target as DisplayObject).transform.matrix;
					testMatrix.rotate(rot);
					(_panGesture.target as DisplayObject).transform.matrix = testMatrix;
					trace("WTF 1: " + (_panGesture.target as DisplayObject).transform.matrix.toString());
				}
				
				//change = touchLocation.subtract(_previousPoint);
				_KSketch.moveCenter(object, gesture.offsetX, gesture.offsetY); //change.x, change.y);
				
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
				
				_KSketch.endMoveCenter(object);
				
				//reset widget to original matrix
				var testMatrix:Matrix = (_panGesture.target as DisplayObject).transform.matrix;
				testMatrix.a = 1;
				testMatrix.b = 0;
				testMatrix.c = 0;
				testMatrix.d = 1;
				(_panGesture.target as DisplayObject).transform.matrix = testMatrix;
				trace("WTF 2 !!! " + (_panGesture.target as DisplayObject).transform.matrix.toString());
			}
			
			_interactionControl.end_interaction_operation(op, _interactionControl.selection);
			
			var log:XML = <op/>;
			var date:Date = new Date();
			
			log.@category = "Widget";
			log.@type = "Move Center";
			log.@elapsedTime = KSketch_TimeControl.toTimeCode(date.time - _KSketch.logStartTime);
			_KSketch.log.appendChild(log);
			
			_interactionControl.dispatchEvent(new Event(CENTER_CHANGE_ENDED));
			
			_resetSelectArea();
			
			reset();
		}
		
		private function _enlargeSelectArea():void
		{
			(_widget as KSketch_Widget_Component).centroid.graphics.beginFill(0x000000, 0);
			(_widget as KSketch_Widget_Component).centroid.graphics.drawCircle(0,0,60);
			(_widget as KSketch_Widget_Component).centroid.graphics.endFill();
		}
		
		private function _resetSelectArea():void
		{
			(_widget as KSketch_Widget_Component).centroid.graphics.clear();
			(_widget as KSketch_Widget_Component).strokeColor = KSketchStyles.WIDGET_INTERPOLATE_COLOR;
			
			(_widget as KSketch_Widget_Component).centroid.graphics.beginFill(KSketchStyles.WIDGET_PERFORM_COLOR);
			(_widget as KSketch_Widget_Component).centroid.graphics.drawCircle(0,0,KSketchStyles.WIDGET_CENTROID_SIZE);
			(_widget as KSketch_Widget_Component).centroid.graphics.endFill();
		}
	}
}