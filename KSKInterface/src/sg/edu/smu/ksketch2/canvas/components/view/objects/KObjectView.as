/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.canvas.components.view.objects
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.events.KObjectEvent;
	import sg.edu.smu.ksketch2.model.data_structures.IKeyFrame;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.operators.KSingleReferenceFrameOperator;
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;
	
	public class KObjectView extends Sprite implements IObjectView
	{		
		protected var _object:KObject;
		protected var _ghost:Sprite;
		protected var _originalPosition:Point;
		
		/**
		 * KObjectView is the view representation of a KObject
		 * It listens to some changes to the KObject's state and updates itself accordingly
		 */
		public function KObjectView(object:KObject)
		{
			super();
			_object = object;
			
			if(_object)
			{
				_object.addEventListener(KObjectEvent.OBJECT_SELECTION_CHANGED, _updateSelection);
				_object.addEventListener(KObjectEvent.OBJECT_VISIBILITY_CHANGED, _handle_object_Updated);
				_object.addEventListener(KObjectEvent.OBJECT_TRANSFORM_CHANGED, _handle_object_Updated);
				_object.addEventListener(KObjectEvent.OBJECT_TRANSFORM_BEGIN, _transformBegin);
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
		
		public function eraseIfHit(xPoint:Number, yPoint:Number, time:Number, op:KCompositeOperation):void
		{
			
		}
		
		/**
		 * Switches the parent of this KObjectView to newParent
		 */
		public function updateParent(newParent:IObjectView):void
		{
			(newParent as KObjectView).addChild(this);
			if(_ghost)
				(newParent as KObjectView).addGhost(_ghost);
		}
		
		public function addGhost(childGhost:Sprite):void
		{
			if(_ghost)
				_ghost.addChild(childGhost);
		}
		
		/**
		 * Removes this KObjectView from its parent
		 */
		public function removeFromParent():void
		{
			this.parent.removeChild(this);
			
			if(_ghost)
			{
				if(_ghost.parent)
					_ghost.parent.removeChild(_ghost);
			}
		}
		
		/**
		 * Updates the transform for this KObject
		 * You can update anything related to time here
		 */
		public function updateView(time:Number):void
		{
			alpha = _object.visibilityControl.alpha(time);
			if(alpha <= 0)
				return;
			
			transform.matrix = _object.transformMatrix(time);
		}
		
		/**
		 * Updates the alpha value of this KObjectView
		 */
		protected function _handle_object_Updated(event:KObjectEvent):void
		{
			updateView(event.time);
		}
		
		/**
		 * handles the selection state change for the associated KObject
		 */
		protected function _updateSelection(event:KObjectEvent):void
		{

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
		
		
		protected function _transformBegin(event:KObjectEvent):void
		{
			_originalPosition = _object.transformInterface.matrix(event.time).transformPoint(_object.center);			
			_object.addEventListener(KObjectEvent.OBJECT_TRANSFORM_UPDATING, _updateGhost);
			_object.addEventListener(KObjectEvent.OBJECT_TRANSFORM_ENDED, _transformEnd);
		}
		
		protected function _updateGhost(event:KObjectEvent):void
		{
			if(_object && _ghost)
			{
				_ghost.visible = true;
				var currentMatrix:Matrix = _object.transformInterface.matrix(event.time);
				if(object.transformInterface.transitionType == KSketch2.TRANSITION_DEMONSTRATED)
				{
					if((_object.transformInterface as KSingleReferenceFrameOperator).hasRotate
						||(_object.transformInterface as KSingleReferenceFrameOperator).hasScale)
					{
						_ghost.visible = true;
					}
					else
					{
						_ghost.visible = false;
						return;
					}
					
					currentMatrix = _object.transformInterface.matrix(event.time);
					var currentPosition:Point = currentMatrix.transformPoint(_object.center);
					var positionDifferences:Point = currentPosition.subtract(_originalPosition);
					
					if(positionDifferences.x > 1 || positionDifferences.y > 1)
					{
						_ghost.visible = true;
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
			
			_object.removeEventListener(KObjectEvent.OBJECT_TRANSFORM_UPDATING, _updateGhost);
		}
	}
}