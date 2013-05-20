package views.canvas.interactors
{
	import flash.geom.Point;
	
	import spark.core.SpriteVisualElement;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.controls.interactioncontrol.IInteractionControl;
	import sg.edu.smu.ksketch2.controls.interactors.draw.KDrawInteractor;
	import sg.edu.smu.ksketch2.view.KModelDisplay;
	import sg.edu.smu.ksketch2.view.objects.IObjectView;
	import sg.edu.smu.ksketch2.view.objects.KObjectView;
	
	public class KTouchDrawInteractor extends KDrawInteractor
	{
		public static var eraser:Boolean = false;
		
		public function KTouchDrawInteractor(KSketchInstance:KSketch2, interactorDisplay:SpriteVisualElement, interactionControl:IInteractionControl)
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