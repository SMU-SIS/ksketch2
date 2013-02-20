/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.view
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import spark.core.SpriteVisualElement;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.events.KGroupEvent;
	import sg.edu.smu.ksketch2.events.KObjectEvent;
	import sg.edu.smu.ksketch2.events.KSketchEvent;
	import sg.edu.smu.ksketch2.events.KTimeChangedEvent;
	import sg.edu.smu.ksketch2.model.objects.KGroup;
	import sg.edu.smu.ksketch2.model.objects.KImage;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.model.objects.KStroke;
	
	/**
	 * Exists to display the objects in the model
	 */
	public class KModelDisplay extends SpriteVisualElement
	{
		protected var _KSketch:KSketch2;
		protected var _viewsTable:Dictionary;
		protected var _showPath:Boolean;
		
		/**
		 * KModel Display is in charge of displaying things from the scene graph
		 */
		public function KModelDisplay()
		{
			super();
			
			_showPath = false;
		}
		
		public function init(kSketchInstance:KSketch2):void
		{
			_KSketch = kSketchInstance;
			_KSketch.addEventListener(KTimeChangedEvent.EVENT_TIME_CHANGED, _handler_UpdateAllViews);
			_KSketch.addEventListener(KSketchEvent.EVENT_MODEL_UPDATED, _handler_UpdateAllViews);
			_KSketch.addEventListener(KSketchEvent.EVENT_KSKETCH_INIT, reset);
			reset();
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
		private function view_addObject(object:KObject):IObjectView
		{
			if(_viewsTable[object])
				throw new Error("Object already exists in view. I don't want you to see doubles man");
			
			var view:IObjectView;
			
			if(object is KGroup)
			{
				view = new KGroupView(object);
				//Need to listen to children changes so as to handle their addition/removal on the view side
				object.addEventListener(KGroupEvent.OBJECT_ADDED, _handler_ObjectParented);
				object.addEventListener(KGroupEvent.OBJECT_REMOVED, _handler_ObjectDiscarded);
			}
			else if(object is KStroke)
				view = new KStrokeView(object as KStroke);
			else if (object is KImage)
			{
				view = new KImageView(object as KImage);
			}
			else
				throw new Error("Object type "+object.toString()+" is not supported by the model display yet");
			
			view.showPath = _showPath;
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
			
			var newChild:KObject = event.child;
			var newChildView:IObjectView = _viewsTable[newChild];
			
			if(!newChildView)
				newChildView = view_addObject(newChild);
			
			newChildView.updateParent(parentView as KGroupView);
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
		
		public function set pathVisible(visible:Boolean):void
		{
			_showPath = visible;
			
			for(var view:Object in _viewsTable)
				(_viewsTable[view] as IObjectView).showPath = _showPath;
		}
	}
}