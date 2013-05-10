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
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;
	import sg.edu.smu.ksketch2.view.objects.IObjectView;
	import sg.edu.smu.ksketch2.view.KModelDisplay;
	import sg.edu.smu.ksketch2.view.objects.KObjectView;
	
	public class KEraserInteractor extends KInteractor
	{
		private var _currentOperation:KCompositeOperation;
		private var _modelDisplay:KModelDisplay;
		private var _startPoint:Point;
		private var _currentPoint:Point;
		
		public function KEraserInteractor(KSketchInstance:KSketch2, interactionControl:IInteractionControl, modelDisplay:KModelDisplay)
		{
			super(KSketchInstance, interactionControl);
			_modelDisplay = modelDisplay;
		}
		
		override public function interaction_Begin(point:Point):void
		{
			_interactionControl.begin_interaction_operation();
			_currentOperation = new KCompositeOperation();
		}
		
		override public function interaction_Update(point:Point):void
		{
			var view:IObjectView;
			point = _modelDisplay.localToGlobal(point);
			for each (view in _modelDisplay.viewsTable)
			{
				if((view as KObjectView).alpha > 0)
					(view as KObjectView).eraseIfHit(point.x, point.y, _KSketch.time, _currentOperation);
			}
		}
		
		override public function interaction_End():void
		{
			if(_currentOperation.length == 0)
				_interactionControl.end_interaction_operation();
			else
				_interactionControl.end_interaction_operation(_currentOperation, null);
		}
	}
}