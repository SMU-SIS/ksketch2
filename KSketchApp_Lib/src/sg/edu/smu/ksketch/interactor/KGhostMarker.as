/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package sg.edu.smu.ksketch.interactor
{
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch.components.KCanvas;
	import sg.edu.smu.ksketch.components.KObjectView;
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.model.KStroke;
	import sg.edu.smu.ksketch.utilities.IIterator;
	
	/**
	 * Create ghosts of corresponding strokes under rotation and scale interaction. 
	 */		
	public class KGhostMarker
	{
		private var _startTime:Number;
		private var _canvas:KCanvas;
		private var _interactionCenters:Object;
		private var _interactionGhosts:Object;
		
		/**
		 * Constructor to initialize canvas, _centers table and _ghost table. 
		 */		
		public function KGhostMarker(canvas:KCanvas)
		{
			_canvas = canvas;
			_interactionCenters = new Object();
			_interactionGhosts = new Object();
		}
		
		/**
		 * Create the ghost sprite and add to the canvas Content Container.
		 * The center and the created ghost sprite are store in the _centers 
		 * and _ghost tables respectively, using object id as the key.
		 */		
		public function add(object:KObject,center:Point,time:Number):void
		{
			_startTime = time;
			_interactionCenters[object.id] = center;
			_interactionGhosts[object.id] = _createGroupSprite(object,time);
			_canvas.contentContainer.addChild(_interactionGhosts[object.id]);
		}

		/**
		 * Obtain the full path matrix of object at time, and update 
		 * the transform property of the ghost sprite of the object.
		 */		
		public function update(object:KObject,time:Number):void
		{
			if (_interactionCenters[object.id] && _interactionGhosts[object.id])
			{
				var center:Point = _interactionCenters[object.id];
				var invert:Matrix = _invert(object.getFullPathMatrix(_startTime));
				var startCenter:Point = invert.transformPoint(center);
				var tMatrix:Matrix = new Matrix(1,0,0,1,-startCenter.x,-startCenter.y);
				tMatrix.concat(_removeTranslation(object.getFullPathMatrix(time)));
				tMatrix.concat(new Matrix(1,0,0,1,center.x,center.y));
				_interactionGhosts[object.id].transform.matrix = tMatrix;
			}
		}
		
		/**
		 * Remove the object and all the children strokes from _center table, and also 
		 * the corresponding ghost sprite from _ghost table and canvas Content Container. 
		 */		
		public function remove(object:KObject):void
		{
			if (_interactionGhosts[object.id])
			{
				_canvas.contentContainer.removeChild(_interactionGhosts[object.id]);
				_interactionGhosts[object.id] = null;
				_interactionCenters[object.id] = null;				
			}
		}
		
		// Create a sprite with structure determined by object. If object is a stroke, 
		// create a sprite with line geometry determined by the stroke points.
		// If the object is a group, create the top level sprite and add the lower level 
		// sprite constructed using the children of the group to the top level sprite.
		private function _createGroupSprite(object:KObject,time:Number):Sprite
		{
			var stroke:KStroke = object is KStroke ? object as KStroke : null;
			var group:KGroup = object is KGroup ? object as KGroup : null;
			if (stroke)
				return _createStrokeSprite(stroke.thickness,stroke.color,stroke.points);
			else if (group)
			{
				var sprite:Sprite = new Sprite();
				var it:IIterator = group.directChildIterator(time);
				var currentChild:Sprite;
				var currentObject:KObject;
				
				while (it.hasNext())
				{
					currentObject = it.next();
					currentChild = _createGroupSprite(currentObject,time);
					sprite.addChild(currentChild);
					currentChild.transform.matrix = currentObject.getFullMatrix(time);
				}
				return sprite;
			}
			return new Sprite();
		}
		
		// Create a sprite with line thickness, color and points. 
		private function _createStrokeSprite(thickness:Number, color:uint,
											 points:Vector.<Point>):Sprite
		{
			var p0:Point = points.length > 0 ? points[0] : new Point(0,0);
			var sprite:Sprite = new Sprite();
			sprite.graphics.moveTo(p0.x, p0.y);
			sprite.graphics.lineStyle(thickness, color, KObjectView.GHOST_ALPHA);
			for(var i:int=1; i < points.length; i++)
				sprite.graphics.lineTo(points[i].x, points[i].y);
			return sprite;
		}

		// Obtain a clone of the invert of matrix m.
		private function _invert(m:Matrix):Matrix
		{
			var matrix:Matrix = m.clone();
			matrix.invert();
			return matrix;
		}
		
		// Obtain a new matrix from matrix m, without translation components (tx,ty).
		private function _removeTranslation(m:Matrix):Matrix
		{
			return new Matrix(m.a,m.b,m.c,m.d);						
		}		
	}
}