/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.canvas.controls.interactors.draw
{
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.canvas.controls.IInteractionControl;
	import sg.edu.smu.ksketch2.utils.KSelection;
	
	/**
	 * The KInteractor class serves as the pseudo-abstract class for
	 * interactors in K-Sketch.
	 */
	public class KInteractor extends EventDispatcher implements IInteractor
	{
		protected var _KSketch:KSketch2;							// the ksketch instance
		protected var _interactionControl:IInteractionControl;		// the interaction control

		// variables for operations
		protected var _oldSelection:KSelection;						// the old selection
		protected var _newSelection:KSelection;						// the new selection
		protected var _interactionStartTime:int;					// the interaction start time
		protected var _interactionEndTime:int;						// the interaction end time
		
		/**
		 * The main constructor of the KInteractor class.
		 * 
		 * @param KSketchIntance The ksketch object.
		 * @param interactionControl The interaction control.
		 */
		public function KInteractor(KSketchInstance:KSketch2, interactionControl:IInteractionControl)
		{
			// sets the interactor
			super(this);
			
			// sets the ksketch instance
			_KSketch = KSketchInstance;
			
			// sets the interaction control
			_interactionControl = interactionControl;
		}
		
		public function activate():void
		{
			
		}
		
		public function reset():void
		{
			
		}
		
		public function interaction_Begin(point:Point):void
		{

		}
		
		public function interaction_Update(point:Point):void
		{
			
		}
		
		public function interaction_End():void
		{
			
		}
	}
}