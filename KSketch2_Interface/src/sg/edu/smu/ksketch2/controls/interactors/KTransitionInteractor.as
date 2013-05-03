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
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;
	import sg.edu.smu.ksketch2.utils.KSelection;
	
	public class KTransitionInteractor extends KInteractor
	{
		protected var _startPoint:Point;
		protected var _previousPoint:Point;
		protected var _currentPoint:Point;
		protected var _toTransitObjects:KModelObjectList;
		protected var _currentOperation:KCompositeOperation;
		
		public function KTransitionInteractor(KSketchInstance:KSketch2, interactionControl:IInteractionControl)
		{
			super(KSketchInstance, interactionControl);
		}
		
		protected function _prepareTransition():void
		{
			_interactionControl.begin_interaction_operation();
				
			//=========
			//Grouping to be done in this space here before _toTransitObjects are set
			//
			//
			//==============
			
			_toTransitObjects = _interactionControl.selection.objects;
			_currentOperation = new KCompositeOperation();
//			_interactionControl.selection = null;
		}
		
		//Compute transitions here
		protected function _updateTransition(point:Point):void
		{
			
		}
		
		protected function _endTransition():void
		{
			_interactionControl.selection = new KSelection(_toTransitObjects);
			_interactionControl.end_interaction_operation(_currentOperation, _interactionControl.selection);
		}
		
		protected function groupSelection(objects:KModelObjectList):void
		{
			
		}
		
		override public function interaction_Begin(point:Point):void
		{

		}
		
		override public function interaction_Update(point:Point):void
		{

		}
		
		override public function interaction_End():void
		{

		}
	}
}