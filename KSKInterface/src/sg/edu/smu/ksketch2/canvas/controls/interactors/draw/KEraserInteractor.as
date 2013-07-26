/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.canvas.controls.interactors.draw
{
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.canvas.controls.IInteractionControl;
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;
	import sg.edu.smu.ksketch2.canvas.components.view.objects.IObjectView;
	import sg.edu.smu.ksketch2.canvas.components.view.KModelDisplay;
	import sg.edu.smu.ksketch2.canvas.components.view.objects.KObjectView;
	
	/**
	 * The KEraserInteractor class serves as the concrete class for erase
	 * interactors in K-Sketch.
	 */
	public class KEraserInteractor extends KInteractor
	{
		private var _currentOperation:KCompositeOperation;	// the current operation
		private var _modelDisplay:KModelDisplay;			// the model display
		private var _startPoint:Point;						// the start point
		private var _currentPoint:Point;					// the current point
		
		/**
		 * The main constructor for the KEraserInteractor class.
		 * 
		 * @param KSketchInstance The target ksketch instance.
		 * @param interactionControl The target interaction control.
		 * @param modelDisplay The target model display.
		 */
		public function KEraserInteractor(KSketchInstance:KSketch2, interactionControl:IInteractionControl, modelDisplay:KModelDisplay)
		{
			super(KSketchInstance, interactionControl);
			_modelDisplay = modelDisplay;
		}
		
		/**
		 * Begins the erase interaction.
		 * 
		 * @param point The target point.
		 */
		override public function interaction_Begin(point:Point):void
		{
			// begin the interaction
			_interactionControl.begin_interaction_operation();
			
			// create the corresponding composite operation
			_currentOperation = new KCompositeOperation();
		}
		
		/**
		 * Updates the erase interaction. Specifically, removes the point
		 * for each active view.
		 * 
		 * @param point The target point.
		 */
		override public function interaction_Update(point:Point):void
		{
			// create the view
			var view:IObjectView;
			
			// converts the point to stage (i.e., global) coordinates
			point = _modelDisplay.localToGlobal(point);
			
			// iterate through each view
			for each (view in _modelDisplay.viewsTable)
			{
				// case: iterate through each active view
				// delete the point at the given view
				if((view as KObjectView).alpha > 0)
					(view as KObjectView).eraseIfHit(point.x, point.y, _KSketch.time, _currentOperation);
			}
		}
		
		/**
		 * Ends the erase interaction.
		 */
		override public function interaction_End():void
		{
			if(_currentOperation.length == 0)
				_interactionControl.end_interaction_operation();
			else
				_interactionControl.end_interaction_operation(_currentOperation, null);
		}
	}
}