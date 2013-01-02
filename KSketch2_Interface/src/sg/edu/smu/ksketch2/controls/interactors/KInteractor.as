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
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.controls.interactioncontrol.IInteractionControl;
	import sg.edu.smu.ksketch2.utils.KSelection;
	
	public class KInteractor extends EventDispatcher implements IInteractor
	{
		protected var _KSketch:KSketch2;
		protected var _interactionControl:IInteractionControl;

		//Variables for operations
		protected var _oldSelection:KSelection;
		protected var _newSelection:KSelection;
		protected var _interactionStartTime:int;
		protected var _interactionEndTime:int;
		
		public function KInteractor(KSketchInstance:KSketch2, interactionControl:IInteractionControl)
		{
			super(this);
			_KSketch = KSketchInstance;
			_interactionControl = interactionControl;
		}
		
		/**
		 * Prepares this interactor for use
		 * So it has its magical values and will tend to fail less often
		 */
		public function activate():void
		{
			
		}
		
		/**
		 * Sets the values of this interactor to their default magical values
		 */
		public function reset():void
		{
			
		}
		
		/**
		 * Start of interaction
		 */
		public function interaction_Begin(point:Point):void
		{

		}
		
		/**
		 * Updating interaction
		 */
		public function interaction_Update(point:Point):void
		{
			
		}
		
		/**
		 * End interaction
		 */
		public function interaction_End():void
		{
			
		}
	}
}