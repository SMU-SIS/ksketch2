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
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.canvas.controls.KInteractionControl;
	import sg.edu.smu.ksketch2.events.KObjectEvent;
	import sg.edu.smu.ksketch2.model.data_structures.KModelObjectList;
	import sg.edu.smu.ksketch2.model.data_structures.KSpatialKeyFrame;
	import sg.edu.smu.ksketch2.model.objects.KGroup;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	
	public class KObjectMotions extends Sprite
	{
		public static var transformer:Sprite = new Sprite();
		public static const PATH_RADII:Number = 150;
		
		
		private var _object:KObject;
		private var _motionPath:Shape;
		private var _rotationMotionPath:Shape;
		private var _prevActiveKey:KSpatialKeyFrame;
		
		protected var _interactionControl:KInteractionControl;
		
		/**
		 *	Display class for motion paths and static ghosts.
		 *	Supposed to help in micromanaging object motion paths
		 * 	Static ghosts show the objects' position, orientation and size
		 *	at the end of the active key frame.
		 */
		public function KObjectMotions(interactionControl:KInteractionControl)
		{
			//So in essence, the object's motions are represented by a ghost and a motion path
			//The motion path will show the user how the object gets to the ghost
			//While the ghostill show how to t
			
			super();
			
			_interactionControl = interactionControl;
			//_interactionControl.addEventListener(KInteractionControl.EVENT_UNDO_REDO, clearTemp);
			
			_motionPath = new Shape();
			addChild(_motionPath);
			
			_rotationMotionPath = new Shape();
			addChild(_rotationMotionPath);
			
			
		}
		
		public function set object(newObject:KObject):void
		{
			_object = newObject;		
			
			if(_object)
				_object.addEventListener(KObjectEvent.OBJECT_TRANSFORM_BEGIN, _transformBegin);
		}
		
		public function get object():KObject
		{
			return object;
		}
		
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			
			if(!value)
				_prevActiveKey = null;
		}
		
		public function _visibilityChanged(event:KObjectEvent):void
		{
			if(!_object)
				return;
			
			if(_object.visibilityControl.alpha(event.time) <= 0)
			{
				visible = false;
				return;
			}
			else
				visible = true;
		}
		
		public function _updateObjectMotion(time:int):void	
		{
			_updateMotionPath(time);
		}
		
		private function _transformBegin(event:KObjectEvent):void
		{
			//If performance, need to hide paths
			//Init ghosts here?			
			if(_object.transformInterface.transitionType == KSketch2.TRANSITION_DEMONSTRATED)
			{
				_motionPath.visible = false;
				_rotationMotionPath.visible = false;
			}
			else
			{
				_motionPath.visible = true;
				_rotationMotionPath.visible = true;
			}
			
			_object.addEventListener(KObjectEvent.OBJECT_TRANSFORM_ENDED, _transformEnd);
			_object.addEventListener(KObjectEvent.OBJECT_TRANSFORM_UPDATING, _transformUpdating);
			_object.removeEventListener(KObjectEvent.OBJECT_TRANSFORM_BEGIN, _transformBegin);
		}
		
		private function _transformUpdating(event:KObjectEvent):void
		{
			if(_motionPath.visible && _rotationMotionPath.visible)
			{
				var activeKey:KSpatialKeyFrame = _object.transformInterface.getActiveKey(event.time) as KSpatialKeyFrame;			
				var firstKeyTime:Number = _object.transformInterface.firstKeyTime;
				var lastKeyTime:Number = _object.transformInterface.lastKeyTime;
				
				if(activeKey)
					_determineAndGeneratePaths(activeKey,firstKeyTime,lastKeyTime);				
			}
		}
		
		private function _transformEnd(event:KObjectEvent):void
		{				
			_motionPath.visible = true;
			_rotationMotionPath.visible = true;
			
			_updateMotionPath(event.time);
			
			_object.removeEventListener(KObjectEvent.OBJECT_TRANSFORM_ENDED, _transformEnd);	
			_object.removeEventListener(KObjectEvent.OBJECT_TRANSFORM_UPDATING, _transformUpdating);
			_object.addEventListener(KObjectEvent.OBJECT_TRANSFORM_BEGIN, _transformBegin);
		}
		
		/**
		 * Generate a motion path at time
		 */
		private function _updateMotionPath(time:Number):void
		{
			if(!(_rotationMotionPath.visible && _motionPath.visible))
				return;
			
			var activeKey:KSpatialKeyFrame = _object.transformInterface.getActiveKey(time) as KSpatialKeyFrame;			
			var firstKeyTime:Number = _object.transformInterface.firstKeyTime;
			var lastKeyTime:Number = _object.transformInterface.lastKeyTime;
			
			if(!activeKey)
			{
				_prevActiveKey = null;
				_motionPath.graphics.clear();
				return;
			}
			
			if(activeKey != _prevActiveKey)
				_determineAndGeneratePaths(activeKey, firstKeyTime, lastKeyTime);
			
			var position:Point = _object.fullPathMatrix(time).transformPoint(_object.center);
			_rotationMotionPath.x = position.x;
			_rotationMotionPath.y = position.y;
		}
		
		private function _determineAndGeneratePaths(activeKey:KSpatialKeyFrame, firstKeyTime:Number, lastKeyTime:Number):void
		{
			_prevActiveKey = activeKey;
			var path:Vector.<Point>;
			
			_motionPath.graphics.clear();
			_generateMotionPath(activeKey,firstKeyTime,lastKeyTime);
		}
		
		private function _generateMotionPath(key:KSpatialKeyFrame, firstKeyTime:Number, lastKeyTime:Number):void
		{			
			if(!key)
				throw new Error("Unable to generate a motion path if there is no active key");
			
			var translatePath:Vector.<Point>= new Vector.<Point>();	
			var rotatePath:Vector.<Number> = new Vector.<Number>();
			var scalePath:Vector.<Number> = new Vector.<Number>();
			
			var matrix:Matrix;
			var currentTime:Number = key.startTime;
			var currentKeyElapsedTime:Number = 0;
			var centroid:Point = _object.center;
			var position:Point;
			
			var proportion:int;
			var accumulatedRotation:Number = 0;
			var currentRotation:Number;
			var prevRotation:Number = 0;
			
			//Just iterate and generate all the values for each frame
			//This iteration generates an object's position and transform values
			while(firstKeyTime <= lastKeyTime)
			{
				matrix = _object.fullPathMatrix(firstKeyTime); //cammie: _object.transformMatrix(firstKeyTime);
				position = matrix.transformPoint(centroid);
				translatePath.push(position);

				transformer.transform.matrix = matrix;// Dont bother computing the values ourselves, just let flash do it
				
				rotatePath.push(transformer.rotation);
				scalePath.push(transformer.scaleX);
					
				firstKeyTime += KSketch2.ANIMATION_INTERVAL;
			}
			
			_drawTranslatePath(translatePath);
			
			if(key == _prevActiveKey)
				_drawRotatePath(rotatePath);
		}
		
		//Translate paths are just hte points themselves, shown on the screen
		private function _drawTranslatePath(path:Vector.<Point>):void
		{
			if(1 < path.length)
			{
				var currentPoint:Point = path[0];
				_motionPath.graphics.lineStyle(2, 0x2E9AFE); //this is the color for motion
				_motionPath.graphics.moveTo(currentPoint.x, currentPoint.y);
				
				var i:int = 1;
				var length:int = path.length;
				
				for(i; i<length-1; i++)
				{
					currentPoint = path[i];
					_motionPath.graphics.lineTo(currentPoint.x, currentPoint.y);
				}
			}	
		}
		
		//Rotate paths are the polar representations of the rotation values
		private function _drawRotatePath(path:Vector.<Number>):void
		{
			if(0 < path.length)
			{
				_rotationMotionPath.graphics.clear();
				var currentPoint:Point = Point.polar(PATH_RADII, path[0]/180*Math.PI)
				_rotationMotionPath.graphics.lineStyle(2, 0x9FF781);
				_rotationMotionPath.graphics.moveTo(currentPoint.x, currentPoint.y);
				
				var i:int = 1;
				var length:int = path.length;
				
				for(i; i<length; i++)
				{
					currentPoint = Point.polar(PATH_RADII+(PATH_RADII*(i/length)), path[i]/180*Math.PI)
					_rotationMotionPath.graphics.lineTo(currentPoint.x, currentPoint.y);
				}
			}	
		}
		
		private function clearTemp(event:Event):void
		{
			if(_motionPath)
				_motionPath.graphics.clear();
			
			if(_rotationMotionPath)
				_rotationMotionPath.graphics.clear();
		}
	}
}