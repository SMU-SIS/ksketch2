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
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch2.events.KObjectEvent;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;
	
	import spark.filters.GlowFilter;
	
	public class KObjectView extends Sprite implements IObjectView
	{
		public var ghost:Boolean;
		protected var _pathView:KPathView;
		protected var _object:KObject;
		protected var _ghost:KObjectView;
		protected var _originalPosition:Point;
		
		/**
		 * KObjectView is the view representation of a KObject
		 * It listens to some changes to the KObject's state and updates itself accordingly
		 */
		public function KObjectView(object:KObject, isGhost:Boolean = false)
		{
			super();
			_object = object;
			
			if(_object && !isGhost)
			{
				_object.addEventListener(KObjectEvent.OBJECT_TRANSFORM_FINALISED, _updatePathView);
				_object.addEventListener(KObjectEvent.OBJECT_VISIBILITY_CHANGED, _handle_object_Updated);
				_object.addEventListener(KObjectEvent.OBJECT_SELECTION_CHANGED, _updateSelection);
				_object.addEventListener(KObjectEvent.OBJECT_TRANSFORM_CHANGED, _handle_object_Updated);
				_object.addEventListener(KObjectEvent.OBJECT_TRANSFORM_BEGIN, _initGhost);
				_object.addEventListener(KObjectEvent.OBJECT_TRANSFORM_UPDATING, _updateGhost);
				_object.addEventListener(KObjectEvent.OBJECT_TRANSFORM_ENDED, _hideGhost);
				
				_pathView = new KSingleCenterPathView(object);
			}
			ghost = isGhost;
			if(_ghost)
			{
				_ghost.visible = false;
				_ghost.alpha = 0.5;
			}
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
		 * Draws the bounding box for this KObjectView
		 */
		public function drawBounds():void
		{
			
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
				_pathView.clearPoints();
				return;
			}
			
			transform.matrix = _object.transformMatrix(time);
			
			if(_pathView)
				_pathView.renderPathView(time);
		}
		
		/**
		 * Updates the alpha value of this KObjectView
		 */
		protected function _handle_object_Updated(event:KObjectEvent):void
		{
			updateView(event.time);
			_updateSelection(event);
		}
		
		protected function _initGhost(event:KObjectEvent):void
		{
			_originalPosition = _object.transformInterface.matrix(event.time).transformPoint(_object.centroid);
			
			if(_ghost)
				_updateGhost(event);
		}
		
		protected function _updateGhost(event:KObjectEvent):void
		{
			if(_object && _ghost)
			{
				var currentMatrix:Matrix = _object.transformInterface.matrix(event.time);
				var currentPosition:Point = currentMatrix.transformPoint(_object.centroid);
				var positionDifferences:Point = currentPosition.subtract(_originalPosition);
				
				if(positionDifferences.x < 1 && positionDifferences.y < 1)
					_ghost.visible = false;
				else
				{
					_ghost.visible = true;
					currentMatrix.translate(-positionDifferences.x, -positionDifferences.y);
					_ghost.transform.matrix = currentMatrix;
				}
			}
		}
		
		protected function _hideGhost(event:KObjectEvent):void
		{
			if(_ghost)
			{
				_updateGhost(event);
				_ghost.visible = false;
			}
		}
		
		protected function _updatePathView(event:KObjectEvent):void
		{
			_pathView.recomputePathPoints(event.time);
			_pathView.renderPathView(event.time);
		}
		
		/**
		 * handles the selection state change for the associated KObject
		 */
		protected function _updateSelection(event:KObjectEvent):void
		{
			_pathView.visible(_object.selected);
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