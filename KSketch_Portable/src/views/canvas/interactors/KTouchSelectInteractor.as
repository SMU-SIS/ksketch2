/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package views.canvas.interactors
{
	import com.coreyoneil.collision.CollisionList;
	
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.controls.interactioncontrol.IInteractionControl;
	import sg.edu.smu.ksketch2.controls.interactors.draw.KInteractor;
	import sg.edu.smu.ksketch2.model.data_structures.KModelObjectList;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.utils.KSelection;
	import sg.edu.smu.ksketch2.view.KModelDisplay;
	import sg.edu.smu.ksketch2.view.objects.IObjectView;
	import sg.edu.smu.ksketch2.view.objects.KImageView;
	import sg.edu.smu.ksketch2.view.objects.KObjectView;
	import sg.edu.smu.ksketch2.view.objects.KStrokeView;
	
	public class KTouchSelectInteractor extends KInteractor
	{
		public static const DETECTION_RADIUS:Number = 30; //detection radius 30px
		private var _selectionArea:Sprite;
		private var _modelDisplay:KModelDisplay;
		
		/**
		 * Touch Select Interactor for selection done through the view.
		 * The old select interactor works thru the model.
		 * Will have to bring this into the model soon instead of letting it run on view components
		 */
		public function KTouchSelectInteractor(KSketchInstance:KSketch2, interactionControl:IInteractionControl,
											   modelDisplay:KModelDisplay)
		{
			super(KSketchInstance, interactionControl);
			_modelDisplay = modelDisplay;

			_selectionArea = new Sprite();
			//_selectionArea.alpha = 0;
		}
		
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
		 * Collision Detection code vs view
		 * Must change it to collision detection vs model data to maintain consistency
		 * View CD can't handle >20 objects :(
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
		 * Processes the result of collision detection
		 * Determines which object/group should be selected based on the given object view
		 * We should make different functions to select bigger groups based on given object view
		 * and use them here.
		 */
		public function select(objectView:KObjectView):void
		{
			var newSelection:KSelection;
			
			if(objectView)
			{
				//Deal with which object to select here
				//The parent group or the object itself or blah blah blah blah
				
				//After we are done with processing the selection, dump the results into the
				//List below and make a new selection
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