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
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.controls.interactioncontrol.IInteractionControl;
	import sg.edu.smu.ksketch2.utils.KMathUtil;
	import sg.edu.smu.ksketch2.utils.KSelection;
	
	public class KScaleInteractor extends KTransitionInteractor
	{
		private var _dSigma:Number;
		private var _workingCenter:Point;
		
		public function KScaleInteractor(KSketchInstance:KSketch2, interactionControl:IInteractionControl)
		{
			super(KSketchInstance, interactionControl);
		}
		
		override public function interaction_Begin(point:Point):void
		{
			//By right should do grouping here. but w/e.
			_workingCenter = _interactionControl.selection.centerAt(_KSketch.time);
			_prepareTransition();
			//Will deal with it when the time comes
			_startPoint = point;
			_previousPoint = point;
			_currentPoint = point;
			
			//Iterate thru the objects and make sure every one of them has been set up
			var i:int = 0;
			var length:int = _toTransitObjects.length();
			_dSigma = 0;
			for(i; i<length; i++)
				_KSketch.beginTransform(_toTransitObjects.getObjectAt(i),
					_interactionControl.transitionMode, _interactionControl.currentInteraction);
		}
		
		override public function interaction_Update(point:Point):void
		{
			var i:int = 0;
			var length:int = _toTransitObjects.length();
			
			_dSigma += (KMathUtil.distanceOf(_workingCenter, point) - KMathUtil.distanceOf(_workingCenter, _previousPoint))*0.01;
			
			for(i; i<length; i++)
				_KSketch.updateTransform(_toTransitObjects.getObjectAt(i), 0, 0, 0, _dSigma);

			_previousPoint = point;
		}
		
		override public function interaction_End():void
		{
			var i:int = 0;
			var length:int = _toTransitObjects.length();
			
			for(i; i<length; i++)
				_KSketch.endTransform(_toTransitObjects.getObjectAt(i),_currentOperation);
			
			_endTransition();
		}
	}
}