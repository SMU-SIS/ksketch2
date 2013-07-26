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
	import sg.edu.smu.ksketch2.model.data_structures.KModelObjectList;
	import sg.edu.smu.ksketch2.model.objects.KStroke;
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;
	import sg.edu.smu.ksketch2.utils.KSelection;
	import sg.edu.smu.ksketch2.canvas.components.view.objects.KStrokeView;
	
	import spark.core.SpriteVisualElement;

	/**
	 * The KDrawInteractor class serves as the concrete class for draw
	 * interactors in K-Sketch.
	 */
	public class KDrawInteractor extends KInteractor
	{
		/**
		 * The pen color.
		 */
		public static var penColor:uint = 0X000000;
		
		/**
		 * The pen thickness.
		 */
		public static var penThickness:Number = 3.5;
		
		private var _temporaryStroke:KStrokeView;				// the temporary stroke
		private var _points:Vector.<Point>;						// the stroke points
		
		protected var _interactorDisplay:SpriteVisualElement;	// the interactor display
		
		/**
		 * The main constructor for the KDrawInteractor class.
		 * 
		 * @param KSketch2 The target ksketch instance.
		 * @param interactorDisplay The target interactor display.
		 * @param interactionControl The target interaction control.
		 */
		public function KDrawInteractor(KSKetchInstance:KSketch2, interactorDisplay:SpriteVisualElement, interactionControl:IInteractionControl)
		{
			_interactorDisplay = interactorDisplay;
			super(KSKetchInstance, interactionControl);
			_temporaryStroke = new KStrokeView(null);
		}
		
		/**
		 * Begins the draw interaction. Specifically, begins the
		 * interaction by updating the interaction with the first point.
		 * Note: This temporary view has no properties and is there simply
		 * for cosmetic purposes.
		 * 
		 * @param point The target point.
		 */
		override public function interaction_Begin(point:Point):void
		{
			// begin the interaction operation
			_interactionControl.begin_interaction_operation();
			
			// activate the interaction
			activate();
			
			// update the interaction with the first point of the stroke
			interaction_Update(point);
		}
		
		/**
		 * Updates the draw interaction. Specifically, updates the
		 * temporary view with the new translated point, and adds to the
		 * collection of points that will be used to create the stroke
		 * object in the model.
		 * 
		 * @param point The target point.
		 */
		override public function interaction_Update(point:Point):void
		{
			// add the point to the temporary stroke
			_temporaryStroke.edit_AddPoint(point);
		}
		
		/**
		 * Ends the draw interaction. Specifically, given a long enough
		 * stroke, creates the stroke from the temporary stroke and adds
		 * it to the interface.
		 */
		override public function interaction_End():void
		{
			// case: there is one or no points
			// don't do anything
			if(_points.length < 2)
			{
				// reset the interactor
				reset();
				
				// end the interaction
				_interactionControl.end_interaction_operation();
				
				// return without doing any drawing
				return;
			}
			
			// create the correspondingcomposite operation
			var drawOp:KCompositeOperation = new KCompositeOperation();
			
			// create the new stroke and add it to the ksketch instance
			var newStroke:KStroke = _KSketch.object_Add_Stroke(_points, _KSketch.time, penColor, penThickness, drawOp);
			
			// create a new list of model objects
			var newObjects:KModelObjectList = new KModelObjectList();
			
			// add the new stroke to the list of model objects
			newObjects.add(newStroke);
			
			// end the interaction
			_interactionControl.end_interaction_operation(drawOp, new KSelection(newObjects));
			
			// reset the interactor
			reset();
		}
		
		/**
		 * Activates the draw interactor by setting up the implementation
		 * before the interaction begins. Specifically, initializes the
		 * list of points, temporary stroke, and interactor display.
		 */
		override public function activate():void
		{
			// initialize the set of points
			_points = new Vector.<Point>();
			
			// initialize the temporary stroke
			_temporaryStroke.points = _points;
			_temporaryStroke.color = penColor;
			_temporaryStroke.thickness = penThickness;
			
			// initialize the interactor display
			_interactorDisplay.addChild(_temporaryStroke);
		}
		
		/**
		 * Resets the draw interactor by cleaning up any mess created by
		 * the previous interaction and then returning the draw interactor
		 * to its default state. Specifically, removing the temporary
		 * stroke.
		 */
		override public function reset():void
		{
			if(_temporaryStroke.parent)
				_temporaryStroke.parent.removeChild(_temporaryStroke);
		}
	}
}