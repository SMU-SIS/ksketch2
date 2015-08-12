/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.canvas.controls.interactors.widgetstates
{
	import flash.display.DisplayObject;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.KSketchGlobals;
	import sg.edu.smu.ksketch2.canvas.components.transformWidget.KSketch_Widget_Component;
	import sg.edu.smu.ksketch2.canvas.controls.KInteractionControl;
	import sg.edu.smu.ksketch2.canvas.controls.interactors.transitions.KRotateInteractor;
	import sg.edu.smu.ksketch2.canvas.controls.interactors.transitions.KScaleInteractor;
	import sg.edu.smu.ksketch2.canvas.controls.interactors.transitions.KTranslateInteractor;
	
	/**
	 * The KBasicTransitionMode class serves as the concrete class for
	 * basic transition mode in K-Sketch.
	 */
	public class KBasicTransitionMode extends KWidgetMode
	{
		private var WIDGET_CIRCLE_RADIUS:Number = 10 * KSketchGlobals.SCALE;
		
		private var _translateInteractor:KTranslateInteractor;		// the translate interactor
		private var _rotateInteractor:KRotateInteractor;			// the rotate interactor
		private var _scaleInteractor:KScaleInteractor;				// the scale interactor
		
		/**
		 * The main constructor for the KBasicTransitionMode class.
		 * 
		 * @param KSketchInstance The ksketch instance.
		 * @param interactionControl The interaction control.
		 * @param widgetBase The sketch widget base component.
		 * @param modelSpace The model space.
		 */
		public function KBasicTransitionMode(KSketchInstance:KSketch2, interactionControl:KInteractionControl, 
											 widgetBase:KSketch_Widget_Component, modelSpace:DisplayObject)
		{
			super(KSketchInstance, interactionControl, widgetBase);
		
			_translateInteractor = new KTranslateInteractor(KSketchInstance, interactionControl, widgetBase.middleTrigger, modelSpace);
			_rotateInteractor = new KRotateInteractor(KSketchInstance, interactionControl, widgetBase.topTrigger, modelSpace);
			_scaleInteractor = new KScaleInteractor(KSketchInstance, interactionControl, widgetBase.baseTrigger, modelSpace);
			
		}
			
		override public function activate():void
		{
			demonstrationMode = false;
			_translateInteractor.activate();
			_rotateInteractor.activate();
			_scaleInteractor.activate();
			
			super.activate();
		}
		
		override public function deactivate():void
		{
			_translateInteractor.deactivate();
			_rotateInteractor.deactivate();
			_scaleInteractor.deactivate();
			
			super.deactivate();
		}
		
		override public function set enabled(value:Boolean):void
		{
			if(value)
				_widget.alpha = KSketchGlobals.ALPHA_1;
			else
				_widget.alpha = KSketchGlobals.ALPHA_02;
		}
		
		override public function set demonstrationMode(value:Boolean):void
		{
			
			_widget.reset();
			
			if(!value)
			{
				_widget.strokeColor = KSketchGlobals.COLOR_GREY_MEDIUM;
				_widget.centroid.graphics.beginFill(KSketchGlobals.COLOR_RED_DARK);
				_widget.centroid.graphics.drawCircle(0,0,WIDGET_CIRCLE_RADIUS);
				_widget.centroid.graphics.endFill();
			}
			else
			{
				_widget.strokeColor = KSketchGlobals.COLOR_RED_DARK;
				_widget.centroid.graphics.beginFill(KSketchGlobals.COLOR_RED_DARK);
				_widget.centroid.graphics.drawCircle(0,0,WIDGET_CIRCLE_RADIUS);
				_widget.centroid.graphics.endFill();
			}
		}
	}
}