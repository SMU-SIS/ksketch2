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
	import sg.edu.smu.ksketch2.controls.widgets.IWidget;
	import sg.edu.smu.ksketch2.events.KSketchEvent;
	import sg.edu.smu.ksketch2.operators.operations.IModelOperation;
	import sg.edu.smu.ksketch2.utils.KInteractionOperation;
	import sg.edu.smu.ksketch2.utils.KSelection;
	import sg.edu.smu.ksketch2.view.KModelDisplay;
	
	import spark.core.SpriteVisualElement;
	
	import views.canvas.interactors.KSelectionDelegator;
	
	public class KMobileInteractionControl extends EventDispatcher implements IInteractionControl
	{
		private var _KSketch:KSketch2;
		private var _transitionMode:int;
		private var _selection:KSelection;
		
		public function KMobileInteractionControl(KSketchInstance:KSketch2)
		{
			super(this);
			_KSketch = KSketchInstance;
		}
		
		public function set transitionMode(mode:int):void
		{
			_transitionMode = mode;
		}
		
		public function get transitionMode():int
		{
			return _transitionMode;
		}
		
		public function set selection(newSelection:KSelection):void
		{
			if(newSelection)
			{
				if(newSelection.objects.length() == 0)
					newSelection = null;
				else
				{
					if(!newSelection.isDifferentFrom(_selection))
						return;
				}
			}
			
			if(!_selection && !newSelection)
				return;
			
			var oldSelection:KSelection = _selection;
			_selection = newSelection;
			
			var i:int;
			var length:int;
			
			//Will trigger the selection/deselection
			//Will cause the objects to trigger their selection events
			if(oldSelection)
				oldSelection.triggerDeselected();
			
			if(newSelection)
				newSelection.triggerSelected();
			
			dispatchEvent(new KSketchEvent(KSketchEvent.EVENT_SELECTION_SET_CHANGED));
		}
		
		public function get selection():KSelection
		{
			return _selection;
		}
		
		/**
		 * For touch versions, call after every selection interaction
		 */
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
		
		public function begin_interaction_operation():void
		{
			
		}
		
		public function get currentInteraction():KInteractionOperation
		{
			return null;
		}
		
		public function end_interaction_operation(operation:IModelOperation=null, newSelection:KSelection=null):void
		{
			
		}
		
		public function debugView():void
		{
			
		}		
		
		/**
		 * Not required for touch
		 */
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
		public function enterDrawingMode(drawModeType:String):void
		{
			
		}
		
		public function init():void
		{
			
		}
		
		public function reset():void
		{
			
		}

		public function determineMode():void
		{
			
		}
		
		
		public function enterSelectionMode():void
		{
			
		}
	}
}