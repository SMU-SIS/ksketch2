/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package views.canvas.interactors
{
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.controls.interactioncontrol.IInteractionControl;
	import sg.edu.smu.ksketch2.controls.interactors.KInteractor;
	
	public class KTouchSelectInteractor extends KInteractor
	{
		/**
		 * Touch Select Interactor for selection done through the view.
		 * The old select interactor works thru the model.
		 */
		public function KTouchSelectInteractor(KSketchInstance:KSketch2, interactionControl:IInteractionControl)
		{
			super(KSketchInstance, interactionControl);
		}
		
		/**
		 *  
		 */
		public function select():void
		{
			
		}
		
		override public function interaction_Begin(point:Point):void
		{
			
		}
	}
}