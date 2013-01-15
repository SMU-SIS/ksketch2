/**
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
*/
package views.canvas.interactioncontrol
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.controls.interactioncontrol.IInteractionControl;
	import sg.edu.smu.ksketch2.controls.interactionmodes.IInteractionMode;
	import sg.edu.smu.ksketch2.controls.interactionmodes.KDrawingMode;
	import sg.edu.smu.ksketch2.operators.operations.IModelOperation;
	import sg.edu.smu.ksketch2.utils.KInteractionOperation;
	import sg.edu.smu.ksketch2.utils.KSelection;
	import sg.edu.smu.ksketch2.view.KModelDisplay;
	
	import spark.core.SpriteVisualElement;
	
	import views.canvas.modes.KMultiPurposeTouchMode;
	import views.canvas.modes.KMultitouchManipulationMode;
	
	public class KMobileInteractionControl extends EventDispatcher implements IInteractionControl
	{
		private var _KSketch:KSketch2;
		private var _displayContainer:KModelDisplay; //display container to visualise model objects
		private var _interactionDisplay:SpriteVisualElement; //display contianer to visualise graphics that appear during interaction. for debugging
		private var _inputComponent:UIComponent; //component that receives the touch inputs
		
		private var _activeMode:IInteractionMode;
		private var _defaultInteractionMode:IInteractionMode;
		private var _manipulationMode:IInteractionMode;
		
		public function KMobileInteractionControl(KSketchInstance:KSketch2, inputComponent:UIComponent,
												  interactionDisplay:SpriteVisualElement
												  , displayContainer:KModelDisplay)
		{
			super(this);
			_KSketch = KSketchInstance;
			_inputComponent = inputComponent;
			_displayContainer = displayContainer;
		}
		
		public function init():void
		{
			_defaultInteractionMode = new KMultiPurposeTouchMode(_KSketch, this, _inputComponent, _displayContainer);
			_manipulationMode = new KMultitouchManipulationMode();
			determineMode();
		}
		
		public function reset():void
		{
			
		}
		
		public function set transitionMode(mode:int):void
		{
			
		}
		
		public function get transitionMode():int
		{
			return 0;
		}
		
		public function set selection(selection:KSelection):void
		{
		}
		
		public function get selection():KSelection
		{
			return null;
		}
		
		public function enterSelectionMode():void
		{
			
		}
		
		public function enterDrawingMode(drawModeType:String):void
		{
			
		}
		
		public function determineMode():void
		{
			_activeMode = _defaultInteractionMode;
			_activeMode.init();
		}
		
		public function beginCanvasInput(point:Point, isManipulation:Boolean, manipulationType:String):void
		{
			//Disabled for touch
		}
		
		public function updateCanvasInput(point:Point):void
		{
			//Disabled for touch
		}
		
		public function completeCanvasInput():void
		{
			//Disabled for touch
		}
		
		public function addToUndoStack(operation:IModelOperation):void
		{
		}
		
		public function undo():void
		{
		}
		
		public function redo():void
		{
		}
		
		public function get hasUndo():Boolean
		{
			return false;
		}
		
		public function get hasRedo():Boolean
		{
			return false;
		}
		
		public function triggerInterfaceUpdate():void
		{
			
		}
		
		public function get currentInteraction():KInteractionOperation
		{
			return null;
		}
		
		public function begin_interaction_operation():void
		{
			
		}
		
		public function end_interaction_operation(operation:IModelOperation=null, newSelection:KSelection=null):void
		{
			
		}
		
		public function debugView():void
		{
			
		}
	}
}