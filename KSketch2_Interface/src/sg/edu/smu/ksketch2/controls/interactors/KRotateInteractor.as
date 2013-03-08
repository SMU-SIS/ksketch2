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
	import sg.edu.smu.ksketch2.model.data_structures.KModelObjectList;
	import sg.edu.smu.ksketch2.utils.KMathUtil;
	import sg.edu.smu.ksketch2.utils.KSelection;
	
	public class KRotateInteractor extends KTransitionInteractor
	{
		public static const PIx2:Number = 6.283185307;
		private var _dTheta:Number;
		
		private var _workingCenter:Point;
		
		
		public function KRotateInteractor(KSketchInstance:KSketch2, interactionControl:IInteractionControl)
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
			_dTheta = 0;
			for(i; i<length; i++)
				_KSketch.beginTransform(_toTransitObjects.getObjectAt(i),
					_interactionControl.transitionMode, _interactionControl.currentInteraction);
		}
		
		override public function interaction_Update(point:Point):void
		{
			var i:int = 0;
			var length:int = _toTransitObjects.length();

			var angleChange:Number = KMathUtil.angleOf(_previousPoint.subtract(_workingCenter), point.subtract(_workingCenter));
			
			if(angleChange > Math.PI)
			{
				angleChange = angleChange - PIx2;
			}
						
			_dTheta += angleChange;
	
			for(i; i<length; i++)
				_KSketch.updateTransform(_toTransitObjects.getObjectAt(i), 0, 0, _dTheta, 0);
			
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