/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.controls.interactionmodes
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.controls.interactioncontrol.IInteractionControl;
	import sg.edu.smu.ksketch2.controls.interactioncontrol.KInteractionControl;
	import sg.edu.smu.ksketch2.controls.interactors.KRotateInteractor;
	import sg.edu.smu.ksketch2.controls.interactors.KScaleInteractor;
	import sg.edu.smu.ksketch2.controls.interactors.KTransitionInteractor;
	import sg.edu.smu.ksketch2.controls.interactors.KTranslateInteractor;
	import sg.edu.smu.ksketch2.controls.widgets.IWidget;
	
	public class KManipulationMode extends EventDispatcher implements IInteractionMode
	{
		public var isManipulation:Boolean;
		
		private var _KSketch:KSketch2;
		private var _interactionControl:IInteractionControl;
		private var _manipulationWidget:IWidget;
		
		private var _activeInteractor:KTransitionInteractor;
		private var _translateInteractor:KTranslateInteractor;
		private var _rotateInteractor:KRotateInteractor;
		private var _scaleInteractor:KScaleInteractor;
		
		public function KManipulationMode(ksketchInstance:KSketch2, interactionControl:IInteractionControl, manipulationWidget:IWidget)
		{
			super(this);
			
			isManipulation = false;
			_KSketch = ksketchInstance;
			_interactionControl = interactionControl;
			_manipulationWidget = manipulationWidget;
		}
		
		public function init():void
		{
			_translateInteractor = new KTranslateInteractor(_KSketch, _interactionControl);
			_rotateInteractor = new KRotateInteractor(_KSketch, _interactionControl);
			_scaleInteractor = new KScaleInteractor(_KSketch, _interactionControl);
		}
		
		public function activate():void
		{
			_manipulationWidget.visible = true;
			_refreshManipulationWidget();
		}
		
		public function updateManipulationMode():void
		{
			_refreshManipulationWidget();
		}
		
		public function reset():void
		{
			isManipulation = false;
			_activeInteractor = null;
		}
		
		public function setManipulator(type:String):void
		{
			switch(type)
			{
				case KWidgetEvent.DOWN_TRANSLATE:
				case KWidgetEvent.DOWN_CENTER:
					_activeInteractor = _translateInteractor;
					break;
				case KWidgetEvent.DOWN_ROTATE:
					_activeInteractor = _rotateInteractor;
					break;
				case KWidgetEvent.DOWN_SCALE:
					_activeInteractor = _scaleInteractor;
					break;
				default:
					_activeInteractor = null;
			}
		}
		
		public function beginInteraction(point:Point):void
		{
			if(isManipulation)
			{
				_manipulationWidget.visible = false;
				if(!_activeInteractor)
					throw new Error("Transition manipulator not set!");
				
				_activeInteractor.interaction_Begin(point);
			}
			else
				_deselect();
		}
		
		public function updateInteraction(point:Point):void
		{
			if(isManipulation)
				_activeInteractor.interaction_Update(point);
		}
		
		public function endInteraction():void
		{
			if(isManipulation)
			{
				//Update this  using the objects that are returned by the interactors
				_manipulationWidget.visible = true;
				_activeInteractor.interaction_End();
			}
			
			isManipulation = false;
			
			if(!KInteractionControl.stickyDemonstration)
				_interactionControl.transitionMode = KSketch2.TRANSITION_INTERPOLATED;
		}
		
		private function _refreshManipulationWidget():void
		{
			_manipulationWidget.highlightSelection(_interactionControl.selection, _KSketch.time);
		}
		
		private function _deselect():void
		{
			_interactionControl.selection = null;
		}
	}
}