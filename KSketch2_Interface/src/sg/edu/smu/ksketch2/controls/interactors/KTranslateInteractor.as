/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.controls.interactors
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.controls.interactioncontrol.IInteractionControl;
	
	public class KTranslateInteractor extends KTransitionInteractor
	{
		private var _startMatrices:Vector.<Matrix>;
		private var _dx:Number;
		private var _dy:Number;
		
		public function KTranslateInteractor(KSketchInstance:KSketch2, interactionControl:IInteractionControl)
		{
			super(KSketchInstance, interactionControl);
		}
		
		override public function interaction_Begin(point:Point):void
		{
			//By right should do grouping here. but w/e.
			_prepareTransition();
			//Will deal with it when the time comes
			_startPoint = point;
			_currentPoint = point;
			
			//Iterate thru the objects and make sure every one of them has been set up
			var i:int = 0;
			var length:int = _toTransitObjects.length();
			_startMatrices = new Vector.<Matrix>();
			for(i; i<length; i++)
			{
				_KSketch.beginTransform(_toTransitObjects.getObjectAt(i), _interactionControl.transitionMode, _interactionControl.currentInteraction);
			}
		}
		
		override public function interaction_Update(point:Point):void
		{
			var i:int = 0;
			var length:int = _toTransitObjects.length();
			
			_dx = point.x - _startPoint.x;
			_dy = point.y - _startPoint.y;

			for(i; i<length; i++)
			{
				var parentMatrix:Matrix = _toTransitObjects.getObjectAt(i).parent.fullPathMatrix(_KSketch.time);
				parentMatrix.tx = 0;
				parentMatrix.ty = 0;
				parentMatrix.invert();
				point = parentMatrix.transformPoint(new Point(_dx, _dy));
				_KSketch.updateTransform(_toTransitObjects.getObjectAt(i), point.x, point.y, 0, 0);
			}
		}
		
		override public function interaction_End():void
		{
			var i:int = 0;
			var length:int = _toTransitObjects.length();
			
			for(i; i<length; i++)
				_KSketch.endTransform(_toTransitObjects.getObjectAt(i), _currentOperation);
			
			_endTransition();
		}
	}
}