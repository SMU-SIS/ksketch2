/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.utils
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.core.FlexGlobals;
	import mx.core.IFlexDisplayObject;
	import mx.managers.PopUpManager;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.controls.ImageInput.ImageEditWindow;
	import sg.edu.smu.ksketch2.controls.interactioncontrol.IInteractionControl;
	import sg.edu.smu.ksketch2.controls.interactioncontrol.KInteractionControl;
	import sg.edu.smu.ksketch2.controls.interactionmodes.KDrawingMode;
	import sg.edu.smu.ksketch2.controls.interactors.KDrawInteractor;
	import sg.edu.smu.ksketch2.controls.widgets.KTimeControl;
	import sg.edu.smu.ksketch2.events.KSketchEvent;
	import sg.edu.smu.ksketch2.model.data_structures.KModelObjectList;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;
	import sg.edu.smu.ksketch2.view.KModelDisplay;
	
	public class KButtonCommandExecutor extends EventDispatcher
	{
		private var _KSketch:KSketch2;
		private var _interactionControl:IInteractionControl
		private var _timeControl:KTimeControl;
		public var debugDisplay:KModelDisplay;
		
		public function KButtonCommandExecutor(KSketchInstance:KSketch2, interactionControl:IInteractionControl, timeControl:KTimeControl)
		{
			super(this);
			_KSketch = KSketchInstance;
			_interactionControl = interactionControl;
			_timeControl = timeControl;
		}
		
		public function newFile():void
		{
			_KSketch.reset();
			_interactionControl.reset();
			_interactionControl.dispatchEvent(new Event(KInteractionControl.EVENT_UNDO_REDO));
		}
		
		public function openFile():void
		{
			
		}
		
		public function saveFile():XML
		{
			var saveXML:XML = <KSketch date=""/>;
			var sceneXML:XML = _KSketch.sceneXML;
			
			if(0 < sceneXML.children().length())
			{
				saveXML.appendChild(sceneXML);
				saveXML.appendChild(<log/>);
				saveXML.@date = new Date().toString();
				return saveXML;
			}
			else
				return null;
		}
		
		public function export():void
		{
			debugDisplay.debug();
		}
		
		public function importImage():void
		{	
			var window:IFlexDisplayObject = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, ImageEditWindow, true);
			(window as ImageEditWindow).init(_KSketch);
			PopUpManager.centerPopUp(window);
		}
		
		public function cut():void
		{
			
		}
		
		public function copy():void
		{
			
		}
		
		public function paste():void
		{
			
		}
		
		public function undo():void
		{
			_interactionControl.undo();
		}
		
		public function redo():void
		{
			_interactionControl.redo();
		}
		
		public function group():void
		{
			_interactionControl.begin_interaction_operation();
			var op:KCompositeOperation = new KCompositeOperation();
			var newObjectList:KModelObjectList = _KSketch.hierarchy_Group(_interactionControl.selection.objects, _KSketch.time, false, op);	
			_interactionControl.selection = new KSelection(newObjectList);
			_interactionControl.end_interaction_operation(op, _interactionControl.selection);
		}
		
		public function ungroup():void
		{
			_interactionControl.begin_interaction_operation();
			var op:KCompositeOperation = new KCompositeOperation();
			var ungroupedObjectList:KModelObjectList = _KSketch.hierarchy_Ungroup(_interactionControl.selection.objects, _KSketch.time, op);
			_interactionControl.selection = new KSelection(ungroupedObjectList);
			_interactionControl.end_interaction_operation(op, _interactionControl.selection);
		}
		
		public function setPenColor(colorValue:uint):void
		{
			_interactionControl.enterDrawingMode(KDrawingMode.DRAW_MODE);
			KDrawInteractor.penColor = colorValue;
		}
		
		public function activateEraser():void
		{
			_interactionControl.enterDrawingMode(KDrawingMode.ERASER_MODE);
		}
		
		public function play():void
		{
			_timeControl.startPlaying();
		}
		
		public function pause():void
		{
			_timeControl.pause();
		}
		
		public function rewind():void
		{
			_timeControl.time = 0;	
		}
		
		public function prevFrame():void
		{
			_timeControl.time = _timeControl.time - KSketch2.ANIMATION_INTERVAL;
		}
		
		public function nextFrame():void
		{
			_timeControl.time = _timeControl.time + KSketch2.ANIMATION_INTERVAL;
		}
		
		public function insertKey(object:KObject, time:int):void
		{
			_interactionControl.begin_interaction_operation();
			var op:KCompositeOperation = new KCompositeOperation();
			object.transformInterface.insertBlankKeyFrame(time, op);
			_interactionControl.end_interaction_operation(op, _interactionControl.selection);
			_KSketch.dispatchEvent(new KSketchEvent(KSketchEvent.EVENT_MODEL_UPDATED));
		}
	}
}