/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.canvas.controls.interactors
{
	import flash.geom.Point;
	
	import spark.core.SpriteVisualElement;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.canvas.controls.IInteractionControl;
	import sg.edu.smu.ksketch2.canvas.controls.interactors.draw.KDrawInteractor;
	import sg.edu.smu.ksketch2.canvas.components.view.KModelDisplay;
	import sg.edu.smu.ksketch2.canvas.components.view.objects.IObjectView;
	import sg.edu.smu.ksketch2.canvas.components.view.objects.KObjectView;
	
	public class KMultiTouchDrawInteractor extends KDrawInteractor
	{
		public static var eraser:Boolean = false;
		
		public function KMultiTouchDrawInteractor(KSketchInstance:KSketch2, interactorDisplay:SpriteVisualElement, interactionControl:IInteractionControl)
		{
			super(KSketchInstance, interactorDisplay, interactionControl);
		}
		
		/**
		 * DrawInteractor.interaction_Begin creates a temporary view to display the
		 * new stroke that is being drawn. This temporaray view has no properties and
		 * is seriously just there for cosmetic purposes
		 */
		override public function interaction_Begin(point:Point):void
		{
			_interactionControl.begin_interaction_operation();

			if(!eraser)
			{
				super.activate();
				super.interaction_Update(point);
			}
		}
		
		/**
		 * Updates the temporary view with the new mouse move point.
		 * Adds to the collection of points that will be used to create the
		 * Stroke Object in the model
		 */
		override public function interaction_Update(point:Point):void
		{
			if(!eraser)
				super.interaction_Update(point);
			else
			{
				var view:IObjectView;
				point = _interactorDisplay.localToGlobal(point);
				for each (view in (_interactorDisplay as KModelDisplay).viewsTable)
				{
					if((view as KObjectView).alpha > 0)
						(view as KObjectView).eraseIfHit(point.x, point.y, _KSketch.time, _interactionControl.currentInteraction);
				}
			}
		}
		
		override public function interaction_End():void
		{
			if(!eraser)
				super.interaction_End();
			else
				_interactionControl.end_interaction_operation();
		}
	}
}