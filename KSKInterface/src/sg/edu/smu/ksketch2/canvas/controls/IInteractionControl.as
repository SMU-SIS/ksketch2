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
	
	/**
	 * The IInteractionControl class serves as the interface class for
	 * interaction control in K-Sketch.
	 */
	public interface IInteractionControl extends IEventDispatcher
	{
		/**
		 * Initializes the application's state variables of the interaction
		 * control.
		 */
		function init():void;
		
		/**
		 * Resets the application's state variables of the interaction
		 * control.  Specifically, resets the following state variables:
		 * 
		 * <ul>
		 * <li>application state variables</li>
		 * <li>undo/redo stacks</li>
		 * <li>selection</li>
		 * <li>interaction state</li>
		 * <li>time control</li>
		 * </ul>
		 */
		function reset():void;
		
		/**
		 * Sets the current transition mode of the interaction control.
		 * Please use KSketch2.TRANSITION_INTERPOLATED and
		 * KSketch2.TRANSITION_DEMONSTRATED as arguments. Changes to
		 * transition mode also trigger changes to the widget.
		 * 
		 * @param mode The target transition mode.
		 */
		function set transitionMode(mode:int):void;
		
		/**
		 * Gets the current transition mode of the interaction control.
		 * 
		 * @return The target current transition mode.
		 */
		function get transitionMode():int;
		
		/**
		 * Sets the application's current selection, and also triggers
		 * updates related to objects being selected and deselected.
		 * 
		 * @param selection The target current selection.
		 */
		function set selection(selection:KSelection):void;
		
		/**
		 * Gets the application's current selection.
		 * 
		 * @param The target current selection.
		 */
		function get selection():KSelection;
		
		/**
		 * Enters the interaction mode to selection mode. Objects can be selected in this mode.
		 */
		function enterSelectionMode():void;
		
		/**
		 * Enters the interaction mode to drawing mode. Gestures can be drawn in this mode.
		 * 
		 * @param drawModeType The target draw mode type.
		 */
		function enterDrawingMode(drawModeType:String):void;
		
		/**
		 * Determines the interaction mode to the previous interaction
		 * mode. If the selection changed, the method will update the
		 * current interaction mode and switch the interaction mode if
		 * necessary.<br>
		 * 
		 * <code>
		 * Current Standing Conditions:<br>
		 * if(selection)<br>
		 *    active mode -> manipulation<br>
		 * 	  if(selection changed)<br>
		 *       refresh widget<br>
		 * else<br>
		 *    active mode -> drawing<br>
		 * </code>
		 */
		function determineMode():void;
		
		/**
		 * Begins the canvas input sequence by requesting the current mode
		 * to perform the necessary procedures for its own input sequences.
		 * This is one of three input methods that will form the interface
		 * for all canvas inputs in the future, which will allow the inputs
		 * to change without changing the interface. We can have touch and
		 * mouse inputs from any interaction delegates trigger these
		 * events.
		 * 
		 * @param point The target canvas point.
		 * @param isManipulation The target boolean flag for determining whether manipulating is enabled.
		 * @param manipulation The target manipulation type.
		 */
		function beginCanvasInput(point:Point, isManipulation:Boolean, manipulationType:String):void;
		
		/**
		 * Updates the current input event, and will fail if the method
		 * for beginning canvas input has not been triggered yet.  This is
		 * one of three input methods that will form the interface for all
		 * canvas inputs in the future, which will allow the inputs to
		 * change without changing the interface. We can have touch and
		 * mouse inputs from any interaction delegates trigger these
		 * events.
		 * 
		 * @param point The target canvas point.
		 */
		function updateCanvasInput(point:Point):void;

		/**
		 * Completes the current input event. This is one of three input
		 * methods that will form the interface for all canvas inputs in
		 * the future, which will allow the inputs to change without
		 * changing the interface. We can have touch and mouse inputs from
		 * any interaction delegates trigger these events.
		 */
		function completeCanvasInput():void;
		
		/**
		 * Adds an operation to the undo stack. Warning: If the redo stack
		 * has any operations in it, those operations will be removed from
		 * the redo stack.
		 * 
		 * @param operation The target model operation.
		 */
		function addToUndoStack(operation:IModelOperation):void;
		
		/**
		 * Undoes the application state to before the previous operation,
		 * and moves the operation to the redo stack.
		 */
		function undo():void;
		
		/**
		 * Redoes the application state to before the previous operation,
		 * and moves the operation to the undo stack.
		 */
		function redo():void;
		
		/**
		 * Determines whether there are any operations in the undo stack.
		 * 
		 * @return Whether there are any operations in the undo stack.
		 */
		function get hasUndo():Boolean;
		
		/**
		 * Determins whether there are any operations in the redo stack.
		 * 
		 * @return Whether there are any operations in the redo stack.
		 */
		function get hasRedo():Boolean;
		
		/**
		 * Triggers an interface update.
		 */
		function triggerInterfaceUpdate():void;
		
		/**
		 * Gets the current interaction opeartion.
		 * 
		 * @return The current interaction operation.
		 */
		function get currentInteraction():KInteractionOperation;
		
		/**
		 * Begins the interaction operation.
		 */
		function begin_interaction_operation():void;
		
		/**
		 * Ends the interaction operation.
		 * 
		 * @param operation The target model operation.
		 * @param newSelection The target new selection.
		 */
		function end_interaction_operation(operation:IModelOperation=null, newSelection:KSelection = null):void;
		
		/**
		 * Debugs the current view.
		 */
		function debugView():void;
	}
}