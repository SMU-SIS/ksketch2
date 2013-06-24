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
	import sg.edu.smu.ksketch2.KSketchStyles;
	import sg.edu.smu.ksketch2.canvas.components.transformWidget.KSketch_Widget_Component;
	import sg.edu.smu.ksketch2.canvas.controls.KInteractionControl;
	import sg.edu.smu.ksketch2.canvas.controls.interactors.transitions.KRotateInteractor;
	import sg.edu.smu.ksketch2.canvas.controls.interactors.transitions.KScaleInteractor;
	import sg.edu.smu.ksketch2.canvas.controls.interactors.transitions.KTranslateInteractor;
	
	public class KBasicTransitionMode extends KWidgetMode
	{
		private var _translateInteractor:KTranslateInteractor;
		private var _rotateInteractor:KRotateInteractor;
		private var _scaleInteractor:KScaleInteractor;
		
		public function KBasicTransitionMode(KSketchInstance:KSketch2, interactionControl:KInteractionControl, widgetBase:KSketch_Widget_Component
											,modelSpace:DisplayObject)
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
				_widget.alpha = KSketchStyles.WIDGET_ENABLED_ALPHA;
			else
				_widget.alpha = KSketchStyles.WIDGET_DISABLED_ALPHA;
		}
		
		override public function set demonstrationMode(value:Boolean):void
		{
			_widget.reset();
			if(!value)
			{
				_widget.strokeColor = KSketchStyles.WIDGET_INTERPOLATE_COLOR;
				_widget.centroid.graphics.beginFill(KSketchStyles.WIDGET_PERFORM_COLOR);
				_widget.centroid.graphics.drawCircle(0,0,KSketchStyles.WIDGET_CENTROID_SIZE);
				_widget.centroid.graphics.endFill();
			}
			else
			{
				_widget.strokeColor = KSketchStyles.WIDGET_PERFORM_COLOR;
				_widget.centroid.graphics.beginFill(KSketchStyles.WIDGET_PERFORM_COLOR);
				_widget.centroid.graphics.drawCircle(0,0,KSketchStyles.WIDGET_CENTROID_SIZE);
				_widget.centroid.graphics.endFill();
			}
		}
	}
}