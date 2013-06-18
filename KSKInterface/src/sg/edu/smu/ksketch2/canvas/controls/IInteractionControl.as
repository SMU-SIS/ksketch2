/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.canvas.controls
{
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch2.operators.operations.IModelOperation;
	import sg.edu.smu.ksketch2.utils.KInteractionOperation;
	import sg.edu.smu.ksketch2.utils.KSelection;
	
	public interface IInteractionControl extends IEventDispatcher
	{
		function init():void;
		function reset():void;
		/**
		 * Determines the current transition mode.
		 * Please use KSketch2.TRANSITION_INTERPOLATED and KSketch2.TRANSITION_DEMONSTRATED as inputs.
		 * Changes to transition mode also trigger changes to the widget
		 */
		function set transitionMode(mode:int):void;
		function get transitionMode():int;
		
		/**
		 * Updates the application's current selection
		 * Triggers updates related to objects being selected and deselected.
		 */
		function set selection(selection:KSelection):void;
		function get selection():KSelection;
		
		/**
		 * Changes the interaction mode to selection mode.
		 * Objects can be selected in this mode and gestures can be drawn.
		 */
		function enterSelectionMode():void;
		function enterDrawingMode(drawModeType:String):void;
		
		/**
		 * Returns the interaction mode to the previous interaction mode.
		 * If the selection changed, this method will update the current interaction mode and switches
		 * the interaction mode if necessary.
		 * 
		 * Current Standing Conditions
		 * If(selection)
		 * 	active mode -> manipulation 
		 * 	if(selection changed)
		 * 		refresh widget
		 * else
		 * 	active mode -> drawing
		 */
		function determineMode():void;
		
		/**
		 * These three input methods will form the interface for all canvas inputs in the future
		 * Will allow the inputs to change without changing the interface.
		 * We can have touch and mouse inputs from the any IInteractionDelegates to trigger these events.
		 */
		/**
		 * Begins the canvas input sequence.
		 * Asks the current mode to perform the necessary procedures for
		 * its own input sequences.
		 */
		function beginCanvasInput(point:Point, isManipulation:Boolean, manipulationType:String):void;
		
		/**
		 * Updates the current input event.
		 * Will fail if the beginCanvasInput has not been triggered.
		 */
		function updateCanvasInput(point:Point):void;

		/**
		 * Completes the current input event.
		 */
		function completeCanvasInput():void;
		
		/**
		 * Adds an operation to the undo stack
		 * *Warning*
		 * If the redo stack has any operations in it, those operations will
		 * be removed from the redo stack
		 */
		function addToUndoStack(operation:IModelOperation):void;
		
		/**
		 * Undo method reverts the application state to before the previous operation
		 * Moves the operation to the redo stack
		 */
		function undo():void;
		
		/**
		 * Redo method reverts the application state to before the previous operation
		 * Moves the operation to the undo stack
		 */
		function redo():void;
		
		/**
		 * Returns true if there are operations in the undo stack.
		 */
		function get hasUndo():Boolean;
		
		/**
		 * Returns true if there are operations in the undo stack.
		 */
		function get hasRedo():Boolean;
		
		function triggerInterfaceUpdate():void;
		function get currentInteraction():KInteractionOperation;
		function begin_interaction_operation():void;
		function end_interaction_operation(operation:IModelOperation=null, newSelection:KSelection = null):void;
		function debugView():void
		
	}
}