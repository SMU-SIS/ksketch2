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
	import com.coreyoneil.collision.CollisionList;
	
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.canvas.controls.IInteractionControl;
	import sg.edu.smu.ksketch2.canvas.controls.interactors.draw.KInteractor;
	import sg.edu.smu.ksketch2.model.data_structures.KModelObjectList;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.utils.KSelection;
	import sg.edu.smu.ksketch2.canvas.components.view.KModelDisplay;
	import sg.edu.smu.ksketch2.canvas.components.view.objects.IObjectView;
	import sg.edu.smu.ksketch2.canvas.components.view.objects.KImageView;
	import sg.edu.smu.ksketch2.canvas.components.view.objects.KObjectView;
	import sg.edu.smu.ksketch2.canvas.components.view.objects.KStrokeView;
	
	/**
	 * The KMultiTouchSelectInteractor class serves as the concrete class
	 * for handling multi-touch select interactions in K-Sketch.
	 * Specifically, touch selection interaction is done through the view,
	 * where the old select interactor works through the model. It will
	 * need to bring this into the model soon isntead of letting it run on
	 * view components.
	 */
	public class KMultiTouchSelectInteractor extends KInteractor
	{
		public static const DETECTION_RADIUS:Number = 30; //detection radius 30px
		private var _selectionArea:Sprite;
		private var _modelDisplay:KModelDisplay;
		
		/**
		 * The main constructor of the KMultiTouchSelectInteractor class.
		 * 
		 * @param KSketchInstance The target ksketch instance.
		 * @param interactorDisplay The target interactor display.
		 * @param interactionControl The target interaction control.
		 */
		public function KMultiTouchSelectInteractor(KSketchInstance:KSketch2, interactionControl:IInteractionControl, modelDisplay:KModelDisplay)
		{
			super(KSketchInstance, interactionControl);
			_modelDisplay = modelDisplay;

			_selectionArea = new Sprite();
			//_selectionArea.alpha = 0;
		}
		
		/**
		 * Handles the tap input of the touch select interaction.
		 * 
		 * @param location The target point location of the tap.
		 */
		public function tap(location:Point):void
		{
			_selectionArea.graphics.clear();
			_selectionArea.graphics.beginFill(0x000000, 1);
			_selectionArea.graphics.drawCircle(location.x, location.y, DETECTION_RADIUS);
			_selectionArea.graphics.endFill();
			
			_modelDisplay.addChild(_selectionArea);
			detectObjects();
			_modelDisplay.removeChild(_selectionArea);
		}
		
		/**
		 * Detects object collision. Must change it to detect collision
		 * versus model data to maintain consistency. View collision
		 * detection cannot handle more than twenty objects.
		 */
		public function detectObjects():void
		{
			var collisionList:CollisionList = new CollisionList(_selectionArea);
			collisionList.cannonicalSpace = _modelDisplay;
			var viewsTable:Dictionary = _modelDisplay.viewsTable;
			
			for each(var view:IObjectView in viewsTable)
			{
				var display:KObjectView = view.displayable();
				
				if(display is KStrokeView || display is KImageView)
					collisionList.addItem(display);
			}
			
			var result:Array = collisionList.checkCollisions();

			var bestResult:Object;
			if(result.length > 0)
			{
				for each(var resultPair:* in result)
				{
					if(bestResult)
					{
						if(resultPair.overlapping.length > bestResult.overlapping.length)
							bestResult = resultPair;
					}
					else
						bestResult = resultPair;
				}
			}
			
			if(bestResult)
				select(bestResult.collidedObject);
			else
				select(null);
		}
		
		/**
		 * Selects objects based on the given object view by processing
		 * the result of the collision detection. Should make different
		 * functions to select larger groups based on the given object
		 * view and use them here.
		 * 
		 * @param objectView The object view.
		 */
		public function select(objectView:KObjectView):void
		{
			var newSelection:KSelection;
			
			if(objectView)
			{
				// handles which object to select here
				// the parent group or the object itself or other types
				
				// after we are done with processing the selection, dump the results into the
				// list below and make a new selection
				var selectedObjectList:KModelObjectList = new KModelObjectList();
				var object:KObject = objectView.object;
				if(object.parent != _KSketch.root)
					selectedObjectList.add(object.parent);
				else
					selectedObjectList.add(object);					
				newSelection = new KSelection(selectedObjectList);
			}
	
			_interactionControl.selection = newSelection;
			_interactionControl.determineMode();
		}
	}
}