/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.canvas.components.view
{
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import spark.core.SpriteVisualElement;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.canvas.components.view.objects.IObjectView;
	import sg.edu.smu.ksketch2.canvas.components.view.objects.KGroupView;
	import sg.edu.smu.ksketch2.canvas.components.view.objects.KImageView;
	import sg.edu.smu.ksketch2.canvas.components.view.objects.KStrokeView;
	import sg.edu.smu.ksketch2.canvas.controls.KInteractionControl;
	import sg.edu.smu.ksketch2.events.KGroupEvent;
	import sg.edu.smu.ksketch2.events.KObjectEvent;
	import sg.edu.smu.ksketch2.events.KSketchEvent;
	import sg.edu.smu.ksketch2.events.KTimeChangedEvent;
	import sg.edu.smu.ksketch2.model.data_structures.KModelObjectList;
	import sg.edu.smu.ksketch2.model.objects.KGroup;
	import sg.edu.smu.ksketch2.model.objects.KImage;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.model.objects.KStroke;
	
	/**
	 * Exists to display the objects in the model
	 */
	public class KModelDisplay extends SpriteVisualElement
	{
		public static const BOUNDS_THICKNESS:Number = 7;
		public static const DOT_LENGTH:Number = 28;
		
		protected var _KSketch:KSketch2;
		protected var _interactionControl:KInteractionControl;
		protected var _viewsTable:Dictionary;
		private var _isInteracting:Boolean = false;
		
		/**
		 * KModel Display is in charge of displaying things from the scene graph
		 */
		public function KModelDisplay()
		{
			super();
		}
		
		public function init(kSketchInstance:KSketch2, interactionControl:KInteractionControl):void
		{
			_KSketch = kSketchInstance;
			
			_KSketch.addEventListener(KTimeChangedEvent.EVENT_TIME_CHANGED, _handler_UpdateAllViews);
			_KSketch.addEventListener(KSketchEvent.EVENT_MODEL_UPDATED, _handler_UpdateAllViews);
			_KSketch.addEventListener(KSketchEvent.EVENT_KSKETCH_INIT, reset);
			
			_interactionControl = interactionControl;
			_interactionControl.addEventListener(KInteractionControl.EVENT_UNDO_REDO, _handler_UpdateAllViews);
			_interactionControl.addEventListener(KSketchEvent.EVENT_SELECTION_SET_CHANGED, _handler_UpdateAllViews);
			_interactionControl.addEventListener(KInteractionControl.EVENT_INTERACTION_BEGIN, _startInteraction);
			_interactionControl.addEventListener(KInteractionControl.EVENT_INTERACTION_END , _endInteraction);
			
			reset();
			
			scaleX = scaleX;
			scaleY = scaleY;
		}
		
		private function _startInteraction(event:Event):void
		{
			graphics.clear();
			_isInteracting = true;
		}
		
		private function _endInteraction(event:Event):void
		{
			_isInteracting = false;
			_drawBounds();
		}
		
		override public function set scaleX(value:Number):void
		{
			super.scaleX = value;
			
			if(_KSketch)
				_KSketch.scaleX = value;
		}
		
		override public function set scaleY(value:Number):void
		{
			super.scaleY = value;
			
			if(_KSketch)
				_KSketch.scaleY = value;
		}
		
		public function get viewsTable():Dictionary
		{
			return _viewsTable;
		}
		
		public function reset(event:KSketchEvent = null):void
		{
			while(numChildren!=0)
				removeChildAt(0);
			
			mouseChildren = false;
			mouseEnabled = false;
			_viewsTable = new Dictionary();
			view_addObject(_KSketch.root);
			addChild(_viewsTable[_KSketch.root]);
		}
		
		/**
		 * Adds given view to the viewsTable. It will be rendered if it is part of the
		 * scene graph
		 */
		public function view_addObject(object:KObject):IObjectView
		{
			var view:IObjectView;
			var i:int;
			
			if(object is KGroup)
			{
				view = new KGroupView(object);
				
				//get the current selection of individual objects
				if(_interactionControl.currentInteraction)
				{
					view = new KGroupView(object);
					var selectionLength:int = _interactionControl.currentInteraction.oldSelection.objects.length();
					
					(view as KGroupView).resetDrawObject();
					
					for(i=0; i<selectionLength; i++)
						(view as KGroupView).drawObject(_interactionControl.currentInteraction.oldSelection.objects);
				}
				else
				{
					if((object as KGroup).children.length() > 0)
					{
						view = _viewsTable[object];
						
						(view as KGroupView).resetDrawObject();
						
						var parent:KGroup = object.parent;
						var parentView:IObjectView = _viewsTable[parent];
						var root:KGroup = _KSketch.root;
						var rootView:IObjectView = _viewsTable[root];
						
						for(i=0; i<(object as KGroup).children.length(); i++)
						{
							(view as KGroupView).drawObject((object as KGroup).children);
							var newChild:KObject = (object as KGroup).children.getObjectAt(i);
							var newChildView:IObjectView = _viewsTable[newChild];
							newChildView.updateParent(view as KGroupView, rootView as KGroupView);
						}
						
						view.updateParent(parentView as KGroupView, rootView as KGroupView);
					}
				}
				
				//Need to listen to children changes so as to handle their addition/removal on the view side
				object.addEventListener(KGroupEvent.OBJECT_ADDED, _handler_ObjectParented);
				object.addEventListener(KGroupEvent.OBJECT_REMOVED, _handler_ObjectDiscarded);
			}
			else if(object is KStroke)
				view = new KStrokeView(object as KStroke);
			else if (object is KImage)
				view = new KImageView(object as KImage);
			else
				throw new Error("Object type "+object.toString()+" is not supported by the model display yet");

			_viewsTable[object] = view;
			
			return view;
		}
		
		/**
		 * Called when an object's parent change
		 */
		protected function _handler_ObjectParented(event:KGroupEvent):void
		{
			var parent:KGroup = event.group;
			var parentView:IObjectView = _viewsTable[parent];
			var root:KGroup = _KSketch.root;
			var rootView:IObjectView = _viewsTable[root];
			
			var newChild:KObject = event.child;
			var newChildView:IObjectView = _viewsTable[newChild];
			
			//if child view exist, update the position of the view to the current object's position
			if(!newChildView)
				newChildView = view_addObject(newChild);
			
			newChildView.updateParent(parentView as KGroupView, rootView as KGroupView);
		}

		/**
		 * Called when an object has been removed from its parent
		 */
		protected function _handler_ObjectDiscarded(event:KGroupEvent):void
		{
			var objectView:IObjectView = _viewsTable[event.child];
			objectView.removeFromParent();
		}
		
		/**
		 * Updates the view of each object in the views table.
		 */
		protected function _handler_UpdateAllViews(event:Event):void
		{
			for(var view:Object in _viewsTable)
				_viewsTable[view].updateView(_KSketch.time);
			
			var _isErasedObject:Boolean = _interactionControl.isSelectionErased(_interactionControl.selection);
			if(!_isErasedObject)
				_drawBounds();
			else
				graphics.clear();
		}
		
		protected function _handler_UpdateObjectView(event:KObjectEvent):void
		{
			var view:IObjectView = _viewsTable[event.object];

			if(!view)
				throw new Error("Object has no view!");
			view.updateView(_KSketch.time);
		}
		
		public function debug():void
		{
			var rootView:IObjectView = _viewsTable[_KSketch.root];
			
			trace("Debugging Views!");
			
			if(rootView)
				rootView.debug();
			else
				trace("No rootview dude!");
		}
		
		/**
		 * Returns a thumbnail sized image (160x90) of the display at time
		 */
		public function getThumbnail(time:Number):BitmapData
		{
			//Size of the area to be captured to be determined here
			var captureArea:Rectangle = new Rectangle(0,0,160,90);
			
			//Generate the matrix to scale
			var toScaleX:Number = KSketch2.CANONICAL_WIDTH/captureArea.width;
			var toScaleY:Number = KSketch2.CANONICAL_HEIGHT/captureArea.height;
			var matrix:Matrix = new Matrix();
			matrix.scale(1/toScaleX, 1/toScaleY);
			
			var savedTime:Number = _KSketch.time;
			
			_KSketch.time = time;
			var bitmapData:BitmapData = new BitmapData(captureArea.width, captureArea.height, false, 0xFFFFFF);	
			bitmapData.draw(this, matrix);				
			_KSketch.time = savedTime;
			return bitmapData;
		}
		
		private function _drawBounds():void
		{			
			graphics.clear();
			
			if(_isInteracting)
				return;

			var currentSelection:KModelObjectList = _interactionControl.selection?_interactionControl.selection.objects:new KModelObjectList();
			
			var i:int;	
			var length:int = currentSelection.length();
			var currentObject:KObject;
			
			var groupView:KGroupView;
			var groupBounds:Rectangle;
			
			graphics.lineStyle(BOUNDS_THICKNESS, 0x000000, 0.3);
			
			for(i = 0; i < length; i++)
			{
				currentObject = currentSelection.getObjectAt(i);
				
				if(currentObject is KGroup)
				{
					groupView = _viewsTable[currentObject] as KGroupView;
					groupBounds = groupView.getBounds(this);
					_dottedLine(groupBounds.left, groupBounds.top, groupBounds.left, groupBounds.bottom);
					_dottedLine(groupBounds.left, groupBounds.bottom, groupBounds.right, groupBounds.bottom);
					_dottedLine(groupBounds.right, groupBounds.bottom, groupBounds.right, groupBounds.top);
					_dottedLine(groupBounds.right, groupBounds.top, groupBounds.left, groupBounds.top);
				}
			}
		}
		
		/**
		 * Draws a dotted line from the left to right, top to bottom (flash coordinate space!) direction
		 */
		private function _dottedLine(fromX:Number, fromY:Number, toX:Number, toY:Number):void
		{
			//Figure out where to start and end
			var startX:Number = Math.min(fromX, toX);
			var startY:Number = Math.min(fromY, toY);
			var endX:Number = Math.max(fromX, toX);
			var endY:Number = Math.max(fromY, toY);
			
			var draw:Boolean = false;
			var currentX:Number = startX;
			var currentY:Number = startY;
			
			//Loop and draw the dotted line!
			while(currentX < endX || currentY < endY)
			{
				if(draw)
					graphics.lineTo(currentX, currentY);
				else
					graphics.moveTo(currentX, currentY);
				draw = !draw;
				
				if(currentX < endX)
				{
					currentX += DOT_LENGTH;
					
					if(endX < currentX)
					{
						currentX = endX;
						if(draw)
							graphics.lineTo(currentX, currentY);
						else
							graphics.moveTo(currentX, currentY);
						draw = !draw;
					}
				}
				
				if(currentY < endY)
				{
					currentY += DOT_LENGTH;
					
					if(endY < currentY)
					{
						currentY = endY;
						if(draw)
							graphics.lineTo(currentX, currentY);
						else
							graphics.moveTo(currentX, currentY);
						draw = !draw;
					}
				}
			}
		}
	}
}