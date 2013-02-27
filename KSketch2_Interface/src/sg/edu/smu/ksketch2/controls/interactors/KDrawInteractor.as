/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.controls.interactors
{
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.controls.interactioncontrol.IInteractionControl;
	import sg.edu.smu.ksketch2.model.data_structures.KModelObjectList;
	import sg.edu.smu.ksketch2.model.objects.KStroke;
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;
	import sg.edu.smu.ksketch2.utils.KSelection;
	import sg.edu.smu.ksketch2.view.KStrokeView;
	
	import spark.core.SpriteVisualElement;

	public class KDrawInteractor extends KInteractor
	{
		public static var penColor:uint = 0X000000;
		public static var penThickness:Number = 3.5;
		private var _temporaryStroke:KStrokeView;
		private var _points:Vector.<Point>;
		protected var _interactorDisplay:SpriteVisualElement;
		
		public function KDrawInteractor(KSKetchInstance:KSketch2, interactorDisplay:SpriteVisualElement, interactionControl:IInteractionControl)
		{
			_interactorDisplay = interactorDisplay;
			super(KSKetchInstance, interactionControl);
			_temporaryStroke = new KStrokeView(null);
		}
		
		/**
		 * DrawInteractor.interaction_Begin creates a temporary view to display the
		 * new stroke that is being drawn. This temporaray view has no properties and
		 * is seriously just there for cosmetic purposes
		 */
		override public function interaction_Begin(point:Point):void
		{
			_interactionControl.begin_interaction_operation();
			activate();
			interaction_Update(point);
		}
		
		/**
		 * Updates the temporary view with the new mouse move point.
		 * Adds to the collection of points that will be used to create the
		 * Stroke Object in the model
		 */
		override public function interaction_Update(point:Point):void
		{
			_temporaryStroke.edit_AddPoint(point);
		}
		
		override public function interaction_End():void
		{
			if(_points.length <= 2)
			{
				_interactionControl.end_interaction_operation();
				return;
			}
			
			var drawOp:KCompositeOperation = new KCompositeOperation();
			var newStroke:KStroke = _KSketch.object_Add_Stroke(_points, _KSketch.time, penColor, penThickness, drawOp);
			var newObjects:KModelObjectList = new KModelObjectList();
			newObjects.add(newStroke);
			_interactionControl.end_interaction_operation(drawOp, new KSelection(newObjects));
			reset();
		}
		
		override public function activate():void
		{
			_points = new Vector.<Point>();
			_temporaryStroke.points = _points;
			_temporaryStroke.color = penColor;
			_temporaryStroke.thickness = penThickness;
			_interactorDisplay.addChild(_temporaryStroke);
		}
		
		override public function reset():void
		{
			if(_temporaryStroke.parent)
				_temporaryStroke.parent.removeChild(_temporaryStroke);
		}
	}
}