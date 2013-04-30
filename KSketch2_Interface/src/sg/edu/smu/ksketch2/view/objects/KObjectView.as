/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.view.objects
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import sg.edu.smu.ksketch2.events.KObjectEvent;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;
	
	public class KObjectView extends Sprite implements IObjectView
	{
		protected var _object:KObject;
		
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
		}
		
		/**
		 * Removes this KObjectView from its parent
		 */
		public function removeFromParent():void
		{
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
	}
}