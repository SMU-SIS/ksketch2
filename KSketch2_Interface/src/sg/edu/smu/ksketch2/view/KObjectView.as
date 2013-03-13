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
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.events.KObjectEvent;
	import sg.edu.smu.ksketch2.model.data_structures.IKeyFrame;
	import sg.edu.smu.ksketch2.model.data_structures.KSpatialKeyFrame;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;
	
	public class KObjectView extends Sprite implements IObjectView
	{
		public var ghost:Boolean;
		protected var _pathView:KPathView;
		protected var _object:KObject;
		protected var _ghost:KObjectView;
		protected var _originalPosition:Point;
		protected var _isTransiting:Boolean;
		
		/**
		 * KObjectView is the view representation of a KObject
		 * It listens to some changes to the KObject's state and updates itself accordingly
		 */
		public function KObjectView(object:KObject, isGhost:Boolean, showPath:Boolean)
		{
			super();
			_object = object;
			_isTransiting = false;
			
			if(_object && !isGhost)
			{
				_object.addEventListener(KObjectEvent.OBJECT_SELECTION_CHANGED, _updateSelection);
				_object.addEventListener(KObjectEvent.OBJECT_VISIBILITY_CHANGED, _handle_object_Updated);
				_object.addEventListener(KObjectEvent.OBJECT_TRANSFORM_CHANGED, _handle_object_Updated);
				_object.addEventListener(KObjectEvent.OBJECT_TRANSFORM_BEGIN, _transformBegin);
				_object.addEventListener(KObjectEvent.OBJECT_TRANSFORM_ENDED, _transformEnd);
				
				if(showPath)
					_pathView = new KSingleCenterPathView(object);
			}
			ghost = isGhost;
			if(_ghost)
			{
				_ghost.visible = false;
				_ghost.alpha = 0.1;
			}
		}
		
		public function get object():KObject
		{
			return _object;
		}
		
		public function displayable():KObjectView
		{
			return this;
		}
		
		public function eraseIfHit(xPoint:Number, yPoint:Number, time:int, op:KCompositeOperation):void
		{
			
		}
		
		/**
		 * Switches the parent of this KObjectView to newParent
		 */
		public function updateParent(newParent:IObjectView):void
		{
			(newParent as KObjectView).addChild(this);
			if(_pathView)
				_pathView.setDrawingArea(newParent as KGroupView, newParent as KGroupView, newParent as KGroupView);
			if(_ghost)
				(newParent as KObjectView).addChild(_ghost as KObjectView);
		}
		
		/**
		 * Removes this KObjectView from its parent
		 */
		public function removeFromParent():void
		{
			this.parent.removeChild(_ghost as KObjectView);
			if(_ghost)
				this.parent.removeChild(this);
		}
		
		/**
		 * Updates the transform for this KObject
		 * You can update anything related to time here
		 */
		public function updateView(time:int):void
		{
			alpha = _object.visibilityControl.alpha(time);
			if(alpha <= 0)
			{
				if(_pathView)
					_pathView.clearPoints();
				return;
			}
			
			transform.matrix = _object.transformMatrix(time);
			
			if(_pathView)
				if(_pathView.visible)
					_updatePathView(time);
		}
		
		/**
		 * Updates the alpha value of this KObjectView
		 */
		protected function _handle_object_Updated(event:KObjectEvent):void
		{
			updateView(event.time);
		}
		
		protected function _transformBegin(event:KObjectEvent):void
		{
			_originalPosition = _object.transformInterface.matrix(event.time).transformPoint(_object.centroid);

			if(_pathView)
			{
				if(object.transformInterface.transitionType == KSketch2.TRANSITION_DEMONSTRATED)
					_pathView.visible = false;
				else
					_pathView.visible = true;
			}
			
			_isTransiting = true;
			_object.addEventListener(KObjectEvent.OBJECT_TRANSFORM_UPDATING, _updateGhost);
		}
		
		protected function _updateGhost(event:KObjectEvent):void
		{
			if(_object && _ghost)
			{
				_ghost.visible = true;
				var currentMatrix:Matrix = _object.transformInterface.matrix(event.time);
				
				if(object.transformInterface.transitionType == KSketch2.TRANSITION_DEMONSTRATED)
				{
					currentMatrix = _object.transformInterface.matrix(event.time);
					var currentPosition:Point = currentMatrix.transformPoint(_object.centroid);
					var positionDifferences:Point = currentPosition.subtract(_originalPosition);
					
					if(positionDifferences.x > 1 || positionDifferences.y > 1)
					{
						currentMatrix.translate(-positionDifferences.x, -positionDifferences.y);
						_ghost.transform.matrix = currentMatrix;
					}
				}
				else
				{
					var activeKey:IKeyFrame = _object.transformInterface.getActiveKey(event.time);
					
					if(!activeKey)
					{
						_ghost.visible = false;
						return;
					}
					else
						_ghost.visible = true;
					
					if(activeKey.time == event.time||!activeKey.hasActivityAtTime())
					{
						activeKey = activeKey.next;
						
						if(!activeKey)
							_ghost.visible = false;
					}

					if(activeKey)
					{
						if(activeKey.hasActivityAtTime())
						{
							currentMatrix = _object.transformInterface.matrix(activeKey.time);
							_ghost.transform.matrix = currentMatrix;
						}
						else
							_ghost.visible = false;
					}
					else
						_ghost.visible = false;
				}
			}
		}
		
		protected function _transformEnd(event:KObjectEvent):void
		{
			if(_ghost)
				_ghost.visible = false;
			
			if(_pathView)
			{
				_pathView.visible = true;
				_updatePathView(event.time)
			}
			
			_isTransiting = false;
			_object.removeEventListener(KObjectEvent.OBJECT_TRANSFORM_UPDATING, _updateGhost);
		}
		
		public var myI:int = 0;
		protected function _updatePathView(time:int):void
		{
			if(_pathView)
			{
				_pathView.recomputePathPoints(time);
				_pathView.renderPathView(time);
			}
		}
		
		/**
		 * handles the selection state change for the associated KObject
		 */
		protected function _updateSelection(event:KObjectEvent):void
		{
			if(_pathView)
				_pathView.visible = _object.selected;
		}
		
		public function debug(debugSpacing:String=""):void
		{
			trace(debugSpacing+this.toString(),"ID", _object.id);
			debugSpacing = debugSpacing+"	";
			trace(debugSpacing+"Debugging object:", _object.id, "has nChildren = ", numChildren,"and its alpha is", alpha);
			for(var i:int = 0; i<numChildren; i++)
			{
				var child:DisplayObject = this.getChildAt(i);
				if(child is IObjectView)
					(child as IObjectView).debug(debugSpacing);
			}
		}
	}
}