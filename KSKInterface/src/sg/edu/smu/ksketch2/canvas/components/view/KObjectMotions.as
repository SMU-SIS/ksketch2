/**
 * Copyright 2010-2015 Singapore Management University
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
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.canvas.controls.KInteractionControl;
	import sg.edu.smu.ksketch2.events.KObjectEvent;
	import sg.edu.smu.ksketch2.model.data_structures.KSpatialKeyFrame;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.utils.KMathUtil;
	import sg.edu.smu.ksketch2.utils.iterators.INumberIterator;
	
	public class KObjectMotions extends Sprite
	{
		public static var transformer:Sprite = new Sprite();
		
		
		private var _object:KObject;
		private var _motionPath:Shape;
		private var _rotationMotionPath:Shape;
		private var _prevActiveKey:KSpatialKeyFrame;
		private var _prevActiveKeyTime:Number;
		
		protected var _interactionControl:KInteractionControl;
		
		private static const TRANS_COLOR:uint = 0x2E9AFE;
		private static const ROT_COLOR:uint = 0x9FF781;
		
		private static const LINE_WIDTH:Number = 2;

		private static const DRAW_FRAME_DOTS:Boolean = false;
		private static const FRAME_DOT_RADIUS:Number = 2;

		private static const DRAW_SEGMENT_DOTS:Boolean = false;
		private static const SEGMENT_DOT_RADIUS:Number = 2;
		
		//public static const PATH_RADII:Number = 150;
		public static const ROT_PATH_RADIUS_MIN:Number = 150;
		public static const ROT_PATH_RADIUS_MAX:Number = 300;
		public static const ROT_PATH_SCALE_MAX:Number = 16.0/1000; // 2px * 8 turns = 16 pts/sec

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
		
		public function updateObjectMotion(time:Number):void	
		{
			var _isErasedObject:Boolean = _interactionControl.isSelectionErased(_interactionControl.selection);
			if(!_isErasedObject)
			{
				_motionPath.visible = true;
				_rotationMotionPath.visible = true;
				updateMotionPath(time);
			}
				
			else
			{
				_motionPath.visible = false;
				_rotationMotionPath.visible = false;
			}
		}
		
		private function _transformBegin(event:KObjectEvent):void
		{
			if(_object.transformInterface.transitionType == KSketch2.TRANSITION_DEMONSTRATED)
			{
				_motionPath.graphics.clear();
				_rotationMotionPath.graphics.clear();
				
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
				
				if(activeKey)
				{
					_determineAndGeneratePaths(activeKey);				
				}
				var position:Point = _object.fullPathMatrix(event.time).transformPoint(_object.center);
				_rotationMotionPath.x = position.x;
				_rotationMotionPath.y = position.y;
			}
		}
		
		private function _transformEnd(event:KObjectEvent):void
		{				
			_motionPath.visible = true;
			_rotationMotionPath.visible = true;
			
			updateMotionPath(event.time);
			
			_object.removeEventListener(KObjectEvent.OBJECT_TRANSFORM_ENDED, _transformEnd);	
			_object.removeEventListener(KObjectEvent.OBJECT_TRANSFORM_UPDATING, _transformUpdating);
			_object.addEventListener(KObjectEvent.OBJECT_TRANSFORM_BEGIN, _transformBegin);
		}
		
		/**
		 * Generate a motion path at time
		 */
		public function updateMotionPath(time:Number):void
		{
			if(!(_rotationMotionPath.visible && _motionPath.visible))
				return;
			
			var activeKey:KSpatialKeyFrame = _object.transformInterface.getActiveKey(time) as KSpatialKeyFrame;			
			var activeKeyTime:Number = activeKey ? activeKey.time : -1;
			
			if(!activeKey)
				return;
			
			if(activeKey != _prevActiveKey || activeKeyTime != _prevActiveKeyTime || (activeKeyTime == 0 && _prevActiveKeyTime == 0))
				_determineAndGeneratePaths(activeKey);
			
			var position:Point = _object.fullPathMatrix(time).transformPoint(_object.center);
			_rotationMotionPath.x = position.x;
			_rotationMotionPath.y = position.y;
		}
		
		private function _determineAndGeneratePaths(activeKey:KSpatialKeyFrame):void
		{
			_prevActiveKey = activeKey;
			_prevActiveKeyTime = activeKey ? activeKey.time : -1;
			var path:Vector.<Point>;
			
			_motionPath.graphics.clear();
			_rotationMotionPath.graphics.clear();
			_generateMotionPath(activeKey);
		}
		
		private function _generateMotionPath(key:KSpatialKeyFrame):void
		{			
			if(!key)
				throw new Error("Unable to generate a motion path if there is no active key");

			_drawTranslatePath();
			_drawRotatePath();		
		}

		/**
		 * Translate paths are just the points themselves, shown on the screen
		 */
		private function _drawTranslatePath():void
		{
			var firstKeyTime:Number = _object.transformInterface.firstKeyTime;
			var lastKeyTime:Number = _object.transformInterface.lastKeyTime;
			var numIter:INumberIterator = _object.translateTimeIterator();
			var totalX:Number, totalY:Number;
			var more:Boolean = false;

			var t0:Number = -1;
			var t1:Number = -1;
			var t2:Number = -1;
			var t3:Number = -1;
			
			var p0:Point = null;
			var p1:Point = null;
			var p2:Point = null;
			var p3:Point = null;
			
			var b0:Point = new Point(0,0);
			var b1:Point = new Point(0,0);
			var b2:Point = new Point(0,0);
			var b3:Point = new Point(0,0);

			var matrix:Matrix;
			var centroid:Point = _object.center;

			// Calculate the total x & y path length
			numIter.reset();
			totalX = totalY = 0;
			t1 = numIter.empty ? 0 : numIter.next();
			p1 = _object.fullPathMatrix(t1).transformPoint(centroid);
			//trace("--- KObjectMotion._drawTranslatePath: translate path for object " + _object.id + " --------------------------");
			//trace("t = " + t1 + " , (" + p1.x + ", "+ p1.y + ")"); 
			while (numIter.hasNext())
			{
				t0 = t1;
				t1 = numIter.next();
				p0 = p1;
				p1 = _object.fullPathMatrix(t1).transformPoint(centroid);
				//trace("t = " + t1 + " , (" + p1.x + ", "+ p1.y + ")"); 
				totalX += Math.abs(p1.x - p0.x);
			}
			
						
			// Do the rest only if there is a path to render
			if (KMathUtil.EPSILON < totalX || KMathUtil.EPSILON < totalY)
			{
				// Initialize styles
				_motionPath.graphics.lineStyle(LINE_WIDTH, TRANS_COLOR); //this is the color for motion
			
				// Draw the frame dot, if necessary.
				if (DRAW_FRAME_DOTS)
				{
					var nextKeyTime:Number = firstKeyTime;
					
					while (nextKeyTime < lastKeyTime + KMathUtil.EPSILON) 
					{
						p0 = _object.fullPathMatrix(nextKeyTime).transformPoint(centroid);
						_motionPath.graphics.drawCircle(p0.x, p0.y, FRAME_DOT_RADIUS);
						nextKeyTime += KSketch2.ANIMATION_INTERVAL;
					}
				}
				
				// Initialize for rendering the path				
				numIter.reset();
				if (numIter.hasNext()) 
				{ 
					t1 = numIter.next(); 
					p1 = _object.fullPathMatrix(t1).transformPoint(centroid);
					_motionPath.graphics.moveTo(p1.x, p1.y);
				}
				
				if (numIter.hasNext()) 
				{ 
					t2 = numIter.next(); 
					p2 = _object.fullPathMatrix(t2).transformPoint(centroid);
					more = true;
				} 
				
				if (numIter.hasNext()) 
				{ 
					t3 = numIter.next(); 
					p3 = _object.fullPathMatrix(t3).transformPoint(centroid);
					
					if(isNaN(p3.x) || isNaN(p3.y))
						p3 = p2;
				} 
				
				while (more)
				{
					// Draw the curve segment
					if (KMathUtil.catmullRomToBezier(p0, p1, p2, p3, b0, b1, b2, b3))
					{
						
						if (DRAW_SEGMENT_DOTS)
						{
							_motionPath.graphics.drawCircle(p2.x, p2.y, SEGMENT_DOT_RADIUS);
							_motionPath.graphics.moveTo(p1.x, p1.y);							
						}
						
						_motionPath.graphics.cubicCurveTo(b1.x, b1.y, b2.x, b2.y, b3.x, b3.y);
					}
					
					// Prepare for the next iteration.
					if (p3 != null)
					{
						t0 = t1;
						t1 = t2;
						t2 = t3;
						
						p0 = p1;
						p1 = p2;
						p2 = p3;
						
						if (numIter.hasNext())
						{
							t3 = numIter.next();
							p3 = _object.fullPathMatrix(t3).transformPoint(centroid);
						}
						else
						{
							t3 = -1;
							p3 = null;
						}
					}
					else
					{
						more = false;
					}
				}
			}
		}
		
		
		/**
		 * Draw a spiral rotating about the objec's centroid.
		 */
		private function _drawRotatePath():void
		{
			var numIter:INumberIterator = _object.rotateTimeIterator();
			var firstKeyTime:Number = numIter.empty ? 0 : numIter.first;
			var lastKeyTime:Number = numIter.empty ? 0 : numIter.last;
			var span:Number = lastKeyTime - firstKeyTime;
			var scale:Number = Math.min(ROT_PATH_SCALE_MAX, (ROT_PATH_RADIUS_MAX - ROT_PATH_RADIUS_MIN)/span);
			var totalRotation:Number;

			var matrix:Matrix;
			var center:Point = new Point(0,0)  // Use (0, 0) instead of _object.center (sprite is centered there).
			var firstSegment:Boolean = true;
			var drawDot:Boolean;
			
			var t0:Number, t1:Number, theta0:Number, theta1:Number, radius0:Number, radius1:Number;
			
			// Allocate these here so do we don't create lots of garbage as we draw.
			var b0:Point = new Point(0,0);
			var b1:Point = new Point(0,0);
			var b2:Point = new Point(0,0);
			var b3:Point = new Point(0,0);

			// Calculate the total rotation
			numIter.reset();
			totalRotation = 0;
			t1 = numIter.empty ? 0 : numIter.next();
			theta1 = numIter.empty ? 0 : _getObjectRotation(t1, 0);
			while (numIter.hasNext())
			{
				t0 = t1;
				t1 = numIter.next();
				theta0 = theta1;
				theta1 = _getObjectRotation(t1, theta0);
				totalRotation += Math.abs(theta1 - theta0);
			}
			
			// Set up for drawing graphics
			_rotationMotionPath.graphics.clear();
			_rotationMotionPath.graphics.lineStyle(LINE_WIDTH, ROT_COLOR);
			
			// Do the rest only if there is some change to show.
			if (KMathUtil.EPSILON < totalRotation)
			{
				// Draw the frame dot, if necessary.
				if (DRAW_FRAME_DOTS)
				{
					var nextKeyTime:Number = firstKeyTime;
					theta1 = 0;
					
					while (nextKeyTime < lastKeyTime + KMathUtil.EPSILON) 
					{
						theta0 = theta1;
						theta1 = _getObjectRotation(nextKeyTime, theta0);
						radius1 = ROT_PATH_RADIUS_MIN + (nextKeyTime - firstKeyTime) * scale;
						_rotationMotionPath.graphics.drawCircle(radius1 * Math.cos(theta1), 
							radius1 * Math.sin(theta1), FRAME_DOT_RADIUS);
						nextKeyTime += KSketch2.ANIMATION_INTERVAL;
					}
				}
				
				// Set up for iteration over segments
				numIter.reset();
				if (numIter.hasNext())
				{
					t1 = numIter.next();
					theta1 = _getObjectRotation(t1, 0);
					radius1 = ROT_PATH_RADIUS_MIN + (t1 - firstKeyTime) * scale;
				}
				
				// Draw the segments
				while (numIter.hasNext())
				{
					// Get the values for this iteration
					t0 = t1;
					t1 = numIter.next();
					theta0 = theta1;
					theta1 = _getObjectRotation(t1, theta0);
					radius0 = radius1;
					radius1 = ROT_PATH_RADIUS_MIN + (t1 - firstKeyTime) * scale;
					
					if (_drawRotatePathSegment(center, theta0, radius0, theta1, radius1, b0, b1, b2, b3))
					{
						// If something was drawn, then we can consider the first segment done.
						firstSegment = false;					
					}
				}
			}
		}
		
		private function _drawRotatePathSegment(center:Point, theta0:Number, radius0:Number, 
												 theta1:Number, radius1:Number,
												 b0:Point, b1:Point, b2:Point, b3:Point):Boolean
		{
			var numSegments:int = Math.ceil(Math.abs(theta1 - theta0)/(Math.PI*.5));
			var thetaStep:Number =  (theta1 - theta0)/numSegments;
			var radiusStep:Number = (radius1 - radius0)/numSegments;
			var drewSomething:Boolean = false;
			
			var i:int;
			var t0:Number, t1:Number, r0:Number, r1:Number;
			
	
			t1 = theta0;
			r1 = radius0;
			for (i = 1; i <= numSegments; i++) 
			{
				t0 = t1;
				r0 = r1;
				
				if (i == numSegments)
				{
					// If last segment, avoid numeric precision error.
					t1 = theta1;
					r1 = radius1;
				}
				else
				{
					// Segments before the last.
					t1 = theta0 + thetaStep*i;
					r1 = radius0 + radiusStep*1
				}
				
				if (KMathUtil.spiralArcToBezier(center, t0, r0, t1, r1, b0, b1, b2, b3))
				{
					if (DRAW_SEGMENT_DOTS)
					{
						_rotationMotionPath.graphics.drawCircle(b3.x, b3.y, SEGMENT_DOT_RADIUS);
					}

					_rotationMotionPath.graphics.moveTo(b0.x, b0.y);
					_rotationMotionPath.graphics.cubicCurveTo(b1.x, b1.y, b2.x, b2.y, b3.x, b3.y);
					drewSomething = true;
				}
			}
				
			return drewSomething;
		}
		
		/**
		 * Gets the object's rotation at the given tiem.
		 * 
		 * @param t The time to get the rotation
		 * @praram rPrev The previous rotation, used as a reference. The new rotation will be PI or fewer radians from this rotation.
		 * @return The rotation in radians.
		 */
		private function _getObjectRotation(t:Number, rPrev:Number):Number
		{
			transformer.transform.matrix = _object.fullPathMatrix(t);
			var r:Number = (transformer.rotation / 180) * Math.PI;			

			var turns:int = Math.round(rPrev/(2*Math.PI));
			var rScaled:Number = r + (turns * 2 * Math.PI);
			var diff:Number = rScaled - rPrev;
			
			if (Math.PI < diff)
			{
				rScaled -= 2 * Math.PI;
			}
			else if (diff < -Math.PI)
			{
				rScaled += 2 * Math.PI;				
			}
			
			return rScaled;
		}
		
	
		public function undoPath(time:Number):void
		{
			if(_motionPath.visible && _rotationMotionPath.visible)
			{
				var activeKey:KSpatialKeyFrame = _object.transformInterface.getActiveKey(time) as KSpatialKeyFrame;	
				
				if(activeKey)
					_determineAndGeneratePaths(activeKey);	
				else
				{
					_motionPath.graphics.clear();
					_rotationMotionPath.graphics.clear();
					_drawTranslatePath();
					_drawRotatePath();	
				}
			}
			
			updateMotionPath(time);
		}
		
		//KSKETCH-SYNPHNE
		public function getTranslatePath():Vector.<Point> 
		{
			var _vectorPoints:Vector.<Point> = new Vector.<Point>();
			var numIter:INumberIterator = null;
			var t1:Number = -1;
			var p1:Point = null;
			
			var centroid:Point = _object.center;
			numIter = _object.translateTimeIterator();
			numIter.reset();
			
			while (numIter.hasNext()) 
			{ 
				t1 = numIter.next(); 
				p1 = _object.fullPathMatrix(t1).transformPoint(centroid);
				_vectorPoints.push(new Point(p1.x, p1.y));
			}
			
			return _vectorPoints;
		}
		
		public function getRotationCount():int
		{
			var numIter:INumberIterator = null;
			var t1:Number = -1;
			var p1:Point = null;
			var totalRotation = 0;
			var theta0:Number, theta1:Number;
			
			numIter = _object.rotateTimeIterator();
			numIter.reset();
			t1 = numIter.empty ? 0 : numIter.next();
			theta1 = numIter.empty ? 0 : _getObjectRotation(t1, 0);
			
			while (numIter.hasNext())
			{
				t1 = numIter.next();
				theta0 = theta1;
				theta1 = _getObjectRotation(t1, theta0);
				totalRotation += Math.abs(theta1 - theta0);
			}
			return totalRotation;
		}

	}
}